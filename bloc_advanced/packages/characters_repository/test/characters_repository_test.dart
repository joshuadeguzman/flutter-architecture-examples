import 'package:characters_repository/characters_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

class MockApiClient extends Mock implements RickAndMortyApiClient {}

class MockCache extends Mock implements CharactersCache {}

const apiRick = ApiCharacter(
  id: 1,
  name: 'Rick Sanchez',
  status: 'Alive',
  species: 'Human',
  image: 'https://example.com/1.jpeg',
  locationName: 'Citadel of Ricks',
);

const rick = Character(
  id: 1,
  name: 'Rick Sanchez',
  status: CharacterStatus.alive,
  species: 'Human',
  imageUrl: 'https://example.com/1.jpeg',
  location: 'Citadel of Ricks',
);

void main() {
  late MockApiClient api;
  late MockCache cache;
  late CharactersRepository repository;

  setUp(() {
    api = MockApiClient();
    cache = MockCache();
    repository = CharactersRepository(apiClient: api, cache: cache);
    when(() => cache.write(any())).thenAnswer((_) async {});
  });

  group('getCharacters', () {
    test('fetches, maps to the domain model and caches', () async {
      when(() => cache.read()).thenAnswer((_) async => []);
      when(() => api.getCharacters()).thenAnswer((_) async => [apiRick]);

      expect(await repository.getCharacters(), [rick]);
      verify(() => cache.write([rick])).called(1);
    });

    test('returns the cache without calling the API', () async {
      when(() => cache.read()).thenAnswer((_) async => [rick]);

      expect(await repository.getCharacters(), [rick]);
      verifyNever(() => api.getCharacters());
    });

    test('forceRefresh skips the cache', () async {
      when(() => api.getCharacters()).thenAnswer((_) async => [apiRick]);

      await repository.getCharacters(forceRefresh: true);

      verifyNever(() => cache.read());
      verify(() => api.getCharacters()).called(1);
    });

    test('falls back to the cache when the API fails', () async {
      when(() => cache.read()).thenAnswer((_) async => [rick]);
      when(() => api.getCharacters())
          .thenThrow(const CharactersRequestFailure(500));

      expect(await repository.getCharacters(forceRefresh: true), [rick]);
    });

    test('rethrows when the API fails and there is no cache', () async {
      when(() => cache.read()).thenAnswer((_) async => []);
      when(() => api.getCharacters())
          .thenThrow(const CharactersRequestFailure(500));

      await expectLater(
        repository.getCharacters(),
        throwsA(isA<CharactersRequestFailure>()),
      );
    });
  });

  test('searchCharacters maps statuses and does not cache', () async {
    when(() => api.getCharacters(name: 'x')).thenAnswer(
      (_) async => [
        apiRick,
        const ApiCharacter(
          id: 2,
          name: 'X',
          status: 'Dead',
          species: 'Alien',
          image: 'https://example.com/2.jpeg',
          locationName: 'unknown',
        ),
        const ApiCharacter(
          id: 3,
          name: 'Y',
          status: 'unknown',
          species: 'Robot',
          image: 'https://example.com/3.jpeg',
          locationName: 'unknown',
        ),
      ],
    );

    final result = await repository.searchCharacters('x');

    expect(result.map((c) => c.status), [
      CharacterStatus.alive,
      CharacterStatus.dead,
      CharacterStatus.unknown,
    ]);
    verifyNever(() => cache.write(any()));
  });

  test('Character survives a JSON round trip', () {
    expect(Character.fromJson(rick.toJson()), rick);
  });
}
