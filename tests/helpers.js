// @ts-check
const path = require('path');

/** Tel Aviv default map anchor used by MapScreen and seed data. */
const TARGET_LAT = 32.0853;
const TARGET_LON = 34.7818;

/** Demo duplicate-tree warning radius (kNearbyDuplicateWarnMeters). */
const NEARBY_WARN_METERS = 50;

const MOCK_TREE_PHOTO = path.join(__dirname, 'fixtures', 'mock_tree.jpg');
const MOCK_TREE_PHOTO_PNG = path.join(__dirname, 'fixtures', 'mock_tree.png');

/**
 * Offset a WGS84 point by meters north (flat-earth; accurate enough for E2E).
 * @param {number} lat
 * @param {number} lon
 * @param {number} metersNorth
 * @returns {{ latitude: number; longitude: number }}
 */
function offsetNorthMeters(lat, lon, metersNorth) {
  const dLat = metersNorth / 111_320;
  return { latitude: lat + dLat, longitude: lon };
}

/**
 * @param {import('@playwright/test').Page} page
 * @param {{ latitude: number; longitude: number }} coords
 */
async function grantGeolocation(page, coords) {
  await page.context().grantPermissions(['geolocation']);
  await page.context().setGeolocation(coords);
}

/**
 * Wait until Flutter web semantics expose auth or shell UI.
 * @param {import('@playwright/test').Page} page
 */
async function waitForAppReady(page) {
  const authOrShell = page
    .getByText('Welcome back')
    .or(page.getByText('Urban tree mapping'))
    .or(page.getByRole('button', { name: 'Home' }))
    .or(page.getByRole('button', { name: 'Map' }));
  await authOrShell.first().waitFor({ timeout: 90_000 });
}

/**
 * Click visible Flutter semantics text with fallbacks for canvas rendering.
 * @param {import('@playwright/test').Page} page
 * @param {string|RegExp} label
 */
async function clickByLabel(page, label) {
  const button = page.getByRole('button', { name: label, exact: true });
  if (await button.count()) {
    await button.first().click({ force: true });
    return;
  }
  const link = page.getByRole('link', { name: label });
  if (await link.count()) {
    await link.first().click();
    return;
  }
  const text = typeof label === 'string' ? page.getByText(label, { exact: true }) : page.getByText(label);
  await text.first().click({ timeout: 15_000 });
}

/**
 * @param {import('@playwright/test').Page} page
 * @param {string} label
 * @param {string} value
 */
async function fillByLabel(page, label, value) {
  const field = page.getByRole('textbox', { name: label });
  await field.first().waitFor({ timeout: 15_000 });
  await field.first().click();
  await page.keyboard.press('ControlOrMeta+A');
  await page.keyboard.press('Backspace');
  await page.keyboard.type(value, { delay: 20 });
}

/**
 * Email auth via AuthScreen. Signs up when [creds.allowSignup] is true.
 * @param {import('@playwright/test').Page} page
 * @param {{ email: string; password: string; allowSignup?: boolean }} creds
 */
async function loginWithEmail(page, creds) {
  const baseURL = (process.env.BASE_URL || 'http://localhost:8080').replace(/\/$/, '');
  if (!page.url().startsWith(baseURL)) {
    await page.goto(`${baseURL}/`, { waitUntil: 'domcontentloaded', timeout: 60_000 });
  }
  await waitForAppReady(page);

  const shellMarker = page
    .getByText('Urban tree mapping')
    .or(page.getByRole('button', { name: 'Home' }));
  if (await shellMarker.count()) {
    return;
  }

  if (creds.allowSignup && (await page.getByText('No account yet? Sign up').count())) {
    await page.getByText('No account yet? Sign up').click();
    await fillByLabel(page, 'Username', 'E2E Tester');
    await fillByLabel(page, 'Email', creds.email);
    await fillByLabel(page, 'Password', creds.password);
    await page.getByRole('button', { name: 'Sign up' }).click();
    await page.waitForTimeout(3000);
  }

  if (await page.getByText('Welcome back').count()) {
    await fillByLabel(page, 'Email', creds.email);
    await fillByLabel(page, 'Password', creds.password);
    await page.getByRole('button', { name: 'Sign in' }).click();
    await page.waitForTimeout(3000);
  }

  await shellMarker.first().waitFor({ timeout: 90_000 });
}

/**
 * Opens the 3-step report wizard from Identify → gallery entry (works in AppShell web).
 * @param {import('@playwright/test').Page} page
 */
async function openReportWizard(page) {
  await page.getByRole('button', { name: 'Map', exact: true }).click();
  await page.getByRole('button', { name: 'Report tree' }).click();
  await page.getByText('Tree report').waitFor({ timeout: 90_000 });
}

/**
 * @param {import('@playwright/test').Page} page
 */
async function uploadGalleryPhoto(page) {
  const [chooser] = await Promise.all([
    page.waitForEvent('filechooser', { timeout: 20_000 }),
    page.getByRole('button', { name: 'Gallery' }).click(),
  ]);
  await chooser.setFiles(MOCK_TREE_PHOTO);
  await page.waitForTimeout(1500);
}

/**
 * @param {import('@playwright/test').Page} page
 */
async function wizardNext(page) {
  await clickByLabel(page, 'Next');
}

/**
 * @param {import('@playwright/test').Page} page
 */
async function wizardSubmit(page) {
  await clickByLabel(page, 'Submit report');
}

module.exports = {
  TARGET_LAT,
  TARGET_LON,
  NEARBY_WARN_METERS,
  MOCK_TREE_PHOTO,
  offsetNorthMeters,
  grantGeolocation,
  waitForAppReady,
  clickByLabel,
  fillByLabel,
  loginWithEmail,
  openReportWizard,
  uploadGalleryPhoto,
  wizardNext,
  wizardSubmit,
};
