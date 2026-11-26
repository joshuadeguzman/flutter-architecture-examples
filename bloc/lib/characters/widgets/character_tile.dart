import 'package:material_ui/material_ui.dart';

import '../../core/data/models/character.dart';

class CharacterTile extends StatelessWidget {
  const CharacterTile({super.key, required this.character});

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

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'Alive' => const Color(0xFF188038),
      'Dead' => const Color(0xFFD93025),
      _ => const Color(0xFF5F6368),
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
          status,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: color),
        ),
      ],
    );
  }
}
