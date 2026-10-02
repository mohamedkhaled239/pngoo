import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_config_provider.dart';
import '../providers/video_download_provider.dart';
import '../services/ad_service.dart';
import '../utils/app_colors.dart';
import '../widgets/studio_brand.dart';

class VideoDownloadScreen extends StatefulWidget {
  const VideoDownloadScreen({super.key});

  @override
  State<VideoDownloadScreen> createState() => _VideoDownloadScreenState();
}

class _VideoDownloadScreenState extends State<VideoDownloadScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeAds());
  }

  Future<void> _initializeAds() async {
    if (!mounted) return;
    final enabled = context.read<AppConfigProvider>().config.enableAds;
    AdService.setAdsEnabled(enabled);
    if (!enabled) return;
    await AdService.initialize();
    if (!mounted) return;
    AdService.loadInterstitialAd();
    AdService.loadAppOpenAd();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final value = data?.text?.trim();
    if (value != null && value.isNotEmpty) {
      _urlController.text = value;
      setState(() {});
    }
  }

  Future<void> _downloadVideo() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _focusNode.unfocus();
    setState(() => _isDownloading = true);
    AdService.showInterstitialAd(onAdDismissed: _performDownloadProcess);
  }

  Future<void> _performDownloadProcess() async {
    final config = context.read<AppConfigProvider>().config;
    final provider = context.read<VideoDownloadProvider>();
    final strings = AppLocalizations.of(context)!;
    try {
      await provider.fetchVideoInfo(
        _urlController.text.trim(),
        config.rapidApiKey,
        config.rapidApiHost,
        config.rapidApiBaseUrl,
      );
      if (provider.errorMessage != null) {
        _showMessage(provider.errorMessage!, error: true);
        return;
      }

      var videos = provider.videoResponse!.medias
          .where((media) => media.type.toLowerCase() == 'video')
          .toList();
      final cleanVideos = videos
          .where((media) => !media.quality.toLowerCase().contains('watermark'))
          .toList();
      if (cleanVideos.isNotEmpty) {
        videos = cleanVideos;
      }
      videos.sort(
        (a, b) => (int.tryParse(b.quality) ?? 0).compareTo(
          int.tryParse(a.quality) ?? 0,
        ),
      );
      if (videos.isEmpty) {
        _showMessage(strings.noVideoFound, error: true);
        return;
      }

      final video = videos.first;
      final fileName =
          '${provider.videoResponse!.id}_${video.quality}.${video.extension}';
      final path = await provider.downloadVideo(video.url, fileName);
      if (path == null) {
        _showMessage(strings.downloadFailed, error: true);
        return;
      }
      await Gal.putVideo(path, album: strings.albumName);
      if (!mounted) return;
      _showMessage(strings.downloadSuccess);
      _urlController.clear();
      provider.reset();
      setState(() {});
    } catch (error) {
      log(error.toString());
      if (mounted) {
        _showMessage('تعذّر تنزيل الفيديو. حاول مرة أخرى.', error: true);
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth >= 600;
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 32 : 20,
                  isTablet ? 24 : 18,
                  isTablet ? 32 : 20,
                  124,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 760 : 610,
                    ),
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 14),
                        _buildAutoDetectStatus(),
                        const SizedBox(height: 18),
                        const Text(
                          'تنزيل فوري بدقة فائقة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'الصق رابط الفيديو لحفظه مباشرةً في المعرض بأعلى\nدقة وبدون أي علامة مائية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 27),
                        _buildDownloadCard(),
                        _AdaptiveBannerSlot(
                          enabled: context
                              .watch<AppConfigProvider>()
                              .config
                              .enableAds,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const StudioAppBar();
  }

  Widget _buildAutoDetectStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF397E6B),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 8, height: 8),
              ),
            ),
          ),
          SizedBox(width: 9),
          Text(
            'كاشف الروابط التلقائي نشط',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadCard() {
    final provider = context.watch<VideoDownloadProvider>();
    final productionMode = context
        .watch<AppConfigProvider>()
        .config
        .productionMode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFF202733)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.link_rounded,
                  color: AppColors.primary,
                  size: 19,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    productionMode
                        ? 'رابط الفيديو المطلوب'
                        : 'رابط الملف المطلوب',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (productionMode)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10151D),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(width: 6, height: 6),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'تيك توك مكتشف',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 9),
            TextFormField(
              controller: _urlController,
              focusNode: _focusNode,
              enabled: !_isDownloading,
              textDirection: TextDirection.ltr,
              onChanged: (_) => setState(() {}),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ألصق رابط الفيديو أولًا';
                }
                if (!value.trim().startsWith('http')) return 'الرابط غير صحيح';
                return null;
              },
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: productionMode
                    ? 'https://www.tiktok.com/@user/video/...'
                    : 'https://example.com/document.pdf',
                hintStyle: const TextStyle(
                  color: Color(0xFF7D8691),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFF090E16),
                prefixIcon: IconButton(
                  tooltip: 'مسح',
                  onPressed: _urlController.text.isEmpty
                      ? null
                      : () {
                          _urlController.clear();
                          setState(() {});
                        },
                  icon: const Icon(Icons.close_rounded, size: 21),
                  color: AppColors.textSecondary,
                ),
                suffixIcon: IconButton(
                  tooltip: 'لصق',
                  onPressed: _isDownloading ? null : _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste_outlined, size: 21),
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                errorStyle: const TextStyle(
                  color: Color(0xFFFF8879),
                  fontWeight: FontWeight.w600,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 17,
                ),
              ),
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isDownloading ? null : _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste_go_outlined, size: 22),
                    label: const Text('لصق من الحافظة'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.surfaceLight,
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'استخراج تلقائي فوري',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'المنصات والصيغ المدعومة بأعلى دقة',
              style: TextStyle(
                color: Color(0xFF747F84),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                const _PlatformChip(
                  label: 'PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  active: true,
                ),
                const _PlatformChip(
                  label: 'Word',
                  icon: Icons.description_outlined,
                  active: true,
                ),
                const _PlatformChip(
                  label: 'Text',
                  icon: Icons.text_snippet_outlined,
                  active: true,
                ),
                if (productionMode) ...const [
                  _PlatformChip(
                    label: 'تيك توك',
                    icon: Icons.play_circle_outline,
                    active: true,
                  ),
                  _PlatformChip(
                    label: 'ريلز إنستغرام',
                    icon: Icons.movie_outlined,
                  ),
                  _PlatformChip(
                    label: 'شورتس يوتيوب',
                    icon: Icons.smart_display_outlined,
                  ),
                  _PlatformChip(label: 'إكس', icon: Icons.bolt_rounded),
                ],
              ],
            ),
            const SizedBox(height: 18),
            if (_isDownloading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: provider.downloadProgress == 0
                      ? null
                      : provider.downloadProgress,
                  minHeight: 5,
                  color: AppColors.primary,
                  backgroundColor: AppColors.outline,
                ),
              ),
              const SizedBox(height: 10),
            ],
            MintButton(
              label: _isDownloading
                  ? 'جاري تجهيز الفيديو ${provider.downloadProgress > 0 ? '${(provider.downloadProgress * 100).round()}%' : ''}'
                  : productionMode
                  ? 'تنزيل الفيديو'
                  : 'تنزيل الملف',
              icon: Icons.download_for_offline_outlined,
              onPressed: _downloadVideo,
              busy: _isDownloading,
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: error
            ? const Color(0xFFB84949)
            : AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    );
  }
}

