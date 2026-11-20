import 'package:equatable/equatable.dart';

import '../../core/data/models/character.dart';

/// The state of the characters screen.
///
/// A sealed class with one subclass per state. Each subclass only holds the
/// data that makes sense for it, and a `switch` on the state must handle every
/// case.
sealed class CharactersState extends Equatable {
  const CharactersState();

  @override
  List<Object?> get props => [];
}

final class CharactersInitial extends CharactersState {
  const CharactersInitial();
}

final class CharactersLoadInProgress extends CharactersState {
  const CharactersLoadInProgress();
}

final class CharactersLoadSuccess extends CharactersState {
  const CharactersLoadSuccess(
    this.characters, {
    this.query = '',
    this.isRefreshing = false,
  });

  final List<Character> characters;

  /// The search that produced these characters. Empty for the full list.
  final String query;

  /// Whether a pull to refresh is running. The list stays on screen.
  final bool isRefreshing;

  @override
  List<Object?> get props => [characters, query, isRefreshing];
}

final class CharactersLoadFailure extends CharactersState {
  const CharactersLoadFailure({this.query = ''});

  /// The search that failed, so retrying runs the same search.
  final String query;

  @override
  List<Object?> get props => [query];
}
