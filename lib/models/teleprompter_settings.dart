import 'package:flutter/material.dart';

/// User-tunable teleprompter display + scroll settings. Persisted as JSON.
class TeleprompterSettings {
  double fontSize;
  double lineHeight;
  double scrollSpeed; // logical pixels per second
  int textColorValue; // ARGB int
  double bgOpacity; // 0..1 opacity of the dark panel behind text
  double readingWidth; // 0..1 fraction of screen width used for text
  bool mirror;
  bool countdownEnabled;

  TeleprompterSettings({
    this.fontSize = 32,
    this.lineHeight = 1.5,
    this.scrollSpeed = 40,
    this.textColorValue = 0xFFFFFFFF,
    this.bgOpacity = 0.45,
    this.readingWidth = 0.9,
    this.mirror = false,
    this.countdownEnabled = true,
  });

  Color get textColor => Color(textColorValue);
  set textColor(Color c) => textColorValue = c.toARGB32();

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'lineHeight': lineHeight,
        'scrollSpeed': scrollSpeed,
        'textColorValue': textColorValue,
        'bgOpacity': bgOpacity,
        'readingWidth': readingWidth,
        'mirror': mirror,
        'countdownEnabled': countdownEnabled,
      };

  factory TeleprompterSettings.fromJson(Map<String, dynamic> json) =>
      TeleprompterSettings(
        fontSize: (json['fontSize'] as num?)?.toDouble() ?? 32,
        lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.5,
        scrollSpeed: (json['scrollSpeed'] as num?)?.toDouble() ?? 40,
        textColorValue: (json['textColorValue'] as num?)?.toInt() ?? 0xFFFFFFFF,
        bgOpacity: (json['bgOpacity'] as num?)?.toDouble() ?? 0.45,
        readingWidth: (json['readingWidth'] as num?)?.toDouble() ?? 0.9,
        mirror: (json['mirror'] as bool?) ?? false,
        countdownEnabled: (json['countdownEnabled'] as bool?) ?? true,
      );

  TeleprompterSettings copy() => TeleprompterSettings.fromJson(toJson());
}
