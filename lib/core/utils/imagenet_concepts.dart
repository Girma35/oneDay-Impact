import 'package:flutter/foundation.dart';

/// Bridges ImageNet classification labels (from ViT) to the broader concepts
/// used in challenge verification keywords.
///
/// ViT returns specific labels like "old woman", "broom", "watering can",
/// "bucket, pail" — but our challenges use keywords like "elderly", "cleanup",
/// "garden", "litter". This utility maps between the two vocabularies.
/// Maps ImageNet-derived words to related verification keyword concepts.
///
/// Each key is a word that might appear in an ImageNet label (after splitting
/// compound labels like "bucket, pail" into individual words). The value is a
/// set of broader concepts that the word relates to.
///
/// For example, the ImageNet label "old woman" splits into ["old", "woman"],
/// and "old" maps to concepts {"elderly", "senior"} which match verification
/// keywords like ["elderly", "senior", "conversation", "visiting", "talking"].
const _imagenetToConcepts = <String, Set<String>>{
  // ── People / Elders ──────────────────────────────────────────────────
  'old': {'elderly', 'senior'},
  'elderly': {'elderly', 'senior'},
  'senior': {'elderly', 'senior'},
  'woman': {'elderly', 'senior', 'talking', 'conversation'},
  'man': {'talking', 'conversation'},
  'person': {'talking', 'conversation', 'visiting'},
  'people': {'talking', 'conversation', 'visiting'},
  'grandma': {'elderly', 'senior'},
  'grandpa': {'elderly', 'senior'},

  // ── Environment / Trees / Nature ────────────────────────────────────
  'tree': {'tree', 'planting', 'environment', 'forest'},
  'plant': {'planting', 'garden', 'sapling'},
  'planting': {'planting', 'garden', 'sapling'},
  'sapling': {'tree', 'planting', 'sapling'},
  'seedling': {'tree', 'planting', 'sapling'},
  'forest': {'tree', 'environment', 'forest'},
  'park': {'tree', 'environment', 'park', 'garden'},
  'garden': {'garden', 'planting', 'watering'},
  'soil': {'soil', 'digging', 'planting'},
  'dirt': {'soil', 'digging'},
  'earth': {'soil', 'digging', 'planting'},
  'dig': {'digging', 'soil'},
  'shovel': {'digging', 'soil', 'planting'},
  'pot': {'planting', 'garden', 'sapling'},
  'flowerpot': {'planting', 'garden', 'sapling'},
  'flower': {'planting', 'garden', 'environment'},
  'leaf': {'tree', 'planting', 'environment'},
  'leaves': {'tree', 'planting', 'environment'},
  'trunk': {'tree', 'environment'},
  'bark': {'tree', 'environment'},
  'branch': {'tree', 'environment'},

  // ── Cleanliness / Litter / Brooms ────────────────────────────────────
  'broom': {'cleanup', 'sweeping', 'clean', 'tidy'},
  'sweep': {'sweeping', 'cleanup', 'clean'},
  'mop': {'cleanup', 'clean', 'tidy'},
  'dust': {'cleanup', 'sweeping', 'clean'},
  'trash': {'trash', 'litter', 'garbage'},
  'litter': {'litter', 'trash', 'garbage', 'cleanup'},
  'garbage': {'garbage', 'trash', 'litter'},
  'bin': {'garbage', 'trash', 'litter', 'cleanup'},
  'can': {'garbage', 'trash', 'cleanup', 'litter'},
  'pail': {'garbage', 'trash', 'litter', 'cleanup'},
  'bucket': {'garbage', 'trash', 'litter', 'cleanup'},
  'bag': {'bag', 'litter', 'trash', 'garbage'},
  'plastic': {'bag', 'trash', 'litter'},
  'rubbish': {'trash', 'litter', 'garbage', 'cleanup'},
  'clean': {'clean', 'cleanup', 'tidy'},
  'sponge': {'clean', 'cleanup', 'tidy'},

  // ── Farming / Agriculture ────────────────────────────────────────────
  'farm': {'farm', 'farming', 'field'},
  'field': {'farm', 'farming', 'field'},
  'barn': {'farm', 'farming'},
  'tractor': {'farm', 'farming', 'field'},
  'harvest': {'harvest', 'farm', 'farming'},
  'crop': {'farm', 'farming', 'harvest'},
  'vegetable': {'vegetables', 'seeds', 'planting', 'garden'},
  'vegetables': {'vegetables', 'seeds', 'planting', 'garden'},
  'fruit': {'farm', 'farming', 'harvest', 'garden'},
  'corn': {'farm', 'farming', 'harvest'},
  'wheat': {'farm', 'farming', 'harvest'},
  'grain': {'farm', 'farming', 'harvest'},
  'hay': {'farm', 'farming'},

  // ── Water / Conservation ────────────────────────────────────────────
  'water': {'water', 'watering'},
  'watering': {'watering', 'garden', 'plants', 'hose'},
  'hose': {'watering', 'hose', 'water'},
  'faucet': {'faucet', 'tap', 'water'},
  'tap': {'faucet', 'tap', 'water'},
  'shower': {'shower', 'water'},
  'rain': {'rainwater', 'water', 'collection'},
  'rainwater': {'rainwater', 'water', 'collection'},
  'pipe': {'pipe', 'water', 'fix', 'leak'},
  'leak': {'leak', 'pipe', 'water', 'fix'},
  'wrench': {'wrench', 'fix', 'pipe', 'water'},
  'container': {'container', 'collection', 'rainwater', 'bucket'},
  'jug': {'water', 'container', 'collection'},
  'lake': {'water', 'environment'},
  'river': {'water', 'environment'},
  'pond': {'water', 'environment'},
  'fountain': {'water', 'environment'},

  // ── Education / Reading / School ────────────────────────────────────
  'book': {'book', 'reading', 'story'},
  'books': {'book', 'reading', 'story'},
  'reading': {'reading', 'book', 'story'},
  'library': {'book', 'reading', 'studying', 'student'},
  'school': {'student', 'studying', 'homework', 'education'},
  'notebook': {'notebook', 'supplies', 'studying'},
  'pen': {'pen', 'supplies', 'notebook'},
  'pencil': {'pen', 'supplies', 'notebook', 'studying'},
  'paper': {'supplies', 'notebook', 'studying'},
  'desk': {'studying', 'homework', 'student', 'tutoring'},
  'student': {'student', 'studying', 'homework', 'tutoring'},
  'studying': {'studying', 'student', 'homework', 'tutoring'},
  'classroom': {'student', 'studying', 'tutoring', 'education'},
  'blackboard': {'studying', 'tutoring', 'student', 'education'},

  // ── Conversation / Visiting ──────────────────────────────────────────
  'talking': {'talking', 'conversation', 'visiting'},
  'conversation': {'conversation', 'talking', 'visiting'},
  'visiting': {'visiting', 'talking', 'conversation'},
  'chat': {'talking', 'conversation', 'visiting'},
  'smiling': {'talking', 'visiting', 'conversation', 'senior'},
  'smile': {'talking', 'visiting', 'conversation'},
  'handshake': {'visiting', 'talking', 'conversation'},
  'hug': {'visiting', 'talking', 'conversation'},
  'chair': {'visiting', 'talking', 'senior', 'conversation'},
  'couch': {'visiting', 'talking', 'conversation'},
  'home': {'visiting', 'neighbor'},

  // ── Group / Team / Community ────────────────────────────────────────
  'group': {'group', 'team', 'community'},
  'team': {'team', 'group', 'community'},

  // ── Building / Tools ────────────────────────────────────────────────
  'hammer': {'hammer', 'building', 'fix'},
  'nail': {'hammer', 'building', 'fix'},
  'wood': {'wood', 'building', 'birdhouse'},
  'saw': {'building', 'fix'},
  'screwdriver': {'fix', 'building'},
  'drill': {'fix', 'building'},

  // ── Birds / Birdhouse ──────────────────────────────────────────────
  'bird': {'bird', 'birdhouse'},
  'birdhouse': {'birdhouse', 'bird'},
  'nest': {'bird', 'birdhouse'},
  'feather': {'bird', 'birdhouse'},

  // ── Compost / Organic ─────────────────────────────────────────────
  'compost': {'compost', 'organic', 'waste'},
  'kitchen': {'kitchen', 'scraps', 'compost', 'organic'},
  'waste': {'waste', 'organic', 'compost', 'litter'},
  'organic': {'organic', 'compost', 'waste'},

  // ── Donation ──────────────────────────────────────────────────────
  'donation': {'donation', 'supplies'},
  'gift': {'donation', 'supplies'},

  // ── Street / Road ─────────────────────────────────────────────────
  'street': {'street', 'cleanup', 'litter'},
  'road': {'street', 'cleanup'},
  'sidewalk': {'street', 'cleanup', 'sweeping'},
  'path': {'street', 'cleanup'},

  // ── General environment ───────────────────────────────────────────
  'sun': {'environment', 'outdoor'},
  'sky': {'environment', 'outdoor'},
  'grass': {'environment', 'garden', 'planting'},
  'green': {'environment', 'tree', 'planting', 'garden'},
  'outdoor': {'environment', 'street', 'cleanup'},
  'yard': {'garden', 'planting', 'environment'},
};

