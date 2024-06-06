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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB7sjgBkdCDhtW-b8s0oGJqcjxD8NgKBAI',
    appId: '1:217605384987:web:536a1c755470df6dd601be',
    messagingSenderId: '217605384987',
    projectId: 'hanap-app',
    authDomain: 'hanap-app.firebaseapp.com',
    storageBucket: 'hanap-app.appspot.com',
    measurementId: 'G-MLB0WZPWQ6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGm0N1JBV5mCPKaOFn630tORfy8GR-0m8',
    appId: '1:217605384987:android:408fcc2c3d598cb8d601be',
    messagingSenderId: '217605384987',
    projectId: 'hanap-app',
    storageBucket: 'hanap-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA3CuEs2Dsox5g5HLcQ8AbFh9JFXs9kS6c',
    appId: '1:217605384987:ios:829ceb3659272922d601be',
    messagingSenderId: '217605384987',
    projectId: 'hanap-app',
    storageBucket: 'hanap-app.appspot.com',
    iosBundleId: 'com.example.hanap',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA3CuEs2Dsox5g5HLcQ8AbFh9JFXs9kS6c',
    appId: '1:217605384987:ios:829ceb3659272922d601be',
    messagingSenderId: '217605384987',
    projectId: 'hanap-app',
    storageBucket: 'hanap-app.appspot.com',
    iosBundleId: 'com.example.hanap',
  );
}
