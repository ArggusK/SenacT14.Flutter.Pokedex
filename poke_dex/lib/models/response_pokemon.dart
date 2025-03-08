import 'pokemon_summary.dart';

class ResponsePokemon {
  final List<PokemonSummary> result;

  ResponsePokemon({required this.result});

  factory ResponsePokemon.fromMap(Map<String, dynamic> map) {
    final rawList = map['results'] as List<dynamic>;

    // Filtra Pokémon duplicados por URL
    final uniquePokemons = <String, PokemonSummary>{};
    for (final item in rawList) {
      final pokemon = PokemonSummary.fromMap(item);
      if (!uniquePokemons.containsKey(pokemon.url)) {
        uniquePokemons[pokemon.url] = pokemon;
      }
    }

    return ResponsePokemon(result: uniquePokemons.values.toList());
  }
}
