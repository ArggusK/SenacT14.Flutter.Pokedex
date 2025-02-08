import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:poke_dex/models/pokemon_list_model.dart';

class PokeHomePage extends StatelessWidget {
  const PokeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Poke Home"),
      ),
      body: _builBody(),
    );
  }

  Future<List<String>> _getPokemons() async {
    final dio = Dio();
    final response = await dio.get('https://pokeapi.co/api/v2/pokemon');
    var model = PokemonListModel.FromMap(response.data);

    var listPokemon = ["Cinderace", "Torchic", "Poliwag"];
    Future.delayed(Duration(seconds: 4));
    return listPokemon;
  }

  Widget _builBody() {
    return FutureBuilder(
      future: _getPokemons(),
      builder: (context, response) {
        if (response.connectionState == ConnectionState.done) {
          var lista = response.data;
          if (lista == null || lista.isEmpty) {
            return Text("Nenhum Pokemon encontrado!");
          }
          return ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(lista[index]));
              });
        }
        return CircularProgressIndicator();
      },
    );
  }
}
