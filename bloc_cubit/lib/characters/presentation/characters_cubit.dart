import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/domain/repositories/characters_repository.dart';
import 'characters_state.dart';

/// Holds the state of the characters screen.
///
/// A Cubit exposes plain methods instead of events. It's the simplest way to
/// use the bloc package, and a good place to start.
class CharactersCubit extends Cubit<CharactersState> {
  CharactersCubit(this._repository) : super(const CharactersState());

  final CharactersRepository _repository;

  Future<void> load({bool forceRefresh = false}) async {
    // Ignore a second load while one is running.
    if (state.status == CharactersStatus.loading) return;

    emit(state.copyWith(status: CharactersStatus.loading));
    CharactersState next;
    try {
      final characters = await _repository.getCharacters(
        forceRefresh: forceRefresh,
      );
      next = state.copyWith(
        status: CharactersStatus.success,
        characters: characters,
      );
    } catch (_) {
      next = state.copyWith(status: CharactersStatus.failure);
    }
    // The screen may have closed while the request ran.
    if (!isClosed) emit(next);
  }
}
