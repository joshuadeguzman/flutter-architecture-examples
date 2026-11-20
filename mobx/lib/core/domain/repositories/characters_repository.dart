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
  Future<List<Character>> getCharacters({bool forceRefresh = false});
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
      final cached = await localStore.getCharacters();
      if (cached.isNotEmpty) return cached;
    }

    try {
      final fresh = await remoteStore.getCharacters();
      await localStore.saveCharacters(fresh);
      return fresh;
    } catch (_) {
      // Offline or the API is down. Fall back to the cache if we have one.
      final cached = await localStore.getCharacters();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }
}
