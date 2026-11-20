import 'dart:convert';

import 'package:characters_repository/characters_repository.dart';
import 'package:hive_ce/hive.dart';

/// Stores characters as JSON in a Hive box.
///
/// This is the app's implementation of [CharactersCache]. The repository
/// package only knows the interface.
class HiveCharactersCache implements CharactersCache {
  HiveCharactersCache(this._box);

  static const boxName = 'characters';
  static const _key = 'characters';

  final Box<String> _box;

  @override
  Future<List<Character>> read() async {
    final json = _box.get(_key);
    if (json == null) return const [];

    try {
      final list = jsonDecode(json) as List<dynamic>;
      return [
        for (final item in list)
          Character.fromJson(item as Map<String, dynamic>),
      ];
    } on Object {
      // The cache is unreadable, for example after a model change. Drop it
      // so the next load fetches fresh data.
      await _box.delete(_key);
      return const [];
    }
  }

  @override
  Future<void> write(List<Character> characters) {
    return _box.put(_key, jsonEncode([for (final c in characters) c.toJson()]));
  }
}
