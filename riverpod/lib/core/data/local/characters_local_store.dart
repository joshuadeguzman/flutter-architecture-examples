import 'dart:convert';

import 'package:hive_ce/hive.dart';

import '../models/character.dart';

/// Reads and writes characters on the device.
abstract interface class CharactersLocalStore {
  Future<List<Character>> getCharacters();

  Future<void> saveCharacters(List<Character> characters);
}

/// Stores characters as a JSON string in a Hive box.
class HiveCharactersLocalStore implements CharactersLocalStore {
  HiveCharactersLocalStore(this._box);

  static const boxName = 'characters';
  static const _key = 'characters';

  final Box<String> _box;

  @override
  Future<List<Character>> getCharacters() async {
    final json = _box.get(_key);
    if (json == null) return const [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return [
        for (final item in list)
          Character.fromJson(item as Map<String, dynamic>),
      ];
    } catch (_) {
      // The cache is unreadable, for example after a model change. Drop it
      // so the next load fetches fresh data instead of failing every time.
      await _box.delete(_key);
      return const [];
    }
  }

  @override
  Future<void> saveCharacters(List<Character> characters) {
    final json = jsonEncode([for (final c in characters) c.toJson()]);
    return _box.put(_key, json);
  }
}
