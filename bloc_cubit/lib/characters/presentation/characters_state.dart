import 'package:equatable/equatable.dart';

import '../../core/data/models/character.dart';

enum CharactersStatus { initial, loading, success, failure }

/// One class with a [status] enum. Simple, and good enough when the screen
/// only has a few states.
final class CharactersState extends Equatable {
  const CharactersState({
    this.status = CharactersStatus.initial,
    this.characters = const [],
  });

  final CharactersStatus status;
  final List<Character> characters;

  CharactersState copyWith({
    CharactersStatus? status,
    List<Character>? characters,
  }) {
    return CharactersState(
      status: status ?? this.status,
      characters: characters ?? this.characters,
    );
  }

  @override
  List<Object> get props => [status, characters];
}
