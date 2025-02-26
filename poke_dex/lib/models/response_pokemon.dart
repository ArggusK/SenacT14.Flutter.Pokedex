import 'package:poke_dex/models/pokemon_summary.dart';

class ResponsePokemon {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonSummary> result;

  ResponsePokemon({
    required this.count,
    required this.next,
    required this.previous,
    required this.result,
  });

  factory ResponsePokemon.fromMap(Map<String, dynamic> map) {
    var pokemonList = (map['results'] as List<dynamic>)
        .map((pokemon) => PokemonSummary.fromMap(pokemon))
        .toList();

    return ResponsePokemon(
      count: map['count'] as int,
      next: map['next'] as String?,
      previous: map['previous'] as String?,
      result: pokemonList,
    );
  }
}
