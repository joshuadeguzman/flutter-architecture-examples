import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/domain/repositories/characters_repository.dart';
import '../presentation/characters_cubit.dart';
import '../presentation/characters_state.dart';
import '../widgets/character_tile.dart';

/// Creates the cubit and starts the first load.
class CharactersPage extends StatelessWidget {
  const CharactersPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CharactersCubit(context.read<CharactersRepository>())..load(),
      child: CharactersView(title: title),
    );
  }
}

/// Builds the screen from the cubit's state.
class CharactersView extends StatelessWidget {
  const CharactersView({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: BlocConsumer<CharactersCubit, CharactersState>(
        // A failed refresh keeps the list on screen, so say that it failed.
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == CharactersStatus.failure &&
            current.characters.isNotEmpty,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text("Couldn't refresh. Try again later."),
              ),
            );
        },
        builder: (context, state) {
          if (state.characters.isEmpty) {
            switch (state.status) {
              case CharactersStatus.initial || CharactersStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case CharactersStatus.failure:
                return _ErrorView(
                  onRetry: () => context.read<CharactersCubit>().load(),
                );
              case CharactersStatus.success:
                break;
            }
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<CharactersCubit>().load(forceRefresh: true),
            child: ListView.builder(
              itemCount: state.characters.length,
              itemBuilder: (context, index) =>
                  CharacterTile(character: state.characters[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Could not load characters. Check your connection.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