/// Takes a list of ImageNet classification results (from ViT) and a set of
/// verification keywords, and returns whether the image matches the challenge.
///
/// Returns a [VerificationResult] with the match details.
VerificationResult matchImageNetToKeywords({
  required List<ImageNetPrediction> predictions,
  required List<String> verificationKeywords,
  required String challengeDescription,
  double minScore = 0.05,
  int maxPredictions = 10,
}) {
  // 1. Expand verification keywords into individual words
  final expandedKeywords = _expandKeywords(verificationKeywords);

  // 2. For each prediction (above min score), extract words and map to concepts
  final matchedKeywords = <String>{};
  final matchedLabels = <String>[];

  final topPredictions = predictions.take(maxPredictions).where((p) => p.score >= minScore);

  // Track labels with no mapping so we can log them for future improvements
  final unmappedLabels = <String>[];

  // Ambiguous ImageNet labels where individual words are too common to map
  // reliably without full-label context. e.g. "can opener" should NOT map
  // "can" → garbage; "pot" in "flowerpot" → planting but "pot" in cooking → skip.
  const ambiguousLabels = {
    'can opener', 'tin opener', 'oilcan',         // "can" ≠ garbage
    'potpie', 'teapot', 'coffeepot',              // cooking pot ≠ planting (keep "flowerpot"!)
    'green lizard', 'green snake', 'green mamba', // "green" ≠ tree
  };

  for (final pred in topPredictions) {
    final fullLabelLower = pred.label.toLowerCase();
    // Skip entire prediction if the full label is ambiguous
    if (ambiguousLabels.any((a) => fullLabelLower.contains(a))) {
      unmappedLabels.add('${pred.label} (${pred.score.toStringAsFixed(3)}) [ambiguous]');
      continue;
    }

    // Split compound ImageNet labels: "bucket, pail" → ["bucket", "pail"]
    final labelWords = _splitImageNetLabel(pred.label);
    bool labelMatched = false;
    bool anyWordMapped = false;

    for (final word in labelWords) {
      // Direct match: does the label word match any keyword?
      if (_wordMatchesKeyword(word, expandedKeywords)) {
        matchedKeywords.add(word);
        labelMatched = true;
        anyWordMapped = true;
      }

      // Concept bridge: does the label word map to concepts that match keywords?
      final concepts = _imagenetToConcepts[word.toLowerCase()];
      if (concepts != null) {
        anyWordMapped = true;
        for (final concept in concepts) {
          if (_wordMatchesKeyword(concept, expandedKeywords)) {
            matchedKeywords.add(concept);
            labelMatched = true;
          }
        }
      }
    }

    if (!anyWordMapped) {
      unmappedLabels.add('${pred.label} (${pred.score.toStringAsFixed(3)})');
    }

    if (labelMatched) {
      matchedLabels.add(pred.label);
    }
  }

  if (unmappedLabels.isNotEmpty) {
    debugPrint('Unmapped ViT labels (consider adding to concept map): $unmappedLabels');
  }

  // 3. Determine threshold
  // Single keyword match is enough — the free ViT model is limited and
  // we want ~80% of challenges to be verified until we can afford a real API.
  const threshold = 1;
  final isVerified = matchedKeywords.length >= threshold;

  // 4. Fallback: if no keywords defined, use description word matching
  if (verificationKeywords.isEmpty && !isVerified) {
    return _matchFromDescription(
      predictions: predictions,
      challengeDescription: challengeDescription,
      minScore: minScore,
      maxPredictions: maxPredictions,
    );
  }

  return VerificationResult(
    isVerified: isVerified,
    matchedKeywords: matchedKeywords.toList(),
    matchedLabels: matchedLabels,
    allLabels: predictions.map((p) => '${p.label} (${p.score.toStringAsFixed(3)})').toList(),
    threshold: threshold,
  );
}

