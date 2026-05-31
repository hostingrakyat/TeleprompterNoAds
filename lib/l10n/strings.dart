/// Lightweight manual EN / ID localization keyed by language code.
class Strings {
  final String code;
  const Strings(this.code);

  bool get isId => code == 'id';

  String get appTitle => 'Teleprompter No Ads';

  String get chooseLanguage => isId ? 'Pilih Bahasa' : 'Choose Language';
  String get english => 'English';
  String get indonesian => 'Bahasa Indonesia';
  String get continueLabel => isId ? 'Lanjutkan' : 'Continue';

  String get challengeBadge => '365 Days App Challenge · Day 6';
  String get createdBy => 'Created by: Ir. Riovan Styx Roring';

  String get myScripts => isId ? 'Naskah Saya' : 'My Scripts';
  String get noScripts =>
      isId ? 'Belum ada naskah. Ketuk + untuk membuat.' : 'No scripts yet. Tap + to create one.';
  String get newScript => isId ? 'Naskah Baru' : 'New Script';
  String get editScript => isId ? 'Edit Naskah' : 'Edit Script';
  String get title => isId ? 'Judul' : 'Title';
  String get scriptText => isId ? 'Teks Naskah' : 'Script Text';
  String get save => isId ? 'Simpan' : 'Save';
  String get delete => isId ? 'Hapus' : 'Delete';
  String get deleteConfirm =>
      isId ? 'Hapus naskah ini?' : 'Delete this script?';
  String get cancel => isId ? 'Batal' : 'Cancel';
  String get untitled => isId ? 'Tanpa Judul' : 'Untitled';
  String get pasteHint =>
      isId ? 'Tempel atau ketik naskah Anda di sini...' : 'Paste or type your script here...';

  String get open => isId ? 'Buka' : 'Open';
  String get settings => isId ? 'Pengaturan' : 'Settings';
  String get fontSize => isId ? 'Ukuran Font' : 'Font Size';
  String get lineHeight => isId ? 'Tinggi Baris' : 'Line Height';
  String get scrollSpeed => isId ? 'Kecepatan Gulir' : 'Scroll Speed';
  String get textColor => isId ? 'Warna Teks' : 'Text Color';
  String get bgOpacity => isId ? 'Opasitas Latar' : 'Background Opacity';
  String get readingWidth => isId ? 'Lebar Baca' : 'Reading Width';
  String get mirror => isId ? 'Mode Cermin' : 'Mirror Mode';
  String get countdown => isId ? 'Hitung Mundur (3-2-1)' : 'Countdown (3-2-1)';

  String get play => isId ? 'Putar' : 'Play';
  String get pause => isId ? 'Jeda' : 'Pause';
  String get restart => isId ? 'Ulang' : 'Restart';
  String get flash => isId ? 'Lampu Kilat' : 'Flash';
  String get record => isId ? 'Rekam' : 'Record';
  String get stop => isId ? 'Berhenti' : 'Stop';
  String get done => isId ? 'Selesai' : 'Done';

  String get cameraPermissionNeeded => isId
      ? 'Izin kamera diperlukan untuk teleprompter.'
      : 'Camera permission is required for the teleprompter.';
  String get grantPermission => isId ? 'Beri Izin' : 'Grant Permission';
  String get openSettings => isId ? 'Buka Pengaturan' : 'Open Settings';
  String get noCamera =>
      isId ? 'Kamera depan tidak ditemukan.' : 'No front camera found.';

  String savedTo(String path) =>
      isId ? 'Video disimpan: $path' : 'Video saved: $path';
  String get recordingStarted =>
      isId ? 'Merekam...' : 'Recording...';
  String get recordingError =>
      isId ? 'Gagal merekam video.' : 'Failed to record video.';
}
