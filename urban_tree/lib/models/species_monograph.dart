import 'dart:convert';

import 'package:flutter/services.dart';

class SpeciesMonograph {
  SpeciesMonograph({
    required this.id,
    required this.hebrewName,
    required this.englishName,
    required this.scientificName,
    required this.family,
    required this.familyHebrew,
    required this.familyEnglish,
    required this.tags,
    required this.summary,
    required this.heroImageUrl,
    required this.thumbnailUrl,
    required this.category,
    required this.stats,
    required this.morphology,
    required this.distribution,
    required this.uses,
    required this.funFacts,
    required this.anatomyCards,
  });

  final String id;
  final String hebrewName;
  final String englishName;
  final String scientificName;
  final String family;
  final String familyHebrew;
  final String familyEnglish;
  final List<String> tags;
  final String summary;
  final String heroImageUrl;
  final String thumbnailUrl;
  final String category;
  final SpeciesStats stats;
  final SpeciesMorphology morphology;
  final SpeciesDistribution distribution;
  final List<SpeciesUse> uses;
  final List<String> funFacts;
  final List<AnatomyCard> anatomyCards;

  String displayNameFor(String languageCode) {
    if (languageCode == 'he') return hebrewName;
    if (englishName.isNotEmpty) return englishName;
    return scientificName;
  }

  String familyLabelFor(String languageCode) {
    if (languageCode == 'he') return familyHebrew;
    if (familyEnglish.isNotEmpty) return familyEnglish;
    return family;
  }

  factory SpeciesMonograph.fromJson(Map<String, dynamic> json) {
    return SpeciesMonograph(
      id: json['id'] as String,
      hebrewName: json['hebrewName'] as String,
      englishName: json['englishName'] as String? ?? '',
      scientificName: json['scientificName'] as String,
      family: json['family'] as String,
      familyHebrew: json['familyHebrew'] as String,
      familyEnglish: json['familyEnglish'] as String? ?? '',
      tags: (json['tags'] as List).cast<String>(),
      summary: json['summary'] as String,
      heroImageUrl: json['heroImageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      category: json['category'] as String,
      stats: SpeciesStats.fromJson(json['stats'] as Map<String, dynamic>),
      morphology:
          SpeciesMorphology.fromJson(json['morphology'] as Map<String, dynamic>),
      distribution: SpeciesDistribution.fromJson(
        json['distribution'] as Map<String, dynamic>,
      ),
      uses: (json['uses'] as List)
          .map((e) => SpeciesUse.fromJson(e as Map<String, dynamic>))
          .toList(),
      funFacts: (json['funFacts'] as List).cast<String>(),
      anatomyCards: (json['anatomyCards'] as List)
          .map((e) => AnatomyCard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SpeciesStats {
  SpeciesStats({
    required this.maxHeight,
    required this.lifespan,
    required this.photosynthesis,
    required this.avgHeight,
    required this.water,
    required this.flowering,
    required this.soil,
  });

  final String maxHeight;
  final String lifespan;
  final String photosynthesis;
  final String avgHeight;
  final String water;
  final String flowering;
  final String soil;

  factory SpeciesStats.fromJson(Map<String, dynamic> json) {
    return SpeciesStats(
      maxHeight: json['maxHeight'] as String,
      lifespan: json['lifespan'] as String,
      photosynthesis: json['photosynthesis'] as String,
      avgHeight: json['avgHeight'] as String,
      water: json['water'] as String,
      flowering: json['flowering'] as String,
      soil: json['soil'] as String,
    );
  }
}

class MorphologySection {
  MorphologySection({required this.title, required this.body, this.imageUrl});

  final String title;
  final String body;
  final String? imageUrl;

  factory MorphologySection.fromJson(Map<String, dynamic> json) {
    return MorphologySection(
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

class SpeciesMorphology {
  SpeciesMorphology({
    required this.leaves,
    required this.fruit,
    required this.bark,
  });

  final MorphologySection leaves;
  final MorphologySection fruit;
  final MorphologySection bark;

  factory SpeciesMorphology.fromJson(Map<String, dynamic> json) {
    return SpeciesMorphology(
      leaves: MorphologySection.fromJson(json['leaves'] as Map<String, dynamic>),
      fruit: MorphologySection.fromJson(json['fruit'] as Map<String, dynamic>),
      bark: MorphologySection.fromJson(json['bark'] as Map<String, dynamic>),
    );
  }
}

class SpeciesDistribution {
  SpeciesDistribution({
    required this.description,
    required this.regions,
    required this.mapImageUrl,
  });

  final String description;
  final List<String> regions;
  final String mapImageUrl;

  factory SpeciesDistribution.fromJson(Map<String, dynamic> json) {
    return SpeciesDistribution(
      description: json['description'] as String,
      regions: (json['regions'] as List).cast<String>(),
      mapImageUrl: json['mapImageUrl'] as String,
    );
  }
}

class SpeciesUse {
  SpeciesUse({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final String icon;

  factory SpeciesUse.fromJson(Map<String, dynamic> json) {
    return SpeciesUse(
      title: json['title'] as String,
      body: json['body'] as String,
      icon: json['icon'] as String,
    );
  }
}

class AnatomyCard {
  AnatomyCard({required this.title, required this.body, required this.imageUrl});

  final String title;
  final String body;
  final String imageUrl;

  factory AnatomyCard.fromJson(Map<String, dynamic> json) {
    return AnatomyCard(
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}

class SpeciesMonographRepository {
  SpeciesMonographRepository._();
  static final instance = SpeciesMonographRepository._();

  List<SpeciesMonograph>? _cache;

  Future<List<SpeciesMonograph>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/species_monographs.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (decoded['species'] as List)
        .map((e) => SpeciesMonograph.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<SpeciesMonograph?> byId(String id) async {
    final all = await loadAll();
    for (final s in all) {
      if (s.id == id) return s;
    }
    return all.isEmpty ? null : all.first;
  }

  Future<SpeciesMonograph?> byScientificName(String? name) async {
    if (name == null || name.trim().isEmpty) return null;
    final all = await loadAll();
    final lower = name.trim().toLowerCase();
    for (final s in all) {
      if (s.scientificName.toLowerCase() == lower) return s;
    }
    return null;
  }

  /// Resolves a monograph entry from report species fields (scientific or common).
  Future<SpeciesMonograph?> resolveForReport({
    String? scientific,
    String? common,
  }) async {
    final all = await loadAll();
    if (all.isEmpty) return null;

    final sci = scientific?.trim().toLowerCase();
    if (sci != null && sci.isNotEmpty) {
      for (final s in all) {
        if (s.scientificName.toLowerCase() == sci) return s;
      }
    }

    final com = common?.trim().toLowerCase();
    if (com != null && com.isNotEmpty) {
      for (final s in all) {
        if (s.scientificName.toLowerCase() == com ||
            s.hebrewName.toLowerCase() == com) {
          return s;
        }
      }
    }

    return null;
  }
}
