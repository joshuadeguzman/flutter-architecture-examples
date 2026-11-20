import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:example_bloc/characters/presentation/characters_bloc.dart';
import 'package:example_bloc/characters/presentation/characters_event.dart';
import 'package:example_bloc/characters/presentation/characters_state.dart';
import 'package:example_bloc/core/domain/repositories/characters_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'characters_repository_test.dart' show rick, morty;

class MockCharactersRepository extends Mock implements CharactersRepository {}

const debounce = Duration(milliseconds: 50);

void main() {
  late MockCharactersRepository repository;

  setUp(() => repository = MockCharactersRepository());

  CharactersBloc build() =>
      CharactersBloc(repository, searchDebounce: debounce);

  blocTest<CharactersBloc, CharactersState>(
    'CharactersStarted loads the list',
    setUp: () =>
        when(() => repository.getCharacters())
            .thenAnswer((_) async => [rick, morty]),
    build: build,
    act: (bloc) => bloc.add(const CharactersStarted()),
    expect: () => [
      const CharactersLoadInProgress(),
      const CharactersLoadSuccess([rick, morty]),
    ],
  );

  blocTest<CharactersBloc, CharactersState>(
    'CharactersStarted emits a failure when the repository throws',
    setUp: () =>
        when(() => repository.getCharacters()).thenThrow(Exception('offline')),
    build: build,
    act: (bloc) => bloc.add(const CharactersStarted()),
    expect: () => [
      const CharactersLoadInProgress(),
      const CharactersLoadFailure(),
    ],
  );

  blocTest<CharactersBloc, CharactersState>(
    'retrying after a failed search runs the same search',
    setUp: () =>
        when(() => repository.searchCharacters('rick'))
            .thenAnswer((_) async => [rick]),
    build: build,
    seed: () => const CharactersLoadFailure(query: 'rick'),
    act: (bloc) => bloc.add(const CharactersStarted()),
    expect: () => [
      const CharactersLoadInProgress(),
      const CharactersLoadSuccess([rick], query: 'rick'),
    ],
  );

  blocTest<CharactersBloc, CharactersState>(
    'search waits for the user to stop typing and uses the latest text',
    setUp: () =>
        when(() => repository.searchCharacters(any()))
            .thenAnswer((_) async => [rick]),
    build: build,
    act: (bloc) => bloc
      ..add(const CharactersSearchChanged('r'))
      ..add(const CharactersSearchChanged('ri'))
      ..add(const CharactersSearchChanged('rick ')),
    wait: debounce * 3,
    expect: () => [
      const CharactersLoadInProgress(),
      const CharactersLoadSuccess([rick], query: 'rick'),
    ],
    verify: (_) {
      verify(() => repository.searchCharacters('rick')).called(1);
      verifyNever(() => repository.searchCharacters('r'));
    },
  );

  blocTest<CharactersBloc, CharactersState>(
    'clearing the search shows the full list again',
    setUp: () =>
        when(() => repository.getCharacters())
            .thenAnswer((_) async => [rick, morty]),
    build: build,
    seed: () => const CharactersLoadSuccess([rick], query: 'rick'),
    act: (bloc) => bloc.add(const CharactersSearchChanged('')),
    wait: debounce * 3,
    expect: () => [
      const CharactersLoadInProgress(),
      const CharactersLoadSuccess([rick, morty]),
    ],
  );

  group('CharactersRefreshed', () {
    late Completer<List<Never>> pending;

    blocTest<CharactersBloc, CharactersState>(
      'skips the cache and keeps the list visible',
      setUp: () =>
          when(() => repository.getCharacters(forceRefresh: true))
              .thenAnswer((_) async => [morty]),
      build: build,
      seed: () => const CharactersLoadSuccess([rick]),
      act: (bloc) => bloc.add(const CharactersRefreshed()),
      expect: () => [
        const CharactersLoadSuccess([morty]),
      ],
    );

    blocTest<CharactersBloc, CharactersState>(
      'ignores a second refresh while one is running',
      setUp: () {
        pending = Completer();
        when(() => repository.getCharacters(forceRefresh: true))
            .thenAnswer((_) => pending.future);
      },
      build: build,
      seed: () => const CharactersLoadSuccess([rick]),
      act: (bloc) async {
        bloc
          ..add(const CharactersRefreshed())
          ..add(const CharactersRefreshed());
        await Future<void>.delayed(Duration.zero);
        pending.complete([]);
      },
      verify: (_) {
        verify(() => repository.getCharacters(forceRefresh: true)).called(1);
      },
    );

    blocTest<CharactersBloc, CharactersState>(
      'refreshes the current search',
      setUp: () =>
          when(() => repository.searchCharacters('rick'))
              .thenAnswer((_) async => [rick, rick]),
      build: build,
      seed: () => const CharactersLoadSuccess([rick], query: 'rick'),
      act: (bloc) => bloc.add(const CharactersRefreshed()),
      expect: () => [
        const CharactersLoadSuccess([rick, rick], query: 'rick'),
      ],
    );
  });
}
