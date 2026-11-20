import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;

import 'data/local/characters_local_store.dart';
import 'data/remote/characters_remote_store.dart';
import 'domain/repositories/characters_repository.dart';

/// The opened Hive box. Overridden in `main()` once Hive is ready.
final charactersBoxProvider = Provider<Box<String>>(
  (ref) => throw UnimplementedError('Override charactersBoxProvider in main.'),
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final charactersRemoteStoreProvider = Provider<CharactersRemoteStore>(
  (ref) => RestCharactersRemoteStore(ref.watch(httpClientProvider)),
);

final charactersLocalStoreProvider = Provider<CharactersLocalStore>(
  (ref) => HiveCharactersLocalStore(ref.watch(charactersBoxProvider)),
);

final charactersRepositoryProvider = Provider<CharactersRepository>(
  (ref) => LiveCharactersRepository(
    remoteStore: ref.watch(charactersRemoteStoreProvider),
    localStore: ref.watch(charactersLocalStoreProvider),
  ),
);
