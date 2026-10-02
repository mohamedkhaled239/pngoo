import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_config_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'video_download_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeNotifications());
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService().initialize();
    } catch (error, stackTrace) {
      debugPrint('Notification startup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configProvider = context.watch<AppConfigProvider>();
    if (configProvider.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final config = configProvider.config;
    // Downloading is a core feature and is always available. The legacy
    // enableVideoDownload Firestore value is intentionally ignored.
    if (!config.enableVideoEdit) {
      return const VideoDownloadScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: const [VideoDownloadScreen(), HomeScreen()],
      ),
      bottomNavigationBar: _StudioNavigationBar(
        selectedIndex: _currentIndex,
        onSelected: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

class _StudioNavigationBar extends StatelessWidget {
  const _StudioNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(isTablet ? 32 : 20, 0, isTablet ? 32 : 20, 14),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Container(
            height: 80,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFF1E232D),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: const Color(0xFF252C37)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x99050B11),
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                _item(0, 'تنزيل الفيديو', Icons.cloud_download_outlined),
                _item(1, 'تحرير الفيديو', Icons.video_settings_outlined),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(int index, String label, IconData icon) {
    final selected = selectedIndex == index;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: () => onSelected(index),
          borderRadius: BorderRadius.circular(34),
          child: AnimatedContainer(
            height: double.infinity,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(34),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: .22),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: selected
                      ? const Color(0xFF075244)
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 9),
                Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF075244)
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
