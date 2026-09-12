import 'package:flutter/material.dart';

import '../models/app_info.dart';
import '../services/app_fetcher.dart';
import '../theme.dart';
import '../widgets/alphabet_index.dart';
import '../widgets/app_list.dart';
import '../widgets/clock_widget.dart';
import '../../update_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const double _itemExtent = 64;

  final AppFetcher _fetcher = const AppFetcher();
  final ScrollController _scrollController = ScrollController();

  List<AppInfo> _apps = const [];
  bool _loading = true;
  String _errorMessage = '';

  List<String> _letters = const [];
  final Map<String, int> _sectionStart = {};
  String _activeLetter = '#';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadApps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadApps();
    }
  }

  Future<void> _loadApps() async {
    try {
      final apps = await _fetcher.getInstalledApps();
      if (!mounted) return;
      setState(() {
        _apps = apps;
        _loading = false;
        _errorMessage = '';
        _rebuildSections();
        if (_apps.isNotEmpty) {
          _activeLetter = _letterOf(_apps[0].name);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Unable to load installed apps.';
      });
    }
  }

  void _rebuildSections() {
    final letters = <String>[];
    final start = <String, int>{};
    for (var i = 0; i < _apps.length; i++) {
      final letter = _letterOf(_apps[i].name);
      if (!start.containsKey(letter)) {
        start[letter] = i;
        letters.add(letter);
      }
    }
    _letters = letters;
    _sectionStart
      ..clear()
      ..addAll(start);
  }

  static String _letterOf(String name) {
    if (name.isEmpty) return '#';
    final first = name[0];
    if (RegExp(r'^[a-zA-Z]$').hasMatch(first)) return first.toUpperCase();
    return '#';
  }

  void _onScroll() {
    if (_apps.isEmpty || !_scrollController.hasClients) return;
    final firstVisible = (_scrollController.offset / _itemExtent).floor().clamp(
      0,
      _apps.length - 1,
    );
    final letter = _letterOf(_apps[firstVisible].name);
    if (letter != _activeLetter) {
      setState(() => _activeLetter = letter);
    }
  }

  void _scrollToLetter(String letter) {
    final startIndex = _sectionStart[letter];
    if (startIndex == null) return;
    final target = (startIndex * _itemExtent).toDouble().clamp(
      0.0,
      _scrollController.hasClients
          ? _scrollController.position.maxScrollExtent
          : double.infinity,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _launchApp(AppInfo app) {
    _fetcher.openApp(app.packageName);
  }

  void _showLauncherSettings() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'Launcher Settings',
                  style: TextStyle(
                    fontFamily: AppTypography.display,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.system_update,
                  color: AppColors.accent,
                ),
                title: const Text(
                  'Check for Updates',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  UpdateService().checkAndDownloadUpdate(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomizeSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(28, 20, 28, 32),
          child: Text(
            'Customize HKVerse',
            style: TextStyle(
              fontFamily: AppTypography.display,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: _showLauncherSettings,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const _Background(),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: ClockWidget(),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28),
                      child: Text(
                        'Choose Your Productivity Features',
                        style: TextStyle(
                          fontFamily: AppTypography.body,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 1.4,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: _buildBody()),
                  ],
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, right: 16),
                    child: IconButton(
                      tooltip: 'Customize HKVerse',
                      onPressed: _showCustomizeSheet,
                      icon: const Icon(Icons.tune_rounded),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2.5,
        ),
      );
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: AppColors.textMuted),
        ),
      );
    }
    if (_apps.isEmpty) {
      return const Center(
        child: Text(
          'No apps found',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 46),
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(left: 24, right: 8, bottom: 28),
            itemExtent: _itemExtent,
            physics: const ClampingScrollPhysics(),
            itemCount: _apps.length,
            itemBuilder: (context, index) {
              final app = _apps[index];
              return AppListItem(app: app, onTap: () => _launchApp(app));
            },
          ),
        ),
        Positioned(
          top: 4,
          bottom: 4,
          right: 2,
          child: AlphabetIndex(
            letters: _letters,
            activeLetter: _activeLetter,
            onLetterSelected: _scrollToLetter,
          ),
        ),
      ],
    );
  }
}

/// A light glass overlay that retains the system wallpaper behind the launcher.
class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.7, -0.8),
              radius: 1.5,
              colors: [
                Color(0x381B0E22),
                Color(0x26030213),
                Color(0x26030213),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Positioned(
          right: -48,
          bottom: -64,
          child: Transform.rotate(
            angle: -0.12,
            child: const Text(
              'HK',
              style: TextStyle(
                fontFamily: AppTypography.display,
                fontWeight: FontWeight.w800,
                fontSize: 220,
                letterSpacing: 4,
                color: Color(0x0AFFFFFF),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
