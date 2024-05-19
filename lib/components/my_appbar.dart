import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastro/firebase/database.dart';
import 'package:gastro/components/shoppingcart_tile.dart';
import 'package:gastro/data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppbar extends StatefulWidget {
  const MyAppbar({super.key, required this.restaurantNameFuture, required this.restaurant});

  final Future<String> restaurantNameFuture;
  final Restaurant restaurant;


  @override
  State<MyAppbar> createState() => _MyAppbarState();
}

class _MyAppbarState extends State<MyAppbar> {

  late List<Gericht> fetchedGerichtList = [];
  MyDatabase db = MyDatabase();

  @override
  void initState() {
    super.initState();
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

  void _showShoppingCart() async {
    _fetchAndUpdateList();
    if (fetchedGerichtList.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey.shade100,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: ShoppingCartTile(
                    restaurant: widget.restaurant,
                  ),
                ),
              ],
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Text('Keine Produkte im Warenkorb',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500
            ),),
            contentPadding: EdgeInsets.only(top: 20),
            actionsPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {Navigator.pop(context);},
                    child: Text('Add products', style: TextStyle(
                      color: Colors.black
                    ),),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.black, width: 1)
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {Navigator.pop(context);},
                    child: Text('Understood', style: TextStyle(
                        color: Colors.black
                    ),),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.black, width: 1)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
}

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndUpdateList();
    });
    return AppBar(
      backgroundColor: Theme.of(context).primaryColorDark,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 76, left: 30, right: 30),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<String>(
                      future: widget.restaurantNameFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Text(
                            snapshot.data ?? '',
                            style: TextStyle(color: Colors.grey.shade100, fontWeight: FontWeight.w700, fontSize: 25),
                          );
                        } else {
                          return const Text(
                            'Loading...',
                            style: TextStyle(color: Colors.white),
                          );
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: _showShoppingCart,
                      child: Container(
                        width: 55,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined, size: 18, ),
                            SizedBox(width: 6,),
                            Text(
                              fetchedGerichtList.length.toString(),
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  width: 400,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.grey.shade800,
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 14),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Icon(Icons.zoom_in, color: Colors.grey),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Theme.of(context).primaryColorLight,
                            decoration: const InputDecoration(
                              hintText: 'Search for something tasty...',
                              hintStyle: TextStyle(color: Colors.white70),
                              border: InputBorder.none,
                            ),
                          ),

                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
