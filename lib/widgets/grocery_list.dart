import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load_items();
  }

  Future<List<GroceryItem>> _load_items() async {
    final url = Uri.https(
        'shopping-d6775-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('failed to fetch item . please try again later');
    }

    if (response.body == 'null') {
      return [];
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> _loadedItems = [];

    for (final item in listData.entries) {
      final Category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      _loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value["name"],
          quantity: item.value["quantity"],
          category: Category));
    }
    return _loadedItems;
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItem.add(newItem);
    });
  }

  void _removedItem(GroceryItem item) async {
    final index = _groceryItem.indexOf(item);
    setState(() {
      _groceryItem.remove(item);
    });
    final url = Uri.https('shopping-d6775-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      setState(() {
        _groceryItem.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
        appBar: AppBar(
          title: const Text('your grocery'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: FutureBuilder(
            future: _loadedItems,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: const Text('failed to fetch data try again   later'));
              }

              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              }

              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('no items added'),
                );
              }

           return   ListView.builder(
                  itemCount:snapshot.data!.length,
                  itemBuilder: (ctx, index) => Dismissible(
                        onDismissed: (direction) {
                          _removedItem(snapshot.data![index]);
                        },
                        key: ValueKey(snapshot.data![index].id),
                        child: ListTile(
                          title: Text(snapshot.data![index].name),
                          leading: Container(
                            height: 24,
                            width: 24,
                            color: snapshot.data![index].category.color,
                          ),
                          trailing:
                              Text(snapshot.data![index].quantity.toString()),
                        ),
                      ));
            }));
  }
}
