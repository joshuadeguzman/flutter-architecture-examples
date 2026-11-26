import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:material_ui/material_ui.dart';

import 'characters/views/characters_page.dart';
import 'core/data/local/characters_local_store.dart';
import 'core/data/remote/characters_remote_store.dart';
import 'core/domain/repositories/characters_repository.dart';

/// Logs every transition: the state before, the event, and the state after.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    debugPrint(
      '${bloc.runtimeType}: ${transition.event.runtimeType} '
      '${transition.currentState.runtimeType} -> '
      '${transition.nextState.runtimeType}',
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) Bloc.observer = const AppBlocObserver();

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
    return RepositoryProvider.value(
      value: repository,
      child: MaterialApp(
        title: 'Bloc',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: const Color(0xFF0175C2)),
        home: const CharactersPage(title: 'Bloc: events'),
      ),
    );
  }
}
