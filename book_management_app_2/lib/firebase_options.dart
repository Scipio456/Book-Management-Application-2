
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: '1:786312443932:android:xxxxxxxxxxxx',
    messagingSenderId: '786312443932',
    projectId: 'book-application-app-2',
    storageBucket: 'book-application-app-2.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: '1:786312443932:ios:8fdfe4189943c999e607d9',
    messagingSenderId: '786312443932',
    projectId: 'book-application-app-2',
    storageBucket: 'book-application-app-2.appspot.com',
    iosBundleId: 'com.example.bookManagementApp2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-macos-api-key',
    appId: '1:786312443932:ios:8fdfe4189943c999e607d9',
    messagingSenderId: '786312443932',
    projectId: 'book-application-app-2',
    storageBucket: 'book-application-app-2.appspot.com',
    iosBundleId: 'com.example.bookManagementApp2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-windows-api-key',
    appId: '1:786312443932:web:f5c3917c4bcc5055e607d9',
    messagingSenderId: '786312443932',
    projectId: 'book-application-app-2',
    storageBucket: 'book-application-app-2.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyCepq_Dney7sfesKUCUZWcOJagBr8L-I-w",
      authDomain: "book-application-app-2.firebaseapp.com",
      projectId: "book-application-app-2",
      storageBucket: "book-application-app-2.firebasestorage.app",
      messagingSenderId: "786312443932",
      appId: "1:786312443932:web:2e4c824f7e37774fe607d9",
      measurementId: "G-8RRVLVXDNH"
  );
}