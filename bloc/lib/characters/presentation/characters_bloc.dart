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
    on<CharactersRefreshed>(_onRefreshed, transformer: droppable());
    // Wait until the user stops typing, then search with the latest text.
    on<CharactersSearchChanged>(
      _onSearchChanged,
      transformer: debounceRestartable(searchDebounce),
    );
  }

  final CharactersRepository _repository;

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
    // Read the query before emitting, so a retry repeats the failed search.
    final query = _currentQuery;
    emit(const CharactersLoadInProgress());
    await _load(emit, query: query);
  }

  Future<void> _onRefreshed(
    CharactersRefreshed event,
    Emitter<CharactersState> emit,
  ) {
    // Keep showing the current list while the refresh runs.
    return _load(emit, query: _currentQuery, forceRefresh: true);
  }

  Future<void> _onSearchChanged(
    CharactersSearchChanged event,
    Emitter<CharactersState> emit,
  ) async {
    emit(const CharactersLoadInProgress());
    await _load(emit, query: event.query.trim());
  }

  Future<void> _load(
    Emitter<CharactersState> emit, {
    required String query,
    bool forceRefresh = false,
  }) async {
    try {
      final characters = query.isEmpty
          ? await _repository.getCharacters(forceRefresh: forceRefresh)
          : await _repository.searchCharacters(query);
      emit(CharactersLoadSuccess(characters, query: query));
    } catch (_) {
      emit(CharactersLoadFailure(query: query));
    }
  }
}
