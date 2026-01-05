import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefautlFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // case TargetPlatform.iOS:
      //   return ios;
      // case TargetPlatform.macOS:
      //   return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGFNlCh35_LBPCAg11_XcgNG6eRCPnbso',
    appId: '1:402511373458:android:34e1a4bf3c21f83a3e724b',
    messagingSenderId: '402511373458',
    projectId: 'task-manager-66ea7',
    databaseURL: 'https://task-manager-66ea7-default-rtdb.firebaseio.com',
    storageBucket: 'task-manager-66ea7.firebasestorage.app',
  );
}
