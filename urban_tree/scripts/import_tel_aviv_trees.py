#!/usr/bin/env python3
"""
Import Tel Aviv municipal urban tree inventory CSV into Supabase `tree_reports`.

Prereqs:
  - Apply migration `20260415120000_tree_import_provenance_geom.sql` (PostGIS geom + flags).
  - If `20260412120000_production_hardening_notes.sql` is applied, each row must include at least
    one whole-tree and one leaves image URL (this script uses inert placeholder URLs).
  - Use SUPABASE_SERVICE_ROLE_KEY so RLS does not block server-side seeding.

Env (from `urban_tree/.env` by default):
  SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, OPENAI_API_KEY
  TEL_AVIV_TREES_CSV_URL — direct HTTPS link to the latest CSV (from the open-data portal).
  Optional: TEL_AVIV_CKAN_API_URL, TEL_AVIV_CKAN_PACKAGE (see --discover-csv).
"""

from __future__ import annotations

import argparse
import csv
import io
import json
import math
import os
import re
import sys
import time
import uuid
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable, Iterator, Optional

import httpx
from dotenv import load_dotenv
from openai import OpenAI
from supabase import Client, create_client

# Stable namespace so the same municipal tree id always maps to the same report UUID.
_IMPORT_UUID_NAMESPACE = uuid.UUID("018f1234-5678-7abc-8def-0123456789ab")
_IMPORT_SOURCE = "tel_aviv_open_data"

# Satisfies cardinality checks when production photo constraints are enabled.
_PLACEHOLDER_WHOLE = "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png"
_PLACEHOLDER_LEAVES = "https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png"


@dataclass(frozen=True)
class LandZone:
    land_type: str
    label: Optional[str]
    min_lat: float
    max_lat: float
    min_lon: float
    max_lon: float
    layer_priority: int

    @property
    def area_deg2(self) -> float:
        return abs(self.max_lat - self.min_lat) * abs(self.max_lon - self.min_lon)

    def contains(self, lat: float, lon: float) -> bool:
        return (
            self.min_lat <= lat <= self.max_lat
            and self.min_lon <= lon <= self.max_lon
        )


def _project_root() -> Path:
    return Path(__file__).resolve().parent.parent


def _norm_header(h: str) -> str:
    return re.sub(r"\s+", "_", h.strip().lstrip("\ufeff")).lower()


def _cell(row: dict[str, str], *candidates: str) -> Optional[str]:
    """First non-empty value matching any header candidate (normalized compare)."""
    rev: dict[str, str] = {}
    for k, v in row.items():
        rev[_norm_header(k)] = v
    for c in candidates:
        key = _norm_header(c)
        if key in rev:
            t = (rev[key] or "").strip()
            if t:
                return t
    return None


def _parse_float(s: Optional[str]) -> Optional[float]:
    if s is None:
        return None
    t = s.strip().replace(",", ".")
    if not t:
        return None
    try:
        return float(t)
    except ValueError:
        return None


def _maybe_wgs84_to_lat_lon(
    x: Optional[float], y: Optional[float]
) -> tuple[Optional[float], Optional[float]]:
    """If values look like Israel TM (EPSG:2039), convert to WGS84; else treat as lon/lat or lat/lon."""
    if x is None or y is None:
        return None, None
    # Rough WGS84 bounds for Tel Aviv metro
    if 34.0 <= x <= 35.0 and 31.9 <= y <= 32.2:
        return y, x
    if 34.0 <= y <= 35.0 and 31.9 <= x <= 32.2:
        return x, y
    # Typical ITM easting/northing magnitudes
    if 150_000 <= x <= 300_000 and 600_000 <= y <= 700_000:
        from pyproj import Transformer

        trans = Transformer.from_crs("EPSG:2039", "EPSG:4326", always_xy=True)
        lon, lat = trans.transform(x, y)
        return lat, lon
    return None, None


