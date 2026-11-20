import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';
import 'package:test/test.dart';

const Map<String, Object> rickJson = {
  'id': 1,
  'name': 'Rick Sanchez',
  'status': 'Alive',
  'species': 'Human',
  'image': 'https://example.com/1.jpeg',
  'location': {'name': 'Citadel of Ricks'},
};

void main() {
  group(RickAndMortyApiClient, () {
    test('requests the first page and parses the results', () async {
      late Uri sent;
      final client = RickAndMortyApiClient(
        httpClient: MockClient((request) async {
          sent = request.url;
          return http.Response(
            jsonEncode({
              'results': [rickJson],
            }),
            200,
          );
        }),
      );

      final characters = await client.getCharacters();

      expect(sent.host, 'rickandmortyapi.com');
      expect(sent.path, '/api/character');
      expect(sent.queryParameters, {'page': '1'});
      expect(characters, [
        const ApiCharacter(
          id: 1,
          name: 'Rick Sanchez',
          status: 'Alive',
          species: 'Human',
          image: 'https://example.com/1.jpeg',
          locationName: 'Citadel of Ricks',
        ),
      ]);
    });

    test('sends the name when searching', () async {
      late Uri sent;
      final client = RickAndMortyApiClient(
        httpClient: MockClient((request) async {
          sent = request.url;
          return http.Response(jsonEncode({'results': <Object>[]}), 200);
        }),
      );

      await client.getCharacters(name: 'rick');

      expect(sent.queryParameters, {'page': '1', 'name': 'rick'});
    });

    test('returns an empty list when a search has no matches', () async {
      final client = RickAndMortyApiClient(
        httpClient: MockClient((_) async => http.Response('{}', 404)),
      );

      expect(await client.getCharacters(name: 'nobody'), isEmpty);
    });

    test('throws CharactersRequestFailure on other errors', () async {
      final client = RickAndMortyApiClient(
        httpClient: MockClient((_) async => http.Response('Oops', 500)),
      );

      await expectLater(
        client.getCharacters(),
        throwsA(
          isA<CharactersRequestFailure>().having(
            (e) => e.statusCode,
            'statusCode',
            500,
          ),
        ),
      );
    });

    test('throws CharactersParseFailure on unexpected JSON', () async {
      final client = RickAndMortyApiClient(
        httpClient: MockClient(
          (_) async => http.Response(jsonEncode({'results': 'nope'}), 200),
        ),
      );

      await expectLater(
        client.getCharacters(),
        throwsA(isA<CharactersParseFailure>()),
      );
    });
  });
}
