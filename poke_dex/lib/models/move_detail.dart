import 'package:flutter/material.dart';

class MoveDetail {
  final String name;
  final int? power;
  final int? accuracy;
  final int pp;
  final String effectDescription;
  final String type;
  final String damageClass;
  final String target;

  MoveDetail({
    required this.name,
    this.power,
    this.accuracy,
    required this.pp,
    required this.effectDescription,
    required this.type,
    required this.damageClass,
    required this.target,
  });

  factory MoveDetail.fromJson(Map<String, dynamic> json) {
    String capitalize(String text) {
      if (text.isEmpty) return text;
      return text
          .split('-')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }

    final effectEntry = (json['effect_entries'] as List).firstWhere(
      (e) => e['language']['name'] == 'en',
      orElse: () => {'effect': 'No description available'},
    );

    return MoveDetail(
      name: capitalize(json['name'] as String),
      power: json['power'] as int?,
      accuracy: json['accuracy'] as int?,
      pp: json['pp'] as int,
      effectDescription: effectEntry['effect'] ?? effectEntry['short_effect'],
      type: capitalize(json['type']['name'] as String),
      damageClass: capitalize(json['damage_class']['name'] as String),
      target:
          capitalize((json['target']['name'] as String).replaceAll('-', ' ')),
    );
  }

  // Lógica de cores dos tipos
  Color getTypeColor() {
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

  Color getTextColorForType() {
    final backgroundColor = getTypeColor();
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.light ? Colors.black : Colors.white;
  }
}
