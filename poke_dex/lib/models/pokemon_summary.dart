class PokemonSummary {
  final String name;
  final String url;
  final String imageUrl;
  final String gifUrl;
  final List<String> types;
  final String generation;
  final List<String> abilities;

  PokemonSummary({
    required this.name,
    required this.url,
    required this.imageUrl,
    required this.gifUrl,
    required this.types,
    required this.generation,
    required this.abilities,
  });

  factory PokemonSummary.fromMap(Map<String, dynamic> map) {
    final pokemonName = map['name'] as String;
    final pokemonUrl = map['url'] as String;
    final pokemonNumber = pokemonUrl.split('/').reversed.elementAt(1);
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonNumber.png';
    final gifUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$pokemonNumber.gif';

    return PokemonSummary(
      name: pokemonName,
      url: pokemonUrl,
      imageUrl: imageUrl,
      gifUrl: gifUrl,
      types: [],
      generation: '',
      abilities: [],
    );
  }
}