def _extract_coords(row: dict[str, str]) -> tuple[Optional[float], Optional[float]]:
    lat = _parse_float(
        _cell(row, "latitude", "lat", "y_wgs84", "y", "שפת_גובה", "קו_רוחב")
    )
    lon = _parse_float(
        _cell(row, "longitude", "long", "lon", "x_wgs84", "x", "קו_אורך")
    )
    if lat is not None and lon is not None and -90 <= lat <= 90 and -180 <= lon <= 180:
        return lat, lon

    east = _parse_float(_cell(row, "easting", "east", "itm_x", "x_itm"))
    north = _parse_float(_cell(row, "northing", "north", "itm_y", "y_itm"))
    lat2, lon2 = _maybe_wgs84_to_lat_lon(east, north)
    if lat2 is not None and lon2 is not None:
        return lat2, lon2

    gx = _parse_float(_cell(row, "cen_global_x", "global_x", "coord_x"))
    gy = _parse_float(_cell(row, "cen_global_y", "global_y", "coord_y"))
    lat3, lon3 = _maybe_wgs84_to_lat_lon(gx, gy)
    return lat3, lon3


def _external_id(row: dict[str, str]) -> Optional[str]:
    raw = _cell(
        row,
        "objectid",
        "tree_id",
        "treeid",
        "מזהה",
        "מספר_עץ",
        "סמל_עץ",
        "fid",
        "globalid",
        "id",
    )
    if raw:
        return raw
    return None


def _species_names(row: dict[str, str]) -> tuple[Optional[str], Optional[str]]:
    he = _cell(
        row,
        "species_hebrew",
        "שם_עברי",
        "שם_עץ_עברי",
        "common_name_he",
        "hebrew_name",
        "שם",
    )
    sci = _cell(
        row,
        "species_scientific",
        "שם_מדעי",
        "שם_מין",
        "latin_name",
        "scientific",
        "species_latin",
        "מין",
    )
    return (he, sci)


def classify_land_type(lat: float, lon: float, zones: list[LandZone]) -> str:
    """Same rule as `LandUseService.classify` in lib/services/land_use_service.dart."""
    matches = [z for z in zones if z.contains(lat, lon)]
    if not matches:
        return "public"
    matches.sort(key=lambda z: (-z.layer_priority, z.area_deg2))
    return matches[0].land_type


def fetch_land_zones(sb: Client) -> list[LandZone]:
    res = (
        sb.table("land_zones")
        .select("land_type,label,min_lat,max_lat,min_lon,max_lon,layer_priority")
        .execute()
    )
    out: list[LandZone] = []
    for r in res.data or []:
        try:
            out.append(
                LandZone(
                    land_type=str(r["land_type"]),
                    label=r.get("label"),
                    min_lat=float(r["min_lat"]),
                    max_lat=float(r["max_lat"]),
                    min_lon=float(r["min_lon"]),
                    max_lon=float(r["max_lon"]),
                    layer_priority=int(r.get("layer_priority") or 0),
                )
            )
        except (KeyError, TypeError, ValueError):
            continue
    return out


def discover_csv_url(
    client: httpx.Client, ckan_api: str, package_id: str
) -> str:
    url = f"{ckan_api.rstrip('/')}/api/3/action/package_show?id={package_id}"
    r = client.get(url, timeout=60.0)
    r.raise_for_status()
    body = r.json()
    if not body.get("success"):
        raise RuntimeError(f"CKAN package_show failed: {body}")
    resources = body["result"].get("resources") or []
    csv_urls: list[tuple[int, str]] = []
    for res in resources:
        fmt = (res.get("format") or "").upper()
        name = (res.get("name") or "").lower()
        if fmt == "CSV" or name.endswith(".csv") or "csv" in fmt:
            u = res.get("url")
            if u:
                csv_urls.append((int(res.get("position") or 0), u))
    if not csv_urls:
        raise RuntimeError("No CSV resource found in CKAN package metadata.")
    csv_urls.sort(key=lambda x: x[0])
    return csv_urls[0][1]


def download_csv(client: httpx.Client, csv_url: str) -> str:
    r = client.get(csv_url, timeout=120.0)
    r.raise_for_status()
    r.encoding = r.encoding or "utf-8"
    return r.text


