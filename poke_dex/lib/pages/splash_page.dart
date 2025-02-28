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

  @override
  void initState() {
    super.initState();
    _getPokemons();
  }

  Future<void> _getPokemons() async {
    final dio = Dio();
    try {
      // First get total Pokémon count
      final countResponse = await dio.get('https://pokeapi.co/api/v2/pokemon');
      final totalCount = countResponse.data['count'];

      // Fetch all Pokémon
      final response = await dio.get(
        'https://pokeapi.co/api/v2/pokemon?limit=$totalCount',
      );

      var model = ResponsePokemon.fromMap(response.data);

      setState(() {
        pokemonList = model.result;
        isLoading = false;
      });

      if (!isLoading) {
        await Future.delayed(const Duration(milliseconds: 500));
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
      // Handle error appropriately
      print('Error fetching Pokémon: $e');
      setState(() => isLoading = false);
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
          ],
        ),
      ),
    );
  }
}
