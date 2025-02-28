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
    return text
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Future<PokemonSummary> _fetchPokemonDetails(PokemonSummary pokemon) async {
    try {
      final response = await _dio.get(pokemon.url);
      if (response.statusCode != 200) throw Exception('Failed to load details');

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
      throw Exception('Error: ${e.toString()}');
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
      'special-defense': 'SDF',
      'speed': 'SPD'
    };
    return statNames[rawName] ?? _capitalize(rawName.replaceAll('-', ' '));
  }

  List<Move> _processMoves(List<dynamic> moves, String method) {
    final uniqueMoves = <String, Move>{};

    for (final move in moves) {
      final moveName = _capitalize(move['move']['name'] as String);
      final details = (move['version_group_details'] as List)
          .where((d) => d['move_learn_method']['name'] == method);

      for (final detail in details) {
        if (!uniqueMoves.containsKey(moveName)) {
          uniqueMoves[moveName] = Move(
            name: moveName,
            levelLearned:
                method == 'level-up' ? detail['level_learned_at'] as int : null,
          );
        }
      }
    }

    return uniqueMoves.values.toList()
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
              border: Border.all(
                color: Colors.red[800]!,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.1,
                  child: Switch(
                    value: _isShiny,
                    onChanged: (value) {
                      setState(() {
                        _isShiny = value;
                      });
                    },
                    thumbIcon: WidgetStateProperty.resolveWith(
                      (state) {
                        if (state.contains(WidgetState.selected)) {
                          return Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 20,
                          );
                        } else {
                          return Icon(
                            Icons.star_border_outlined,
                            color: Colors.yellow,
                            size: 20,
                          );
                        }
                      },
                    ),
                    trackOutlineColor: WidgetStateProperty.resolveWith(
                      (state) {
                        if (state.contains(WidgetState.selected)) {
                          return Colors.yellow;
                        } else {
                          return Colors.transparent;
                        }
                      },
                    ),
                    activeColor: Colors.grey,
                    activeTrackColor: Colors.grey[800],
                    inactiveThumbColor: Colors.grey[400],
                    inactiveTrackColor: Colors.grey[800],
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
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found'));
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
                          Tab(text: 'Stats'),
                          Tab(text: 'Moves'),
                          Tab(text: 'Evolutions'),
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
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    gifUrl,
                    width: 150,
                    height: 150,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.white, size: 50),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: _buildAbilityButton(pokemon),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDescription('Weight', pokemon.weight, 'kg'),
              _buildDescription('Height', pokemon.height, 'm'),
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
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (context) => SizedBox(
          height: 200,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Abilities',
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
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          FontAwesomeIcons.meteor,
          color: Colors.white,
          size: 22,
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
            'Base Stats',
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ...pokemon.stats.entries.map((e) => _buildStatRow(e.key, e.value)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, int value) {
    const double iconSize = 26;
    const double labelFontSize = 9;

    final Map<String, Color> typeColors = {
      'HP': Colors.red[400]!,
      'ATK': Colors.orange[400]!,
      'DEF': Colors.blue[400]!,
      'STK': Colors.red[800]!,
      'SDF': Colors.purple[400]!,
      'SPD': Colors.yellow[600]!,
    };

    final Map<String, IconData> typeIcons = {
      'HP': FontAwesomeIcons.heartPulse,
      'ATK': FontAwesomeIcons.handFist,
      'DEF': FontAwesomeIcons.shieldHalved,
      'STK': FontAwesomeIcons.fireFlameCurved,
      'SDF': FontAwesomeIcons.shieldVirus,
      'SPD': FontAwesomeIcons.bolt,
    };

    final Color dynamicColor = value < 50
        ? Colors.red[400]!
        : value < 100
            ? Colors.orange[400]!
            : Colors.green[400]!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(typeIcons[label]!, size: iconSize, color: typeColors[label]),
              const SizedBox(height: 2),
              Text(
                '($label)',
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: typeColors[label]!.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: value / 150,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation(dynamicColor),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: dynamicColor,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 1.5,
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(1, 1),
                  )
                ],
              ),
            ),
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
          _buildMoveSection('Level Up Moves', pokemon.movesByLevel),
          _buildMoveSection('TM/HM Moves', pokemon.movesByTM),
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
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        ...moves.map((move) => ListTile(
              title: Text(
                move.levelLearned != null
                    ? '${move.name} (Lv. ${move.levelLearned})'
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
            'Evolution',
            style: TextStyle(
                fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (pokemon.evolutions.isEmpty)
            const Text(
              'This Pokémon does not evolve.',
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Image.network(
              gifUrl,
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
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
              errorBuilder: (context, error, stackTrace) => Icon(
                // Corrigido aqui
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
                  color: Colors.grey[300],
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
