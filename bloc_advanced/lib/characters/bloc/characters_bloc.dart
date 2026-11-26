import 'dart:async';

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
    on<CharactersRefreshed>(_onRefreshed);
    on<CharactersSearchChanged>(
      _onSearchChanged,
      transformer: debounceRestartable(searchDebounce),
    );
  }

  final CharactersRepository _charactersRepository;

  /// Counts loads. Each transformer only controls its own event type, so a
  /// search can run while a refresh or a retry does. Every load takes the
  /// next number, and only the newest load may change the screen.
  var _latestLoad = 0;

  Future<void> _onStarted(
    CharactersStarted event,
    Emitter<CharactersState> emit,
  ) async {
    final load = ++_latestLoad;
    emit(state.copyWith(status: CharactersStatus.loading));
    final next = await _load(query: state.query);
    if (load == _latestLoad) emit(next);
  }

  Future<void> _onRefreshed(
    CharactersRefreshed event,
    Emitter<CharactersState> emit,
  ) async {
    try {
      final load = ++_latestLoad;
      emit(state.copyWith(status: CharactersStatus.refreshing));
      final next = await _load(query: state.query, forceRefresh: true);
      if (load == _latestLoad) emit(next);
    } finally {
      // Always stop the spinner, even if a newer load replaced this one.
      event.completer?.complete();
    }
  }

  Future<void> _onSearchChanged(
    CharactersSearchChanged event,
    Emitter<CharactersState> emit,
  ) async {
    final query = event.query.trim();
    // Typing a space after "rick" doesn't need a new search.
    if (query == state.query && state.status == CharactersStatus.success) {
      return;
    }

    final load = ++_latestLoad;
    emit(state.copyWith(status: CharactersStatus.loading, query: query));
    // A failed search clears the list, so old results don't show under the
    // new search text.
    final next = await _load(query: query, keepCharactersOnFailure: false);
    if (load == _latestLoad) emit(next);
  }

  Future<CharactersState> _load({
    required String query,
    bool forceRefresh = false,
    bool keepCharactersOnFailure = true,
  }) async {
    try {
      final characters = query.isEmpty
          ? await _charactersRepository.getCharacters(
              forceRefresh: forceRefresh,
            )
          : await _charactersRepository.searchCharacters(query);
      return state.copyWith(
        status: CharactersStatus.success,
        characters: characters,
        query: query,
      );
    } on Object catch (error, stackTrace) {
      // Catch errors too, not only exceptions, so the screen never stays
      // stuck on a spinner. addError reports it to the BlocObserver.
      addError(error, stackTrace);
      // Keep the current characters so the screen can still show them.
      return state.copyWith(
        status: CharactersStatus.failure,
        query: query,
        characters: keepCharactersOnFailure ? null : const [],
      );
    }
  }
}
