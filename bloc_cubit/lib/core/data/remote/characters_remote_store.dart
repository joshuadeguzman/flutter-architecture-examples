import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/rick_and_morty_api.dart';
import '../models/character.dart';

/// Fetches characters from the network.
abstract interface class CharactersRemoteStore {
  Future<List<Character>> getCharacters();
}

/// Fetches characters over REST.
class RestCharactersRemoteStore implements CharactersRemoteStore {
  RestCharactersRemoteStore(this._client);

  final http.Client _client;

  @override
  Future<List<Character>> getCharacters() async {
    final response = await _client.get(RickAndMortyApi.charactersUri);
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Failed to load characters (${response.statusCode})',
        RickAndMortyApi.charactersUri,
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;
    return [
      for (final item in results)
        Character.fromJson(item as Map<String, dynamic>),
    ];
  }
}
