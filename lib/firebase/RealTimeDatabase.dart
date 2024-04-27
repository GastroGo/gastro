import 'package:firebase_database/firebase_database.dart';

class RealTimeDatabase {
  //extracts the data of a DatabaseSnapshot to a Map<String, String>
  Map<String, String> extractDataToStringMap(snapshot) {
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

  //Returns a Map<String, String> with the data of the given path, use like this: await updateData(path);
  Future<Map<String, String>> getDataOnce(String path) async {
    final ref = FirebaseDatabase.instance.ref(path);
    final snapshot = await ref?.once();
    return extractDataToStringMap(snapshot?.snapshot);
  }
}
