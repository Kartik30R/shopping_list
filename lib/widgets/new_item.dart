import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending =false;

  void _saveItem() async {
    if (_formkey.currentState!.validate()) _formkey.currentState!.save();
    setState(() {
      _isSending=true;
    });
    final url = Uri.https(
        'shopping-d6775-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.post(url,
        headers: {
          'content-Type': 'application/json',
        },
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.title
        }));

    final Map<String, dynamic> resData = json.decode(response.body);

    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop(GroceryItem(
        id: resData['name'],
        name: _enteredName,
        quantity: _enteredQuantity,
        category: _selectedCategory));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('add a new item '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('name')),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(label: Text('quantity')),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be valid number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                        value: _selectedCategory,
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.title),
                                ]))
                          //how onChanged executing without setstate?
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        }),
                  )
                ],
              ),
              SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed:_isSending? null: () {
                        _formkey.currentState!.reset();
                      },
                      child: Text('reset')),
                  ElevatedButton(onPressed:_isSending ? null: _saveItem, child:_isSending? SizedBox(height: 16,width: 16,child: CircularProgressIndicator(),) :Text('add Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// The value property is a critical part of each DropdownMenuItem as it indicates what value is associated with that specific item. When a user selects a particular item from the dropdown list, the corresponding value of that item will be passed to the onChanged callback.

// In the given code, within the onChanged callback, the parameter value represents the value of the selected DropdownMenuItem. It could be the category.value (which seems to be the category object) or any other data associated with that specific item.

// For instance, if category.value is an object with properties like id, title, and color, selecting a particular item will pass the entire category.value object as the value parameter in the onChanged callback. This allows you to access and utilize the properties of the selected category object when the dropdown value changes.
