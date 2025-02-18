import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:poke_dex/models/pokemon_summary.dart';

class PokemonInfoPage extends StatefulWidget {
  final PokemonSummary pokemon;

  const PokemonInfoPage({super.key, required this.pokemon});

  @override
  _PokemonInfoPageState createState() => _PokemonInfoPageState();
}

class _PokemonInfoPageState extends State<PokemonInfoPage> {
  late Future<PokemonSummary> _pokemonDetails;

  @override
  void initState() {
    super.initState();
    _pokemonDetails = _fetchPokemonDetails(widget.pokemon);
  }

  Future<PokemonSummary> _fetchPokemonDetails(PokemonSummary pokemon) async {
    final dio = Dio();
    final response = await dio.get(pokemon.url);

    if (response.statusCode == 200) {
      final data = response.data;
      final types = (data['types'] as List)
          .map((type) => (type['type']['name'] as String).toUpperCase())
          .toList();
      final abilities = (data['abilities'] as List)
          .map((ability) => ability['ability']['name'] as String)
          .toList();
      final speciesResponse = await dio.get(data['species']['url']);
      final speciesData = speciesResponse.data;
      final generation = speciesData['generation']['name'] as String;

      return PokemonSummary(
        name: pokemon.name,
        url: pokemon.url,
        imageUrl:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/${_extractPokemonNumber(pokemon.url)}.png',
        gifUrl:
            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/${_extractPokemonNumber(pokemon.url)}.gif',
        types: types,
        generation: generation,
        abilities: abilities,
      );
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

  int _extractPokemonNumber(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return int.parse(segments[segments.length - 2]);
  }

  String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  Color _getTypeColor(String type) {
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
      case 'unknown':
        return Colors.grey[800]!;
      case 'shadow':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  Color _getTextColorForBackground(Color backgroundColor) {
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    return brightness == Brightness.light ? Colors.black : Colors.white;
  }

  String _formatGeneration(String generation) {
    final romanNumeral = generation.split('-').last;
    final location = _generationToLocation(romanNumeral);

    return location;
  }

  String _generationToLocation(String romanNumeral) {
    switch (romanNumeral.toLowerCase()) {
      case 'i':
        return 'Kanto';
      case 'ii':
        return 'Johto';
      case 'iii':
        return 'Hoenn2';
      case 'iv':
        return 'Sinnoh';
      case 'v':
        return 'Unova';
      case 'vi':
        return 'Kalos';
      case 'vii':
        return 'Alola';
      case 'viii':
        return 'Galar';
      case 'ix':
        return 'Paldea';
      default:
        return 'Unknown Region';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: Text(
          _capitalize(widget.pokemon.name),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<PokemonSummary>(
        future: _pokemonDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
          }

          final pokemon = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(_capitalize(pokemon.name),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          pokemon.gifUrl,
                          width: 150,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error,
                                  color: Colors.white, size: 50),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              ...pokemon.types.map((type) {
                                final backgroundColor = _getTypeColor(type);
                                final textColor =
                                    _getTextColorForBackground(backgroundColor);
                                return WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 4.0),
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Text(
                                      type,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text(
                              'Região: ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Text(
                                _formatGeneration(pokemon.generation),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Center(
                    child: Text('Habilidades:',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white))),
                const SizedBox(height: 10),
                Column(
                  children: pokemon.abilities
                      .map((ability) => Card(
                            color: Colors.grey[800],
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                              onTap: () {},
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                    child: Text(' ${_capitalize(ability)}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white))),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
