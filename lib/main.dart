import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'food_storage.dart';
import 'manage_foods.dart';

void main() {
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
  /// Default list if user has none saved yet
  static const List<String> _defaults = [
    'Pizza', 'Burger', 'Sushi', 'Pasta', 'Ramen', 'Salad', 'Steak', 'Tacos'
  ];

  /// Icons used purely for the loading animation (don’t need to match the label)
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
  String _displayedFood = 'Tap “Pick Food” to choose!';
  IconData _currentIcon = Icons.restaurant_menu;

  bool _isCycling = false;
  Timer? _iconTimer;
  Timer? _labelTimer;
  int _iconIndex = 0;
  int _labelIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
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

    // Cycle LABELS through the user’s food list
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
    });
  }

  void _showAddFoodDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Food'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _confirmAdd(controller),
          decoration: const InputDecoration(
            labelText: 'Food name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => _confirmAdd(controller), child: const Text('Add')),
        ],
      ),
    );
  }

  Future<void> _confirmAdd(TextEditingController c) async {
    final text = c.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _foods.add(text);
    });
    await FoodStorage.saveFoodList(_foods);
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _iconTimer?.cancel();
    _labelTimer?.cancel();
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
      body: Center(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _isCycling ? null : _showAddFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  
}
