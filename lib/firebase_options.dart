
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDiiAytIyMzWZ3_HqleZxZUUQgpFnKz6CA',
    appId: '1:234949198999:android:75b65ee70f87aacb5d15d2',
    messagingSenderId: '234949198999',
    projectId: 'videodownloud',
    storageBucket: 'videodownloud.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC3ExXYYGAki0O75JkCLQ6vmQLm7iDDY-o',
    appId: '1:234949198999:ios:e198457c0a9209975d15d2',
    messagingSenderId: '234949198999',
    projectId: 'videodownloud',
    storageBucket: 'videodownloud.firebasestorage.app',
    iosBundleId: 'com.tolba.videoDownloudApp',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA59O4L0465EqjGLTda-Emp3miIfKaSDG0',
    appId: '1:309893999371:ios:d7140928c54d377af5100e',
    messagingSenderId: '309893999371',
    projectId: 'alzeeb-b60e3',
    storageBucket: 'alzeeb-b60e3.firebasestorage.app',
    iosBundleId: 'com.example.videoEditingApp',
  );

}
