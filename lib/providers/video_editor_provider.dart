import 'package:easy_video_editor/easy_video_editor.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class VideoEditorProvider extends ChangeNotifier {
  String? _videoPath;
  String? _processedVideoPath;
  String? _thumbnailPath;
  VideoMetadata? _metadata;
  double _exportProgress = 0.0;
  bool _isProcessing = false;
  String? _errorMessage;

  String? get videoPath => _videoPath;
  String? get processedVideoPath => _processedVideoPath;
  String? get thumbnailPath => _thumbnailPath;
  VideoMetadata? get metadata => _metadata;
  double get exportProgress => _exportProgress;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  Future<void> loadVideo(String path) async {
    try {
      _videoPath = path;
      _processedVideoPath = null;
      _errorMessage = null;

      final editor = VideoEditorBuilder(videoPath: path);
      _metadata = await editor.getVideoMetadata();

      
      _thumbnailPath = await editor.generateThumbnail(
        positionMs: 1000,
        quality: 85,
        width: 320,
        height: 240,
      );

      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الفيديو: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<String?> trimVideo(int startMs, int endMs) async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      final editor = VideoEditorBuilder(videoPath: _videoPath!)
          .trim(startTimeMs: startMs, endTimeMs: endMs);

      final outputPath = await editor.export(
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );

      _processedVideoPath = outputPath;
      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في قص الفيديو: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> mergeVideos(List<String> otherPaths) async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      final editor = VideoEditorBuilder(videoPath: _videoPath!)
          .merge(otherVideoPaths: otherPaths);

      final outputPath = await editor.export(
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );

      _processedVideoPath = outputPath;
      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في دمج الفيديو: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> changeSpeed(double speed) async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      final editor = VideoEditorBuilder(videoPath: _videoPath!)
          .speed(speed: speed);

      final outputPath = await editor.export(
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );

      _processedVideoPath = outputPath;
      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في تغيير السرعة: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> removeAudio() async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      final editor = VideoEditorBuilder(videoPath: _videoPath!)
          .removeAudio();

      final outputPath = await editor.export(
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );

      _processedVideoPath = outputPath;
      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في إزالة الصوت: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> extractAudio() async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      final editor = VideoEditorBuilder(videoPath: _videoPath!);

      final outputPath = await editor.extractAudio(
        outputPath: '${_videoPath!}_audio.m4a',
      );

      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في استخراج الصوت: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> rotateVideo(RotationDegree degree) async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      final editor = VideoEditorBuilder(videoPath: _videoPath!)
          .rotate(degree: degree);

      final outputPath = await editor.export(
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );

      _processedVideoPath = outputPath;
      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في تدوير الفيديو: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> cropVideo(VideoAspectRatio aspectRatio) async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      final editor = VideoEditorBuilder(videoPath: _videoPath!)
          .crop(aspectRatio: aspectRatio);

      final outputPath = await editor.export(
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );

      _processedVideoPath = outputPath;
      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في اقتصاص الفيديو: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> compressVideo(VideoResolution resolution) async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      final editor = VideoEditorBuilder(videoPath: _videoPath!)
          .compress(resolution: resolution);

      final outputPath = await editor.export(
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );

      _processedVideoPath = outputPath;
      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في ضغط الفيديو: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> flipVideo(FlipDirection direction) async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      final editor = VideoEditorBuilder(videoPath: _videoPath!)
          .flip(flipDirection: direction);

      final outputPath = await editor.export(
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );

      _processedVideoPath = outputPath;
      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في قلب الفيديو: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> applyMultipleOperations(Map<String, dynamic> operations) async {
    try {
      _isProcessing = true;
      _exportProgress = 0.0;
      notifyListeners();

      VideoEditorBuilder editor = VideoEditorBuilder(videoPath: _videoPath!);

      if (operations.containsKey('trim')) {
        final trim = operations['trim'] as Map<String, int>;
        editor = editor.trim(
          startTimeMs: trim['start']!,
          endTimeMs: trim['end']!,
        );
      }

      if (operations.containsKey('speed')) {
        editor = editor.speed(speed: operations['speed'] as double);
      }

      if (operations.containsKey('removeAudio') && operations['removeAudio'] == true) {
        editor = editor.removeAudio();
      }

      if (operations.containsKey('rotate')) {
        editor = editor.rotate(degree: operations['rotate'] as RotationDegree);
      }

      if (operations.containsKey('crop')) {
        editor = editor.crop(aspectRatio: operations['crop'] as VideoAspectRatio);
      }

      if (operations.containsKey('compress')) {
        editor = editor.compress(resolution: operations['compress'] as VideoResolution);
      }

      if (operations.containsKey('flip')) {
        editor = editor.flip(flipDirection: operations['flip'] as FlipDirection);
      }

      final outputPath = await editor.export(
        onProgress: (progress) {
          _exportProgress = progress;
          notifyListeners();
        },
      );

      _processedVideoPath = outputPath;
      _isProcessing = false;
      notifyListeners();
      return outputPath;
    } catch (e) {
      _errorMessage = 'خطأ في تطبيق العمليات: $e';
      _isProcessing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> generateNewThumbnail(int positionMs) async {
    try {
      final editor = VideoEditorBuilder(videoPath: _videoPath!);

      _thumbnailPath = await editor.generateThumbnail(
        positionMs: positionMs,
        quality: 85,
        width: 320,
        height: 240,
      );

      notifyListeners();
      return _thumbnailPath;
    } catch (e) {
      _errorMessage = 'خطأ في توليد الثامبنيل: $e';
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _videoPath = null;
    _processedVideoPath = null;
    _thumbnailPath = null;
    _metadata = null;
    _exportProgress = 0.0;
    _isProcessing = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> saveProcessedVideoToGallery() async {
    if (_processedVideoPath == null) {
      _errorMessage = 'لا يوجد فيديو معدل للحفظ';
      notifyListeners();
      return false;
    }

    try {
      await Gal.putVideo(_processedVideoPath!, album: 'تطبيق تحرير الفيديو');
      return true;
    } catch (e) {
      _errorMessage = 'خطأ في حفظ الفيديو: $e';
      notifyListeners();
      return false;
    }
  }

  String? getProcessedVideoPathForSharing() {
    return _processedVideoPath;
  }
}