/// Fallback when no verification keywords are defined: match ImageNet labels
/// against meaningful words from the challenge description via concept mapping.
VerificationResult _matchFromDescription({
  required List<ImageNetPrediction> predictions,
  required String challengeDescription,
  required double minScore,
  required int maxPredictions,
}) {
  final stopWords = {
    'the', 'a', 'an', 'in', 'on', 'at', 'with', 'and', 'or', 'to',
    'for', 'of', 'is', 'are', 'was', 'were', 'your', 'you', 'it',
    'this', 'that', 'from', 'by', 'as', 'be', 'has', 'have', 'had',
    'do', 'does', 'did', 'but', 'not', 'its', 'can', 'will', 'just',
    'about', 'some', 'any', 'all', 'each', 'their', 'them', 'they',
  };

  final descWords = challengeDescription
      .toLowerCase()
      .split(RegExp(r'\W+'))
      .where((w) => w.length > 3 && !stopWords.contains(w))
      .toSet();

  final matchedKeywords = <String>{};
  final matchedLabels = <String>[];

  final topPredictions = predictions.take(maxPredictions).where((p) => p.score >= minScore);

  for (final pred in topPredictions) {
    final labelWords = _splitImageNetLabel(pred.label);
    bool labelMatched = false;

    for (final word in labelWords) {
      // Direct match
      if (descWords.contains(word.toLowerCase())) {
        matchedKeywords.add(word);
        labelMatched = true;
      }
      // Concept bridge
      final concepts = _imagenetToConcepts[word.toLowerCase()];
      if (concepts != null) {
        for (final concept in concepts) {
          if (descWords.contains(concept)) {
            matchedKeywords.add(concept);
            labelMatched = true;
          }
        }
      }
    }
    if (labelMatched) {
      matchedLabels.add(pred.label);
    }
  }

  return VerificationResult(
    isVerified: matchedKeywords.isNotEmpty,
    matchedKeywords: matchedKeywords.toList(),
    matchedLabels: matchedLabels,
    allLabels: predictions.map((p) => '${p.label} (${p.score.toStringAsFixed(3)})').toList(),
    threshold: 1,
  );
}

