import 'package:example_mobx/core/data/local/characters_local_store.dart';
import 'package:example_mobx/core/data/models/character.dart';
import 'package:example_mobx/core/data/remote/characters_remote_store.dart';
import 'package:example_mobx/core/domain/repositories/characters_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const rick = Character(
  id: 1,
  name: 'Rick Sanchez',
  status: 'Alive',
  species: 'Human',
  imageUrl: 'https://example.com/1.jpeg',
  location: 'Citadel of Ricks',
);

const morty = Character(
  id: 2,
  name: 'Morty Smith',
  status: 'Alive',
  species: 'Human',
  imageUrl: 'https://example.com/2.jpeg',
  location: 'Citadel of Ricks',
);

class FakeRemoteStore implements CharactersRemoteStore {
  List<Character> characters = [rick, morty];
  bool fail = false;
  int calls = 0;

  @override
  Future<List<Character>> getCharacters() async {
    calls++;
    if (fail) throw Exception('offline');
    return characters;
  }
}

class FakeLocalStore implements CharactersLocalStore {
  List<Character> saved = [];
  bool failReads = false;
  bool failWrites = false;

  @override
  Future<List<Character>> getCharacters() async {
    if (failReads) throw StateError('cache is broken');
    return saved;
  }

  @override
  Future<void> saveCharacters(List<Character> characters) async {
    if (failWrites) throw StateError('disk is full');
    saved = characters;
  }
}

void main() {
  late FakeRemoteStore remote;
  late FakeLocalStore local;
  late LiveCharactersRepository repository;

  setUp(() {
    remote = FakeRemoteStore();
    local = FakeLocalStore();
    repository = LiveCharactersRepository(
      remoteStore: remote,
      localStore: local,
    );
  });

  test('fetches from the network and caches when the cache is empty', () async {
    final result = await repository.getCharacters();

    expect(result.map((c) => c.name), ['Rick Sanchez', 'Morty Smith']);
    expect(local.saved, hasLength(2));
    expect(remote.calls, 1);
  });

  test('returns the cache without calling the network', () async {
    local.saved = [rick];

    final result = await repository.getCharacters();

    expect(result.single.name, 'Rick Sanchez');
    expect(remote.calls, 0);
  });

  test('forceRefresh skips the cache', () async {
    local.saved = [rick];

    final result = await repository.getCharacters(forceRefresh: true);

    expect(result, hasLength(2));
    expect(remote.calls, 1);
  });

  test('a failed refresh throws, even with a cache', () async {
    local.saved = [rick];
    remote.fail = true;

    await expectLater(
      repository.getCharacters(forceRefresh: true),
      throwsException,
    );
  });

  test('a cache that cannot be written does not fail the load', () async {
    local.failWrites = true;

    final result = await repository.getCharacters();

    expect(result, hasLength(2));
  });

  test('a cache that cannot be read counts as empty', () async {
    local.failReads = true;

    final result = await repository.getCharacters();

    expect(result, hasLength(2));
    expect(remote.calls, 1);
  });

  test('throws when the network fails and there is no cache', () async {
    remote.fail = true;

    await expectLater(repository.getCharacters(), throwsException);
  });

  test('Character survives a JSON round trip', () {
    final copy = Character.fromJson(rick.toJson());

    expect(copy.id, rick.id);
    expect(copy.name, rick.name);
    expect(copy.location, rick.location);
  });

  test('Character reads string ids from GraphQL', () {
    final json = rick.toJson()..['id'] = '1';

    expect(Character.fromJson(json).id, 1);
  });
}
