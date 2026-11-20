import 'dart:io';

import 'package:example_bloc_advanced/cache/hive_characters_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import '../helpers/fixtures.dart';

void main() {
  late Directory dir;
  late Box<String> box;
  late HiveCharactersCache cache;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(dir.path);
    box = await Hive.openBox<String>(HiveCharactersCache.boxName);
    cache = HiveCharactersCache(box);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await dir.delete(recursive: true);
  });

  test('returns an empty list when nothing is saved', () async {
    expect(await cache.read(), isEmpty);
  });

  test('reads back what it writes', () async {
    await cache.write([rick, morty]);

    expect(await cache.read(), [rick, morty]);
  });

  test('drops an unreadable cache instead of throwing', () async {
    await box.put('characters', 'not json');

    expect(await cache.read(), isEmpty);
    expect(box.get('characters'), isNull);
  });
}
