import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rick_and_morty_api/src/models/api_character.dart';

/// Thrown when the API answers with an unexpected status code.
class CharactersRequestFailure implements Exception {
  /// Creates a [CharactersRequestFailure].
  const CharactersRequestFailure(this.statusCode);

  /// The HTTP status code the API returned.
  final int statusCode;

  @override
  String toString() => 'CharactersRequestFailure($statusCode)';
}

/// A small client for the public Rick and Morty REST API.
///
/// No API key is needed. See https://rickandmortyapi.com/documentation.
class RickAndMortyApiClient {
  /// Creates a client. Pass an [httpClient] to control networking in tests.
  RickAndMortyApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static const _authority = 'rickandmortyapi.com';

  final http.Client _httpClient;

  /// Returns the first page of characters, filtered by [name] if given.
  ///
  /// A search with no matches returns an empty list. Throws a
  /// [CharactersRequestFailure] for any other error response.
  Future<List<ApiCharacter>> getCharacters({String? name}) async {
    final uri = Uri.https(_authority, '/api/character', {
      'page': '1',
      if (name != null && name.isNotEmpty) 'name': name,
    });
    final response = await _httpClient.get(uri);

    // The API answers a search with no matches with a 404.
    if (response.statusCode == 404 && name != null) return const [];
    if (response.statusCode != 200) {
      throw CharactersRequestFailure(response.statusCode);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>;
    return [
      for (final item in results)
        ApiCharacter.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Closes the underlying HTTP client.
  void close() => _httpClient.close();
}
