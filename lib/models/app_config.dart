class AppConfig {
  final bool isVideoEdit;
  final String rapidApiBaseUrl;
  final String rapidApiKey;
  final String rapidApiHost;
  final bool enableVideoDownload;
  final bool enableVideoEdit;
  final bool enableAds;
  final bool productionMode;

  AppConfig({
    required this.isVideoEdit,
    required this.rapidApiBaseUrl,
    required this.rapidApiKey,
    required this.rapidApiHost,
    this.enableVideoDownload = true,
    this.enableVideoEdit = true,
    this.enableAds = true,
    this.productionMode = true,
  });

  factory AppConfig.fromFirestore(Map<String, dynamic> data) {
    return AppConfig(
      isVideoEdit: data['isVideoEdit'] ?? true,
      rapidApiBaseUrl:
          data['rapidApiBaseUrl'] ??
          'https://auto-download-all-in-one.p.rapidapi.com',
      rapidApiKey: data['rapidApiKey'] ?? '',
      rapidApiHost:
          data['rapidApiHost'] ?? 'auto-download-all-in-one.p.rapidapi.com',
      enableVideoDownload: data['enableVideoDownload'] ?? true,
      enableVideoEdit: data['enableVideoEdit'] ?? true,
      enableAds: data['enableAds'] ?? true,
      productionMode: data['productionmode'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isVideoEdit': isVideoEdit,
      'rapidApiBaseUrl': rapidApiBaseUrl,
      'rapidApiKey': rapidApiKey,
      'rapidApiHost': rapidApiHost,
      'enableVideoDownload': enableVideoDownload,
      'enableVideoEdit': enableVideoEdit,
      'enableAds': enableAds,
      'productionmode': productionMode,
    };
  }

  // Default config
  factory AppConfig.defaultConfig() {
    return AppConfig(
      isVideoEdit: true,
      rapidApiBaseUrl: 'https://auto-download-all-in-one.p.rapidapi.com',
      rapidApiKey: '239d768d8cmshd49361eb49f1af5p1ab3fejsn6ed58d950752',
      rapidApiHost: 'auto-download-all-in-one.p.rapidapi.com',
      enableVideoDownload: true,
      enableVideoEdit: true,
      enableAds: true,
      productionMode: true,
    );
  }
}