def iter_csv_rows(text: str) -> Iterator[dict[str, str]]:
    f = io.StringIO(text)
    sample = f.read(4096)
    f.seek(0)
    try:
        dialect = csv.Sniffer().sniff(sample)
    except csv.Error:
        dialect = csv.excel
    reader = csv.DictReader(f, dialect=dialect)
    for row in reader:
        out: dict[str, str] = {}
        for k, v in row.items():
            if k is None:
                continue
            out[k] = (v or "").strip()
        yield out


def species_insight(
    openai: OpenAI,
    *,
    species_scientific: Optional[str],
    species_common: Optional[str],
    model: str,
) -> str:
    if not (species_scientific or species_common):
        return ""
    ctx = {
        "species": species_common,
        "species_scientific": species_scientific,
    }
    resp = openai.chat.completions.create(
        model=model,
        response_format={"type": "json_object"},
        messages=[
            {
                "role": "system",
                "content": (
                    "You assist urban tree citizen science. Output ONLY valid JSON with key "
                    "'insight_text': 2–4 sentences for residents about this species in a "
                    "Mediterranean coastal city (Tel Aviv climate): typical size, drought "
                    "tolerance, common urban pests or diseases, and one practical care tip. "
                    "Use Hebrew if the common name is clearly Hebrew; otherwise English. "
                    "No medical claims."
                ),
            },
            {"role": "user", "content": json.dumps(ctx, ensure_ascii=False)},
        ],
    )
    content = resp.choices[0].message.content or "{}"
    try:
        obj = json.loads(content)
    except json.JSONDecodeError:
        return ""
    t = obj.get("insight_text")
    return t.strip() if isinstance(t, str) else ""


def build_report_row(
    *,
    ext_id: str,
    lat: float,
    lon: float,
    species: Optional[str],
    species_scientific: Optional[str],
    land_type: str,
    land_type_auto: bool,
    insight: str,
) -> dict[str, Any]:
    report_uuid = str(uuid.uuid5(_IMPORT_UUID_NAMESPACE, f"{_IMPORT_SOURCE}:{ext_id}"))
    audit: dict[str, Any] = {
        "import": {
            "source": _IMPORT_SOURCE,
            "external_id": ext_id,
            "needs_physiological_update": True,
        }
    }
    row: dict[str, Any] = {
        "id": report_uuid,
        "user_id": None,
        "latitude": lat,
        "longitude": lon,
        "accuracy_meters": None,
        "land_type": land_type,
        "land_type_auto": land_type_auto,
        "health_score": 3,
        "canopy_density": "moderate",
        "structural_issues": [],
        "whole_tree_image_urls": [_PLACEHOLDER_WHOLE],
        "flower_image_urls": [],
        "phenological_stage": None,
        "flower_abundance": None,
        "leaves_image_urls": [_PLACEHOLDER_LEAVES],
        "leaf_condition": "healthy",
        "damage_extent": "minimal",
        "needs_physiological_update": True,
        "import_source": _IMPORT_SOURCE,
        "external_id": ext_id,
        "ai_suggestion_json": audit,
    }
    if species:
        row["species"] = species
    if species_scientific:
        row["species_scientific"] = species_scientific
    if insight:
        row["insights_text"] = insight
    return row


