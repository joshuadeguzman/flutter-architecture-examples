abstract class LocalDb {
  Future<void> add();
  Future<void> read();
  Future<void> update();
  Future<void> delete();
}

class HiveDb extends LocalDb {
  @override
  Future<void> add() {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  Future<void> delete() {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> read() {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  Future<void> update() {
    // TODO: implement update
    throw UnimplementedError();
  }
}
