import 'package:flutter/material.dart';
import 'food_storage.dart';

class ManageFoodsPage extends StatefulWidget {
  const ManageFoodsPage({super.key});

  @override
  State<ManageFoodsPage> createState() => _ManageFoodsPageState();
}

class _ManageFoodsPageState extends State<ManageFoodsPage> {
  List<String> _foods = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final foods = await FoodStorage.loadFoodList();
    setState(() {
      _foods = foods;
    });
  }

  Future<void> _addFood(String food) async {
    if (food.trim().isEmpty) return;
    setState(() {
      _foods.add(food.trim());
    });
    await FoodStorage.saveFoodList(_foods);
    _controller.clear();
  }

  Future<void> _editFood(int index, String newFood) async {
    setState(() {
      _foods[index] = newFood.trim();
    });
    await FoodStorage.saveFoodList(_foods);
  }

  Future<void> _deleteFood(int index) async {
    setState(() {
      _foods.removeAt(index);
    });
    await FoodStorage.saveFoodList(_foods);
  }

  void _showEditDialog(int index) {
    final editController = TextEditingController(text: _foods[index]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Food"),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              _editFood(index, editController.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Foods")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Add new food...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addFood(_controller.text),
                  child: const Text("Add"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _foods.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_foods[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFood(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
