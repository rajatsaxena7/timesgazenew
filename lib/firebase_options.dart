// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDAZkAd60cGw5mMnZ1jALZ7EUW1jtjqmh0',
    appId: '1:318926159367:web:29587eea330cf9b2d6b4a2',
    messagingSenderId: '318926159367',
    projectId: 'timesgaze-41052',
    authDomain: 'timesgaze-41052.firebaseapp.com',
    storageBucket: 'timesgaze-41052.appspot.com',
    measurementId: 'G-1F1LL7RZC1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBuDTUncLInc4CDZPSlEa9mt7dxpH6Jxvk',
    appId: '1:318926159367:android:73145b12c5634f7bd6b4a2',
    messagingSenderId: '318926159367',
    projectId: 'timesgaze-41052',
    storageBucket: 'timesgaze-41052.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYM1usMVnin9ZrKEbaPwwfTsPse0lYZwY',
    appId: '1:318926159367:ios:019b7802101e1ab0d6b4a2',
    messagingSenderId: '318926159367',
    projectId: 'timesgaze-41052',
    storageBucket: 'timesgaze-41052.appspot.com',
    iosBundleId: 'com.timesgaze.timesgaze',
  );
}
