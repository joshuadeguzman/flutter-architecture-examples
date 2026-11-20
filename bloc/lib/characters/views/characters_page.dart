import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/domain/repositories/characters_repository.dart';
import '../presentation/characters_bloc.dart';
import '../presentation/characters_event.dart';
import '../presentation/characters_state.dart';
import '../widgets/character_tile.dart';

/// Creates the bloc and sends the first event.
class CharactersPage extends StatelessWidget {
  const CharactersPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CharactersBloc(context.read<CharactersRepository>())
            ..add(const CharactersStarted()),
      child: CharactersView(title: title),
    );
  }
}

/// Builds the screen from the bloc's state and turns input into events.
class CharactersView extends StatelessWidget {
  const CharactersView({super.key, required this.title});

  final String title;

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<CharactersBloc>()
      ..add(const CharactersRefreshed());
    // Keep the spinner until the refresh finishes.
    await bloc.stream
        .firstWhere((state) => state is! CharactersLoadInProgress)
        .timeout(const Duration(seconds: 15), onTimeout: () => bloc.state);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchBar(
              hintText: 'Search by name',
              leading: const Icon(Icons.search),
              elevation: const WidgetStatePropertyAll(0),
              onChanged: (query) => context.read<CharactersBloc>().add(
                CharactersSearchChanged(query),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<CharactersBloc, CharactersState>(
              builder: (context, state) => switch (state) {
                CharactersInitial() || CharactersLoadInProgress() =>
                  const Center(child: CircularProgressIndicator()),
                CharactersLoadFailure() => _ErrorView(
                  onRetry: () => context.read<CharactersBloc>().add(
                    const CharactersStarted(),
                  ),
                ),
                CharactersLoadSuccess(:final characters, :final query)
                    when characters.isEmpty =>
                  Center(child: Text('No characters match "$query".')),
                CharactersLoadSuccess(:final characters) => RefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: ListView.builder(
                    itemCount: characters.length,
                    itemBuilder: (context, index) =>
                        CharacterTile(character: characters[index]),
                  ),
                ),
              },
            ),
          ),
        ],
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
