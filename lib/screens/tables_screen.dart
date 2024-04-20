import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/helpers/snackbar_helper.dart';
import '../values/app_strings.dart';
import 'package:firebase_database/firebase_database.dart';


class TablesScreen extends StatefulWidget {
  @override
  _TablesScreenState createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  List<String> tableNum = [];
  String? restaurantId;
  DatabaseReference? ref;

  @override
  void initState() {
    super.initState();
    loadRestaurantId();
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

        // Print the names of the child nodes
        values.forEach((key, value) {
          print('Child node name: $key');
        });

        // Sort the entries based on the keys
        var entries = values.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        // Convert the sorted entries to a list of strings
        setState(() {
          tableNum = entries.map((entry) => entry.key.toString()).toList();
        });
      } catch (e) {
        print('Error in setupFirebase: $e');
      }
    });
  }

  @override
  void dispose() {
    if (ref != null) {
      ref!.onValue.listen((_) {}).cancel(); // Cancel the subscription when the widget is disposed
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: SnackbarHelper.key,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.tables),
        ),
        body: ListView(
          children: tableNum.map((item) => ListTile(
            title: Text(item),
          )).toList(),
        ),
      ),
    );
  }
}