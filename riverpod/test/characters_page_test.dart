import 'package:example_riverpod/characters/views/characters_page.dart';
import 'package:example_riverpod/core/data/models/character.dart';
import 'package:example_riverpod/core/domain/repositories/characters_repository.dart';
import 'package:example_riverpod/core/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

Widget app(CharactersRepository repository) => ProviderScope(
  // Swap the real repository for a fake. Nothing else changes.
  overrides: [charactersRepositoryProvider.overrideWithValue(repository)],
  // The app keeps Riverpod's automatic retry. It's off here so the error
  // shows right away instead of after the retry delay.
  retry: (_, _) => null,
  child: const MaterialApp(home: CharactersPage(title: 'Riverpod')),
);

void main() {
  testWidgets('shows the characters from the provider', (tester) async {
    await tester.pumpWidget(app(FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Morty Smith'), findsOneWidget);
    expect(find.text('Alive'), findsNWidgets(2));
  });

  testWidgets('shows an error and retries', (tester) async {
    final repository = FakeRepository(fail: true);

    await tester.pumpWidget(app(repository));
    await tester.pumpAndSettle();
    expect(find.text('Try again'), findsOneWidget);

    repository.fail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
  });

  testWidgets('pull to refresh skips the cache', (tester) async {
    final repository = FakeRepository();
    await tester.pumpWidget(app(repository));
    await tester.pumpAndSettle();

    await tester.fling(find.text('Rick Sanchez'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(repository.refreshes, [false, true]);
  });
}
