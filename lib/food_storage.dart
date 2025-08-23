import 'package:shared_preferences/shared_preferences.dart';

class FoodStorage {
  static const String _lastFoodKey = 'last_food';
  static const String _foodListKey = 'food_list';

  static Future<void> saveLastFood(String food) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastFoodKey, food);
  }

  static Future<String?> loadLastFood() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastFoodKey);
  }

  static Future<void> saveFoodList(List<String> foods) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_foodListKey, foods);
  }

  static Future<List<String>> loadFoodList() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_foodListKey) ?? <String>[];
  }
}
