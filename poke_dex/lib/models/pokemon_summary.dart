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
    final pokemonNumber = map['url'].split('/').reversed.elementAt(1);

    return PokemonSummary(
      name: map['name'] as String,
      url: map['url'] as String,
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonNumber.png',
      shinyImageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$pokemonNumber.png',
      gifUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$pokemonNumber.gif',
      shinyGifUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/shiny/$pokemonNumber.gif',
      types: [],
      generation: '',
      abilities: [],
      weight: 0.0,
      height: 0.0,
      stats: {},
      movesByLevel: [],
      movesByTM: [],
      evolutions: [],
    );
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
