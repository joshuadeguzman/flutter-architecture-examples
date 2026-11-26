import 'package:example_bloc_cubit/characters/views/characters_page.dart';
import 'package:example_bloc_cubit/core/data/models/character.dart';
import 'package:example_bloc_cubit/core/domain/repositories/characters_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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

Widget app(CharactersRepository repository) => RepositoryProvider.value(
  value: repository,
  child: const MaterialApp(home: CharactersPage(title: 'Cubit')),
);

void main() {
  testWidgets('shows the characters', (tester) async {
    await tester.pumpWidget(app(FakeRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Morty Smith'), findsOneWidget);
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

  testWidgets('a failed refresh keeps the list and says so', (tester) async {
    final repository = FakeRepository();
    await tester.pumpWidget(app(repository));
    await tester.pumpAndSettle();

    repository.fail = true;
    await tester.fling(find.text('Rick Sanchez'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text("Couldn't refresh. Try again later."), findsOneWidget);
    expect(find.byType(RefreshProgressIndicator), findsNothing);
  });
}
