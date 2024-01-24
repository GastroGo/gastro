class Restaurant {
  String id;
  Daten daten;
  Map<String, Gericht> speisekarte;
  Map<String, Tisch> tische;

  Restaurant({required this.id, required this.daten, required this.speisekarte, required this.tische});
}

class Daten {
  int hausnr;
  String name;
  String ort;
  int plz;
  bool speisekarte;
  String strasse;
  String uid;

  Daten({required this.hausnr, required this.name, required this.ort, required this.plz, required this.speisekarte, required this.strasse, required this.uid});
}

class Gericht {
  String gericht;
  double preis;
  Zutaten zutaten;

  Gericht({required this.gericht, required this.preis, required this.zutaten});
}

class Zutaten {
  bool eier;
  bool fleisch;
  bool milch;

  Zutaten({required this.eier, required this.fleisch, required this.milch});
}

class Tisch {
  Map<String, int> bestellungen;
  Map<String, int> geschlosseneBestellungen;
  int personen;

  Tisch({required this.bestellungen, required this.geschlosseneBestellungen, required this.personen});
}