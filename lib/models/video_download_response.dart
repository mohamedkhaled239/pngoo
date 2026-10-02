class VideoDownloadResponse {
  final String url;
  final String source;
  final String id;
  final String uniqueId;
  final String author;
  final String title;
  final String thumbnail;
  final int duration;
  final List<MediaItem> medias;
  final String type;
  final bool error;
  final int timeEnd;

  VideoDownloadResponse({
    required this.url,
    required this.source,
    required this.id,
    required this.uniqueId,
    required this.author,
    required this.title,
    required this.thumbnail,
    required this.duration,
    required this.medias,
    required this.type,
    required this.error,
    required this.timeEnd,
  });

  factory VideoDownloadResponse.fromJson(Map<String, dynamic> json) {
    return VideoDownloadResponse(
      url: json['url'] ?? '',
      source: json['source'] ?? '',
      id: json['id'] ?? '',
      uniqueId: json['unique_id'] ?? '',
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: _parseToInt(json['duration']),
      medias: (json['medias'] as List?)
          ?.map((item) => MediaItem.fromJson(item))
          .toList() ??
          [],
      type: json['type'] ?? '',
      error: json['error'] ?? false,
      timeEnd: _parseToInt(json['time_end']),
    );
  }

  
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class MediaItem {
  final String url;
  final int? dataSize;
  final String quality;
  final String extension;
  final String type;
  final int? duration;

  MediaItem({
    required this.url,
    this.dataSize,
    required this.quality,
    required this.extension,
    required this.type,
    this.duration,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      url: json['url'] ?? '',
      dataSize: _parseToIntNullable(json['data_size']),
      quality: (json['quality'] ?? '').toString(),
      extension: json['extension'] ?? '',
      type: json['type'] ?? '',
      duration: _parseToIntNullable(json['duration']),
    );
  }

  
  static int? _parseToIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  String get qualityLabel {
    switch (quality) {
      case 'hd_no_watermark':
        return 'HD بدون علامة مائية';
      case 'no_watermark':
        return 'بدون علامة مائية';
      case 'audio':
        return 'صوت فقط';
      default:
        return quality;
    }
  }

  String get sizeInMB {
    if (dataSize == null) return 'غير معروف';
    return '${(dataSize! / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

