import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/script.dart';
import '../models/teleprompter_settings.dart';

/// Persists scripts, teleprompter settings and the chosen language using
/// shared_preferences (JSON encoded).
class StorageService {
  static const _kScripts = 'scripts';
  static const _kSettings = 'settings';
  static const _kLanguage = 'language';

  // ---- Language ----
  Future<String?> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLanguage);
  }

  Future<void> saveLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, code);
  }

  // ---- Settings ----
  Future<TeleprompterSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSettings);
    if (raw == null) return TeleprompterSettings();
    try {
      return TeleprompterSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return TeleprompterSettings();
    }
  }

  Future<void> saveSettings(TeleprompterSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSettings, jsonEncode(settings.toJson()));
  }

  // ---- Scripts ----
  Future<List<Script>> loadScripts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kScripts);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Script.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<Script> scripts) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(scripts.map((s) => s.toJson()).toList());
    await prefs.setString(_kScripts, raw);
  }

  Future<List<Script>> upsertScript(Script script) async {
    final scripts = await loadScripts();
    final idx = scripts.indexWhere((s) => s.id == script.id);
    if (idx >= 0) {
      scripts[idx] = script;
    } else {
      scripts.insert(0, script);
    }
    await _saveAll(scripts);
    return scripts;
  }

  Future<List<Script>> deleteScript(String id) async {
    final scripts = await loadScripts();
    scripts.removeWhere((s) => s.id == id);
    await _saveAll(scripts);
    return scripts;
  }
}
