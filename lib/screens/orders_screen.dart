import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/app_strings.dart';

enum States { OPEN, CLOSED }

class OrderScreen extends StatefulWidget {
  final String tableNum;

  OrderScreen({required this.tableNum});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  States curState = States.OPEN;
  Map<String, String> orders = {};
  Map<String, String> dishNames = {};
  String? restaurantId;
  DatabaseReference? ref;

  @override
  void initState() {
    super.initState();
    setupAsync();
  }

  Future<void> setupAsync() async {
    await loadRestaurantId();
    loadDishNames();
  }

  Future<void> loadRestaurantId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    restaurantId = prefs.getString('restaurantId');
    if (restaurantId != null && restaurantId!.isNotEmpty) {
      setupFirebase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.table + " " + widget.tableNum),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('Open Orders', States.OPEN),
              _buildButton('Closed Orders', States.CLOSED),
            ],
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 1,
              childAspectRatio: 8 / 2,
              children:
              orders.keys.map((item) => _buildSquareButton(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String title, States state) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          curState = state;
          updateData();
        });
      },
      child: Text(title, style: TextStyle(color: Colors.black)),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            curState == state ? Colors.amber : Colors.grey),
      ),
    );
  }

  Widget _buildSquareButton(String item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      margin: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: Row(
              children: [
                Text(
                  (orders[item] != null ? orders[item]! : '0') +
                      "x " +
                      (dishNames[item] != null ? dishNames[item]! : 'Unknown'),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: TextButton(
                            onPressed: () => closeOpenOrder(item),
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                curState == States.CLOSED
                                    ? "Reopen Order"
                                    : "Close Order",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color?>(
                                  curState == States.OPEN ? Colors.amber : Colors.amber),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> closeOpenOrder(var dish) async {
    String formattedTableNum = 'T' + widget.tableNum.padLeft(3, '0');
    DatabaseReference ref = FirebaseDatabase.instance.ref(
        'Restaurants/$restaurantId/tische/$formattedTableNum');
    if (curState == States.OPEN) {
      await ref.update(
          {
            "geschlosseneBestellungen/$dish": int.parse(orders[dish]!),
            "bestellungen/$dish": 0
          }
      );
    } else {
      await ref.update(
          {
            "bestellungen/$dish": int.parse(orders[dish]!),
            "geschlosseneBestellungen/$dish": 0
          }
      );
    }

    print(curState);
    updateData();

  }

  StreamSubscription<DatabaseEvent>? _subscription;

  void setupFirebase() {
    String formattedTableNum = 'T' + widget.tableNum.padLeft(3, '0');
    if (curState == States.OPEN) {
      ref = FirebaseDatabase.instance.ref(
          'Restaurants/$restaurantId/tische/$formattedTableNum/bestellungen');
    } else {
      ref = FirebaseDatabase.instance.ref(
          'Restaurants/$restaurantId/tische/$formattedTableNum/geschlosseneBestellungen');
    }

    _subscription = ref!.onValue.listen((event) {
      var snapshot = event.snapshot;
      if (snapshot.value != null) {
        if (snapshot.value is Map<dynamic, dynamic>) {
          Map<dynamic, dynamic> values =
          snapshot.value as Map<dynamic, dynamic>;

          // Convert the Map<dynamic, dynamic> to Map<String, String>
          Map<String, String> stringMap = values.map(
                  (key, value) => MapEntry(key.toString(), value.toString()));

          // Filter out entries with 0 orders
          stringMap.removeWhere((key, value) => value == '0');

          // Sort the entries based on the keys
          var entries = stringMap.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));

          // Convert the sorted entries back to a map and assign it to orders
          if (mounted) {
            setState(() {
              orders = Map.fromEntries(entries);
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void updateData() async {
    String formattedTableNum = 'T' + widget.tableNum.padLeft(3, '0');
    if (curState == States.OPEN) {
      ref = FirebaseDatabase.instance.ref(
          'Restaurants/$restaurantId/tische/$formattedTableNum/bestellungen');
    } else {
      ref = FirebaseDatabase.instance.ref(
          'Restaurants/$restaurantId/tische/$formattedTableNum/geschlosseneBestellungen');
    }

    final snapshot = await ref?.get();

    if (snapshot?.value != null) {
      if (snapshot?.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> values = snapshot?.value as Map<dynamic, dynamic>;

        // Convert the Map<dynamic, dynamic> to Map<String, String>
        Map<String, String> stringMap = values
            .map((key, value) => MapEntry(key.toString(), value.toString()));
        // Filter out entries with 0 orders
        stringMap.removeWhere((key, value) => value == '0');

        // Sort the entries based on the keys
        var entries = stringMap.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        // Convert the sorted entries back to a map and assign it to orders
        setState(() {
          orders = Map.fromEntries(entries);
        });
      }
    }
  }

  void loadDishNames() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot =
    await ref.child('Restaurants/$restaurantId/speisekarte').get();

    Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
    for (var entry in values.entries) {
      Map<dynamic, dynamic> dishDetails = entry.value as Map<dynamic, dynamic>;

      String dishName = dishDetails['gericht'].toString();

      setState(() {
        dishNames[entry.key.toString()] = dishName;
      });
    }
  }
}