import 'package:flutter/material.dart';
import 'package:poke_dex/models/pokemon_summary.dart';
import 'package:poke_dex/pages/poke_info_page.dart';

class PokeHomePage extends StatefulWidget {
  final List<PokemonSummary> initialPokemonList;
  final Future<List<PokemonSummary>> Function(int offset) loadMorePokemons;

  const PokeHomePage({
    super.key,
    required this.initialPokemonList,
    required this.loadMorePokemons,
  });

  @override
  State<PokeHomePage> createState() => _PokeHomePageState();
}

class _PokeHomePageState extends State<PokeHomePage> {
  List<PokemonSummary> allPokemonList = [];
  List<PokemonSummary> pokemonList = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool isLoadingMore = false;
  int offset = 20;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    allPokemonList = widget.initialPokemonList;
    pokemonList = allPokemonList;
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() => _filterPokemons());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoadingMore) {
      _loadMorePokemons();
    }
  }

  Future<void> _loadMorePokemons() async {
    setState(() => isLoadingMore = true);
    final newPokemons = await widget.loadMorePokemons(offset);
    setState(() {
      allPokemonList.addAll(newPokemons);
      if (!_isSearching) pokemonList = allPokemonList;
      offset += 20;
      isLoadingMore = false;
    });
  }

  Future<void> _filterPokemons() async {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        pokemonList = allPokemonList;
      });
      return;
    }

    setState(() => _isSearching = true);

    while (true) {
      final found = allPokemonList.any((p) =>
          p.name.toLowerCase().contains(query) ||
          (allPokemonList.indexOf(p) + 1).toString().contains(query));

      if (found || isLoadingMore || offset > 1500) break;
      await _loadMorePokemons();
    }

    setState(() {
      pokemonList = allPokemonList.where((p) {
        final index = allPokemonList.indexOf(p);
        return p.name.toLowerCase().contains(query) ||
            (index + 1).toString().contains(query);
      }).toList();
    });
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
          pokemonList.sort((a, b) =>
              pokemonList.indexOf(a).compareTo(pokemonList.indexOf(b)));
          break;
        case 'Decrescente':
          pokemonList.sort((a, b) =>
              pokemonList.indexOf(b).compareTo(pokemonList.indexOf(a)));
          break;
      }
    });
  }

  String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  void _onPokemonCardPressed(BuildContext context, PokemonSummary pokemon) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PokemonInfoPage(pokemon: pokemon)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text('Pokédex',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            icon: const Icon(Icons.filter_list, color: Colors.white),
            color: Colors.grey[900],
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'A a Z',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Center(
                      child:
                          Text('A a Z', style: TextStyle(color: Colors.white))),
                ),
              ),
              PopupMenuItem(
                value: 'Z a A',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Center(
                      child:
                          Text('Z a A', style: TextStyle(color: Colors.white))),
                ),
              ),
              PopupMenuItem(
                value: 'Crescente',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Center(
                      child: Text('Crescente',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
              PopupMenuItem(
                value: 'Decrescente',
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Center(
                      child: Text('Decrescente',
                          style: TextStyle(color: Colors.white))),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 3))
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Pesquisar pokémon...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Colors.red),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: pokemonList.length + (isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == pokemonList.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final pokemon = pokemonList[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: Colors.grey[800],
                  child: InkWell(
                    onTap: () => _onPokemonCardPressed(context, pokemon),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Image.network(pokemon.imageUrl,
                              width: 50,
                              height: 50,
                              errorBuilder: (context, _, __) =>
                                  const Icon(Icons.error, color: Colors.white)),
                          const SizedBox(width: 16),
                          Text('#${allPokemonList.indexOf(pokemon) + 1}',
                              style: const TextStyle(color: Colors.white)),
                          const SizedBox(width: 16),
                          Text(_capitalize(pokemon.name),
                              style: const TextStyle(color: Colors.white)),
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
