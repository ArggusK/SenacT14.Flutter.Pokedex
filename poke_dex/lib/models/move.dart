import 'package:poke_dex/string_extension.dart';

class Move {
  final String name;
  final int? levelLearned;

  Move({required this.name, this.levelLearned});

  factory Move.fromMap(Map<String, dynamic> map) {
    return Move(
      name: (map['move']['name'] as String).capitalize(),
      levelLearned: map['version_group_details'][0]['level_learned_at'] as int?,
    );
  }
}
