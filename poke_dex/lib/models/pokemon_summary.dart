import 'package:flutter/material.dart';
import 'package:poke_dex/string_extension.dart';

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

  factory PokemonSummary.fromMap(Map<String, dynamic> data) {
    return PokemonSummary(
      name: data['name'] as String,
      url: data['url'] as String,
      imageUrl:
          data['sprites']['other']['official-artwork']['front_default'] ?? '',
      shinyImageUrl:
          data['sprites']['other']['official-artwork']['front_shiny'] ?? '',
      gifUrl: data['sprites']['versions']['generation-v']['black-white']
              ['animated']['front_default'] ??
          '',
      shinyGifUrl: data['sprites']['versions']['generation-v']['black-white']
              ['animated']['front_shiny'] ??
          '',
      types: (data['types'] as List)
          .map((t) => (t['type']['name'] as String).capitalize())
          .toList(),
      generation:
          (data['species']['generation']['name'].toString().capitalize()),
      abilities: (data['abilities'] as List)
          .map((a) => (a['ability']['name'] as String).capitalize())
          .toList(),
      weight: (data['weight'] as int) / 10,
      height: (data['height'] as int) / 10,
      stats: _processStats(data['stats']),
      movesByLevel: _processMoves(data['moves'], 'level-up'),
      movesByTM: _processMoves(data['moves'], 'machine'),
      evolutions: data['evolutions'] ?? [],
    );
  }

  static Map<String, int> _processStats(List<dynamic> stats) {
    final result = <String, int>{};
    for (var stat in stats) {
      final statEntry = stat as Map<String, dynamic>;
      final statName = _formatStatName(statEntry['stat']['name'] as String);
      result[statName] = statEntry['base_stat'] as int;
    }
    return result;
  }

  static String _formatStatName(String rawName) {
    const statNames = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'STK',
      'special-defense': 'SDF',
      'speed': 'SPD'
    };
    return statNames[rawName] ?? rawName.replaceAll('-', ' ').capitalize();
  }

  static List<Move> _processMoves(List<dynamic> moves, String method) {
    final uniqueMoves = <String, Move>{};
    for (final move in moves) {
      final moveName = (move['move']['name'] as String).capitalize();
      final details = (move['version_group_details'] as List)
          .where((d) => d['move_learn_method']['name'] == method);

      for (final detail in details) {
        final level =
            method == 'level-up' ? detail['level_learned_at'] as int : null;
        if (!uniqueMoves.containsKey(moveName) ||
            (level != null &&
                (uniqueMoves[moveName]?.levelLearned ?? 0) > level)) {
          uniqueMoves[moveName] = Move(
            name: moveName,
            levelLearned: level,
          );
        }
      }
    }
    return uniqueMoves.values.toList()
      ..sort((a, b) => (a.levelLearned ?? 0).compareTo(b.levelLearned ?? 0));
  }

  Color getTypeColor(String type) {
    switch (type.toLowerCase()) {
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

  Color getTextColorForBackground(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.light ? Colors.black : Colors.white;
  }
}

class Move {
  final String name;
  final int? levelLearned;

  Move({required this.name, this.levelLearned});
}

class Evolution {
  final String name;
  final String imageUrl;
  final String shinyImageUrl;
  final String gifUrl;
  final String shinyGifUrl;
  final List<Evolution> nextEvolutions;
  final String? trigger;

  Evolution({
    required this.name,
    required this.imageUrl,
    required this.shinyImageUrl,
    required this.gifUrl,
    required this.shinyGifUrl,
    this.nextEvolutions = const [],
    this.trigger,
  });

  Evolution copyWith({
    List<Evolution>? nextEvolutions,
    String? trigger,
  }) {
    return Evolution(
      name: name,
      imageUrl: imageUrl,
      shinyImageUrl: shinyImageUrl,
      gifUrl: gifUrl,
      shinyGifUrl: shinyGifUrl,
      nextEvolutions: nextEvolutions ?? this.nextEvolutions,
      trigger: trigger ?? this.trigger,
    );
  }
}
