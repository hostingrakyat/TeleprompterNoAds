import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/script.dart';
import '../services/storage_service.dart';
import '../widgets/credits_bar.dart';
import 'script_edit_screen.dart';
import 'teleprompter_screen.dart';

class HomeScreen extends StatefulWidget {
  final String code;
  const HomeScreen({super.key, required this.code});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();
  List<Script> _scripts = [];
  bool _loading = true;

  Strings get s => Strings(widget.code);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scripts = await _storage.loadScripts();
    if (!mounted) return;
    setState(() {
      _scripts = scripts;
      _loading = false;
    });
  }

  Future<void> _edit(Script? script) async {
    final result = await Navigator.of(context).push<Script>(
      MaterialPageRoute(
        builder: (_) => ScriptEditScreen(code: widget.code, script: script),
      ),
    );
    if (result != null) {
      final updated = await _storage.upsertScript(result);
      if (!mounted) return;
      setState(() => _scripts = updated);
    }
  }

  Future<void> _delete(Script script) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.delete),
        content: Text(s.deleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final updated = await _storage.deleteScript(script.id);
      if (!mounted) return;
      setState(() => _scripts = updated);
    }
  }

  void _open(Script script) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeleprompterScreen(code: widget.code, script: script),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(s.myScripts)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(null),
        icon: const Icon(Icons.add),
        label: Text(s.newScript),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _scripts.isEmpty
                    ? _EmptyState(message: s.noScripts)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
                        itemCount: _scripts.length,
                        itemBuilder: (context, i) {
                          final script = _scripts[i];
                          final title = script.title.trim().isEmpty
                              ? s.untitled
                              : script.title.trim();
                          final preview = script.body
                              .replaceAll('\n', ' ')
                              .trim();
                          return Card(
                            child: ListTile(
                              title: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                preview.isEmpty ? '—' : preview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _open(script),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _edit(script),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _delete(script),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.play_circle_fill),
                                    onPressed: () => _open(script),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const CreditsBar(),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notes,
                size: 72,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
