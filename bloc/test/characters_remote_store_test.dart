import 'dart:convert';

import 'package:example_bloc/core/data/remote/characters_remote_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('parses the REST response', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/character');
      return http.Response(
        jsonEncode({
          'results': [
            {
              'id': 1,
              'name': 'Rick Sanchez',
              'status': 'Alive',
              'species': 'Human',
              'image': 'https://example.com/1.jpeg',
              'location': {'name': 'Citadel of Ricks'},
            },
          ],
        }),
        200,
      );
    });

    final characters = await RestCharactersRemoteStore(client).getCharacters();

    expect(characters.single.id, 1);
    expect(characters.single.name, 'Rick Sanchez');
    expect(characters.single.location, 'Citadel of Ricks');
  });

  test('throws when the server returns an error', () async {
    final client = MockClient((_) async => http.Response('Oops', 500));

    await expectLater(
      RestCharactersRemoteStore(client).getCharacters(),
      throwsA(isA<http.ClientException>()),
    );
  });

  test('sends the name when searching', () async {
    Uri? sent;
    final client = MockClient((request) async {
      sent = request.url;
      return http.Response(jsonEncode({'results': []}), 200);
    });

    await RestCharactersRemoteStore(client).getCharacters(name: 'rick');

    expect(sent?.queryParameters, {'page': '1', 'name': 'rick'});
  });

  test('a search with no matches returns an empty list', () async {
    final client = MockClient((_) async => http.Response('{}', 404));

    final characters = await RestCharactersRemoteStore(client)
        .getCharacters(name: 'nobody');

    expect(characters, isEmpty);
  });
}
