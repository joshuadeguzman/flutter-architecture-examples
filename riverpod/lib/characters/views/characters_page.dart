import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/characters_notifier.dart';
import '../widgets/character_tile.dart';

class CharactersPage extends ConsumerWidget {
  const CharactersPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characters = ref.watch(charactersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: characters.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _ErrorView(
          message: 'Could not load characters. Check your connection.',
          onRetry: () => ref.invalidate(charactersProvider),
        ),
        data: (characters) => RefreshIndicator(
          onRefresh: () => _refresh(context, ref),
          child: ListView.builder(
            itemCount: characters.length,
            itemBuilder: (context, index) =>
                CharacterTile(character: characters[index]),
          ),
        ),
      ),
    );
  }
}

Future<void> _refresh(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await ref.read(charactersProvider.notifier).refresh();
  } catch (_) {
    // The list stays on screen, so say that the refresh failed.
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text("Couldn't refresh. Try again later.")),
      );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
