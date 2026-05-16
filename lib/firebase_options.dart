import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBbtydnl4P3oEf2vFqx-NadSjA0xWSYjWg',
    appId: '1:995496544985:web:92d6f507a31e159bd54cc8',
    messagingSenderId: '995496544985',
    projectId: 'educationpath-6e767',
    authDomain: 'educationpath-6e767.firebaseapp.com',
    storageBucket: 'educationpath-6e767.firebasestorage.app',
    measurementId: 'G-MF51JK19XW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBb_t6WEFfOUqcGTqxhcS359GHu40nJFzA',
    appId: '1:995496544985:android:23a407be4aaa8fded54cc8',
    messagingSenderId: '995496544985',
    projectId: 'educationpath-6e767',
    storageBucket: 'educationpath-6e767.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDItzfz4r0Rk0TY2enUxyCO4od-IEU1XsE',
    appId: '1:995496544985:ios:0769a35f48b093f3d54cc8',
    messagingSenderId: '995496544985',
    projectId: 'educationpath-6e767',
    storageBucket: 'educationpath-6e767.firebasestorage.app',
    iosBundleId: 'com.example.educationPath',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDItzfz4r0Rk0TY2enUxyCO4od-IEU1XsE',
    appId: '1:995496544985:ios:0769a35f48b093f3d54cc8',
    messagingSenderId: '995496544985',
    projectId: 'educationpath-6e767',
    storageBucket: 'educationpath-6e767.firebasestorage.app',
    iosBundleId: 'com.example.educationPath',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBbtydnl4P3oEf2vFqx-NadSjA0xWSYjWg',
    appId: '1:995496544985:web:702af45947349cd0d54cc8',
    messagingSenderId: '995496544985',
    projectId: 'educationpath-6e767',
    authDomain: 'educationpath-6e767.firebaseapp.com',
    storageBucket: 'educationpath-6e767.firebasestorage.app',
    measurementId: 'G-G1B3YZ523B',
  );
}
