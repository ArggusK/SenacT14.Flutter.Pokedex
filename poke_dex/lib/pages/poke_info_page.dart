import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:poke_dex/models/pokemon_summary.dart';

class PokemonInfoPage extends StatefulWidget {
  final PokemonSummary pokemon;

  const PokemonInfoPage({super.key, required this.pokemon});

  @override
  _PokemonInfoPageState createState() => _PokemonInfoPageState();
}

class _PokemonInfoPageState extends State<PokemonInfoPage> {
  late Future<PokemonSummary> _pokemonDetails;
  bool _isShiny = false;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _pokemonDetails = _fetchPokemonDetails(widget.pokemon);
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<PokemonSummary> _fetchPokemonDetails(PokemonSummary pokemon) async {
    try {
      final response = await _dio.get(pokemon.url);
      if (response.statusCode != 200)
        throw Exception('Falha ao carregar detalhes');

      final data = response.data;
      final speciesResponse = await _dio.get(data['species']['url']);
      final speciesData = speciesResponse.data;

      return PokemonSummary(
        name: pokemon.name,
        url: pokemon.url,
        imageUrl: pokemon.imageUrl,
        shinyImageUrl: pokemon.shinyImageUrl,
        gifUrl: pokemon.gifUrl,
        shinyGifUrl: pokemon.shinyGifUrl,
        types: (data['types'] as List)
            .map((t) => _capitalize(t['type']['name'] as String))
            .toList(),
        generation: _capitalize(speciesData['generation']['name'].toString()),
        abilities: (data['abilities'] as List)
            .map((a) => _capitalize(a['ability']['name'] as String))
            .toList(),
        weight: (data['weight'] as int) / 10,
        height: (data['height'] as int) / 10,
        stats: _processStats(data['stats']),
        movesByLevel: _processMoves(data['moves'], 'level-up'),
        movesByTM: _processMoves(data['moves'], 'machine'),
        evolutions:
            await _fetchEvolutionChain(speciesData['evolution_chain']['url']),
      );
    } catch (e) {
      throw Exception('Erro: ${e.toString()}');
    }
  }

  Map<String, int> _processStats(List<dynamic> stats) {
    final result = <String, int>{};
    for (var stat in stats) {
      final statEntry = stat as Map<String, dynamic>;
      final statName = _formatStatName(statEntry['stat']['name'] as String);
      result[statName] = statEntry['base_stat'] as int;
    }
    return result;
  }

  String _formatStatName(String rawName) {
    const statNames = {
      'hp': 'HP',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'STK',
      'special-defense': 'SEF',
      'speed': 'SPD'
    };
    return statNames[rawName] ?? _capitalize(rawName.replaceAll('-', ' '));
  }

  List<Move> _processMoves(List<dynamic> moves, String method) {
    return moves
        .expand((move) => (move['version_group_details'] as List)
            .where((d) => d['move_learn_method']['name'] == method)
            .map((d) => Move(
                  name: _capitalize(move['move']['name'] as String),
                  levelLearned: method == 'level-up'
                      ? d['level_learned_at'] as int
                      : null,
                )))
        .toSet()
        .toList()
      ..sort((a, b) => (a.levelLearned ?? 0).compareTo(b.levelLearned ?? 0));
  }

  Future<List<Evolution>> _fetchEvolutionChain(String url) async {
    try {
      final response = await _dio.get(url);
      final List<Evolution> evolutions = [];
      _parseEvolutionChain(response.data['chain'], evolutions);
      return evolutions;
    } catch (e) {
      return [];
    }
  }

  void _parseEvolutionChain(dynamic chain, List<Evolution> evolutions,
      {String? trigger}) {
    final evolvesTo = chain['evolves_to'] as List<dynamic>;
    final current = _createEvolution(
        chain['species'], chain['evolution_details'],
        previousTrigger: trigger);

    final nextEvolutions = <Evolution>[];
    for (final next in evolvesTo) {
      final nextTrigger =
          _getTrigger(next['evolution_details'] as List<dynamic>);
      _parseEvolutionChain(next, nextEvolutions, trigger: nextTrigger);
    }

    if (evolutions.every((e) => e.name != current.name)) {
      evolutions.add(current.copyWith(nextEvolutions: nextEvolutions));
    }
  }

  Evolution _createEvolution(
      Map<String, dynamic> species, List<dynamic> details,
      {String? previousTrigger}) {
    final id = _extractId(species['url'] as String);
    return Evolution(
      name: _capitalize(species['name'] as String),
      imageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png',
      shinyImageUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/shiny/$id.png',
      gifUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/$id.gif',
      shinyGifUrl:
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/showdown/shiny/$id.gif',
      trigger: previousTrigger ?? _getTrigger(details),
    );
  }

