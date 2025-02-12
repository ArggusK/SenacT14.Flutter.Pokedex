import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:poke_dex/models/pokemon_list_model.dart';
import 'package:poke_dex/models/pokemon_model.dart';

class PokeHomePage extends StatefulWidget {
  const PokeHomePage({super.key});

  @override
  State<PokeHomePage> createState() => _PokeHomePageState();
}

class _PokeHomePageState extends State<PokeHomePage> {
  List<PokemonModel> pokemonList = [];
  List<PokemonModel> filteredPokemonList = [];
  bool isLoading = true;
  int pokemonCount = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getPokemons();
  }

  Future<void> _getPokemons() async {
    final dio = Dio();
    final response =
        await dio.get('https://pokeapi.co/api/v2/pokemon?limit=1034');

    var model = PokemonListModel.fromMap(response.data);

    setState(() {
      pokemonList = model.result;
      filteredPokemonList = model.result;
      pokemonCount = model.count;
      isLoading = false;
    });
  }

  void _onPokemonCardPressed(
      BuildContext context, String gifUrl, int pokemonNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                gifUrl,
                width: 200,
                height: 200,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Icon(Icons.error, color: Colors.white);
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Pokémon #$pokemonNumber',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _filterPokemons(String query) {
    setState(() {
      filteredPokemonList = pokemonList.where((pokemon) {
        final originalIndex = pokemonList.indexOf(pokemon);
        final pokemonNumber = (originalIndex + 1).toString();
        final pokemonName = pokemon.name.toLowerCase();

        return pokemonName.contains(query.toLowerCase()) ||
            pokemonNumber.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text(
          'Pokédex',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar pokémon...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.red),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: _filterPokemons,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredPokemonList.length,
                    itemBuilder: (context, index) {
                      final pokemon = filteredPokemonList[index];
                      final originalIndex = pokemonList.indexOf(pokemon);
                      final pokemonNumber = originalIndex + 1;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color: Colors.grey[800],
                        child: InkWell(
                          onTap: () => _onPokemonCardPressed(
                              context, pokemon.gifUrl, pokemonNumber),
                          borderRadius: BorderRadius.circular(10.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Image.network(
                                  pokemon.imageUrl,
                                  width: 50,
                                  height: 50,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return const Icon(Icons.error,
                                        color: Colors.white);
                                  },
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '#$pokemonNumber',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  pokemon.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
