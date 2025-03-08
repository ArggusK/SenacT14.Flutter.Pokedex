import 'dart:async';

import 'package:flutter/material.dart';
import 'package:poke_dex/models/pokemon_summary.dart';
import 'package:poke_dex/pages/poke_info_page.dart';

class PokeHomePage extends StatefulWidget {
  final List<PokemonSummary> initialPokemonList;
  final Future<List<PokemonSummary>> Function(String query) searchPokemons;

  const PokeHomePage({
    super.key,
    required this.initialPokemonList,
    required this.searchPokemons,
  });

  @override
  State<PokeHomePage> createState() => _PokeHomePageState();
}

class _PokeHomePageState extends State<PokeHomePage> {
  List<PokemonSummary> pokemonList = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    pokemonList = widget.initialPokemonList;

    _searchController.addListener(() {
      if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () {
        _filterPokemons(_searchController.text);
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _applyFilter(String filter) {
    setState(() {
      switch (filter) {
        case 'A a Z':
          pokemonList.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Z a A':
          pokemonList.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'Crescente':
          pokemonList = widget.initialPokemonList;
          break;
        case 'Decrescente':
          pokemonList = widget.initialPokemonList.reversed.toList();
          break;
      }
    });
  }

  void _onPokemonCardPressed(BuildContext context, PokemonSummary pokemon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PokemonInfoPage(pokemon: pokemon),
      ),
    );
  }

  Future<void> _filterPokemons(String query) async {
    if (query.isEmpty) {
      setState(() {
        pokemonList = widget.initialPokemonList;
      });
      return;
    }

    final results = await widget.searchPokemons(query);
    setState(() {
      pokemonList = results;
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
        actions: [
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'A a Z',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Text('A a Z', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'Z a A',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Text('Z a A', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'Crescente',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Text('Crescente',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'Decrescente',
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Center(
                    child: Text('Decrescente',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ],
            icon: const Icon(Icons.filter_list, color: Colors.white),
            color: Colors.grey[900],
          ),
        ],
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
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                final pokemon = pokemonList[index];
                final pokemonNumber =
                    widget.initialPokemonList.contains(pokemon)
                        ? widget.initialPokemonList.indexOf(pokemon) + 1
                        : index + 1;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  color: Colors.grey[800],
                  child: InkWell(
                    onTap: () => _onPokemonCardPressed(context, pokemon),
                    borderRadius: BorderRadius.circular(10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Image.network(
                            pokemon.imageUrl,
                            width: 50,
                            height: 50,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error, color: Colors.white),
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
                            pokemon.formattedName,
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
