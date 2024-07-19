// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
// Modified for security purposes.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:yamble_yap_to_gamble_ai_game/encrypted/env.dart';

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
  static final Env env = Env.create();

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

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: env.firebaseWebApiKey,
        appId: env.firebaseWebAppId,
        messagingSenderId: env.firebaseWebMessagingSenderId,
        projectId: env.firebaseWebProjectId,
        authDomain: env.firebaseWebAuthDomain,
        storageBucket: env.firebaseWebStorageBucket,
        measurementId: env.firebaseWebMeasurementId,
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: env.firebaseAndroidApiKey,
        appId: env.firebaseAndroidAppId,
        messagingSenderId: env.firebaseAndroidMessagingSenderId,
        projectId: env.firebaseAndroidProjectId,
        storageBucket: env.firebaseAndroidStorageBucket,
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: env.firebaseIosApiKey,
        appId: env.firebaseIosAppId,
        messagingSenderId: env.firebaseIosMessagingSenderId,
        projectId: env.firebaseIosProjectId,
        storageBucket: env.firebaseIosStorageBucket,
        iosBundleId: env.firebaseIosBundleId,
      );

  static FirebaseOptions get macos => FirebaseOptions(
        apiKey: env.firebaseMacosApiKey,
        appId: env.firebaseMacosAppId,
        messagingSenderId: env.firebaseMacosMessagingSenderId,
        projectId: env.firebaseMacosProjectId,
        storageBucket: env.firebaseMacosStorageBucket,
        iosBundleId: env.firebaseMacosBundleId,
      );

  static FirebaseOptions get windows => FirebaseOptions(
        apiKey: env.firebaseWindowsApiKey,
        appId: env.firebaseWindowsAppId,
        messagingSenderId: env.firebaseWindowsMessagingSenderId,
        projectId: env.firebaseWindowsProjectId,
        storageBucket: env.firebaseWindowsStorageBucket,
        measurementId: env.firebaseWindowsMeasurementId,
      );
}