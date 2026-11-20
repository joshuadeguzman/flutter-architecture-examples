import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:characters_repository/characters_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

part 'characters_event.dart';
part 'characters_state.dart';

/// Waits for [duration] of quiet, then handles only the latest event and
/// cancels any search that is still running.
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) =>
      restartable<E>().call(events.debounce(duration), mapper);
}

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  CharactersBloc({
    required CharactersRepository charactersRepository,
    Duration searchDebounce = const Duration(milliseconds: 300),
  }) : _charactersRepository = charactersRepository,
       super(const CharactersState()) {
    on<CharactersStarted>(_onStarted, transformer: droppable());
    on<CharactersRefreshed>(_onRefreshed, transformer: droppable());
    on<CharactersSearchChanged>(
      _onSearchChanged,
      transformer: debounceRestartable(searchDebounce),
    );
  }

  final CharactersRepository _charactersRepository;

  Future<void> _onStarted(
    CharactersStarted event,
    Emitter<CharactersState> emit,
  ) async {
    emit(state.copyWith(status: CharactersStatus.loading));
    await _load(emit, query: state.query);
  }

  Future<void> _onRefreshed(
    CharactersRefreshed event,
    Emitter<CharactersState> emit,
  ) async {
    // Mark the refresh as running. This also makes sure the final state is
    // new, so the view always sees the refresh finish, even when the data
    // didn't change.
    emit(state.copyWith(status: CharactersStatus.refreshing));
    await _load(
      emit,
      query: state.query,
      forceRefresh: true,
      // Each transformer only controls its own event type, so a search can
      // run while a refresh does. Drop the refresh result if anything else
      // changed the screen in the meantime.
      shouldEmit: () => state.status == CharactersStatus.refreshing,
    );
  }

  Future<void> _onSearchChanged(
    CharactersSearchChanged event,
    Emitter<CharactersState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(status: CharactersStatus.loading, query: query));
    // A failed search clears the list, so old results don't show under the
    // new search text.
    await _load(emit, query: query, keepCharactersOnFailure: false);
  }

  Future<void> _load(
    Emitter<CharactersState> emit, {
    required String query,
    bool forceRefresh = false,
    bool keepCharactersOnFailure = true,
    bool Function()? shouldEmit,
  }) async {
    CharactersState next;
    try {
      final characters = query.isEmpty
          ? await _charactersRepository.getCharacters(
              forceRefresh: forceRefresh,
            )
          : await _charactersRepository.searchCharacters(query);
      next = state.copyWith(
        status: CharactersStatus.success,
        characters: characters,
        query: query,
      );
    } on Exception {
      // Keep the current characters so the screen can still show them.
      next = state.copyWith(
        status: CharactersStatus.failure,
        query: query,
        characters: keepCharactersOnFailure ? null : const [],
      );
    }
    if (shouldEmit == null || shouldEmit()) emit(next);
  }
}
