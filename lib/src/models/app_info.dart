import 'dart:typed_data';

/// A single installed application exposed to the launcher UI.
class AppInfo {
  const AppInfo({
    required this.name,
    required this.packageName,
    this.icon,
  });

  final String name;
  final String packageName;

  /// Pre-sized PNG bytes (square), or null when the icon could not be loaded.
  final Uint8List? icon;
}