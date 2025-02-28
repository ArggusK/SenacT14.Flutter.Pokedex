import 'package:poke_dex/models/pokemon_summary.dart';

class ResponsePokemon {
  final List<PokemonSummary> result;

  ResponsePokemon({
    required this.result,
  });

  factory ResponsePokemon.fromMap(Map<String, dynamic> map) {
    return ResponsePokemon(
      result: (map['results'] as List<dynamic>)
          .map((pokemon) => PokemonSummary.fromMap(pokemon))
          .toList(),
    );
  }
}
