# MealSpin - Food Picker App with Ads

A Flutter application that helps users decide what to eat by randomly selecting from a customizable list of foods, monetized with Google AdMob.

## Features

### Core Functionality
- **Random Food Picker**: Animated food selection with spinning icons and cycling food names
- **Customizable Food List**: Add, edit, and delete food items
- **Persistent Storage**: Saves food list and last selected food
- **Smart Selection**: Avoids repeating the last selected food

### Monetization
- **Banner Ads**: Non-intrusive ads displayed at the bottom of the main screen
- **Interstitial Ads**: Full-screen ads shown every 4 food picks
- **Test Ads**: Currently configured with AdMob test ad units

### Default Content
Pre-loaded with 15 popular Malaysian dishes:
- Nasi Lemak, Roti Canai, Char Kuey Teow, Satay, Rendang
- Laksa, Nasi Goreng, Mee Goreng, Curry Puff, Asam Pedas
- Murtabak, Curry Laksa, Rojak, Chicken Rice, Teh Tarik

## Ad Integration Details

### AdMob Setup
- **Package**: `google_mobile_ads: ^5.1.0`
- **Test App IDs**: 
  - Android: `ca-app-pub-3940256099942544~3347511713`
  - iOS: `ca-app-pub-3940256099942544~1458002511`

### Ad Types Implemented
1. **Banner Ads**
   - Displayed at bottom of main screen
   - Always visible when loaded
   - Standard banner size (320x50)

2. **Interstitial Ads**
   - Shown every 4 food picks
   - Full-screen experience
   - Auto-loads next ad after display

### Ad Configuration Files
- `lib/ad_helper.dart`: Contains ad unit IDs for different platforms
- Platform-specific configurations in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`

## Production Setup

### To Replace Test Ads with Real Ads:
1. Create an AdMob account at https://admob.google.com
2. Create an app in AdMob console
3. Generate ad unit IDs for banner and interstitial ads
4. Replace test IDs in `lib/ad_helper.dart` with your real ad unit IDs
5. Update app IDs in platform-specific configuration files

### Real Ad Unit ID Format:
```dart
// Replace test IDs with format: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
static String get bannerAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your Android banner ID
  } else if (Platform.isIOS) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your iOS banner ID
  }
}
```

## Getting Started

### Prerequisites
- Flutter SDK
- Dart SDK
- Android Studio / Xcode for platform-specific builds

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Testing Ads
- The app is configured with AdMob test ads that will display immediately
- Test ads show "Test Ad" label and don't generate revenue
- Banner ad appears at bottom of main screen
- Interstitial ad shows after every 4 food picks

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_fortune_wheel: ^1.3.1
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.3
  google_mobile_ads: ^5.1.0
```

## Ad Revenue Optimization Tips

1. **Ad Frequency**: Currently set to show interstitial every 4 picks - adjust based on user feedback
2. **Ad Placement**: Banner at bottom doesn't interfere with core functionality
3. **User Experience**: Ads only show after user completes an action (food selection)
4. **Future Enhancements**: Consider rewarded ads for premium features

## Development Notes

- Test ads are safe to click and won't affect your AdMob account
- Real ads should only be implemented when ready for production
- Monitor ad performance through AdMob dashboard
- Consider implementing consent forms for GDPR compliance in production

## Support

For Flutter development help, visit:
- [Flutter Documentation](https://docs.flutter.dev/)
- [AdMob Flutter Plugin](https://pub.dev/packages/google_mobile_ads)
- [AdMob Documentation](https://developers.google.com/admob/flutter)
