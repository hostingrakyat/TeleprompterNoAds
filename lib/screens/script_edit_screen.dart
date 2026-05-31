import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/script.dart';
import '../widgets/credits_bar.dart';

class ScriptEditScreen extends StatefulWidget {
  final String code;
  final Script? script;
  const ScriptEditScreen({super.key, required this.code, this.script});

  @override
  State<ScriptEditScreen> createState() => _ScriptEditScreenState();
}

class _ScriptEditScreenState extends State<ScriptEditScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;

  Strings get s => Strings(widget.code);

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.script?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.script?.body ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final script = widget.script ?? Script.create();
    script.title = _titleCtrl.text.trim();
    script.body = _bodyCtrl.text;
    Navigator.of(context).pop(script);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.script == null ? s.newScript : s.editScript),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: Text(s.save),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: s.title,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _bodyCtrl,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: InputDecoration(
                        labelText: s.scriptText,
                        hintText: s.pasteHint,
                        alignLabelWithHint: true,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const CreditsBar(),
        ],
      ),
    );
  }
}
