import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:characters_repository/characters_repository.dart';
import 'package:example_bloc_advanced/characters/characters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class MockCharactersRepository extends Mock implements CharactersRepository {}

const debounce = Duration(milliseconds: 50);

void main() {
  late MockCharactersRepository repository;

  setUp(() => repository = MockCharactersRepository());

  CharactersBloc build() => CharactersBloc(
    charactersRepository: repository,
    searchDebounce: debounce,
  );

  test('starts in the initial state', () {
    expect(build().state, const CharactersState());
  });

  group(CharactersStarted, () {
    blocTest<CharactersBloc, CharactersState>(
      'emits loading then success',
      setUp: () =>
          when(() => repository.getCharacters())
              .thenAnswer((_) async => [rick, morty]),
      build: build,
      act: (bloc) => bloc.add(const CharactersStarted()),
      expect: () => const [
        CharactersState(status: CharactersStatus.loading),
        CharactersState(
          status: CharactersStatus.success,
          characters: [rick, morty],
        ),
      ],
    );

    blocTest<CharactersBloc, CharactersState>(
      'emits failure when the repository throws',
      setUp: () =>
          when(() => repository.getCharacters())
              .thenThrow(Exception('offline')),
      build: build,
      act: (bloc) => bloc.add(const CharactersStarted()),
      expect: () => const [
        CharactersState(status: CharactersStatus.loading),
        CharactersState(status: CharactersStatus.failure),
      ],
    );

    blocTest<CharactersBloc, CharactersState>(
      'retries the current search',
      setUp: () =>
          when(() => repository.searchCharacters('rick'))
              .thenAnswer((_) async => [rick]),
      build: build,
      seed: () => const CharactersState(
        status: CharactersStatus.failure,
        query: 'rick',
      ),
      act: (bloc) => bloc.add(const CharactersStarted()),
      expect: () => const [
        CharactersState(status: CharactersStatus.loading, query: 'rick'),
        CharactersState(
          status: CharactersStatus.success,
          characters: [rick],
          query: 'rick',
        ),
      ],
    );
  });

  group(CharactersRefreshed, () {
    blocTest<CharactersBloc, CharactersState>(
      'skips the cache and keeps the list visible',
      setUp: () =>
          when(() => repository.getCharacters(forceRefresh: true))
              .thenAnswer((_) async => [morty]),
      build: build,
      seed: () => const CharactersState(
        status: CharactersStatus.success,
        characters: [rick],
      ),
      act: (bloc) => bloc.add(const CharactersRefreshed()),
      expect: () => const [
        CharactersState(status: CharactersStatus.success, characters: [morty]),
      ],
    );

    blocTest<CharactersBloc, CharactersState>(
      'keeps the old list when the refresh fails',
      setUp: () =>
          when(() => repository.getCharacters(forceRefresh: true))
              .thenThrow(Exception('offline')),
      build: build,
      seed: () => const CharactersState(
        status: CharactersStatus.success,
        characters: [rick],
      ),
      act: (bloc) => bloc.add(const CharactersRefreshed()),
      expect: () => const [
        CharactersState(status: CharactersStatus.failure, characters: [rick]),
      ],
    );

    late Completer<List<Character>> pending;

    blocTest<CharactersBloc, CharactersState>(
      'ignores a second refresh while one is running',
      setUp: () {
        pending = Completer();
        when(() => repository.getCharacters(forceRefresh: true))
            .thenAnswer((_) => pending.future);
      },
      build: build,
      act: (bloc) async {
        bloc
          ..add(const CharactersRefreshed())
          ..add(const CharactersRefreshed());
        await Future<void>.delayed(Duration.zero);
        pending.complete([rick]);
      },
      verify: (_) =>
          verify(() => repository.getCharacters(forceRefresh: true)).called(1),
    );
  });

  group(CharactersSearchChanged, () {
    blocTest<CharactersBloc, CharactersState>(
      'waits for the user to stop typing and uses the latest text',
      setUp: () =>
          when(() => repository.searchCharacters(any()))
              .thenAnswer((_) async => [rick]),
      build: build,
      act: (bloc) => bloc
        ..add(const CharactersSearchChanged('r'))
        ..add(const CharactersSearchChanged('ri'))
        ..add(const CharactersSearchChanged(' rick ')),
      wait: debounce * 3,
      expect: () => const [
        CharactersState(status: CharactersStatus.loading, query: 'rick'),
        CharactersState(
          status: CharactersStatus.success,
          characters: [rick],
          query: 'rick',
        ),
      ],
      verify: (_) {
        verify(() => repository.searchCharacters('rick')).called(1);
        verifyNever(() => repository.searchCharacters('r'));
      },
    );

    blocTest<CharactersBloc, CharactersState>(
      'clears the list when a search fails',
      setUp: () =>
          when(() => repository.searchCharacters('x'))
              .thenThrow(Exception('offline')),
      build: build,
      seed: () => const CharactersState(
        status: CharactersStatus.success,
        characters: [rick],
      ),
      act: (bloc) => bloc.add(const CharactersSearchChanged('x')),
      wait: debounce * 3,
      expect: () => const [
        CharactersState(
          status: CharactersStatus.loading,
          characters: [rick],
          query: 'x',
        ),
        CharactersState(status: CharactersStatus.failure, query: 'x'),
      ],
    );
  });
}
