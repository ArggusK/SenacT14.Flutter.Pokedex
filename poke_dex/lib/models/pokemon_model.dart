class PokemonModel {
  final String name;
  final String url;

  PokemonModel({
    required this.name,
    required this.url,
  });

  factory PokemonModel.fromMap(Map<String, dynamic> map) {
    return PokemonModel(
      name: map['name'] as String,
      url: map['url'] as String,
    );
  }
}
