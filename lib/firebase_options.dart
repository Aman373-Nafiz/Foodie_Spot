// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAR5d85WU8ysiwCQl_o7xaZmMrN4mn0vk4',
    appId: '1:558244785517:web:0775f716186d5f8a35fe64',
    messagingSenderId: '558244785517',
    projectId: 'foodiespot-37039',
    authDomain: 'foodiespot-37039.firebaseapp.com',
    storageBucket: 'foodiespot-37039.firebasestorage.app',
    measurementId: 'G-Z36LG2FRCC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEYRCDyk9OQRhJ7Aaf1gXVP6TE-WiQ3Kw',
    appId: '1:558244785517:android:17e8c7282349f55735fe64',
    messagingSenderId: '558244785517',
    projectId: 'foodiespot-37039',
    storageBucket: 'foodiespot-37039.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVcAuMJJ2CZEaCPe63H7cajFiPL_4V3HM',
    appId: '1:558244785517:ios:a90cb3d8b45c807335fe64',
    messagingSenderId: '558244785517',
    projectId: 'foodiespot-37039',
    storageBucket: 'foodiespot-37039.firebasestorage.app',
    iosBundleId: 'com.example.foodiespot',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCVcAuMJJ2CZEaCPe63H7cajFiPL_4V3HM',
    appId: '1:558244785517:ios:a90cb3d8b45c807335fe64',
    messagingSenderId: '558244785517',
    projectId: 'foodiespot-37039',
    storageBucket: 'foodiespot-37039.firebasestorage.app',
    iosBundleId: 'com.example.foodiespot',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAR5d85WU8ysiwCQl_o7xaZmMrN4mn0vk4',
    appId: '1:558244785517:web:5644eb1a642cf52735fe64',
    messagingSenderId: '558244785517',
    projectId: 'foodiespot-37039',
    authDomain: 'foodiespot-37039.firebaseapp.com',
    storageBucket: 'foodiespot-37039.firebasestorage.app',
    measurementId: 'G-RRF2KB9J9L',
  );
}