/// Expands multi-word verification keywords into individual words.
Set<String> _expandKeywords(List<String> verificationKeywords) {
  final expanded = <String>{};
  for (final keyword in verificationKeywords) {
    final trimmed = keyword.toLowerCase().trim();
    if (trimmed.isEmpty) continue;
    if (!trimmed.contains(' ')) {
      expanded.add(trimmed);
    } else {
      for (final word in trimmed.split(RegExp(r'\s+'))) {
        if (word.isNotEmpty) expanded.add(word);
      }
    }
  }
  return expanded;
}

/// Splits a compound ImageNet label into individual words.
/// e.g. "bucket, pail" → {"bucket", "pail"}
///      "ping-pong ball" → {"ping", "pong", "ball"}
Set<String> _splitImageNetLabel(String label) {
  return label
      .toLowerCase()
      .split(RegExp(r'[,\-\s]+'))
      .where((w) => w.isNotEmpty && w.length > 1)
      .toSet();
}

/// Checks if a word matches any keyword exactly.
///
/// Relies on the concept mapping table to bridge synonyms and variants
/// (e.g., "old" → "elderly") rather than using loose prefix matching,
/// which would produce false positives like "clean" matching "cleaver".
bool _wordMatchesKeyword(String word, Set<String> keywords) {
  final lowerWord = word.toLowerCase().trim();
  if (lowerWord.isEmpty) return false;
  return keywords.contains(lowerWord);
}

/// A single ViT image classification prediction.
class ImageNetPrediction {
  final String label;
  final double score;
  const ImageNetPrediction({required this.label, required this.score});
}

/// The result of matching ImageNet predictions against verification keywords.
class VerificationResult {
  final bool isVerified;
  final List<String> matchedKeywords;
  final List<String> matchedLabels;
  final List<String> allLabels;
  final int threshold;

  const VerificationResult({
    required this.isVerified,
    required this.matchedKeywords,
    required this.matchedLabels,
    required this.allLabels,
    required this.threshold,
  });
}
