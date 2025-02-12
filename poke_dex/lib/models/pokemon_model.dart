class PokemonModel {
  final String name;
  final String url;
  final String imageUrl;
  final String gifUrl;

  PokemonModel({
    required this.name,
    required this.url,
    required this.imageUrl,
    required this.gifUrl,
  });

  factory PokemonModel.fromMap(Map<String, dynamic> map) {
    final pokemonNumber = map['url'].split('/').reversed.elementAt(1);
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonNumber.png';
    final gifUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$pokemonNumber.gif';

    return PokemonModel(
      name: map['name'] as String,
      url: map['url'] as String,
      imageUrl: imageUrl,
      gifUrl: gifUrl,
    );
  }
}
