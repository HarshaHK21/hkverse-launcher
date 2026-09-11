import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hkverse_launcher/main.dart';

const _channel = MethodChannel('hkverse.launcher/apps');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  testWidgets('renders clock and lists installed apps A-Z', (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
      if (call.method == 'getInstalledApps') {
        return [
          {
            'name': 'YouTube',
            'packageName': 'com.google.android.youtube',
            'icon': null,
          },
          {
            'name': 'Gmail',
            'packageName': 'com.google.android.gm',
            'icon': Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]),
          },
          {
            'name': '31 Music',
            'packageName': 'com.example.music31',
            'icon': null,
          },
        ];
      }
      return null;
    });

    await tester.pumpWidget(const HkverseLauncherApp());
    await tester.pump();
    await tester.pump();

    expect(find.text('Gmail'), findsOneWidget);
    expect(find.text('YouTube'), findsOneWidget);

    // Sorted A-Z: '31 Music' ('#'), Gmail (G), YouTube (Y).
    final gmailY = tester.getTopLeft(find.text('Gmail')).dy;
    final youtubeY = tester.getTopLeft(find.text('YouTube')).dy;
    expect(gmailY, lessThan(youtubeY));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('shows error state when the platform channel fails',
      (tester) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      _channel,
      (call) async => throw PlatformException(code: 'FAILED'),
    );

    await tester.pumpWidget(const HkverseLauncherApp());
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Unable to load installed apps'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}