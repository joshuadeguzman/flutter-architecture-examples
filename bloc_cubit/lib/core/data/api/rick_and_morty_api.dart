/// Endpoints for the public Rick and Morty API. No API key is needed.
///
/// See https://rickandmortyapi.com/documentation.
abstract final class RickAndMortyApi {
  static final charactersUri = Uri.parse(
    'https://rickandmortyapi.com/api/character?page=1',
  );
}
