import 'package:flutter/material.dart';

class PokeHomePageStatefull extends StatefulWidget {
  const PokeHomePageStatefull({super.key});

  @override
  State<PokeHomePageStatefull> createState() => _PokeHomePageStateFullState();
}

class _PokeHomePageStateFullState extends State<PokeHomePageStatefull> {
  bool isCarregando = true;
  List<String> listaDePokemon = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await Future.delayed(Duration(seconds: 4));
    listaDePokemon = ["Cinderace", "Torchic", "Poliwag"];
    isCarregando = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("lista de pokemon"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return isCarregando
        ? CircularProgressIndicator()
        : ListView.builder(
            itemCount: listaDePokemon.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(listaDePokemon[index]));
            },
          );
  }
}
