import 'package:characters_repository/characters_repository.dart';
import 'package:flutter/material.dart';

class CharacterTile extends StatelessWidget {
  const CharacterTile({required this.character, super.key});

  final Character character;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        foregroundImage: NetworkImage(character.imageUrl),
        // Shows the initial instead of failing when the image can't load.
        onForegroundImageError: (_, _) {},
        child: Text(character.name.characters.first),
      ),
      title: Text(character.name),
      subtitle: Text('${character.species} · ${character.location}'),
      trailing: _StatusChip(status: character.status),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final CharacterStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      CharacterStatus.alive => ('Alive', const Color(0xFF188038)),
      CharacterStatus.dead => ('Dead', const Color(0xFFD93025)),
      CharacterStatus.unknown => ('unknown', const Color(0xFF5F6368)),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
