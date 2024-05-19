import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gastro/Firebase/database.dart';
import 'package:gastro/components/my_dish_tile.dart';
import 'package:gastro/components/my_bottomsheet_tile.dart';
import 'package:gastro/components/paybutton.dart';
import 'package:gastro/data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pay/pay.dart';

class MyScrollView extends StatefulWidget {
  final Restaurant restaurant;

  MyScrollView({required this.restaurant, Key? key}) : super(key: key);

  @override
  State<MyScrollView> createState() => _MyScrollViewState();
}

class _MyScrollViewState extends State<MyScrollView> {
  List<Gericht> gerichtList = [];
  List<Gericht> fetchedGerichtList = [];
  MyDatabase db = MyDatabase();

  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    List<Gericht> fetchedGerichtList = await db.getDataGericht(widget.restaurant);
    setState(() {
      gerichtList = fetchedGerichtList;
    });
  }

  Future<List<Gericht>> loadObjectList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList('dishList') ?? [];
    return jsonStringList.map((jsonString) => Gericht.fromJson(jsonDecode(jsonString))).toList();
  }

  Future<void> _fetchAndUpdateList() async {
    fetchedGerichtList = await loadObjectList();
    setState(() {});
  }

  void _showDishDetails(index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
              color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25))
          ),
          height: MediaQuery.of(context).size.height * 0.58,
          child: BottomSheetTile(restaurant: widget.restaurant, gerichtList: gerichtList, index: index, onAddButtonPressed: _fetchAndUpdateList),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // number of items in each row
            mainAxisSpacing: 10.0, // spacing between rows
            crossAxisSpacing: 10.0, // spacing between columns
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0), // padding around the grid
          itemCount: gerichtList.length, // total number of items
          itemBuilder: (context, index) {
            final gericht = gerichtList[index];
            return GestureDetector(
              onTap: () => _showDishDetails(index),
              child: DishTile(name: gericht.dishName, price: gericht.dishPrice),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 90,
            child: MyPayButton()
          ),
        )
      ],
    );
  }
}
