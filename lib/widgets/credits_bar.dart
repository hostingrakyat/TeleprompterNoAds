import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Bottom credits bar shown on every screen.
class CreditsBar extends StatelessWidget {
  final bool transparent;
  const CreditsBar({super.key, this.transparent = false});

  static const _tiktok = 'https://www.tiktok.com/@ir.riovansroring';
  static const _instagram = 'https://www.instagram.com/ir.riovansroring/';
  static const _youtube = 'https://youtube.com/@ir.riovanroring';

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Silently ignore - no browser / handler available.
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = transparent ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      color: transparent ? Colors.black54 : Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Created by: Ir. Riovan Styx Roring',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w500),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LinkButton(label: 'TikTok', icon: Icons.music_note, color: fg, onTap: () => _open(_tiktok)),
              _LinkButton(label: 'Instagram', icon: Icons.camera_alt, color: fg, onTap: () => _open(_instagram)),
              _LinkButton(label: 'YouTube', icon: Icons.play_circle_fill, color: fg, onTap: () => _open(_youtube)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _LinkButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
