import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:poke_dex/models/pokemon_summary.dart';
import 'package:poke_dex/pages/poke_home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final Dio _dio = Dio();
  List<PokemonSummary> _pokemonList = [];
  bool _isLoading = true;
  int _totalCount = 0;
  int _loadedCount = 0;

  @override
  void initState() {
    super.initState();
    _getTotalCount();
  }

  Future<void> _getTotalCount() async {
    try {
      final response = await _dio.get('https://pokeapi.co/api/v2/pokemon');
      _totalCount = response.data['count'];
      await _loadPokemonsInBatches();
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> _loadPokemonsInBatches() async {
    const initialBatchSize = 50;
    final totalBatches = (_totalCount / initialBatchSize).ceil();

    for (int i = 0; i < totalBatches; i++) {
      try {
        final response = await _dio.get(
          'https://pokeapi.co/api/v2/pokemon',
          queryParameters: {
            'limit': initialBatchSize,
            'offset': i * initialBatchSize,
          },
        );

        final newPokemons = (response.data['results'] as List)
            .map((p) => PokemonSummary.fromMap(p))
            .where((p) => !_pokemonList
                .any((existing) => existing.url == p.url)) // Evita duplicatas
            .toList();

        setState(() {
          _pokemonList.addAll(newPokemons);
          _loadedCount = _pokemonList.length;
        });
      } catch (e) {
        _handleError(e);
        break;
      }
    }

    _navigateToHome();
  }

  void _navigateToHome() {
    if (_isLoading) {
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => PokeHomePage(
            initialPokemonList: _pokemonList,
            searchPokemons: _searchPokemons,
          ),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  Future<List<PokemonSummary>> _searchPokemons(String query) async {
    final lowerQuery = query.toLowerCase();
    return _pokemonList.where((p) {
      final index = _pokemonList.indexOf(p) + 1;
      return p.name.toLowerCase().contains(lowerQuery) ||
          index.toString().contains(query);
    }).toList();
  }

  void _handleError(dynamic error) {
    print('Erro: $error');
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro ao carregar Pokémon!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pokédex',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.catching_pokemon,
                    size: 100, color: Colors.white),
                if (_isLoading) ...[
                  Positioned(
                    bottom: 0,
                    child: Text(
                      '$_loadedCount/$_totalCount',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading) ...[
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 10),
              const Text(
                'Carregando Pokémon...',
                style: TextStyle(color: Colors.white),
              )
            ],
          ],
        ),
      ),
    );
  }
}
