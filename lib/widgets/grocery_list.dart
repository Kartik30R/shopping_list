import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';


class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItem = [];

  void _addItem()  async {
    final newItem = await Navigator.of(context).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));


        if(newItem ==null){
          return;
        }

        setState(() {
          return _groceryItem.add(newItem);
        });

        
  }
  void _removedItem(GroceryItem item){
            setState(() {
              _groceryItem.remove(item);
            });
        }
        

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('no items added'),);

    if(_groceryItem.isNotEmpty){content= ListView.builder(
          itemCount: _groceryItem.length,
          itemBuilder: (ctx, index) => Dismissible(
           onDismissed: (direction){_removedItem(_groceryItem[index]);},
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
          ));}
    return Scaffold(
      appBar: AppBar(
        title: const Text('your grocery'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body:content
    );
  }
}
