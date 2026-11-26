import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:material_ui/material_ui.dart';

import 'characters/views/characters_page.dart';
import 'core/data/local/characters_local_store.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<String>(HiveCharactersLocalStore.boxName);

  // Providers wire the layers together. Only the box needs to be supplied.
  runApp(
    ProviderScope(
      overrides: [charactersBoxProvider.overrideWithValue(box)],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod + REST',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF0175C2)),
      home: const CharactersPage(title: 'Riverpod + REST'),
    );
  }
}
