import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/app_strings.dart';

enum States { open, closed }

class OrderScreen extends StatefulWidget {
  final String tableNum;

  const OrderScreen({super.key, required this.tableNum});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  States curState = States.open;
  Map<String, String> orders = {};
  Map<String, String> dishNames = {};
  String? restaurantId;
  DatabaseReference? ref;
  StreamSubscription<DatabaseEvent>? _subscription;


  //Overrides
  @override
  void initState() {
    super.initState();
    setupAsync();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }


  //Setup
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


  //Widgets
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppStrings.table} ${widget.tableNum}"),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildButton('Open Orders', States.open),
              _buildButton('Closed Orders', States.closed),
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
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
            curState == state ? Colors.amber : Colors.grey),
      ),
      child: Text(title, style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildSquareButton(String item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: [
                Text(
                  "${orders[item] != null ? orders[item]! : '0'}x ${dishNames[item] != null ? dishNames[item]! : 'Unknown'}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextButton(
                            onPressed: () => closeOpenOrder(item),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                      curState == States.open
                                          ? Colors.amber
                                          : Colors.amber),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                curState == States.closed
                                    ? "Reopen Order"
                                    : "Close Order",
                                style: const TextStyle(color: Colors.black),
                              ),
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


  //Database
  void setupFirebase() {
    String formattedTableNum = 'T${widget.tableNum.padLeft(3, '0')}';
    ref = FirebaseDatabase.instance.ref('Restaurants/$restaurantId/tische/$formattedTableNum');


    _subscription = ref!.onValue.listen((event) {
      var snapshot = event.snapshot.child(curState == States.open? 'bestellungen':'geschlosseneBestellungen');

      setState(() {
        orders = getData(snapshot);
      });
    });
  }

  Map<String, String> getData(snapshot) {
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

        return Map.fromEntries(entries);
      }
    }
    return {};
  }

  Future<void> closeOpenOrder(var dish) async {
    String formattedTableNum = 'T${widget.tableNum.padLeft(3, '0')}';
    DatabaseReference ref = FirebaseDatabase.instance
        .ref('Restaurants/$restaurantId/tische/$formattedTableNum');
    if (curState == States.open) {

      final snapshot = await ref?.child("geschlosseneBestellungen").get();
      Map<String, String> closedOrders = getData(snapshot);

      await ref.update({
        "geschlosseneBestellungen/$dish": int.parse(closedOrders[dish] ?? '0') + int.parse(orders[dish] ?? '0'),
        "bestellungen/$dish": 0
      });
    } else {

      final snapshot = await ref?.child("bestellungen").get();
      Map<String, String> openOrders = getData(snapshot);

      await ref.update({
        "bestellungen/$dish": int.parse(openOrders[dish] ?? '0') + int.parse(orders[dish] ?? '0'),
        "geschlosseneBestellungen/$dish": 0
      });
    }

    updateData();
  }

  void updateData() async {
    String formattedTableNum = 'T${widget.tableNum.padLeft(3, '0')}';
    if (curState == States.open) {
      ref = FirebaseDatabase.instance.ref(
          'Restaurants/$restaurantId/tische/$formattedTableNum/bestellungen');
    } else {
      ref = FirebaseDatabase.instance.ref(
          'Restaurants/$restaurantId/tische/$formattedTableNum/geschlosseneBestellungen');
    }

    final snapshot = await ref?.get();

    setState(() {
      orders = getData(snapshot);
    });
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