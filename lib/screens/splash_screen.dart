import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/storage_service.dart';
import '../widgets/credits_bar.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = StorageService();
  String _code = 'en';

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final saved = await _storage.loadLanguage();
    if (saved != null && mounted) {
      setState(() => _code = saved);
    }
  }

  Future<void> _continue() async {
    await _storage.saveLanguage(_code);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen(code: _code)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Strings(_code);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chrome_reader_mode,
                        size: 96, color: scheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Teleprompter No Ads',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s.challengeBadge,
                        style: TextStyle(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(s.chooseLanguage,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    _LangTile(
                      label: s.english,
                      selected: _code == 'en',
                      onTap: () => setState(() => _code = 'en'),
                    ),
                    const SizedBox(height: 8),
                    _LangTile(
                      label: s.indonesian,
                      selected: _code == 'id',
                      onTap: () => setState(() => _code = 'id'),
                    ),
                    const SizedBox(height: 32),
                    FilledButton.icon(
                      onPressed: _continue,
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(s.continueLabel),
                    ),
                  ],
                ),
              ),
            ),
            const CreditsBar(),
          ],
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 280,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? scheme.primaryContainer : null,
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2 : 1,
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (selected)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(Icons.check_circle,
                    size: 18, color: scheme.primary),
              ),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
