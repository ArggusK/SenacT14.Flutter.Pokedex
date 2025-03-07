import 'package:flutter/material.dart';

class PokemonSummary {
  final String name;
  final String url;
  final String imageUrl;
  final String shinyImageUrl;
  final String gifUrl;
  final String shinyGifUrl;
  final List<String> types;
  final String generation;
  final List<String> abilities;
  final double weight;
  final double height;
  final Map<String, int> stats;
  final List<Move> movesByLevel;
  final List<Move> movesByTM;
  final List<Evolution> evolutions;

  PokemonSummary({
    required this.name,
    required this.url,
    required this.imageUrl,
    required this.shinyImageUrl,
    required this.gifUrl,
    required this.shinyGifUrl,
    required this.types,
    required this.generation,
    required this.abilities,
    required this.weight,
    required this.height,
    required this.stats,
    required this.movesByLevel,
    required this.movesByTM,
    required this.evolutions,
  });

  factory PokemonSummary.fromMap(Map<String, dynamic> map) {
    final pokemonNumber = _extractId(map['url']);

    return PokemonSummary(
      name: (map['name'] as String).capitalize,
      url: map['url'] as String,
      imageUrl: _buildImageUrl(pokemonNumber),
      shinyImageUrl: _buildShinyImageUrl(pokemonNumber),
      gifUrl: _buildGifUrl(pokemonNumber),
      shinyGifUrl: _buildShinyGifUrl(pokemonNumber),
      types: _parseTypes(map['types'] ?? []),
      generation: _parseGeneration(map['species']?['url'] ?? ''),
      abilities: _parseAbilities(map['abilities'] ?? []),
      weight: (map['weight'] as int? ?? 0) / 10,
      height: (map['height'] as int? ?? 0) / 10,
      stats: _parseStats(map['stats'] ?? []),
      movesByLevel: _parseMoves(map['moves'] ?? [], 'level-up'),
      movesByTM: _parseMoves(map['moves'] ?? [], 'machine'),
      evolutions: _parseEvolutions(map['evolution_chain'] ?? {}),
    );
  }

  // Métodos auxiliares de parsing
  static int _extractId(String url) =>
      int.parse(url.split('/').where((s) => s.isNotEmpty).last);

  static String _buildImageUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

  static String _buildShinyImageUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png';

  static String _buildGifUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif';

  static String _buildShinyGifUrl(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/shiny/$id.gif';

  static List<String> _parseTypes(List<dynamic> types) =>
      types.map((t) => (t['type']['name'] as String).capitalize).toList();

  static String _parseGeneration(String speciesUrl) {
    final parts = speciesUrl.split('/');
    return 'Gen ${parts[parts.length - 2]}';
  }

  static List<String> _parseAbilities(List<dynamic> abilities) => abilities
      .map((a) => (a['ability']['name'] as String).capitalize)
      .toList();

  static Map<String, int> _parseStats(List<dynamic> stats) {
    return {
      for (var stat in stats)
        _formatStatName(stat['stat']['name']): stat['base_stat'] as int
    };
  }

  static String _formatStatName(String raw) {
    const statsMap = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'SATK',
      'special-defense': 'SDEF',
      'speed': 'SPD'
    };
    return statsMap[raw] ?? raw.capitalize;
  }

  static List<Move> _parseMoves(List<dynamic> moves, String method) {
    return moves
        .where((m) => (m['version_group_details'] as List).any(
              (d) => d['move_learn_method']['name'] == method,
            ))
        .map((m) => Move(
              name: (m['move']['name'] as String).capitalize,
              levelLearned: method == 'level-up'
                  ? (m['version_group_details'][0]['level_learned_at'] as int)
                  : null,
            ))
        .toList();
  }

  static List<Evolution> _parseEvolutions(Map<String, dynamic> chain) {
    final evolutions = <Evolution>[];
    _parseEvolutionChain(chain['chain'], evolutions);
    return evolutions;
  }

  static void _parseEvolutionChain(dynamic chain, List<Evolution> evolutions,
      {String? trigger}) {
    final evolvesTo = chain['evolves_to'] as List<dynamic>;
    final current = _createEvolution(
        chain['species'], chain['evolution_details'],
        previousTrigger: trigger);

    final nextEvolutions = <Evolution>[];
    for (final next in evolvesTo) {
      final nextTrigger =
          _getTrigger(next['evolution_details'] as List<dynamic>);
      _parseEvolutionChain(next, nextEvolutions, trigger: nextTrigger);
    }

    if (evolutions.every((e) => e.name != current.name)) {
      evolutions.add(current.copyWith(nextEvolutions: nextEvolutions));
    }
  }

  static Evolution _createEvolution(
      Map<String, dynamic> species, List<dynamic> details,
      {String? previousTrigger}) {
    final id = _extractId(species['url'] as String);
    return Evolution(
      name: (species['name'] as String).capitalize,
      imageUrl: _buildImageUrl(id),
      shinyImageUrl: _buildShinyImageUrl(id),
      gifUrl: _buildGifUrl(id),
      shinyGifUrl: _buildShinyGifUrl(id),
      trigger: previousTrigger ?? _getTrigger(details),
    );
  }

  static String? _getTrigger(List<dynamic> details) {
    if (details.isEmpty) return null;
    final d = details.first;
    if (d['item'] != null) {
      return 'Usar ${(d['item']['name'] as String).capitalize}';
    }
    if (d['min_level'] != null) return 'Nível ${d['min_level']}';
    if (d['trigger']['name'] == 'trade') return 'Troca';
    return (d['trigger']['name'] as String).capitalize;
  }

  // Métodos de formatação
  String get formattedWeight => '${weight.toStringAsFixed(1)} kg';
  String get formattedHeight => '${height.toStringAsFixed(1)} m';
  String get formattedName => name.capitalize;
  int get id => _extractId(url);

  // Métodos de cor
  Color getTypeColor(String type) {
    return type.toLowerCase().pokemonColor;
  }

  Color getTextColorForBackground(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.light ? Colors.black : Colors.white;
  }
}

// Extensão para cores de tipos
extension TypeColorExtension on String {
  Color get pokemonColor {
    switch (toLowerCase()) {
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'grass':
        return Colors.green;
      case 'electric':
        return Colors.yellow;
      case 'psychic':
        return Colors.purple;
      case 'ice':
        return Colors.lightBlue;
      case 'dragon':
        return Colors.indigo;
      case 'dark':
        return Colors.brown;
      case 'fairy':
        return Colors.pink;
      case 'normal':
        return Colors.grey;
      case 'fighting':
        return Colors.red;
      case 'flying':
        return Colors.lightBlue[300]!;
      case 'poison':
        return Colors.purple[300]!;
      case 'ground':
        return Colors.brown[300]!;
      case 'rock':
        return Colors.grey[600]!;
      case 'bug':
        return Colors.lightGreen[500]!;
      case 'ghost':
        return Colors.deepPurple;
      case 'steel':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }
}
