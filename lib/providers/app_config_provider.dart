import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/app_config.dart';

class AppConfigProvider extends ChangeNotifier {
  static const String _collectionName = 'videoapp-config';
  static const String _documentName = 'config';

  AppConfig _config = AppConfig.defaultConfig();
  bool _isLoading = true;
  String? _errorMessage;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  AppConfig get config => _config;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> get _configDocument =>
      _firestore.collection(_collectionName).doc(_documentName);

  AppConfigProvider() {
    loadConfig().then((_) => listenToConfigChanges());
  }

  Future<void> loadConfig() async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _configDocument.get();

      if (doc.exists && doc.data() != null) {
        _config = AppConfig.fromFirestore(doc.data()!);
      } else {
        await createDefaultConfig();
      }

      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحميل الإعدادات: $e';
      _isLoading = false;
      _config = AppConfig.defaultConfig();
      notifyListeners();
    }
  }

  Future<void> createDefaultConfig() async {
    try {
      final defaultConfig = AppConfig.defaultConfig();
      await _configDocument.set(defaultConfig.toMap());
      _config = defaultConfig;
    } catch (e) {
      debugPrint('خطأ في إنشاء الإعدادات الافتراضية: $e');
    }
  }

  Future<void> updateConfig(AppConfig newConfig) async {
    try {
      await _configDocument.set(newConfig.toMap(), SetOptions(merge: true));
      _config = newConfig;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'خطأ في تحديث الإعدادات: $e';
      notifyListeners();
    }
  }

  void listenToConfigChanges() {
    try {
      _subscription?.cancel();
      _subscription = _configDocument.snapshots().listen(
        (snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            _config = AppConfig.fromFirestore(snapshot.data()!);
            notifyListeners();
          }
        },
        onError: (error) {
          _errorMessage = 'خطأ في الاستماع للتغييرات: $error';
          notifyListeners();
        },
      );
    } catch (error) {
      _errorMessage = 'تعذر تشغيل تحديثات الإعدادات: $error';
      debugPrint(_errorMessage);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
