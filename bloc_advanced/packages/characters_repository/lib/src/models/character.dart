import 'package:equatable/equatable.dart';

/// Whether a character is alive.
enum CharacterStatus {
  /// The character is alive.
  alive,

  /// The character is dead.
  dead,

  /// Nobody knows.
  unknown,
}

/// A character, as the rest of the app sees it.
///
/// This is the domain model. It's built from the API model by the
/// repository, so the app never depends on the API's JSON shape.
class Character extends Equatable {
  /// Creates a [Character].
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.imageUrl,
    required this.location,
  });

  /// Reads a character saved with [toJson].
  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: CharacterStatus.values.byName(json['status'] as String),
      species: json['species'] as String,
      imageUrl: json['imageUrl'] as String,
      location: json['location'] as String,
    );
  }

  /// The character id.
  final int id;

  /// The character name.
  final String name;

  /// Whether the character is alive.
  final CharacterStatus status;

  /// The species, for example `Human`.
  final String species;

  /// The URL of the character's avatar.
  final String imageUrl;

  /// The name of the last known location.
  final String location;

  /// Converts this character to JSON, for the local cache.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status.name,
    'species': species,
    'imageUrl': imageUrl,
    'location': location,
  };

  @override
  List<Object> get props => [id, name, status, species, imageUrl, location];
}
