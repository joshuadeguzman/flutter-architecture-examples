import 'dart:async';

import 'package:equatable/equatable.dart';

/// Something that happened on the characters screen.
///
/// Events are named in the past tense, as the bloc docs recommend.
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
///
/// The bloc completes [completer] when the refresh is over, so the view knows
/// when to hide the spinner. It completes with a [RefreshFailure] error if
/// the refresh failed.
final class CharactersRefreshed extends CharactersEvent {
  const CharactersRefreshed({this.completer});

  final Completer<void>? completer;

  @override
  List<Object> get props => [?completer];
}

/// The user typed in the search field.
final class CharactersSearchChanged extends CharactersEvent {
  const CharactersSearchChanged(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}
