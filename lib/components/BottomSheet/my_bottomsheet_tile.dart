import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gastro/Firebase/database.dart';
import 'package:gastro/components/my_categories.dart';
import 'package:gastro/data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomSheetTile extends StatefulWidget {
  final Restaurant restaurant;
  final List<Gericht> gerichtList;
  final int index;
  final Function()? onAddButtonPressed;
  MyDatabase db = MyDatabase();

  BottomSheetTile({ required this.restaurant, required this.gerichtList, required this.index, required this.onAddButtonPressed});

  @override
  State<BottomSheetTile> createState() => _BottomSheetTileState();
}

class _BottomSheetTileState extends State<BottomSheetTile> {
  List<dynamic> allNutritions = [
    [198, 'kcal'], [13.1, 'proteins'], [13.4, 'fats'], [5.8, 'carbohydrates']
  ];

  Future<void> saveObjectList(List<Gericht> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonStringList = list.map((dish) => jsonEncode(dish.toJson())).toList();
    await prefs.setStringList('dishList', jsonStringList);
  }

  Future<List<Gericht>> loadObjectList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList('dishList') ?? [];
    return jsonStringList.map((jsonString) => Gericht.fromJson(jsonDecode(jsonString))).toList();
  }

  int _amount = 1;

  void _decrease(){
    setState(() {
      if (_amount > 0) {
        _amount--;
      }
    });
  }

  void _increase(){
    setState(() {
      _amount++;
    });
  }


  void _addButton(int _amount) async {
    List<Gericht> selectedGerichte = await loadObjectList();
    bool isAlreadySelected = false;

    for (Gericht gericht in selectedGerichte) {
      if (gericht.dishName == widget.gerichtList[widget.index].dishName) { // Änderung: Vergleichen der Gerichtsnamen
        isAlreadySelected = true;
        break;
      }
    }

    if (!isAlreadySelected) {
      setState(() {
        selectedGerichte.add(widget.gerichtList[widget.index]);
        selectedGerichte[selectedGerichte.length-1].amount = _amount;
        saveObjectList(selectedGerichte);
      });
    }
    widget.onAddButtonPressed?.call();
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.gerichtList[widget.index].dishName, style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24
                      ),),
                      Text('240g', style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15
                      ),),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade600)
                    ),
                    child: Row(
                      children: [
                        IconButton(onPressed: _decrease, icon: Icon(CupertinoIcons.minus_circle)),
                        Text(_amount.toString()),
                        IconButton(onPressed: _increase, icon: Icon(CupertinoIcons.add_circled))
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 16),
              MyCategories(backgroundColor: Colors.grey.shade200,),
            ],
          ),
          SizedBox(height: 6,),
          Divider(color: Colors.grey.shade300, height: 35,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nutritional value per 100g', style: TextStyle(
                  color: Colors.grey.shade600
              ),),
              Container(
                height: 55,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allNutritions.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(allNutritions[index][0].toString(), style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),),
                          Text(allNutritions[index][1], style: TextStyle(
                              color: Colors.grey.shade600
                          ),)
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 35,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ingredients', style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),),
              SizedBox(height: 2,),
              Text('Kartoffeln, Zwiebeln, Hähnchenbrust, Paprika, Salz, Knoblauch, Olivenöl, Tomate, Pfeffer, Oregano', style: TextStyle(
                  color: Colors.grey.shade600
              ),)
            ],
          ),
          SizedBox(height: 40,),
          Center(
            child: SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                ),
                onPressed: () => _addButton(_amount),
                child: Text(
                  'Add to order ($_amount)',
                  style: TextStyle(
                    color: Theme.of(context).primaryColorLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
