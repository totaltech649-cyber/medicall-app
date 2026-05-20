import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions non configuré pour cette plateforme.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPymKpRJUn7SK1T05-L0qBPJ20kDiDe6E',
    appId: '1:661505990382:android:8a2431b68978638cfe9dff',
    messagingSenderId: '661505990382',
    projectId: 'medicall-bad5b',
    storageBucket: 'medicall-bad5b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'VOTRE-API-KEY-IOS',
    appId: 'VOTRE-APP-ID-IOS',
    messagingSenderId: '661505990382',
    projectId: 'medicall-bad5b',
    storageBucket: 'medicall-bad5b.firebasestorage.app',
    iosBundleId: 'com.example.medicallapp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'VOTRE-API-KEY-WEB',
    appId: 'VOTRE-APP-ID-WEB',
    messagingSenderId: '661505990382',
    projectId: 'medicall-bad5b',
    storageBucket: 'medicall-bad5b.firebasestorage.app',
    authDomain: 'medicall-bad5b.firebaseapp.com',
  );
}
