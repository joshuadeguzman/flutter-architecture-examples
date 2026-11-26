import 'dart:async';

import 'package:characters_repository/characters_repository.dart';
import 'package:example_bloc_advanced/characters/bloc/characters_bloc.dart';
import 'package:example_bloc_advanced/characters/widgets/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

/// Provides the bloc. Kept apart from [CharactersView] so the view can be
/// tested with a mock bloc.
class CharactersPage extends StatelessWidget {
  const CharactersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CharactersBloc(
        charactersRepository: context.read<CharactersRepository>(),
      )..add(const CharactersStarted()),
      child: const CharactersView(),
    );
  }
}

class CharactersView extends StatelessWidget {
  const CharactersView({super.key});

  Future<void> _refresh(BuildContext context) {
    final done = Completer<void>();
    context.read<CharactersBloc>().add(CharactersRefreshed(completer: done));
    // The spinner shows until the bloc completes this. A failed refresh
    // shows a snackbar through the BlocListener below.
    return done.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bloc: bigger teams')),
      body: BlocListener<CharactersBloc, CharactersState>(
        // Show a message when a load fails but there are characters to show.
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
        child: Column(
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
                builder: (context, state) {
                  if (state.characters.isEmpty) {
                    return switch (state.status) {
                      CharactersStatus.initial ||
                      CharactersStatus.loading ||
                      CharactersStatus.refreshing => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      CharactersStatus.failure => CharactersError(
                        onRetry: () => context.read<CharactersBloc>().add(
                          const CharactersStarted(),
                        ),
                      ),
                      CharactersStatus.success => Center(
                        child: Text('No characters match "${state.query}".'),
                      ),
                    };
                  }

                  return Column(
                    children: [
                      if (state.status == CharactersStatus.loading)
                        const LinearProgressIndicator(minHeight: 2),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => _refresh(context),
                          child: ListView.builder(
                            itemCount: state.characters.length,
                            itemBuilder: (context, index) => CharacterTile(
                              character: state.characters[index],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
