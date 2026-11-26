import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/models/character.dart';
import '../../core/providers.dart';

/// Holds the state of the characters screen.
///
/// The state is an [AsyncValue], which already covers loading and error states.
class CharactersNotifier extends AsyncNotifier<List<Character>> {
  @override
  Future<List<Character>> build() {
    return ref.watch(charactersRepositoryProvider).getCharacters();
  }

  /// Fetches fresh characters, skipping the cache.
  ///
  /// If it fails, the current list stays and the error is rethrown, so the
  /// view can say that the refresh failed.
  Future<void> refresh() async {
    final fresh = await ref
        .read(charactersRepositoryProvider)
        .getCharacters(forceRefresh: true);
    // The screen may have closed while the request ran.
    if (ref.mounted) state = AsyncData(fresh);
  }
}

final charactersProvider =
    AsyncNotifierProvider<CharactersNotifier, List<Character>>(
      CharactersNotifier.new,
    );
