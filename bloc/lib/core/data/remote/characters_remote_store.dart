import 'dart:convert';

import 'package:http/http.dart' as http;

import '../api/rick_and_morty_api.dart';
import '../models/character.dart';

/// Fetches characters from the network.
abstract interface class CharactersRemoteStore {
  /// Returns the first page of characters, filtered by [name] if given.
  Future<List<Character>> getCharacters({String? name});
}

/// Fetches characters over REST.
class RestCharactersRemoteStore implements CharactersRemoteStore {
  RestCharactersRemoteStore(this._client);

  final http.Client _client;

  @override
  Future<List<Character>> getCharacters({String? name}) async {
    final uri = RickAndMortyApi.charactersUri(name: name);
    final response = await _client.get(uri);

    // The API answers a search with no matches with a 404.
    if (response.statusCode == 404 && name != null) return const [];
    if (response.statusCode != 200) {
      throw http.ClientException(
        'Failed to load characters (${response.statusCode})',
        uri,
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
