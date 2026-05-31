import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../l10n/strings.dart';
import '../models/script.dart';
import '../models/teleprompter_settings.dart';
import '../services/storage_service.dart';
import '../widgets/credits_bar.dart';
import '../widgets/settings_sheet.dart';

class TeleprompterScreen extends StatefulWidget {
  final String code;
  final Script script;
  const TeleprompterScreen({
    super.key,
    required this.code,
    required this.script,
  });

  @override
  State<TeleprompterScreen> createState() => _TeleprompterScreenState();
}

class _TeleprompterScreenState extends State<TeleprompterScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _storage = StorageService();
  final _scrollController = ScrollController();

  CameraController? _controller;
  bool _cameraReady = false;
  bool _permissionDenied = false;
  bool _noCamera = false;

  TeleprompterSettings _settings = TeleprompterSettings();

  Ticker? _ticker;
  Duration _lastElapsed = Duration.zero;
  bool _playing = false;
  int _countdown = 0; // 0 = not counting

  bool _flashOn = false;
  bool _brightnessBoosted = false;

  bool _isRecording = false;

  Strings get s => Strings(widget.code);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _init();
  }

  Future<void> _init() async {
    _settings = await _storage.loadSettings();
    if (mounted) setState(() {});
    await _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cam = await Permission.camera.request();
    await Permission.microphone.request();
    if (!cam.isGranted) {
      if (mounted) setState(() => _permissionDenied = true);
      return;
    }

    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.isNotEmpty
            ? cameras.first
            : throw Exception('no camera'),
      );
      final controller = CameraController(
        front,
        ResolutionPreset.high,
        enableAudio: true,
      );
      await controller.initialize();
      try {
        await controller.setFlashMode(FlashMode.off);
      } catch (_) {}
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cameraReady = true;
      });
    } catch (_) {
      if (mounted) setState(() => _noCamera = true);
    }
  }

  // ---- Scrolling ----
  void _onTick(Duration elapsed) {
    final dt = (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (!_playing || !_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final next = _scrollController.offset + _settings.scrollSpeed * dt;
    if (next >= max) {
      _scrollController.jumpTo(max);
      _pause();
    } else {
      _scrollController.jumpTo(next);
    }
  }

  Future<void> _play() async {
    if (_playing || _countdown != 0) return;
    if (_settings.countdownEnabled) {
      for (var n = 3; n >= 1; n--) {
        if (!mounted) return;
        setState(() => _countdown = n);
        await Future.delayed(const Duration(seconds: 1));
      }
      if (!mounted) return;
      setState(() => _countdown = 0);
    }
    _lastElapsed = Duration.zero;
    _ticker ??= createTicker(_onTick);
    if (!_ticker!.isActive) _ticker!.start();
    setState(() => _playing = true);
  }

  void _pause() {
    _ticker?.stop();
    if (mounted) setState(() => _playing = false);
  }

  void _restart() {
    _pause();
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  // ---- Flash (front camera) ----
  Future<void> _toggleFlash() async {
    final turnOn = !_flashOn;
    setState(() => _flashOn = turnOn);
    // 1) Try hardware torch first (most front cameras have none -> no-op/throws).
    try {
      await _controller?.setFlashMode(
          turnOn ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      // ignore - fall back to screen glow below.
    }
    // 2) Screen-flash fallback: boost brightness; white glow overlay is drawn
    //    in build() while _flashOn is true.
    if (turnOn) {
      try {
        await ScreenBrightness.instance.setApplicationScreenBrightness(1.0);
        _brightnessBoosted = true;
      } catch (_) {}
    } else {
      await _restoreBrightness();
    }
    if (mounted) setState(() {});
  }

  Future<void> _restoreBrightness() async {
    if (!_brightnessBoosted) return;
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (_) {}
    _brightnessBoosted = false;
  }

  // ---- Recording ----
  Future<void> _toggleRecording() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (_isRecording) {
      try {
        final file = await c.stopVideoRecording();
        final saved = await _persistVideo(file);
        _snack(s.savedTo(saved));
      } catch (_) {
        _snack(s.recordingError);
      }
      if (mounted) setState(() => _isRecording = false);
    } else {
      try {
        await c.startVideoRecording();
        if (mounted) setState(() => _isRecording = true);
        _snack(s.recordingStarted);
      } catch (_) {
        _snack(s.recordingError);
      }
    }
  }

  Future<String> _persistVideo(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final name = 'teleprompter_${DateTime.now().millisecondsSinceEpoch}.mp4';
    final dest = p.join(dir.path, name);
    await file.saveTo(dest);
    return dest;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  // ---- Settings ----
  Future<void> _openSettings() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => SettingsSheet(
        code: widget.code,
        settings: _settings,
        onChanged: (s) {
          setState(() => _settings = s);
          _storage.saveSettings(s);
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.dispose();
    _scrollController.dispose();
    _restoreBrightness();
    try {
      _controller?.setFlashMode(FlashMode.off);
    } catch (_) {}
    _controller?.dispose();
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody()),
            const CreditsBar(transparent: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_permissionDenied) return _permissionView();
    if (_noCamera) return Center(child: Text(s.noCamera));
    if (!_cameraReady || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _cameraPreview(),
        if (_flashOn) _screenGlow(),
        _textOverlay(),
        if (_countdown > 0) _countdownView(),
        _topBar(),
        _controls(),
      ],
    );
  }

  Widget _cameraPreview() {
    final controller = _controller!;
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(child: CameraPreview(controller)),
      ),
    );
  }

  // Bright white ring that illuminates the subject when no hardware torch.
  Widget _screenGlow() {
    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 48),
        ),
      ),
    );
  }

  Widget _textOverlay() {
    final width = MediaQuery.of(context).size.width * _settings.readingWidth;
    Widget content = Container(
      width: width,
      color: Colors.black.withValues(alpha: _settings.bgOpacity),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        widget.script.body.isEmpty ? '...' : widget.script.body,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _settings.textColor,
          fontSize: _settings.fontSize,
          height: _settings.lineHeight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (_settings.mirror) {
      content = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
        child: content,
      );
    }

    return Positioned.fill(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Leading space so text starts below the top bar.
            SizedBox(height: MediaQuery.of(context).size.height * 0.45),
            Center(child: content),
            SizedBox(height: MediaQuery.of(context).size.height * 0.6),
          ],
        ),
      ),
    );
  }

  Widget _countdownView() {
    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: Text(
          '$_countdown',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 120,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Positioned(
      top: 8,
      left: 8,
      right: 8,
      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.script.title.trim().isEmpty
                  ? s.untitled
                  : widget.script.title.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black)],
              ),
            ),
          ),
          if (_isRecording)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text('REC',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _controls() {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _circleButton(
                  icon: Icons.restart_alt,
                  onTap: _restart,
                  tooltip: s.restart,
                ),
                _circleButton(
                  icon: _playing ? Icons.pause : Icons.play_arrow,
                  onTap: _playing ? _pause : _play,
                  tooltip: _playing ? s.pause : s.play,
                  big: true,
                ),
                _circleButton(
                  icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                  onTap: _toggleFlash,
                  tooltip: s.flash,
                  highlight: _flashOn,
                ),
                _circleButton(
                  icon: _isRecording ? Icons.stop : Icons.videocam,
                  onTap: _toggleRecording,
                  tooltip: _isRecording ? s.stop : s.record,
                  highlight: _isRecording,
                ),
                _circleButton(
                  icon: Icons.tune,
                  onTap: _openSettings,
                  tooltip: s.settings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    bool big = false,
    bool highlight = false,
  }) {
    final btn = Material(
      color: highlight ? Colors.amber : Colors.white24,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(big ? 12 : 8),
          child: Icon(
            icon,
            color: highlight ? Colors.black : Colors.white,
            size: big ? 32 : 24,
          ),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }

  Widget _permissionView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography, size: 64, color: Colors.white70),
            const SizedBox(height: 16),
            Text(
              s.cameraPermissionNeeded,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                FilledButton(
                  onPressed: () async {
                    setState(() => _permissionDenied = false);
                    await _setupCamera();
                  },
                  child: Text(s.grantPermission),
                ),
                OutlinedButton(
                  onPressed: openAppSettings,
                  child: Text(s.openSettings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
