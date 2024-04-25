import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../utils/helpers/snackbar_helper.dart';
import '../values/app_strings.dart';

class QRCodesScreen extends StatefulWidget {
  @override
  _QRCodesScreenState createState() => _QRCodesScreenState();
}

class _QRCodesScreenState extends State<QRCodesScreen> {
  Map<String, String> closedOrders = {};

  @override
  void initState() {
    super.initState();
    retrieveAndDisplayClosedOrders();
  }

  void retrieveAndDisplayClosedOrders() async {
    String restaurantId = "-NnEe9pHqGgDIdtocR-d"; // replace with your restaurant id
    String tableNum = "T001"; // replace with your table number
    DatabaseReference ref = FirebaseDatabase.instance
        .ref('Restaurants/$restaurantId/tische/$tableNum/geschlosseneBestellungen');

    final snapshot = await ref.get();
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

        setState(() {
          closedOrders = Map.fromEntries(entries);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: SnackbarHelper.key,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.qrcodes),
        ),
        body: ListView.builder(
          itemCount: closedOrders.length,
          itemBuilder: (context, index) {
            String key = closedOrders.keys.elementAt(index);
            return ListTile(
              title: Text('Dish: $key'),
              subtitle: Text('Quantity: ${closedOrders[key]}'),
            );
          },
        ),
      ),
    );
  }
}