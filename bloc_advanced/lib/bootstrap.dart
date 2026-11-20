import 'dart:developer';

import 'package:characters_repository/characters_repository.dart';
import 'package:example_bloc_advanced/app/app.dart';
import 'package:example_bloc_advanced/app/app_bloc_observer.dart';
import 'package:example_bloc_advanced/cache/hive_characters_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:rick_and_morty_api/rick_and_morty_api.dart';

/// Sets up logging and dependencies, then starts the app.
///
/// Every entry point (for example a dev and a prod flavor) calls this, so
/// setup lives in one place.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };
  // Logs every transition. Only in debug builds, since it logs app data.
  if (kDebugMode) Bloc.observer = const AppBlocObserver();

  await Hive.initFlutter();
  final box = await Hive.openBox<String>(HiveCharactersCache.boxName);

  final charactersRepository = CharactersRepository(
    apiClient: RickAndMortyApiClient(),
    cache: HiveCharactersCache(box),
  );

  runApp(App(charactersRepository: charactersRepository));
}
