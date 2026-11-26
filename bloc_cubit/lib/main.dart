import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;

import 'characters/views/characters_page.dart';
import 'core/data/local/characters_local_store.dart';
import 'core/data/remote/characters_remote_store.dart';
import 'core/domain/repositories/characters_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<String>(HiveCharactersLocalStore.boxName);

  final repository = LiveCharactersRepository(
    remoteStore: RestCharactersRemoteStore(http.Client()),
    localStore: HiveCharactersLocalStore(box),
  );

  runApp(App(repository: repository));
}

class App extends StatelessWidget {
  const App({super.key, required this.repository});

  final CharactersRepository repository;

  @override
  Widget build(BuildContext context) {
    // Makes the repository available to every cubit below.
    return RepositoryProvider.value(
      value: repository,
      child: MaterialApp(
        title: 'Cubit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF0175C2)),
        home: const CharactersPage(title: 'Bloc: Cubit'),
      ),
    );
  }
}
