import 'package:equatable/equatable.dart';

/// A character exactly as the Rick and Morty API returns it.
///
/// This model belongs to the API layer. The repository maps it to its own
/// domain model, so changes in the API don't leak into the app.
class ApiCharacter extends Equatable {
  /// Creates an [ApiCharacter].
  const ApiCharacter({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.image,
    required this.locationName,
  });

  /// Reads a character from the API's JSON.
  factory ApiCharacter.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    return ApiCharacter(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      image: json['image'] as String,
      locationName: location?['name'] as String? ?? 'unknown',
    );
  }

  /// The character id.
  final int id;

  /// The character name.
  final String name;

  /// `Alive`, `Dead` or `unknown`.
  final String status;

  /// The species, for example `Human`.
  final String species;

  /// The URL of the character's avatar.
  final String image;

  /// The name of the last known location.
  final String locationName;

  @override
  List<Object> get props => [id, name, status, species, image, locationName];
}
