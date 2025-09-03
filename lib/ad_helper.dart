import 'dart:io';
import 'package:flutter/foundation.dart';

class AdHelper {
  // Real Ad Unit IDs for Android, Test IDs for iOS, Disable for Web
  static String get bannerAdUnitId {
    if (kIsWeb) {
      return ''; // Web doesn't support AdMob
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-5222428175679569/3241114031'; // Real Android banner
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test banner for iOS
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) {
      return ''; // Web doesn't support AdMob
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-5222428175679569/9334914948'; // Real Android interstitial
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // Test interstitial for iOS
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) {
      return ''; // Web doesn't support AdMob
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // Test rewarded for Android (not created yet)
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test rewarded for iOS
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static bool get isAdSupported {
    return !kIsWeb; // Ads are only supported on mobile platforms
  }
}
