import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/helpers/snackbar_helper.dart';
import '../values/app_strings.dart';

enum States{OPEN, CLOSED}

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
    String? id = prefs.getString('restaurantId');
    if (id != null && id.isNotEmpty) {
      setState(() {
        restaurantId = id;
        setupFirebase();
      });
    } else {
      print('Restaurant ID not found in SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.table + " 1"),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    curState = States.OPEN;
                  });
                },
                child: Text('Open Orders'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    curState = States.CLOSED;
                  });
                },
                child: Text('Closed Orders'),
              ),
            ],
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 3 / 2,
              children: orders.keys
                  .map((item) => _buildSquareButton(item))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquareButton(String item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber, // Change this to your desired color
        borderRadius: BorderRadius.circular(10), // Adjust for desired roundness
      ),
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(orders[item].toString() + "x " + dishNames[item].toString(),
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void setupFirebase() {
    String formattedTableNum = 'T' + widget.tableNum.padLeft(3, '0');
    if (curState == States.OPEN){
      ref = FirebaseDatabase.instance.ref('Restaurants/$restaurantId/tische/$formattedTableNum/bestellungen');
    } else {
      ref = FirebaseDatabase.instance.ref('Restaurants/$restaurantId/tische/$formattedTableNum/geschlosseneBestellungen');
    }

    ref!.onValue.listen((event) {
      try {
        var snapshot = event.snapshot;
        if (snapshot.value != null) {
          if (snapshot.value is Map<dynamic, dynamic>) {
            Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;

            // Convert the Map<dynamic, dynamic> to Map<String, String>
            Map<String, String> stringMap = values.map((key, value) => MapEntry(key.toString(), value.toString()));

            // Filter out entries with 0 orders
            stringMap.removeWhere((key, value) => value == '0');

            // Sort the entries based on the keys
            var entries = stringMap.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));

            // Convert the sorted entries back to a map and assign it to orders
            setState(() {
              orders = Map.fromEntries(entries);
            });
          } else {
            print('Unexpected data type: ${snapshot.value.runtimeType}');
          }
        } else {
          print('No data found at the specified location');
        }
      } catch (e) {
        print('Error in setupFirebase: $e');
      }
    });
  }


  void loadDishNames() async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('Restaurants/$restaurantId/speisekarte').get();

    Map<dynamic, dynamic> values= snapshot.value as Map<dynamic, dynamic>;
    for (var entry in values.entries){
      Map<dynamic, dynamic> dishDetails = entry.value as Map<dynamic, dynamic>;

      String dishName = dishDetails['gericht'].toString();

      print(dishName);
      setState(() {
        dishNames[entry.key.toString()] = dishName;
      });
    }
  }

}