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
    apiKey: 'AIzaSyD0m7YAenDIfISP65DuusHsm4Gxb6Tr9HU',
    appId: '1:948576209897:web:937fe7cf916b8e62305978',
    messagingSenderId: '948576209897',
    projectId: 'zegoapp-3db9a',
    authDomain: 'zegoapp-3db9a.firebaseapp.com',
    storageBucket: 'zegoapp-3db9a.appspot.com',
    measurementId: 'G-2BZ5T6XEBK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzEtaQ781zV5XtHWx4OCpfJaJysDP6GJ0',
    appId: '1:948576209897:android:25064fdc2f903650305978',
    messagingSenderId: '948576209897',
    projectId: 'zegoapp-3db9a',
    storageBucket: 'zegoapp-3db9a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCK4j9irWbMff7iz_JJtfg8U9iVL9REg-c',
    appId: '1:948576209897:ios:e70588015f1a759e305978',
    messagingSenderId: '948576209897',
    projectId: 'zegoapp-3db9a',
    storageBucket: 'zegoapp-3db9a.appspot.com',
    iosBundleId: 'com.example.zego',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCK4j9irWbMff7iz_JJtfg8U9iVL9REg-c',
    appId: '1:948576209897:ios:e70588015f1a759e305978',
    messagingSenderId: '948576209897',
    projectId: 'zegoapp-3db9a',
    storageBucket: 'zegoapp-3db9a.appspot.com',
    iosBundleId: 'com.example.zego',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD0m7YAenDIfISP65DuusHsm4Gxb6Tr9HU',
    appId: '1:948576209897:web:93d927314dd167ad305978',
    messagingSenderId: '948576209897',
    projectId: 'zegoapp-3db9a',
    authDomain: 'zegoapp-3db9a.firebaseapp.com',
    storageBucket: 'zegoapp-3db9a.appspot.com',
    measurementId: 'G-113FQXVMKN',
  );
}
