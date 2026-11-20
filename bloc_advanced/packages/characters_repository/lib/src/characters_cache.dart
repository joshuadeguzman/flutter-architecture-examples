import 'package:characters_repository/src/models/character.dart';

/// Stores characters on the device.
///
/// The repository only knows this interface. The app decides how characters
/// are stored, so this package has no Flutter or database dependency.
abstract interface class CharactersCache {
  /// Returns the saved characters, or an empty list if there are none.
  Future<List<Character>> read();

  /// Replaces the saved characters with [characters].
  Future<void> write(List<Character> characters);
}
