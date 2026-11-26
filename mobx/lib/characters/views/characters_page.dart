import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobx/mobx.dart';

import '../presentation/characters_store.dart';
import '../widgets/character_tile.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key, required this.title, required this.store});

  final String title;
  final CharactersStore store;

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  CharactersStore get _store => widget.store;
  late final ReactionDisposer _disposeErrorReaction;

  @override
  void initState() {
    super.initState();
    // A failed refresh keeps the list on screen, so say that it failed.
    _disposeErrorReaction = reaction((_) => _store.errorMessage, (message) {
      if (message == null || _store.characters.isEmpty || !mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text("Couldn't refresh. Try again later.")),
        );
    });
    _store.load();
  }

  @override
  void dispose() {
    _disposeErrorReaction();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Observer(
        builder: (context) {
          if (_store.characters.isEmpty) {
            if (_store.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (_store.errorMessage case final message?) {
              return _ErrorView(message: message, onRetry: _store.load);
            }
          }

          return RefreshIndicator(
            onRefresh: () => _store.load(forceRefresh: true),
            child: ListView.builder(
              itemCount: _store.characters.length,
              itemBuilder: (context, index) =>
                  CharacterTile(character: _store.characters[index]),
            ),
          );
        },
      ),
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
