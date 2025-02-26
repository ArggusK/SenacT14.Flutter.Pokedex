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
    final response =
        await dio.get('https://pokeapi.co/api/v2/pokemon?limit=20');

    var model = ResponsePokemon.fromMap(response.data);

    setState(() {
      pokemonList = model.result;
      isLoading = false;
    });

    if (!isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => PokeHomePage(
            initialPokemonList: pokemonList,
            loadMorePokemons: _loadMorePokemons,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  Future<List<PokemonSummary>> _loadMorePokemons(int offset) async {
    final dio = Dio();
    final response = await dio
        .get('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=20');
    var model = ResponsePokemon.fromMap(response.data);
    return model.result;
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
