class Restaurant {
  String id;
  String restaurantName;
  Restaurant({required this.id, this.restaurantName = ""});
}



class Gericht {
  String dishName;
  double dishPrice;
  int amount;
  int index;
  //Zutaten zutaten;


  Gericht({required this.dishName, required this.dishPrice, this.amount = 0, this.index = 0});

  Map<String, dynamic> toJson() {
    return {
      'dishName': dishName,
      'dishPrice': dishPrice,
      'amount': amount,
      'index': index
    };
  }

  factory Gericht.fromJson(Map<String, dynamic> json) {
    return Gericht(
        dishName: json['dishName'],
        dishPrice: json['dishPrice'],
        amount: json['amount'],
        index: json['index'],

    );
  }
}



class Zutaten {
  bool eier;
  bool fleisch;
  bool milch;

  Zutaten({required this.eier, required this.fleisch, required this.milch});
}


