import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'characters/presentation/characters_store.dart';
import 'characters/views/characters_page.dart';
import 'core/data/local/characters_local_store.dart';
import 'core/data/api/rick_and_morty_api.dart';
import 'core/data/remote/characters_remote_store.dart';
import 'core/domain/repositories/characters_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<String>(HiveCharactersLocalStore.boxName);

  // Wire the layers together, from the data sources up to the store.
  final repository = LiveCharactersRepository(
    remoteStore: GraphQLCharactersRemoteStore(RickAndMortyApi.createClient()),
    localStore: HiveCharactersLocalStore(box),
  );
  final store = CharactersStore(repository: repository);

  runApp(App(store: store));
}

class App extends StatelessWidget {
  const App({super.key, required this.store});

  final CharactersStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MobX + GraphQL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF0175C2)),
      home: CharactersPage(title: 'MobX + GraphQL', store: store),
    );
  }
}
