import 'dart:convert';
import 'dart:developer';
import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/video_download_response.dart';

class VideoDownloadProvider extends ChangeNotifier {
  VideoDownloadResponse? _videoResponse;
  bool _isLoading = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  String? _downloadedFilePath;
  String? _currentDownloadingUrl; 

  VideoDownloadResponse? get videoResponse => _videoResponse;

  bool get isLoading => _isLoading;

  bool get isDownloading => _isDownloading;

  double get downloadProgress => _downloadProgress;

  String? get errorMessage => _errorMessage;

  String? get downloadedFilePath => _downloadedFilePath;

  String? get currentDownloadingUrl => _currentDownloadingUrl;

  
  bool isDownloadingUrl(String url) => _currentDownloadingUrl == url;

  
  String _sanitizeFileName(String filename) {
    
    String sanitized = filename
        .replaceAll(RegExp(r'[^\w\s\-.]'), '_') 
        .replaceAll(RegExp(r'\s+'), '_') 
        .replaceAll(RegExp(r'_+'), '_') 
        .replaceAll(RegExp(r'[()<>]'), '') 
        .trim();

    
    if (sanitized.isEmpty) {
      sanitized = 'video_${DateTime.now().millisecondsSinceEpoch}';
    }

    return sanitized;
  }

  
  Future<void> fetchVideoInfo(
    String url,
    String apiKey,
    String apiHost,
    String baseUrl,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _videoResponse = null;
      notifyListeners();

      final headers = {
        'x-rapidapi-host': apiHost,
        'Content-Type': 'application/json',
        'x-rapidapi-key': apiKey,
      };

      final request = http.Request(
        'POST',
        Uri.parse('$baseUrl/v1/social/autolink'),
      );
      request.body = json.encode({'url': url});
      request.headers.addAll(headers);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _videoResponse = VideoDownloadResponse.fromJson(jsonData);
        _errorMessage = null;
      } else {
        _errorMessage = 'فشل في جلب معلومات الفيديو: ${response.reasonPhrase}';
      }
    } catch (e) {
      _errorMessage = 'خطأ في الاتصال: $e';
      log(_errorMessage!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  
  Future<String?> downloadVideo(String videoUrl, String filename) async {
    try {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _errorMessage = null;
      _currentDownloadingUrl = videoUrl; 
      notifyListeners();

      
      
      final directory = await getTemporaryDirectory();

      
      final sanitizedFilename = _sanitizeFileName(filename);
      final filePath = '${directory.path}/$sanitizedFilename';
      final file = File(filePath);

      
      if (await file.exists()) {
        await file.delete();
      }

      final request = await http.Client().send(
        http.Request('GET', Uri.parse(videoUrl)),
      );
      final contentLength = request.contentLength ?? 0;

      var received = 0;
      final sink = file.openWrite();

      await for (var chunk in request.stream) {
        sink.add(chunk);
        received += chunk.length;

        if (contentLength > 0) {
          _downloadProgress = received / contentLength;
          notifyListeners();
        }
      }

      await sink.close();

      _downloadedFilePath = filePath;
      _isDownloading = false;
      _downloadProgress = 1.0;
      _currentDownloadingUrl = null;
      notifyListeners();

      return filePath;
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الفيديو: $e';
      _isDownloading = false;
      _currentDownloadingUrl = null;
      notifyListeners();
      return null;
    }
  }

  void reset() {
    _videoResponse = null;
    _isLoading = false;
    _isDownloading = false;
    _downloadProgress = 0.0;
    _errorMessage = null;
    _downloadedFilePath = null;
    _currentDownloadingUrl = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

