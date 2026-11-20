import 'package:example_mobx_graphql/core/data/remote/characters_remote_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql/client.dart';

/// A GraphQL client that answers every request with [response], without
/// touching the network.
GraphQLClient fakeClient(Response Function(Request request) response) {
  return GraphQLClient(
    link: Link.function(
      (request, [forward]) => Stream.value(response(request)),
    ),
    cache: GraphQLCache(),
    defaultPolicies: DefaultPolicies(
      query: Policies(fetch: FetchPolicy.noCache),
    ),
  );
}

void main() {
  test('parses the GraphQL response', () async {
    Request? sent;
    final client = fakeClient((request) {
      sent = request;
      return const Response(
        response: {},
        data: {
          'characters': {
            'results': [
              {
                'id': '1',
                'name': 'Rick Sanchez',
                'status': 'Alive',
                'species': 'Human',
                'image': 'https://example.com/1.jpeg',
                'location': {'name': 'Citadel of Ricks'},
              },
            ],
          },
        },
      );
    });

    final characters = await GraphQLCharactersRemoteStore(client)
        .getCharacters();

    expect(sent?.variables, {'page': 1});
    expect(characters.single.id, 1);
    expect(characters.single.name, 'Rick Sanchez');
  });

  test('throws when the server returns errors', () async {
    final client = fakeClient(
      (_) => const Response(
        response: {},
        errors: [GraphQLError(message: 'Something went wrong')],
      ),
    );

    await expectLater(
      GraphQLCharactersRemoteStore(client).getCharacters(),
      throwsA(isA<OperationException>()),
    );
  });
}
