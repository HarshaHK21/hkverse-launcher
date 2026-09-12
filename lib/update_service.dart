import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_installer/flutter_app_installer.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  static final Uri _latestReleaseUri = Uri.parse(
    'https://api.github.com/repos/HarshaHK21/hkverse-launcher/releases/latest',
  );

  final FlutterAppInstaller _appInstaller = FlutterAppInstaller();

  Future<void> checkAndDownloadUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final releaseResponse = await http.get(
        _latestReleaseUri,
        headers: {
          'Accept': 'application/vnd.github+json',
          'User-Agent': '${packageInfo.packageName}/${packageInfo.version}',
        },
      );

      if (releaseResponse.statusCode != HttpStatus.ok) {
        throw HttpException(
          'Could not check for updates (HTTP ${releaseResponse.statusCode}).',
        );
      }

      final release = jsonDecode(releaseResponse.body) as Map<String, dynamic>;
      final apkUrl = _findApkUrl(release);
      if (apkUrl == null) {
        throw StateError('The latest release does not contain an APK asset.');
      }

      if (!context.mounted) return;
      final shouldDownload = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          content: const Text(
            'New Update Available. Do you want to download and install?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('No'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (shouldDownload != true || !context.mounted) return;

      _showLoadingDialog(context);
      try {
        final temporaryDirectory = await getTemporaryDirectory();
        final apkFile = File('${temporaryDirectory.path}/hkverse-latest.apk');
        final downloadResponse = await http.get(Uri.parse(apkUrl));
        if (downloadResponse.statusCode != HttpStatus.ok) {
          throw HttpException(
            'Could not download update (HTTP ${downloadResponse.statusCode}).',
          );
        }

        await apkFile.writeAsBytes(downloadResponse.bodyBytes, flush: true);
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        await _appInstaller.installApk(filePath: apkFile.path);
      } catch (_) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        rethrow;
      }
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $error')));
    }
  }

  String? _findApkUrl(Map<String, dynamic> release) {
    final assets = release['assets'];
    if (assets is! List) return null;

    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;
      final downloadUrl = asset['browser_download_url'];
      if (downloadUrl is String && downloadUrl.toLowerCase().endsWith('.apk')) {
        return downloadUrl;
      }
    }
    return null;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Expanded(child: Text('Downloading update...')),
          ],
        ),
      ),
    );
  }
}