class _AdaptiveBannerSlot extends StatefulWidget {
  const _AdaptiveBannerSlot({required this.enabled});

  final bool enabled;

  @override
  State<_AdaptiveBannerSlot> createState() => _AdaptiveBannerSlotState();
}

class _AdaptiveBannerSlotState extends State<_AdaptiveBannerSlot> {
  BannerAd? _bannerAd;
  AdSize? _bannerSize;
  int? _requestedWidth;
  bool _loadScheduled = false;
  bool _isLoaded = false;

  @override
  void didUpdateWidget(covariant _AdaptiveBannerSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) {
      _disposeBanner();
    } else if (!oldWidget.enabled && widget.enabled) {
      _requestedWidth = null;
    }
  }

  void _scheduleLoad(int width) {
    if (_loadScheduled || !widget.enabled || width <= 0) return;
    if (_requestedWidth == width && _bannerAd != null) return;

    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      if (mounted) _loadBanner(width);
    });
  }

  Future<void> _loadBanner(int width) async {
    _requestedWidth = width;
    await AdService.initialize();
    if (!mounted || !widget.enabled || !AdService.canLoadAds) return;

    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width);
    if (!mounted || size == null || _requestedWidth != width) return;

    _disposeBanner(keepRequestedWidth: true);
    final ad = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          if (!mounted || !identical(_bannerAd, loadedAd)) {
            loadedAd.dispose();
            return;
          }
          setState(() {
            _bannerSize = size;
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (failedAd, error) {
          debugPrint('Banner failed to load: ${error.message}');
          failedAd.dispose();
          if (mounted && identical(_bannerAd, failedAd)) {
            setState(() {
              _bannerAd = null;
              _bannerSize = null;
              _isLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd = ad;
    await ad.load();
  }

  void _disposeBanner({bool keepRequestedWidth = false}) {
    _bannerAd?.dispose();
    _bannerAd = null;
    _bannerSize = null;
    _isLoaded = false;
    if (!keepRequestedWidth) _requestedWidth = null;
  }

  @override
  void dispose() {
    _disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.floor();
        if (widget.enabled && width != _requestedWidth) {
          _scheduleLoad(width);
        }

        final ad = _bannerAd;
        final size = _bannerSize;
        if (!widget.enabled || !_isLoaded || ad == null || size == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Center(
            child: SizedBox(
              width: size.width.toDouble(),
              height: size.height.toDouble(),
              child: AdWidget(ad: ad),
            ),
          ),
        );
      },
    );
  }
}

class _PlatformChip extends StatelessWidget {
  const _PlatformChip({
    required this.label,
    required this.icon,
    this.active = false,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF123B32) : const Color(0xFF0E141C),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: active ? AppColors.primary : AppColors.textSecondary,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.primary : AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
