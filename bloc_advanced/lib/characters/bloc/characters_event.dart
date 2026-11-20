part of 'characters_bloc.dart';

/// Something that happened on the characters screen.
sealed class CharactersEvent extends Equatable {
  const CharactersEvent();

  @override
  List<Object> get props => [];
}

/// The screen opened, or the user tapped retry.
final class CharactersStarted extends CharactersEvent {
  const CharactersStarted();
}

/// The user pulled to refresh.
final class CharactersRefreshed extends CharactersEvent {
  const CharactersRefreshed();
}

/// The user typed in the search field.
final class CharactersSearchChanged extends CharactersEvent {
  const CharactersSearchChanged(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}
