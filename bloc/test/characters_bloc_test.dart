import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:example_bloc/characters/presentation/characters_bloc.dart';
import 'package:example_bloc/characters/presentation/characters_event.dart';
import 'package:example_bloc/characters/presentation/characters_state.dart';
import 'package:example_bloc/core/data/models/character.dart';
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

  blocTest<CharactersBloc, CharactersState>(
    'a slow CharactersStarted does not replace a newer search',
    setUp: () {
      final slow = Completer<List<Character>>();
      when(() => repository.getCharacters()).thenAnswer((_) {
        Future<void>.delayed(debounce * 4, () => slow.complete([rick, morty]));
        return slow.future;
      });
      when(() => repository.searchCharacters('rick'))
          .thenAnswer((_) async => [rick]);
    },
    build: build,
    act: (bloc) => bloc
      ..add(const CharactersStarted())
      ..add(const CharactersSearchChanged('rick')),
    wait: debounce * 6,
    expect: () => [
      const CharactersLoadInProgress(),
      const CharactersLoadSuccess([rick], query: 'rick'),
    ],
  );

  blocTest<CharactersBloc, CharactersState>(
    'skips a search for the query already shown',
    build: build,
    seed: () => const CharactersLoadSuccess([rick], query: 'rick'),
    act: (bloc) => bloc.add(const CharactersSearchChanged('rick ')),
    wait: debounce * 2,
    expect: () => <CharactersState>[],
    verify: (_) => verifyNever(() => repository.searchCharacters(any())),
  );

  group('CharactersRefreshed', () {
    late Completer<List<Character>> pending;

    blocTest<CharactersBloc, CharactersState>(
      'skips the cache and keeps the list visible',
      setUp: () =>
          when(() => repository.getCharacters(forceRefresh: true))
              .thenAnswer((_) async => [morty]),
      build: build,
      seed: () => const CharactersLoadSuccess([rick]),
      act: (bloc) => bloc.add(const CharactersRefreshed()),
      expect: () => [
        const CharactersLoadSuccess([rick], isRefreshing: true),
        const CharactersLoadSuccess([morty]),
      ],
    );

    blocTest<CharactersBloc, CharactersState>(
      'still finishes when the data did not change',
      setUp: () =>
          when(() => repository.getCharacters(forceRefresh: true))
              .thenAnswer((_) async => [rick]),
      build: build,
      seed: () => const CharactersLoadSuccess([rick]),
      act: (bloc) => bloc.add(const CharactersRefreshed()),
      expect: () => [
        const CharactersLoadSuccess([rick], isRefreshing: true),
        const CharactersLoadSuccess([rick]),
      ],
    );

    test('completes the completer when it finishes', () async {
      when(() => repository.getCharacters(forceRefresh: true))
          .thenAnswer((_) async => [morty]);
      final bloc = build()..emit(const CharactersLoadSuccess([rick]));
      final done = Completer<void>();

      bloc.add(CharactersRefreshed(completer: done));

      await expectLater(done.future, completes);
      expect(bloc.state, const CharactersLoadSuccess([morty]));
      await bloc.close();
    });

    test('keeps the list and reports a failed refresh', () async {
      when(() => repository.getCharacters(forceRefresh: true))
          .thenThrow(Exception('offline'));
      final bloc = build()..emit(const CharactersLoadSuccess([rick]));
      final done = Completer<void>();

      bloc.add(CharactersRefreshed(completer: done));

      await expectLater(done.future, throwsA(isA<RefreshFailure>()));
      expect(bloc.state, const CharactersLoadSuccess([rick]));
      await bloc.close();
    });

    test('a second refresh wins, and both spinners stop', () async {
      final first = Completer<List<Character>>();
      final second = Completer<List<Character>>();
      final answers = [first, second];
      when(() => repository.getCharacters(forceRefresh: true))
          .thenAnswer((_) => answers.removeAt(0).future);
      final bloc = build()..emit(const CharactersLoadSuccess([rick]));
      final doneA = Completer<void>();
      final doneB = Completer<void>();

      bloc
        ..add(CharactersRefreshed(completer: doneA))
        ..add(CharactersRefreshed(completer: doneB));
      await Future<void>.delayed(Duration.zero);
      second.complete([morty]);
      await doneB.future;
      first.complete([rick, rick]);
      await doneA.future;

      expect(bloc.state, const CharactersLoadSuccess([morty]));
      await bloc.close();
    });

    test('stops the spinner when a search replaces it', () async {
      final pending = Completer<List<Character>>();
      when(() => repository.getCharacters(forceRefresh: true))
          .thenAnswer((_) => pending.future);
      when(() => repository.searchCharacters('rick'))
          .thenAnswer((_) async => [rick]);
      final bloc = build()..emit(const CharactersLoadSuccess([rick, morty]));
      final done = Completer<void>();

      bloc
        ..add(CharactersRefreshed(completer: done))
        ..add(const CharactersSearchChanged('rick'));
      await Future<void>.delayed(debounce * 3);
      pending.complete([rick, morty]);

      await expectLater(done.future, completes);
      expect(bloc.state, const CharactersLoadSuccess([rick], query: 'rick'));
      await bloc.close();
    });

    blocTest<CharactersBloc, CharactersState>(
      'is dropped when a search finishes while it runs',
      setUp: () {
        pending = Completer();
        when(() => repository.getCharacters(forceRefresh: true))
            .thenAnswer((_) => pending.future);
        when(() => repository.searchCharacters('rick'))
            .thenAnswer((_) async => [rick]);
      },
      build: build,
      seed: () => const CharactersLoadSuccess([rick, morty]),
      act: (bloc) async {
        bloc
          ..add(const CharactersRefreshed())
          ..add(const CharactersSearchChanged('rick'));
        await Future<void>.delayed(debounce * 3);
        pending.complete([rick, morty]);
      },
      wait: debounce,
      expect: () => [
        const CharactersLoadSuccess([rick, morty], isRefreshing: true),
        const CharactersLoadInProgress(),
        const CharactersLoadSuccess([rick], query: 'rick'),
      ],
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
        const CharactersLoadSuccess([rick], query: 'rick', isRefreshing: true),
        const CharactersLoadSuccess([rick, rick], query: 'rick'),
      ],
    );
  });
}
