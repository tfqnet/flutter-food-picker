import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'food_storage.dart';
import 'manage_foods.dart';
import 'ad_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Only initialize AdMob on supported platforms (not web)
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }
  
  runApp(const FoodPickerApp());
}

class FoodPickerApp extends StatelessWidget {
  const FoodPickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealSpin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const FoodPickerPage(),
    );
  }
}

class FoodPickerPage extends StatefulWidget {
  const FoodPickerPage({super.key});

  @override
  State<FoodPickerPage> createState() => _FoodPickerPageState();
}

class _FoodPickerPageState extends State<FoodPickerPage> {
  /// Using defaults defined in ManageFoodsPage
  /// Default list if user has none saved yet
  static const List<String> _defaults = [
    'Nasi Lemak', 'Roti Canai', 'Char Kuey Teow', 'Satay', 'Rendang',
    'Laksa', 'Nasi Goreng', 'Mee Goreng', 'Curry Puff', 'Asam Pedas',
    'Murtabak', 'Curry Laksa', 'Rojak', 'Chicken Rice', 'Teh Tarik'
  ];

  /// Icons used purely for the loading animation (don't need to match the label)
  static const List<IconData> _cycleIcons = [
    Icons.local_pizza,
    Icons.fastfood,
    Icons.ramen_dining,
    Icons.rice_bowl,
    Icons.set_meal,
    Icons.dinner_dining,
    Icons.lunch_dining,
    Icons.local_cafe,
  ];

  final Random _random = Random();

  List<String> _foods = [];
  String? _lastFood;             // persisted last pick
  String _displayedFood = 'Tap "Pick Food" to choose!';
  IconData _currentIcon = Icons.restaurant_menu;

  bool _isCycling = false;
  Timer? _iconTimer;
  Timer? _labelTimer;
  int _iconIndex = 0;
  int _labelIndex = 0;

  // Ad related variables
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  int _pickCount = 0; // Track picks to show interstitial ads

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    
    // Only load ads on supported platforms (Android/iOS, not web)
    if (AdHelper.isAdSupported) {
      _loadBannerAd();
      _loadInterstitialAd();
    }
  }

  void _loadBannerAd() {
    if (!AdHelper.isAdSupported) return;
    
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          print('Banner ad loaded successfully');
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load banner ad: ${err.message}');
          print('Error code: ${err.code}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }

  void _loadInterstitialAd() {
    if (!AdHelper.isAdSupported) return;
    
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('Interstitial ad loaded successfully');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          _interstitialAd!.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('Interstitial ad failed to load: $error');
          print('Error code: ${error.code}');
          _interstitialAd = null;
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  void _showInterstitialAd() {
    if (!AdHelper.isAdSupported || !_isInterstitialAdReady) {
      if (!AdHelper.isAdSupported) {
        print('Ads not supported on this platform');
      } else {
        print('Interstitial ad not ready');
      }
      return;
    }
    
    print('Showing interstitial ad');
    _interstitialAd!.show();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
    _loadInterstitialAd(); // Load next ad
  }

  Future<void> _loadSavedData() async {
    final savedList = await FoodStorage.loadFoodList();
    final last = await FoodStorage.loadLastFood();

    setState(() {
      _foods = savedList.isEmpty ? List<String>.from(_defaults) : savedList;
      _lastFood = last;
      if (last != null) _displayedFood = last;
    });
  }

  void _startPick() {
    if (_foods.isEmpty || _isCycling) return;

    _isCycling = true;
    _iconTimer?.cancel();
    _labelTimer?.cancel();

    _iconIndex = 0;
    _labelIndex = 0;

    // Cycle ICONS (visual flair)
    _iconTimer = Timer.periodic(const Duration(milliseconds: 120), (t) {
      setState(() {
        _currentIcon = _cycleIcons[_iconIndex];
        _iconIndex = (_iconIndex + 1) % _cycleIcons.length;
      });
    });

    // Cycle LABELS through the user's food list
    _labelTimer = Timer.periodic(const Duration(milliseconds: 120), (t) {
      setState(() {
        _displayedFood = _foods[_labelIndex];
        _labelIndex = (_labelIndex + 1) % _foods.length;
      });
    });

    // Stop after ~1.8s and choose final result (avoid immediate repeat)
    Future.delayed(const Duration(milliseconds: 1800), () {
      _iconTimer?.cancel();
      _labelTimer?.cancel();

      String choice;
      if (_foods.length == 1) {
        choice = _foods.first;
      } else {
        do {
          choice = _foods[_random.nextInt(_foods.length)];
        } while (choice == _lastFood);
      }

      setState(() {
        _displayedFood = choice;
        _lastFood = choice;
        _currentIcon = Icons.restaurant; // settle on a neutral icon
        _isCycling = false;
      });

      FoodStorage.saveLastFood(choice);

      // Increment pick count and show interstitial ad every 4 picks
      _pickCount++;
      if (_pickCount % 4 == 0) {
        _showInterstitialAd();
      }
    });
  }

  // Removed unused dialog methods since we're using ManageFoodsPage

  @override
  void dispose() {
    _iconTimer?.cancel();
    _labelTimer?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPick = _foods.isNotEmpty && !_isCycling;

    return Scaffold(
      appBar: AppBar(
  title: const Text('MealSpin'),
  actions: [
    IconButton(
      icon: const Icon(Icons.list_alt),
      tooltip: 'Manage Foods',
      onPressed: () async {
        // Navigate to manage page
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ManageFoodsPage()),
        );

        // Reload list when returning
        _loadSavedData();
      },
    ),
  ],
),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_currentIcon, size: 100, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    _displayedFood,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: canPick ? _startPick : null,
                    icon: const Icon(Icons.restaurant),
                    label: Text(_isCycling ? 'Choosing…' : 'Pick Food'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  ),
                  const SizedBox(height: 8),
                  if (_foods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Your list is empty. Add some foods to start!',
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Banner Ad at bottom (only show on supported platforms)
          if (_isBannerAdReady && AdHelper.isAdSupported)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isCycling ? null : () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManageFoodsPage()),
          );
          // Reload list when returning
          _loadSavedData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  
}
