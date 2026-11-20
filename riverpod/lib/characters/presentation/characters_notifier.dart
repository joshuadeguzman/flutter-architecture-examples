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
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref
          .read(charactersRepositoryProvider)
          .getCharacters(forceRefresh: true),
    );
  }
}

final charactersProvider =
    AsyncNotifierProvider<CharactersNotifier, List<Character>>(
      CharactersNotifier.new,
    );
