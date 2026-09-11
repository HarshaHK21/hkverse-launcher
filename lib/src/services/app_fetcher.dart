import 'package:flutter/services.dart';

import '../models/app_info.dart';

/// Talks to the native [Platform channel][hkverse.launcher/apps] that queries
/// the Android PackageManager and launches apps.
class AppFetcher {
  const AppFetcher();

  static const MethodChannel _channel = MethodChannel('hkverse.launcher/apps');

  Future<List<AppInfo>> getInstalledApps() async {
    final raw = await _channel.invokeListMethod<dynamic>('getInstalledApps');
    if (raw == null) return const [];

    final apps = <AppInfo>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final packageName = item['packageName']?.toString() ?? '';
      if (packageName.isEmpty) continue;

      final name = item['name']?.toString() ?? packageName;
      Uint8List? icon;
      final iconRaw = item['icon'];
      if (iconRaw is Uint8List) {
        icon = iconRaw;
      } else if (iconRaw is List) {
        icon = Uint8List.fromList(iconRaw.cast<int>());
      }

      apps.add(AppInfo(name: name, packageName: packageName, icon: icon));
    }

    apps.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return apps;
  }

  Future<bool> openApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod<bool>(
        'openApp',
        {'packageName': packageName},
      );
      return result ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}