  String? _getTrigger(List<dynamic> details) {
    if (details.isEmpty) return null;
    final d = details.first;
    if (d['item'] != null)
      return 'Usar ${_capitalize((d['item']['name'] as String).replaceAll('-', ' '))}';
    if (d['min_level'] != null) return 'Nível ${d['min_level']}';
    if (d['trigger']['name'] == 'trade') return 'Troca';
    return _capitalize(d['trigger']['name'].toString().replaceAll('-', ' '));
  }

  int _extractId(String url) => int.parse(url.split('/').reversed.elementAt(1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.red[800],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red[800]!, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Transform.scale(
                  scale: 1.1,
                  child: Switch(
                    value: _isShiny,
                    onChanged: (value) => setState(() => _isShiny = value),
                    activeColor: Colors.white,
                    activeTrackColor: Colors.red[800]!.withOpacity(0.9),
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<PokemonSummary>(
        future: _pokemonDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Dados não encontrados'));
          }

          final pokemon = snapshot.data!;

          return Column(
            children: [
              _buildPokemonHeader(pokemon),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: const [
                          Tab(text: 'Estatísticas'),
                          Tab(text: 'Movimentos'),
                          Tab(text: 'Evoluções'),
                        ],
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey,
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildStatsTab(pokemon),
                            _buildMovesTab(pokemon),
                            _buildEvolutionsTab(pokemon),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPokemonHeader(PokemonSummary pokemon) {
    final gifUrl = _isShiny ? pokemon.shinyGifUrl : pokemon.gifUrl;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _capitalize(pokemon.name),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                gifUrl,
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.white, size: 50),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDescription('Peso', pokemon.weight, 'kg'),
              _buildDescription('Altura', pokemon.height, 'm'),
              _buildAbilityButton(pokemon),
            ],
          ),
          const SizedBox(height: 20),
          _buildTypeChips(pokemon),
        ],
      ),
    );
  }

  Widget _buildDescription(String title, double value, String unit) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildTypeChips(PokemonSummary pokemon) {
    return Wrap(
      spacing: 8.0,
      children: pokemon.types.map((type) {
        final color = pokemon.getTypeColor(type);
        return Chip(
          backgroundColor: color,
          label: Text(
            type,
            style: TextStyle(
              color: pokemon.getTextColorForBackground(color),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAbilityButton(PokemonSummary pokemon) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: const Icon(
        FontAwesomeIcons.meteor,
        color: Colors.white,
        size: 22,
      ),
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
          height: 200,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Habilidades',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: pokemon.abilities
                      .map((ability) => ListTile(
                            title: Text(
                              ability,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsTab(PokemonSummary pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Estatísticas Base',
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...pokemon.stats.entries
              .map((e) => _buildStatProgress(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildStatProgress(String label, int value) {
    Color color;
    if (value < 50) {
      color = Colors.red;
    } else if (value < 80) {
      color = Colors.orange;
    } else if (value < 100) {
      color = Colors.yellow;
    } else {
      color = Colors.green;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 150,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMovesTab(PokemonSummary pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildMoveSection('Aprendidos por Nível', pokemon.movesByLevel),
          _buildMoveSection('Aprendidos por TM/HM', pokemon.movesByTM),
        ],
      ),
    );
  }

  Widget _buildMoveSection(String title, List<Move> moves) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        ...moves.map((move) => ListTile(
              title: Text(
                move.levelLearned != null
                    ? '${move.name} (Nv. ${move.levelLearned})'
                    : move.name,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            )),
      ],
    );
  }

  Widget _buildEvolutionsTab(PokemonSummary pokemon) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Cadeia Evolutiva',
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (pokemon.evolutions.isEmpty)
            const Text(
              'Este Pokémon não evolui.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          if (pokemon.evolutions.isNotEmpty)
            _buildEvolutionTree(pokemon.evolutions),
        ],
      ),
    );
  }

  Widget _buildEvolutionTree(List<Evolution> evolutions) {
    return Column(
      children: evolutions
          .map((evolution) => _buildEvolutionChain(evolution))
          .toList(),
    );
  }

  Widget _buildEvolutionChain(Evolution evolution) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          _buildEvolutionCard(evolution),
          if (evolution.nextEvolutions.isNotEmpty) ...[
            const Icon(Icons.arrow_downward, color: Colors.white54, size: 32),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: evolution.nextEvolutions
                  .map((nextEvo) => _buildEvolutionChain(nextEvo))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEvolutionCard(Evolution evolution) {
    final gifUrl = _isShiny ? evolution.shinyGifUrl : evolution.gifUrl;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[850]!.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Image.network(
              gifUrl,
              fit: BoxFit.contain, // Exibe a imagem completa sem cortes
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.red[800],
                  ),
                );
              },
              errorBuilder: (_, __, ___) => Icon(
                Icons.error_outline,
                color: Colors.grey[800],
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            evolution.name,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (evolution.trigger != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                evolution.trigger!,
                style: TextStyle(
                  color: Colors.grey[300], // Cor mais neutra
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
