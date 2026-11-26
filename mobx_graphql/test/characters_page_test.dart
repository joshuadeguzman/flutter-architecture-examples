import 'package:example_mobx_graphql/characters/presentation/characters_store.dart';
import 'package:example_mobx_graphql/characters/views/characters_page.dart';
import 'package:example_mobx_graphql/core/data/models/character.dart';
import 'package:example_mobx_graphql/core/domain/repositories/characters_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'characters_repository_test.dart' show rick, morty;

class FakeRepository implements CharactersRepository {
  FakeRepository({this.fail = false});

  bool fail;
  final refreshes = <bool>[];

  @override
  Future<List<Character>> getCharacters({bool forceRefresh = false}) async {
    refreshes.add(forceRefresh);
    if (fail) throw Exception('offline');
    return [rick, morty];
  }
}

Widget app(CharactersStore store) => MaterialApp(
  home: CharactersPage(title: 'MobX', store: store),
);

void main() {
  testWidgets('shows the characters from the store', (tester) async {
    final store = CharactersStore(repository: FakeRepository());

    await tester.pumpWidget(app(store));
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Morty Smith'), findsOneWidget);
    expect(find.text('Alive'), findsNWidgets(2));
  });

  testWidgets('shows an error and retries', (tester) async {
    final repository = FakeRepository(fail: true);
    final store = CharactersStore(repository: repository);

    await tester.pumpWidget(app(store));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);

    repository.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
  });

  testWidgets('pull to refresh skips the cache', (tester) async {
    final repository = FakeRepository();
    await tester.pumpWidget(app(CharactersStore(repository: repository)));
    await tester.pumpAndSettle();

    await tester.fling(find.text('Rick Sanchez'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(repository.refreshes, [false, true]);
  });

  testWidgets('a failed refresh keeps the list and says so', (tester) async {
    final repository = FakeRepository();
    final store = CharactersStore(repository: repository);
    await tester.pumpWidget(app(store));
    await tester.pumpAndSettle();

    repository.fail = true;
    await tester.fling(find.text('Rick Sanchez'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text("Couldn't refresh. Try again later."), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsNothing);
  });
}
