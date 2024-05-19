import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastro/Firebase/database.dart';
import 'package:gastro/components/my_scroll_view.dart';
import 'package:gastro/components/my_appbar.dart';
import 'package:gastro/components/my_categories.dart';
import 'package:gastro/components/my_headline.dart';
import 'package:gastro/data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuDisplay extends StatefulWidget {
  final Restaurant restaurant;

  MenuDisplay({required this.restaurant, Key? key}) : super(key: key);

  @override
  _MenuDisplayState createState() => _MenuDisplayState();
}

class _MenuDisplayState extends State<MenuDisplay> {
  MyDatabase database = MyDatabase();
  late Future<String> restaurantNameFuture;

  @override
  void initState() {
    super.initState();
    restaurantNameFuture = database.getRestaurantName(widget.restaurant);
    database.reset(widget.restaurant);
    List<Gericht> list = [];
    saveObjectList(list);
  }

  Future<void> saveObjectList(List<Gericht> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonStringList = list.map((dish) => jsonEncode(dish.toJson())).toList();
    await prefs.setStringList('dishList', jsonStringList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140.0),
        child: MyAppbar(restaurantNameFuture: restaurantNameFuture, restaurant: widget.restaurant,),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MyHeadline(headline: 'Top Categories'),
            SizedBox(height: 12,),
            MyCategories(),
            SizedBox(height: 20,),
            MyHeadline(headline: 'Recommended for you'),
            SizedBox(height: 12,),
            Expanded(
              child: MyScrollView(
                restaurant: widget.restaurant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
