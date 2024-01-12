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
  var isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load_items();
  }

  Future< List<GroceryItem>> _load_items() async {
    final url = Uri.https(
        'shopping-d6775-default-rtdb.firebaseio.com', 'shopping-list.json');

         final response = await http.get(url);
        
    if(response.statusCode>= 400){
      setState(() {
          _error =' failed to fetch data. please try again later';
      });
    
    }

    if(response.body == 'null'){
      setState(() {
        isLoading =false;
      });
      return [];
    }
    final Map<String,  dynamic> listData =
        json.decode(response.body);
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
   final newItem= await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));

        if(newItem==null){return;}


        setState(() {
          _groceryItem.add(newItem);
        });
  }

  void _removedItem(GroceryItem item) async {
 final index = _groceryItem.indexOf(item);
   setState(() {
      _groceryItem.remove(item);
    });
 final url = Uri.https(
        'shopping-d6775-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');


   final response = await http.delete(url);
 if(response.statusCode>=400){
  
   setState(() {
      _groceryItem.insert(index, item);
    });
 }

  
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('no items added'),
    );

    if(isLoading){
      content =const Center(child: CircularProgressIndicator(),);
    }

    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItem.length,
          itemBuilder: (ctx, index) => Dismissible(
                onDismissed: (direction) {
                  _removedItem(_groceryItem[index]);
                },
                key: ValueKey(_groceryItem[index].id),
                child: ListTile(
                  title: Text(_groceryItem[index].name),
                  leading: Container(
                    height: 24,
                    width: 24,
                    color: _groceryItem[index].category.color,
                  ),
                  trailing: Text(_groceryItem[index].quantity.toString()),
                ),
              ));
    }

    if(_error != null){
      content= Center( child:  Text('failed to fetch data try again   later'));
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('your grocery'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body:FutureBuilder(future: , builder: (context, snapshot){

        }));
  }
}
