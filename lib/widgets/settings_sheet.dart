import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../models/teleprompter_settings.dart';

/// Bottom sheet exposing all text + scroll controls. Calls [onChanged] live as
/// the user drags sliders / toggles switches.
class SettingsSheet extends StatefulWidget {
  final String code;
  final TeleprompterSettings settings;
  final ValueChanged<TeleprompterSettings> onChanged;

  const SettingsSheet({
    super.key,
    required this.code,
    required this.settings,
    required this.onChanged,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late TeleprompterSettings _s;

  Strings get t => Strings(widget.code);

  static const _colors = <Color>[
    Colors.white,
    Colors.yellow,
    Color(0xFF00E5FF),
    Color(0xFF69F0AE),
    Colors.orangeAccent,
    Colors.pinkAccent,
  ];

  @override
  void initState() {
    super.initState();
    _s = widget.settings.copy();
  }

  void _emit() => widget.onChanged(_s.copy());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(t.settings,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              _slider(
                label: t.fontSize,
                value: _s.fontSize,
                min: 14,
                max: 72,
                display: _s.fontSize.toStringAsFixed(0),
                onChanged: (v) => setState(() {
                  _s.fontSize = v;
                  _emit();
                }),
              ),
              _slider(
                label: t.lineHeight,
                value: _s.lineHeight,
                min: 1.0,
                max: 3.0,
                display: _s.lineHeight.toStringAsFixed(2),
                onChanged: (v) => setState(() {
                  _s.lineHeight = v;
                  _emit();
                }),
              ),
              _slider(
                label: t.scrollSpeed,
                value: _s.scrollSpeed,
                min: 10,
                max: 200,
                display: _s.scrollSpeed.toStringAsFixed(0),
                onChanged: (v) => setState(() {
                  _s.scrollSpeed = v;
                  _emit();
                }),
              ),
              _slider(
                label: t.bgOpacity,
                value: _s.bgOpacity,
                min: 0.0,
                max: 1.0,
                display: '${(_s.bgOpacity * 100).toStringAsFixed(0)}%',
                onChanged: (v) => setState(() {
                  _s.bgOpacity = v;
                  _emit();
                }),
              ),
              _slider(
                label: t.readingWidth,
                value: _s.readingWidth,
                min: 0.4,
                max: 1.0,
                display: '${(_s.readingWidth * 100).toStringAsFixed(0)}%',
                onChanged: (v) => setState(() {
                  _s.readingWidth = v;
                  _emit();
                }),
              ),
              const SizedBox(height: 8),
              Text(t.textColor,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: _colors.map((c) {
                  final selected = c.toARGB32() == _s.textColorValue;
                  return GestureDetector(
                    onTap: () => setState(() {
                      _s.textColorValue = c.toARGB32();
                      _emit();
                    }),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.blueAccent : Colors.black26,
                          width: selected ? 3 : 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.mirror),
                value: _s.mirror,
                onChanged: (v) => setState(() {
                  _s.mirror = v;
                  _emit();
                }),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.countdown),
                value: _s.countdownEnabled,
                onChanged: (v) => setState(() {
                  _s.countdownEnabled = v;
                  _emit();
                }),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider({
    required String label,
    required double value,
    required double min,
    required double max,
    required String display,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(display,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