def chunked(xs: list[dict[str, Any]], n: int) -> Iterable[list[dict[str, Any]]]:
    for i in range(0, len(xs), n):
        yield xs[i : i + n]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--env-file",
        type=Path,
        default=_project_root() / ".env",
        help="Dotenv path (default: urban_tree/.env)",
    )
    parser.add_argument(
        "--csv-url",
        default=os.environ.get("TEL_AVIV_TREES_CSV_URL", ""),
        help="Direct CSV download URL (or set TEL_AVIV_TREES_CSV_URL)",
    )
    parser.add_argument(
        "--discover-csv",
        action="store_true",
        help="Resolve CSV via CKAN package_show (TEL_AVIV_CKAN_API_URL + TEL_AVIV_CKAN_PACKAGE)",
    )
    parser.add_argument(
        "--land-use",
        choices=("public", "zones"),
        default="public",
        help="'public' = municipal inventory on public ROW (default). 'zones' = LandUseService-style bbox match with fallback public.",
    )
    parser.add_argument("--limit", type=int, default=0, help="Max rows (0 = all)")
    parser.add_argument("--batch-size", type=int, default=200)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--skip-openai", action="store_true")
    parser.add_argument(
        "--openai-model", default="gpt-4o-mini", help="Model for species insights"
    )
    parser.add_argument(
        "--openai-delay-ms",
        type=int,
        default=50,
        help="Sleep between OpenAI calls to reduce rate-limit pressure",
    )
    args = parser.parse_args()

    load_dotenv(args.env_file)
    supabase_url = os.environ.get("SUPABASE_URL", "").strip()
    service_key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "").strip()
    openai_key = os.environ.get("OPENAI_API_KEY", "").strip()

    if not supabase_url or not service_key:
        print(
            "Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in environment.",
            file=sys.stderr,
        )
        return 1

    csv_url = args.csv_url.strip()
    if args.discover_csv:
        ckan = os.environ.get(
            "TEL_AVIV_CKAN_API_URL",
            "https://data.tel-aviv.gov.il",
        ).rstrip("/")
        pkg = os.environ.get("TEL_AVIV_CKAN_PACKAGE", "trees")
        with httpx.Client(follow_redirects=True, headers={"User-Agent": "UrbanTreeImport/1.0"}) as h:
            csv_url = discover_csv_url(h, ckan, pkg)
            print(f"Discovered CSV: {csv_url}")
    elif not csv_url:
        print(
            "Provide --csv-url or TEL_AVIV_TREES_CSV_URL, or pass --discover-csv.",
            file=sys.stderr,
        )
        return 1

    zones: list[LandZone] = []
    if args.land_use == "zones":
        sb_preview = create_client(supabase_url, service_key)
        zones = fetch_land_zones(sb_preview)
        print(f"Loaded {len(zones)} land_zones rows for classification.")

    openai_client: Optional[OpenAI] = None
    if not args.skip_openai:
        if not openai_key:
            print(
                "OPENAI_API_KEY missing; use --skip-openai or set the key.",
                file=sys.stderr,
            )
            return 1
        openai_client = OpenAI(api_key=openai_key)

    insight_cache: dict[str, str] = {}

    rows_out: list[dict[str, Any]] = []
    skipped = 0

    with httpx.Client(follow_redirects=True, headers={"User-Agent": "UrbanTreeImport/1.0"}) as http:
        text = download_csv(http, csv_url)

    for row in iter_csv_rows(text):
        ext_id = _external_id(row)
        lat, lon = _extract_coords(row)
        if (
            not ext_id
            or lat is None
            or lon is None
            or not math.isfinite(lat)
            or not math.isfinite(lon)
        ):
            skipped += 1
            continue

        species_he, species_sci = _species_names(row)
        if args.land_use == "zones":
            lt = classify_land_type(lat, lon, zones)
            lt_auto = True
        else:
            lt = "public"
            lt_auto = True

        cache_key = (species_sci or species_he or "").strip().lower()
        insight = ""
        if openai_client and cache_key:
            if cache_key in insight_cache:
                insight = insight_cache[cache_key]
            else:
                insight = species_insight(
                    openai_client,
                    species_scientific=species_sci,
                    species_common=species_he,
                    model=args.openai_model,
                )
                insight_cache[cache_key] = insight
                time.sleep(max(0, args.openai_delay_ms) / 1000.0)

        rows_out.append(
            build_report_row(
                ext_id=ext_id,
                lat=lat,
                lon=lon,
                species=species_he,
                species_scientific=species_sci,
                land_type=lt,
                land_type_auto=lt_auto,
                insight=insight,
            )
        )

        if args.limit and len(rows_out) >= args.limit:
            break

    print(
        f"Prepared {len(rows_out)} rows ({skipped} skipped: missing id or coordinates)."
    )

    if args.dry_run:
        if rows_out:
            print(json.dumps(rows_out[0], indent=2, ensure_ascii=False, default=str))
        return 0

    sb: Client = create_client(supabase_url, service_key)
    total = 0
    for batch in chunked(rows_out, max(1, args.batch_size)):
        sb.table("tree_reports").upsert(batch, on_conflict="id").execute()
        total += len(batch)
        print(f"Upserted {total} / {len(rows_out)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
