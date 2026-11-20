import 'package:graphql/client.dart';

import '../models/character.dart';

/// Fetches characters from the network.
abstract interface class CharactersRemoteStore {
  Future<List<Character>> getCharacters();
}

/// Fetches characters over GraphQL.
class GraphQLCharactersRemoteStore implements CharactersRemoteStore {
  GraphQLCharactersRemoteStore(this._client);

  final GraphQLClient _client;

  static const _query = r'''
    query Characters($page: Int!) {
      characters(page: $page) {
        results {
          id
          name
          status
          species
          image
          location {
            name
          }
        }
      }
    }
  ''';

  @override
  Future<List<Character>> getCharacters() async {
    final result = await _client.query(
      QueryOptions(document: gql(_query), variables: const {'page': 1}),
    );
    if (result.hasException) throw result.exception!;

    final results = result.data!['characters']['results'] as List<dynamic>;
    return [
      for (final item in results)
        Character.fromJson(item as Map<String, dynamic>),
    ];
  }
}
