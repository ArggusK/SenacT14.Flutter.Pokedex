import 'package:poke_dex/models/pokemon_model.dart';

class PokemonListModel {
  final int count;
  final String next;
  final String? previous;
  final List<PokemonModel> result;

  PokemonListModel({
    required this.count,
    required this.next,
    required this.previous,
    required this.result,
  });

  factory PokemonListModel.fromMap(Map<String, dynamic> map) {
    return PokemonListModel(
      count: map['count'] as int,
      next: map['next'] as String,
      previous: map['previous'] as String?,
      result: (map['results'] as List<dynamic>)
          .map((pokemon) => PokemonModel.fromMap(pokemon))
          .toList(),
    );
  }
}
