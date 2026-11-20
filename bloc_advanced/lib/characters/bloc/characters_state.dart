part of 'characters_bloc.dart';

enum CharactersStatus { initial, loading, success, failure }

/// The state of the characters screen.
///
/// One class with a [status], instead of a sealed class. The states here are
/// not exclusive: the screen keeps showing [characters] while a refresh runs,
/// and still shows them if the refresh fails.
final class CharactersState extends Equatable {
  const CharactersState({
    this.status = CharactersStatus.initial,
    this.characters = const [],
    this.query = '',
  });

  final CharactersStatus status;
  final List<Character> characters;

  /// The search that produced [characters]. Empty for the full list.
  final String query;

  CharactersState copyWith({
    CharactersStatus? status,
    List<Character>? characters,
    String? query,
  }) {
    return CharactersState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
      query: query ?? this.query,
    );
  }

  @override
  List<Object> get props => [status, characters, query];
}
