# Teleprompter No Ads

A free, offline **camera teleprompter** for Android. No ads. Forever.

Part of the **365 Days App Challenge · Day 6** by Ir. Riovan Styx Roring.

## Features

- 📷 Live **front camera** preview filling the screen (selfie-camera teleprompter)
- 📜 Scrolling script text overlaid on the preview
- ✍️ Editable scripts — paste / type and save multiple scripts (offline, on-device)
- ▶️ Scroll controls — play / pause, adjustable speed, restart
- 🎚️ Text controls — font size, line height, color, background opacity, reading width
- 🪞 **Mirror mode** for beam-splitter / glass teleprompter rigs
- ⏱️ 3-2-1 countdown before scrolling starts
- 💡 **Front-camera flash** — hardware torch if present, otherwise a bright screen-glow
  fallback with max screen brightness (restored when turned off)
- 🎥 Record video while reading your script
- 🌐 English / Bahasa Indonesia

## Tech

- Flutter (stable) · Material 3
- `camera`, `screen_brightness`, `shared_preferences`, `wakelock_plus`,
  `permission_handler`, `path_provider`, `url_launcher`

## Build

APKs and App Bundles are built automatically by GitHub Actions
(`.github/workflows/build.yml`) and attached to a GitHub Release.

Signing is optional: run the **Generate Keystore** workflow once and add the
4 secrets it prints (`KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_PASSWORD`,
`KEY_ALIAS`) to get signed releases. Without secrets the release builds
**unsigned** (still installable via sideload after enabling unknown sources).

## Credits

Created by: **Ir. Riovan Styx Roring**

- TikTok: https://www.tiktok.com/@ir.riovansroring
- Instagram: https://www.instagram.com/ir.riovansroring/
- YouTube: https://youtube.com/@ir.riovanroring
