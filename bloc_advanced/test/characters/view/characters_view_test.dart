import 'package:bloc_test/bloc_test.dart';
import 'package:characters_repository/characters_repository.dart';
import 'package:example_bloc_advanced/characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fixtures.dart';

class MockCharactersBloc extends MockBloc<CharactersEvent, CharactersState>
    implements CharactersBloc {}

class MockCharactersRepository extends Mock implements CharactersRepository {}

void main() {
  late MockCharactersBloc bloc;

  setUp(() => bloc = MockCharactersBloc());

  Widget view() => MaterialApp(
    home: BlocProvider<CharactersBloc>.value(
      value: bloc,
      child: const CharactersView(),
    ),
  );

  group(CharactersView, () {
    testWidgets('shows a spinner while the first load runs', (tester) async {
      when(() => bloc.state)
          .thenReturn(const CharactersState(status: CharactersStatus.loading));

      await tester.pumpWidget(view());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows the characters', (tester) async {
      when(() => bloc.state).thenReturn(
        const CharactersState(
          status: CharactersStatus.success,
          characters: [rick, morty],
        ),
      );

      await tester.pumpWidget(view());

      expect(find.text('Rick Sanchez'), findsOneWidget);
      expect(find.text('Morty Smith'), findsOneWidget);
    });

    testWidgets('keeps the list and shows a progress bar while loading', (
      tester,
    ) async {
      when(() => bloc.state).thenReturn(
        const CharactersState(
          status: CharactersStatus.loading,
          characters: [rick],
        ),
      );

      await tester.pumpWidget(view());

      expect(find.text('Rick Sanchez'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('shows a message when a search has no matches', (tester) async {
      when(() => bloc.state).thenReturn(
        const CharactersState(
          status: CharactersStatus.success,
          query: 'nobody',
        ),
      );

      await tester.pumpWidget(view());

      expect(find.text('No characters match "nobody".'), findsOneWidget);
    });

    testWidgets('retry adds CharactersStarted', (tester) async {
      when(() => bloc.state)
          .thenReturn(const CharactersState(status: CharactersStatus.failure));

      await tester.pumpWidget(view());
      await tester.tap(find.text('Try again'));

      verify(() => bloc.add(const CharactersStarted())).called(1);
    });

    testWidgets('typing adds CharactersSearchChanged', (tester) async {
      when(() => bloc.state).thenReturn(const CharactersState());

      await tester.pumpWidget(view());
      await tester.enterText(find.byType(TextField), 'rick');

      verify(() => bloc.add(const CharactersSearchChanged('rick'))).called(1);
    });

    testWidgets('shows a snackbar when a refresh fails with a list', (
      tester,
    ) async {
      const success = CharactersState(
        status: CharactersStatus.success,
        characters: [rick],
      );
      whenListen(
        bloc,
        Stream.fromIterable([
          success.copyWith(status: CharactersStatus.failure),
        ]),
        initialState: success,
      );

      await tester.pumpWidget(view());
      await tester.pump();

      expect(
        find.text("Couldn't refresh. Showing saved characters."),
        findsOneWidget,
      );
      expect(find.text('Rick Sanchez'), findsOneWidget);
    });
  });

  group(CharactersPage, () {
    testWidgets('creates the bloc and loads characters', (tester) async {
      final repository = MockCharactersRepository();
      when(repository.getCharacters).thenAnswer((_) async => [rick]);

      await tester.pumpWidget(
        RepositoryProvider<CharactersRepository>.value(
          value: repository,
          child: const MaterialApp(home: CharactersPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rick Sanchez'), findsOneWidget);
    });
  });
}
