import '../../data/local/characters_local_store.dart';
import '../../data/models/character.dart';
import '../../data/remote/characters_remote_store.dart';

/// The single source of truth for characters.
///
/// The presentation layer only talks to this repository. It never knows
/// whether the data came from the network or the device.
abstract interface class CharactersRepository {
  /// Returns cached characters if there are any. Otherwise fetches them from
  /// the network and caches them.
  ///
  /// Set [forceRefresh] to skip the cache, for example on pull to refresh.
  /// Throws if the network request fails.
  Future<List<Character>> getCharacters({bool forceRefresh = false});

  /// Searches characters by name. Always uses the network, since search
  /// results are not cached.
  Future<List<Character>> searchCharacters(String name);
}

class LiveCharactersRepository implements CharactersRepository {
  LiveCharactersRepository({
    required this.remoteStore,
    required this.localStore,
  });

  final CharactersRemoteStore remoteStore;
  final CharactersLocalStore localStore;

  @override
  Future<List<Character>> getCharacters({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _readCache();
      if (cached.isNotEmpty) return cached;
    }

    // If this fails, the error reaches the caller, so a failed refresh is
    // reported instead of quietly showing the same cached list.
    final fresh = await remoteStore.getCharacters();
    try {
      await localStore.saveCharacters(fresh);
    } catch (_) {
      // The cache is only a speed-up. Failing to write it isn't fatal.
    }
    return fresh;
  }

  Future<List<Character>> _readCache() async {
    try {
      return await localStore.getCharacters();
    } catch (_) {
      // A broken cache counts as an empty one.
      return const [];
    }
  }

  @override
  Future<List<Character>> searchCharacters(String name) {
    return remoteStore.getCharacters(name: name);
  }
}
