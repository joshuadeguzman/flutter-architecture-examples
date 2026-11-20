import 'package:characters_repository/characters_repository.dart';
import 'package:example_bloc_advanced/characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({required this.charactersRepository, super.key});

  final CharactersRepository charactersRepository;

  @override
  Widget build(BuildContext context) {
    // Repositories are provided once at the top. Blocs are created where
    // they're used, in each feature's page.
    return RepositoryProvider.value(
      value: charactersRepository,
      child: MaterialApp(
        title: 'Bloc for bigger teams',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF0175C2)),
        home: const CharactersPage(),
      ),
    );
  }
}
