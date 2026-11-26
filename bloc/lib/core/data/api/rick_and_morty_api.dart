/// Endpoints for the public Rick and Morty API. No API key is needed.
///
/// See https://rickandmortyapi.com/documentation.
abstract final class RickAndMortyApi {
  /// The first page of characters, optionally filtered by [name].
  static Uri charactersUri({String? name}) {
    return Uri.https('rickandmortyapi.com', '/api/character', {
      'page': '1',
      if (name != null && name.isNotEmpty) 'name': name,
    });
  }
}
