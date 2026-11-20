/// A character from the Rick and Morty API.
///
/// The same model is used for REST and GraphQL responses, and for the local
/// cache. [toJson] writes the API shape, so [Character.fromJson] can read it
/// back.
class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.imageUrl,
    required this.location,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>?;
    return Character(
      // REST returns an int id. GraphQL returns a string.
      id: int.parse('${json['id']}'),
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      imageUrl: json['image'] as String,
      location: location?['name'] as String? ?? 'Unknown',
    );
  }

  final int id;
  final String name;

  /// `Alive`, `Dead` or `unknown`.
  final String status;
  final String species;
  final String imageUrl;

  /// The name of the character's last known location.
  final String location;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status,
    'species': species,
    'image': imageUrl,
    'location': {'name': location},
  };
}
