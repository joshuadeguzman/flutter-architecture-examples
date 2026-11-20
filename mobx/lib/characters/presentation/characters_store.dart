import 'package:mobx/mobx.dart';

import '../../core/data/models/character.dart';
import '../../core/domain/repositories/characters_repository.dart';

part 'characters_store.g.dart';

/// Holds the state of the characters screen.
///
/// Views observe the `@observable` fields and call the `@action` methods.
class CharactersStore = CharactersStoreBase with _$CharactersStore;

abstract class CharactersStoreBase with Store {
  CharactersStoreBase({required this.repository});

  final CharactersRepository repository;

  @observable
  List<Character> characters = const [];

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @action
  Future<void> load({bool forceRefresh = false}) async {
    // Ignore a second load while one is running, for example a pull to
    // refresh during the first load.
    if (isLoading) return;
    isLoading = true;
    errorMessage = null;
    try {
      characters = await repository.getCharacters(forceRefresh: forceRefresh);
    } catch (_) {
      errorMessage = 'Could not load characters. Check your connection.';
    } finally {
      isLoading = false;
    }
  }
}
