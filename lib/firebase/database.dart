import 'package:firebase_database/firebase_database.dart';
import 'package:gastro/data/models.dart';

class MyDatabase {

  Future<List<String>> getAllGerichte(Restaurant restaurant) async {
    String id = restaurant.id.substring(0,restaurant.id.length-3);
    DatabaseReference dbGerichte = FirebaseDatabase.instance.ref('Restaurants').child(id).child('speisekarte');

    List<String> allGerichte = [];

    try {
      DatabaseEvent event = await dbGerichte.once();
      DataSnapshot snapshot = event.snapshot;

      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        List<dynamic> keys = values.keys.toList()..sort((a, b) => a.compareTo(b));
        keys.forEach((key) {
          allGerichte.add(key.toString());
        });
      }
    } catch (error) {
      print('Error finding dish: $error');
    }

    return allGerichte;
  }

  Future<List<Gericht>> getDataGericht(Restaurant restaurant) async {
    String id = restaurant.id.substring(0,restaurant.id.length-3);
    List<String> allGerichte = await getAllGerichte(restaurant);
    List<Gericht> gerichtList = [];

    for (int i = 0; i < allGerichte.length; i++) {
      DatabaseReference dbGerichte = FirebaseDatabase.instance.ref('Restaurants').child(id).child('speisekarte').child(allGerichte[i]);

      try {
        DatabaseEvent event = await dbGerichte.once();
        DataSnapshot snapshot = event.snapshot;
        Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          gerichtList.add(Gericht(
              dishName: values['gericht'].toString(),
              dishPrice: double.parse(values['preis'].toString()),
              index: i
          ));
        }
      } catch(error) {
        print('Error finding values of dish: $error');
      }
    }

    return gerichtList;
  }

  Future<String> getRestaurantName(Restaurant restaurant) async {
    String id = restaurant.id.substring(0,restaurant.id.length-3);
    DatabaseReference dbGerichte = FirebaseDatabase.instance.ref('Restaurants').child(id).child('daten');
    String name = "";
    try {
      DatabaseEvent event = await dbGerichte.once();
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

      if (values != null) {
        name = values['name'].toString();
      }
    } catch(error) {
      print('Error finding restaurant name: $error');
    }
    return name;
  }

  Future<void> setAmount (Restaurant restaurant, int index, int amount) async {
    String tableNumber = restaurant.id.substring(restaurant.id.length-3);
    String id = restaurant.id.substring(0, restaurant.id.length-3);
    String newIndex = (index+1).toString().padLeft(3, '0');
    DatabaseReference ref = FirebaseDatabase.instance.ref('Restaurants').child(id).child('tische').child('T'+tableNumber.toString()).child('bestellungen');

    int previousAmount = 0;
    DatabaseEvent event = await ref.once();
    DataSnapshot snapshot = event.snapshot;
    Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

    if (values != null) {
      previousAmount = values['G' + newIndex];
    }

    await ref.update({
      'G'+newIndex: previousAmount + amount
    });

  }

  Future<void> reset (Restaurant restaurant,) async {
    String tableNumber = restaurant.id.substring(restaurant.id.length-3);
    String id = restaurant.id.substring(0, restaurant.id.length-3);
    List<Gericht> gerichtList = await getDataGericht(restaurant) as List<Gericht>;
    DatabaseReference ref = FirebaseDatabase.instance.ref('Restaurants').child(id).child('tische').child('T'+tableNumber.toString()).child('bestellungen');


      for (int i = 1; i <= gerichtList.length; i++) {
        await ref.update({
          'G'+i.toString().padLeft(3, '0') : 0
        });
      }
  }
}
