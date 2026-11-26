import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../core/domain/repositories/characters_repository.dart';
import 'characters_event.dart';
import 'characters_state.dart';

/// Waits for [duration] of quiet, then handles only the latest event and
/// cancels any search that is still running.
EventTransformer<E> debounceRestartable<E>(Duration duration) {
  return (events, mapper) =>
      restartable<E>().call(events.debounce(duration), mapper);
}

/// Turns events from the characters screen into states.
///
/// Unlike a Cubit, every change is caused by an event, so the BlocObserver
/// can log why the state changed. Each event also picks how it handles
/// overlapping events.
class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  CharactersBloc(
    this._repository, {
    Duration searchDebounce = const Duration(milliseconds: 300),
  }) : super(const CharactersInitial()) {
    // Ignore taps while a load is already running.
    on<CharactersStarted>(_onStarted, transformer: droppable());
    on<CharactersRefreshed>(_onRefreshed);
    // Wait until the user stops typing, then search with the latest text.
    on<CharactersSearchChanged>(
      _onSearchChanged,
      transformer: debounceRestartable(searchDebounce),
    );
  }

  final CharactersRepository _repository;

  /// Counts loads. Each transformer only controls its own event type, so a
  /// search can run while a refresh or a retry does. Every load takes the
  /// next number, and only the newest load may change the screen.
  var _latestLoad = 0;

  /// The search the screen is showing, or an empty string for the full list.
  String get _currentQuery => switch (state) {
    CharactersLoadSuccess(:final query) => query,
    CharactersLoadFailure(:final query) => query,
    _ => '',
  };

  Future<void> _onStarted(
    CharactersStarted event,
    Emitter<CharactersState> emit,
  ) async {
    final load = ++_latestLoad;
    // Read the query before emitting, so a retry repeats the failed search.
    final query = _currentQuery;
    emit(const CharactersLoadInProgress());
    final next = await _load(query: query);
    if (load == _latestLoad) emit(next);
  }

  Future<void> _onRefreshed(
    CharactersRefreshed event,
    Emitter<CharactersState> emit,
  ) async {
    try {
      final current = state;
      if (current is! CharactersLoadSuccess) return;

      final load = ++_latestLoad;
      // Keep showing the list while the refresh runs.
      emit(
        CharactersLoadSuccess(
          current.characters,
          query: current.query,
          isRefreshing: true,
        ),
      );
      final next = await _load(query: current.query, forceRefresh: true);
      if (load != _latestLoad) return;

      if (next is CharactersLoadFailure) {
        // Keep the list on screen, and tell the view the refresh failed.
        emit(CharactersLoadSuccess(current.characters, query: current.query));
        event.completer?.completeError(const RefreshFailure());
      } else {
        emit(next);
      }
    } finally {
      // Always stop the spinner, even if a newer load replaced this one.
      if (event.completer case final c? when !c.isCompleted) c.complete();
    }
  }

  Future<void> _onSearchChanged(
    CharactersSearchChanged event,
    Emitter<CharactersState> emit,
  ) async {
    final query = event.query.trim();
    // Typing a space after "rick" doesn't need a new search.
    if (state case CharactersLoadSuccess(query: final shown)
        when shown == query) {
      return;
    }

    final load = ++_latestLoad;
    emit(const CharactersLoadInProgress());
    final next = await _load(query: query);
    if (load == _latestLoad) emit(next);
  }

  Future<CharactersState> _load({
    required String query,
    bool forceRefresh = false,
  }) async {
    try {
      final characters = query.isEmpty
          ? await _repository.getCharacters(forceRefresh: forceRefresh)
          : await _repository.searchCharacters(query);
      return CharactersLoadSuccess(characters, query: query);
    } catch (error, stackTrace) {
      // Report it to the BlocObserver, then show the error screen.
      addError(error, stackTrace);
      return CharactersLoadFailure(query: query);
    }
  }
}

/// Completes a [CharactersRefreshed.completer] when a refresh fails.
class RefreshFailure implements Exception {
  const RefreshFailure();
}
