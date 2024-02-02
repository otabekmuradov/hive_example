import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  List<Map<String, dynamic>> _items = [];

  final _shoppingBox = Hive.box('shopping_box');
  @override
  void initState() {
    super.initState();
    _refreshItem();
  }

  void _refreshItem() {
    final data = _shoppingBox.keys.map(
      (key) {
        final item = _shoppingBox.get(key);
        return {
          "key": key,
          "name": item['name'],
          "quantity": item['quantity'],
        };
      },
    ).toList();

    setState(() {
      _items = data.reversed.toList();
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    print('amount data is ${_shoppingBox.length}');
    _refreshItem();
  }

  Future<void> _updateItem(int itemKey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemKey, item);
    _refreshItem();
  }

  Future<void> _deleteItem(int itemKey) async {
    await _shoppingBox.delete(itemKey);
    _refreshItem();

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('An Item has been deleted')));
  }

  void _showForm(BuildContext ctx, int? itemKey) async {
    if (itemKey != null) {
      final existingItem =
          _items.firstWhere((element) => element['key'] == itemKey);
      _nameController.text = existingItem['name'];
      _quantityController.text = existingItem['quantity'];
    }

    showModalBottomSheet(
      context: ctx,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Quantity'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    _nameController.text = '';
                    _quantityController.text = '';
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    if (itemKey == null) {
                      _createItem({
                        'name': _nameController.text,
                        'quantity': _quantityController.text,
                      });
                    } else {
                      _updateItem(itemKey, {
                        'name': _nameController.text.trim(),
                        'quantity': _quantityController.text.trim(),
                      });
                    }

                    _nameController.text = '';
                    _quantityController.text = '';

                    Navigator.of(ctx).pop();
                  },
                  child: Text(itemKey == null ? 'Create New' : 'Update'),
                ),
              ],
            ),
            const SizedBox(height: 15)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[600],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueGrey[700],
        centerTitle: true,
        title: const Text(
          'Hive Example',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
          itemCount: _items.length,
          itemBuilder: (_, index) {
            final currentItem = _items[index];
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.all(10),
              elevation: 3,
              child: ListTile(
                title: Text(currentItem['name']),
                subtitle: Text(currentItem['quantity'].toString()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showForm(context, currentItem['key']),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => _deleteItem(currentItem['key']),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: () {
          _showForm(context, null);
        },
        child: Text(
          'ADD',
          style: TextStyle(color: Colors.grey[850]),
        ),
      ),
    );
  }
}
