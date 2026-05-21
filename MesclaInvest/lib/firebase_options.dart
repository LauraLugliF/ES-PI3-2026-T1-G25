import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9-iK5F_agTCg2yjn26b1qOG15xy2zvkU',
    appId: '1:358487499986:android:50ae2fe7f13223bbab390b',
    messagingSenderId: '358487499986',
    projectId: 'pi3-time25',
    storageBucket: 'pi3-time25.firebasestorage.app',
  );
}
