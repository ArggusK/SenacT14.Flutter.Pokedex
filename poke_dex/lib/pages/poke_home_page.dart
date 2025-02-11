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
    debugPrint('Dados do model:');
    debugPrint('Total de pokémons: ${model.count}');
    debugPrint('Próxima página: ${model.next}');
    debugPrint('Página anterior: ${model.previous ?? "Nenhuma"}');
    debugPrint('Lista de pokémons:');

    for (var pokemon in model.result) {
      debugPrint('Nome: ${pokemon.name}, URL: ${pokemon.url}');
    }

    setState(() {
      pokemonList = model.result;
      filteredPokemonList = model.result;
      pokemonCount = model.count;
      isLoading = false;
    });
  }

  void _onPokemonCardPressed() {}

  void _filterPokemons(String query) {
    setState(() {
      filteredPokemonList = pokemonList
          .where((pokemon) =>
              pokemon.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Pesquisar pokémon...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: _filterPokemons,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total de Pokémons: $pokemonCount',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredPokemonList.length,
                    itemBuilder: (context, index) {
                      final pokemon = filteredPokemonList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        elevation: 4.0,
                        child: InkWell(
                          onTap: _onPokemonCardPressed,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  pokemon.name,
                                  style: const TextStyle(
                                    fontSize: 16,
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
