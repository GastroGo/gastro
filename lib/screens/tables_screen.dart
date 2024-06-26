import 'dart:async';
import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../values/app_strings.dart';
import 'orders_screen.dart';

enum States { sortByTableNum, sortByElapsedTime }

class TablesScreen extends StatefulWidget {
  @override
  _TablesScreenState createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  Map<String, String> tableNumAndTimer = {};
  Map<String, int> tableNumAndStatus = {};
  String? restaurantId;
  DatabaseReference? ref;
  States curState = States.sortByTableNum;

  Timer? timer;
  DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    loadLastTables();
    loadRestaurantId();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        currentTime = DateTime.now();
      });
    });
  }

  Future<void> loadRestaurantId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      restaurantId = prefs.getString('restaurantId');
      setupFirebase();
    });
  }

  void setupFirebase() {
    ref = FirebaseDatabase.instance.ref('Restaurants/$restaurantId/tische');
    ref!.onValue.listen((event) {
      try {
        var snapshot = event.snapshot;
        var values = snapshot.value as Map<dynamic, dynamic>;

        // Sort the entries based on the keys
        var entries = values.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        // Convert the sorted entries to a map of table numbers and last orders
        setState(() {
          tableNumAndTimer = Map.fromEntries(entries.map((entry) {
            String tableNum =
                int.parse(entry.key.toString().substring(1)).toString();
            String lastOrder = entry.value['letzteBestellung'];
            return MapEntry(tableNum, lastOrder);
          }));

          tableNumAndStatus = Map.fromEntries(entries.map((entry) {
            String tableNum =
                int.parse(entry.key.toString().substring(1)).toString();
            int status = entry.value['status'];
            return MapEntry(tableNum, status);
          }));
          print(tableNumAndStatus);
        });
      } catch (e) {
        print('Error in setupFirebase: $e');
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    safeLastTables();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.tables),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildSortButtons(AppStrings.sortByTableNumber, _sortByTableNum),
              SizedBox(width: 20), // Add this
              _buildSortButtons(
                  AppStrings.sortByElapsedTime, _sortByElapsedTime),
            ],
          ),
          SizedBox(height: 10), // Add this
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 10 / 4,
              children: tableNumAndTimer.keys
                  .map((item) => _buildSquareButton(item))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _sortByTableNum() {
    setState(() {
      curState = States.sortByTableNum;
      var entries = tableNumAndTimer.entries.toList();

      // Sort the entries based on the table number
      entries.sort((a, b) => a.key.compareTo(b.key));

      // Convert the sorted entries back to a map
      tableNumAndTimer = Map.fromEntries(entries);
    });
  }

  void _sortByElapsedTime() {
    setState(() {
      curState = States.sortByElapsedTime;
      tableNumAndTimer = _getSortedTableNumAndTimer();
    });
  }

  Widget _buildSortButtons(String title, callback) {
    return ElevatedButton(
      onPressed: callback,
      style: ButtonStyle(
        side: MaterialStateProperty.all(const BorderSide(color: Colors.black)),
        backgroundColor: MaterialStateProperty.all<Color>(
            (curState == States.sortByTableNum &&
                        title == AppStrings.sortByTableNumber) ||
                    (curState == States.sortByElapsedTime &&
                        title == AppStrings.sortByElapsedTime)
                ? Colors.amber
                : Colors.white54),
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
      child: Text(title, style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildSquareButton(String item) {
    return Container(
      decoration: BoxDecoration(
        color: tableNumAndStatus[item] == 0
            ? Colors.grey
            : tableNumAndStatus[item] == 1
                ? Colors.amber
                : Colors.red, //Colors.amber
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text("${AppStrings.table} $item",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(getElapsedTime(item)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => OrderScreen(tableNum: item)),
          );
        },
      ),
    );
  }

  String getElapsedTime(String tableNum) {
    String lastOrder = tableNumAndTimer[tableNum] ?? '00:00';

    if (lastOrder != "-") {
      // Parse the lastOrder string into a DateTime object
      List<String> parts = lastOrder.split(':');
      DateTime lastOrderTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          int.parse(parts[0]),
          int.parse(parts[1]));

      // Calculate the elapsed time
      Duration elapsedTime = currentTime.difference(lastOrderTime);

      // Format the elapsed time into a string in the format 'mm:ss'
      String elapsedTimeStr =
          '${elapsedTime.inMinutes.toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}';

      return elapsedTimeStr;
    } else {
      return "-";
    }
  }

  Map<String, String> _getSortedTableNumAndTimer() {
    var entries = tableNumAndTimer.entries.toList();

    // Sort the entries based on the elapsed time in descending order
    entries.sort((a, b) {
      if (a.value == "-") return 1;
      if (b.value == "-") return -1;

      Duration elapsedTimeA = _getDuration(a.key);
      Duration elapsedTimeB = _getDuration(b.key);
      return elapsedTimeB
          .compareTo(elapsedTimeA); // Reverse the comparison here
    });

    // Convert the sorted entries back to a map
    return Map.fromEntries(entries);
  }

  Duration _getDuration(String tableNum) {
    String lastOrder = tableNumAndTimer[tableNum] ?? '00:00';

    if (lastOrder == "-") {
      // Return a large duration for tables that have not yet been ordered
      return const Duration(days: 9999);
    }

    // Parse the lastOrder string into a DateTime object
    List<String> parts = lastOrder.split(':');
    DateTime lastOrderTime = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, int.parse(parts[0]), int.parse(parts[1]));

    // Calculate the elapsed time
    return currentTime.difference(lastOrderTime);
  }

  void loadLastTables() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      String? mapString = prefs.getString('lastTables');
      tableNumAndTimer = jsonDecode(mapString!).cast<String, String>();
    } catch (e) {
      print(e);
    }
  }

  void safeLastTables() async {
    var prefs = await SharedPreferences.getInstance();
    String mapString = jsonEncode(tableNumAndTimer);
    prefs.setString('lastTables', mapString);
  }
}
