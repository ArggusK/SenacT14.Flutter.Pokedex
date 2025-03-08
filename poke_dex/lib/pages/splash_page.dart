import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:poke_dex/models/response_pokemon.dart';
import 'package:poke_dex/models/pokemon_summary.dart';
import 'package:poke_dex/pages/poke_home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  List<PokemonSummary> pokemonList = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getPokemons();
  }

  Future<void> _getPokemons() async {
    final dio = Dio();
    try {
      List<PokemonSummary> allPokemons = [];
      int offset = 0;
      const int limit = 100; // Carrega 100 Pokémon por vez

      while (true) {
        final response = await dio.get(
          'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset',
        );
        final model = ResponsePokemon.fromMap(response.data);
        allPokemons.addAll(model.result);

        // Se a resposta tiver menos Pokémon que o limite, para o loop
        if (model.result.length < limit) break;
        offset += limit;
      }

      setState(() {
        pokemonList = allPokemons;
        isLoading = false;
      });

      // Navega para a PokeHomePage após um pequeno delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                PokeHomePage(
              initialPokemonList: pokemonList,
              searchPokemons: _searchPokemons,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erro ao carregar Pokémon: $e';
      });
    }
  }

  Future<List<PokemonSummary>> _searchPokemons(String query) async {
    final lowerQuery = query.toLowerCase();
    return pokemonList.where((pokemon) {
      final originalIndex = pokemonList.indexOf(pokemon);
      final pokemonNumber = (originalIndex + 1).toString();
      return pokemon.name.toLowerCase().contains(lowerQuery) ||
          pokemonNumber.contains(query);
    }).toList();
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
            const Icon(
              Icons.catching_pokemon,
              size: 100,
              color: Colors.white,
            ),
            if (isLoading) const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            if (errorMessage != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getPokemons,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
