import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/video_editor_provider.dart';
import '../services/ad_service.dart';
import '../utils/app_colors.dart';
import '../utils/permissions_helper.dart';
import '../widgets/studio_brand.dart';
import 'edit_screen.dart';
import 'merge_screen.dart';
import 'player_screen.dart';
import 'settings_screen.dart';
import 'trim_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPicking = false;

  Future<void> _pickVideo(ImageSource source) async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    try {
      // The system gallery picker does not need broad photos/storage access.
      if (source == ImageSource.camera) {
        final cameraAllowed = await PermissionsHelper.requestCameraPermission();
        final micAllowed =
            await PermissionsHelper.requestMicrophonePermission();
        if (!cameraAllowed || !micAllowed) {
          if (mounted) {
            await _showPermissionMessage(
              permissions: const [Permission.camera, Permission.microphone],
              message: 'نحتاج إذن الكاميرا والميكروفون لتصوير فيديو جديد.',
            );
          }
          return;
        }
      }

      final file = await _picker.pickVideo(source: source);
      if (file != null && mounted) {
        await context.read<VideoEditorProvider>().loadVideo(file.path);
      }
    } catch (_) {
      if (mounted) _showSnack('تعذّر فتح الفيديو، حاول مرة أخرى.');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _pickWithAd(ImageSource source) {
    AdService.showInterstitialAd(onAdDismissed: () => _pickVideo(source));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VideoEditorProvider>();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 124),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 610),
                child: provider.videoPath == null
                    ? _buildWelcomeContent()
                    : _buildSelectedVideo(provider),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeContent() {
    return Column(
      children: [
        StudioAppBar(
          onSettings: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 45,
              height: 15,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color(0xFF4C9B83),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF151A23),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ستوديو المونتاج الذكي',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 3),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'أدوات احترافية لقص، تحسين وفلترة الفيديوهات بلمسة واحدة\nسينمائية',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.65,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 26),
        _buildProjectCard(),
        const SizedBox(height: 28),
        _buildQuickTools(),
      ],
    );
  }

  Widget _buildProjectCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 27),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        gradient: const LinearGradient(
          colors: [Color(0xFF142729), Color(0xFF181C24), Color(0xFF22211F)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: const Color(0xFF1C292C)),
      ),
      child: Column(
        children: [
          Container(
            width: 101,
            height: 101,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: .92),
              borderRadius: BorderRadius.circular(23),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.video_library_outlined,
                  color: AppColors.primary,
                  size: 48,
                ),
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF095144),
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'ابدأ مشروعك الإبداعي الجديد',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'يدعم تنسيقات 60fps، 4K HDR، Dolby Vision مع فصل المسارات\nالصوتية',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          MintButton(
            label: _isPicking ? 'جاري فتح المعرض...' : 'اختر فيديو من المعرض',
            icon: Icons.file_open_outlined,
            onPressed: () => _pickWithAd(ImageSource.gallery),
            busy: _isPicking,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: _isPicking
                  ? null
                  : () => _pickWithAd(ImageSource.camera),
              icon: const Icon(
                Icons.videocam_outlined,
                color: AppColors.accent,
              ),
              label: const Text('تصوير مقطع جديد فورًا'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.surfaceLight,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTools() {
    const tools = [
      (Icons.auto_fix_off_outlined, 'إزالة العلامة', AppColors.primary),
      (Icons.content_cut_rounded, 'قص تلقائي', AppColors.accent),
      (Icons.high_quality_outlined, 'ترقية 4K', Color(0xFF65DFAF)),
      (Icons.graphic_eq_rounded, 'فصل الصوت', Color(0xFFAAA6E9)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(Icons.bolt_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                'أدوات المونتاج السريعة',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              'الذكاء التوليدي',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tools.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final tool = tools[index];
              return InkWell(
                onTap: () => _pickWithAd(ImageSource.gallery),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: 108,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(tool.$1, color: tool.$3, size: 28),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        tool.$2,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedVideo(VideoEditorProvider provider) {
    final path = provider.processedVideoPath ?? provider.videoPath!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StudioAppBar(onClose: provider.reset),
        const SizedBox(height: 22),
        const Text(
          'مشروعك جاهز للتحرير',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'اختر أداة وابدأ التعديل باحترافية.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 22),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PlayerScreen(videoPath: path)),
          ),
          child: Container(
            height: 215,
            decoration: BoxDecoration(
              color: const Color(0xFF070B11),
              borderRadius: BorderRadius.circular(24),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (provider.thumbnailPath != null)
                  Image.file(File(provider.thumbnailPath!), fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xAA000000)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    color: AppColors.primary,
                    size: 62,
                  ),
                ),
                if (provider.metadata != null)
                  Positioned(
                    right: 15,
                    bottom: 13,
                    child: Text(
                      '${provider.metadata!.width}×${provider.metadata!.height}  •  ${(provider.metadata!.duration / 1000).round()} ثانية',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 11,
          crossAxisSpacing: 11,
          childAspectRatio: 2.25,
          children: [
            _editAction(
              'قص الفيديو',
              Icons.content_cut_rounded,
              () => _open(TrimScreen(videoPath: provider.videoPath!)),
            ),
            _editAction(
              'دمج الفيديوهات',
              Icons.video_collection_outlined,
              () => _open(MergeScreen(mainVideoPath: provider.videoPath!)),
            ),
            _editAction(
              'تغيير السرعة',
              Icons.speed_rounded,
              () => _open(
                EditScreen(
                  videoPath: provider.videoPath!,
                  editType: EditType.speed,
                ),
              ),
            ),
            _editAction(
              'ضغط الفيديو',
              Icons.compress_rounded,
              () => _open(
                EditScreen(
                  videoPath: provider.videoPath!,
                  editType: EditType.compress,
                ),
              ),
            ),
            _editAction(
              'تدوير الفيديو',
              Icons.rotate_90_degrees_ccw_outlined,
              () => _open(
                EditScreen(
                  videoPath: provider.videoPath!,
                  editType: EditType.rotate,
                ),
              ),
            ),
            _editAction(
              'تغيير الأبعاد',
              Icons.crop_rounded,
              () => _open(
                EditScreen(
                  videoPath: provider.videoPath!,
                  editType: EditType.crop,
                ),
              ),
            ),
          ],
        ),
        if (provider.isProcessing) ...[
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: provider.exportProgress,
            color: AppColors.primary,
            backgroundColor: AppColors.outline,
          ),
        ],
      ],
    );
  }

  Widget _editAction(String label, IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppColors.primary, size: 21),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _open(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _showPermissionMessage({
    required List<Permission> permissions,
    required String message,
  }) async {
    var permanentlyDenied = false;
    for (final permission in permissions) {
      if (await permission.isPermanentlyDenied) {
        permanentlyDenied = true;
        break;
      }
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          permanentlyDenied
              ? 'فعّل الأذونات المطلوبة من إعدادات الهاتف.'
              : message,
        ),
        action: permanentlyDenied
            ? SnackBarAction(label: 'الإعدادات', onPressed: openAppSettings)
            : null,
        backgroundColor: const Color(0xFF8B5A28),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFB84949),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
