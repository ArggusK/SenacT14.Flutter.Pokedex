import 'package:dio/dio.dart';
import 'package:poke_dex/models/pokemon_summary.dart';
import 'package:poke_dex/string_extension.dart';

class PokemonService {
  final Dio _dio = Dio();

  Future<PokemonSummary> fetchPokemonDetails(PokemonSummary pokemon) async {
    try {
      final response = await _dio.get(pokemon.url);
      if (response.statusCode != 200) throw Exception('Failed to load details');

      final data = response.data;
      final speciesResponse = await _dio.get(data['species']['url']);
      final speciesData = speciesResponse.data;

      final evolutionChainUrl =
          speciesData['evolution_chain']?['url']?.toString();
      if (evolutionChainUrl == null)
        throw Exception('Evolution chain not available');

      return PokemonSummary(
        name: pokemon.name,
        url: pokemon.url,
        imageUrl: pokemon.imageUrl,
        shinyImageUrl: pokemon.shinyImageUrl,
        gifUrl: pokemon.gifUrl,
        shinyGifUrl: pokemon.shinyGifUrl,
        types: _processTypes(data['types']),
        generation: speciesData['generation']['name'].toString().capitalize(),
        abilities: _processAbilities(data['abilities']),
        weight: (data['weight'] as int) / 10,
        height: (data['height'] as int) / 10,
        stats: _processStats(data['stats']),
        movesByLevel: _processMoves(data['moves'], 'level-up'),
        movesByTM: _processMoves(data['moves'], 'machine'),
        evolutions: await _fetchEvolutionChain(evolutionChainUrl),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Error: ${e.toString()}');
    }
  }

  Future<List<Evolution>> _fetchEvolutionChain(String url) async {
    try {
      final response = await _dio.get(url);
      final chainData = response.data['chain'];
      if (chainData == null) return [];

      final List<Evolution> evolutions = [];
      await _parseEvolutionChain(chainData, evolutions);
      return evolutions;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Failed to parse evolution chain: ${e.toString()}');
    }
  }

  Future<void> _parseEvolutionChain(
    dynamic chainData,
    List<Evolution> evolutions, {
    String? previousTrigger,
  }) async {
    try {
      final species = chainData['species'];
      if (species == null || species['name'] == null) return;

      final evolutionDetails = chainData['evolution_details'] ?? [];
      final trigger = _getTrigger(evolutionDetails);

      final pokemonNumber =
          species['url'].toString().split('/').reversed.elementAt(1);
      final evolution = Evolution.fromPokemonNumber(
        pokemonNumber,
        species['name'].toString().capitalize(),
      ).copyWith(trigger: previousTrigger ?? trigger);

      if (!evolutions.any((e) => e.name == evolution.name)) {
        evolutions.add(evolution);
      }

      final evolvesToList = chainData['evolves_to'] as List<dynamic>? ?? [];
      for (final nextEvolution in evolvesToList) {
        final nextTrigger =
            _getTrigger(nextEvolution['evolution_details'] ?? []);
        await _parseEvolutionChain(
          nextEvolution,
          evolution.nextEvolutions,
          previousTrigger: nextTrigger,
        );
      }
    } catch (e) {
      throw Exception('Error parsing evolution chain: ${e.toString()}');
    }
  }

  String? _getTrigger(List<dynamic> details) {
    if (details.isEmpty) return null;
    final d = details.first;

    String trigger = '';
    if (d['item'] != null) {
      trigger =
          'Usar ${(d['item']['name'] as String).replaceAll('-', ' ').capitalize()}';
    } else if (d['min_level'] != null) {
      trigger = 'Nível ${d['min_level']}';
    } else if (d['min_happiness'] != null) {
      trigger = 'Felicidade ${d['min_happiness']}';
    } else if (d['time_of_day']?.toString().isNotEmpty == true) {
      trigger = 'À ${d['time_of_day']}'.capitalize();
    } else if (d['known_move_type'] != null) {
      trigger =
          'Saber ${(d['known_move_type']['name'] as String).capitalize()}';
    } else if (d['trigger']['name'] == 'trade') {
      trigger = 'Troca';
    } else {
      trigger =
          (d['trigger']['name'].toString().replaceAll('-', ' ').capitalize());
    }

    return trigger.isNotEmpty ? trigger : null;
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timeout. Check your internet');
      case DioExceptionType.receiveTimeout:
        return Exception('Server response timeout');
      case DioExceptionType.sendTimeout:
        return Exception('Request send timeout');
      case DioExceptionType.badResponse:
        return Exception('Invalid server response: ${e.response?.statusCode}');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      case DioExceptionType.connectionError:
        return Exception('Connection error. Check network');
      case DioExceptionType.unknown:
        return Exception('Network error: ${e.message}');
      default:
        return Exception('Unknown error occurred');
    }
  }

  List<String> _processTypes(List<dynamic> types) {
    return types
        .map((t) => (t['type']['name'] as String).toUpperCase())
        .toList();
  }

  List<String> _processAbilities(List<dynamic> abilities) {
    return abilities
        .map((a) => (a['ability']['name'] as String).capitalize())
        .toList();
  }

  Map<String, int> _processStats(List<dynamic> stats) {
    final result = <String, int>{};
    for (final stat in stats) {
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
    return statNames[rawName] ?? rawName.replaceAll('-', ' ').capitalize();
  }

  List<Move> _processMoves(List<dynamic> moves, String method) {
    final uniqueMoves = <String, Move>{};
    for (final move in moves) {
      final moveName = (move['move']['name'] as String).capitalize();
      final moveUrl = move['move']['url'] as String;
      final details = (move['version_group_details'] as List)
          .where((d) => d['move_learn_method']['name'] == method);

      for (final detail in details) {
        uniqueMoves[moveName] = Move(
          name: moveName,
          levelLearned:
              method == 'level-up' ? detail['level_learned_at'] as int : null,
          url: moveUrl,
        );
      }
    }
    return uniqueMoves.values.toList()
      ..sort((a, b) => (a.levelLearned ?? 0).compareTo(b.levelLearned ?? 0));
  }
}
