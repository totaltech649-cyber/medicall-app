// =====================================================
// FICHIER GÉNÉRÉ PAR : flutterfire configure
// NE PAS MODIFIER MANUELLEMENT
//
// INSTRUCTIONS :
// 1. Créez votre projet sur https://console.firebase.google.com
// 2. Installez FlutterFire CLI :
//      dart pub global activate flutterfire_cli
// 3. Dans ce dossier, exécutez :
//      flutterfire configure --project=VOTRE-PROJECT-ID
// Ce fichier sera automatiquement généré et rempli.
// =====================================================

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

  // ⚠️  REMPLACEZ CES VALEURS par celles générées par FlutterFire CLI
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'VOTRE-API-KEY-ANDROID',
    appId: 'VOTRE-APP-ID-ANDROID',
    messagingSenderId: 'VOTRE-SENDER-ID',
    projectId: 'VOTRE-PROJECT-ID',
    storageBucket: 'VOTRE-PROJECT-ID.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'VOTRE-API-KEY-IOS',
    appId: 'VOTRE-APP-ID-IOS',
    messagingSenderId: 'VOTRE-SENDER-ID',
    projectId: 'VOTRE-PROJECT-ID',
    storageBucket: 'VOTRE-PROJECT-ID.appspot.com',
    iosBundleId: 'com.medicall.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'VOTRE-API-KEY-WEB',
    appId: 'VOTRE-APP-ID-WEB',
    messagingSenderId: 'VOTRE-SENDER-ID',
    projectId: 'VOTRE-PROJECT-ID',
    storageBucket: 'VOTRE-PROJECT-ID.appspot.com',
    authDomain: 'VOTRE-PROJECT-ID.firebaseapp.com',
  );
}
