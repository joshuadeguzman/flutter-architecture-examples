import 'package:graphql/client.dart';

/// The GraphQL client for the public Rick and Morty API. No API key is needed.
///
/// See https://rickandmortyapi.com/documentation/#graphql.
abstract final class RickAndMortyApi {
  static const graphQLEndpoint = 'https://rickandmortyapi.com/graphql';

  static GraphQLClient createClient() {
    return GraphQLClient(
      link: HttpLink(graphQLEndpoint),
      // The local store does the caching, so the client skips its own cache.
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.noCache),
      ),
    );
  }
}
