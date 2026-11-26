import 'dart:convert';

import 'package:example_bloc_cubit/core/data/remote/characters_remote_store.dart';
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
}
