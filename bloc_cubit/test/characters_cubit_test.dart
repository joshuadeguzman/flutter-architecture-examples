import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:example_bloc_cubit/characters/presentation/characters_cubit.dart';
import 'package:example_bloc_cubit/characters/presentation/characters_state.dart';
import 'package:example_bloc_cubit/core/data/models/character.dart';
import 'package:example_bloc_cubit/core/domain/repositories/characters_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'characters_repository_test.dart' show rick, morty;

class MockCharactersRepository extends Mock implements CharactersRepository {}

void main() {
  late MockCharactersRepository repository;

  setUp(() => repository = MockCharactersRepository());

  test('starts in the initial state', () {
    expect(CharactersCubit(repository).state, const CharactersState());
  });

  blocTest<CharactersCubit, CharactersState>(
    'emits loading then success with the characters',
    setUp: () =>
        when(() => repository.getCharacters())
            .thenAnswer((_) async => [rick, morty]),
    build: () => CharactersCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const CharactersState(status: CharactersStatus.loading),
      const CharactersState(
        status: CharactersStatus.success,
        characters: [rick, morty],
      ),
    ],
  );

  blocTest<CharactersCubit, CharactersState>(
    'emits failure when the repository throws',
    setUp: () =>
        when(() => repository.getCharacters()).thenThrow(Exception('offline')),
    build: () => CharactersCubit(repository),
    act: (cubit) => cubit.load(),
    expect: () => [
      const CharactersState(status: CharactersStatus.loading),
      const CharactersState(status: CharactersStatus.failure),
    ],
  );

  blocTest<CharactersCubit, CharactersState>(
    'keeps the old list while refreshing',
    setUp: () =>
        when(() => repository.getCharacters(forceRefresh: true))
            .thenAnswer((_) async => [morty]),
    build: () => CharactersCubit(repository),
    seed: () => const CharactersState(
      status: CharactersStatus.success,
      characters: [rick],
    ),
    act: (cubit) => cubit.load(forceRefresh: true),
    expect: () => [
      const CharactersState(
        status: CharactersStatus.loading,
        characters: [rick],
      ),
      const CharactersState(
        status: CharactersStatus.success,
        characters: [morty],
      ),
    ],
  );

  test('ignores a second load while one is running', () async {
    final pending = Completer<List<Character>>();
    when(() => repository.getCharacters()).thenAnswer((_) => pending.future);
    final cubit = CharactersCubit(repository);

    final first = cubit.load();
    await cubit.load();
    pending.complete([rick]);
    await first;

    verify(() => repository.getCharacters()).called(1);
    expect(cubit.state.characters, [rick]);
  });

  test('does not emit after it is closed', () async {
    final pending = Completer<List<Character>>();
    when(() => repository.getCharacters()).thenAnswer((_) => pending.future);
    final cubit = CharactersCubit(repository);

    final load = cubit.load();
    await cubit.close();
    pending.complete([rick]);

    await expectLater(load, completes);
  });
}
