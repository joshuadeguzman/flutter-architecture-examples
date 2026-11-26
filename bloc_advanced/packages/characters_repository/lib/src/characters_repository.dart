import 'package:characters_repository/src/characters_cache.dart';
import 'package:characters_repository/src/models/character.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';

/// The single source of truth for characters.
///
/// It combines the API and the cache, and turns API models into domain
/// models. Blocs depend on this class, never on the API client directly.
class CharactersRepository {
  /// Creates a [CharactersRepository].
  CharactersRepository({
    required RickAndMortyApiClient apiClient,
    required CharactersCache cache,
  }) : _apiClient = apiClient,
       _cache = cache;

  final RickAndMortyApiClient _apiClient;
  final CharactersCache _cache;

  /// Returns cached characters if there are any. Otherwise fetches them and
  /// caches them.
  ///
  /// Set [forceRefresh] to skip the cache. Throws if the network request
  /// fails, so a failed refresh is reported instead of quietly returning the
  /// same cached characters.
  Future<List<Character>> getCharacters({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _readCache();
      if (cached.isNotEmpty) return cached;
    }

    final characters = _toDomain(await _apiClient.getCharacters());
    try {
      await _cache.write(characters);
    } on Object {
      // The cache is only a speed-up. Failing to write it, for example with
      // a HiveError, isn't fatal.
    }
    return characters;
  }

  /// Searches characters by name. Search results are not cached.
  Future<List<Character>> searchCharacters(String name) async {
    return _toDomain(await _apiClient.getCharacters(name: name));
  }

  Future<List<Character>> _readCache() async {
    try {
      return await _cache.read();
    } on Object {
      // A broken cache counts as an empty one.
      return const [];
    }
  }

  List<Character> _toDomain(List<ApiCharacter> characters) => [
    for (final c in characters)
      Character(
        id: c.id,
        name: c.name,
        status: switch (c.status) {
          'Alive' => CharacterStatus.alive,
          'Dead' => CharacterStatus.dead,
          _ => CharacterStatus.unknown,
        },
        species: c.species,
        imageUrl: c.image,
        location: c.locationName,
      ),
  ];
}
