import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gastro/Firebase/database.dart';
import 'package:gastro/components/my_button.dart';
import 'package:gastro/data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShoppingCartTile extends StatefulWidget {
  ShoppingCartTile({
    Key? key,
    required this.restaurant,
  }) : super(key: key);

  final Restaurant restaurant;

  @override
  State<ShoppingCartTile> createState() => _ShoppingCartTileState();
}

class _ShoppingCartTileState extends State<ShoppingCartTile> {
  MyDatabase db = MyDatabase();
  List<Gericht> fetchedGerichtList = [];
  double _promoValue = 3.00;

  @override
  void initState() {
    super.initState();
    _pullData();
  }

  void _pullData() async {
    fetchedGerichtList = await loadObjectList();
    setState(() {});
  }

  String formatPrice(double price) => '${price.toStringAsFixed(2)}€';

  void _addAmount(int index, int amount) async {
    setState(() => fetchedGerichtList[index].amount++);
    saveObjectList(fetchedGerichtList);
  }

  void _subAmount(int index, int amount) async {
    if ((amount) > 1) {
      setState(() => fetchedGerichtList[index].amount--);
      saveObjectList(fetchedGerichtList);
    }
  }

  double _calculateSubtotal() {
    double subAmount = 0;
    for (Gericht gericht in fetchedGerichtList) {
      subAmount += gericht.dishPrice * gericht.amount;
    }
    return double.parse(subAmount.toStringAsFixed(2));
  }

  void _completeOrder(){
    Navigator.pop(context);
    for (Gericht gericht in fetchedGerichtList) {
      db.setAmount(widget.restaurant, gericht.index, gericht.amount);
    }
  }

  Future<List<Gericht>> loadObjectList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList('dishList') ?? [];
    return jsonStringList.map((jsonString) => Gericht.fromJson(jsonDecode(jsonString))).toList();
  }

  Future<void> saveObjectList(List<Gericht> list) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonStringList = list.map((dish) => jsonEncode(dish.toJson())).toList();
    await prefs.setStringList('dishList', jsonStringList);
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = _calculateSubtotal();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            child: ListView.builder(
              itemCount: fetchedGerichtList.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(fetchedGerichtList[index].dishName),
                  onDismissed: (direction) async {
                    int removedIndex = index;
                    setState(() {
                      fetchedGerichtList.removeAt(removedIndex);
                    });
                    if (fetchedGerichtList.isEmpty) {
                      Navigator.pop(context);
                    }
                    saveObjectList(fetchedGerichtList);
                  },
                  background: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.red.shade900,
                      ),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 30,
                      ),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 8,
                          ),
                          Icon(
                            Icons.circle_outlined,
                            size: 80,
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fetchedGerichtList[index].dishName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4,),
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(16),
                                      color: Colors.grey.shade100,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () => _subAmount(
                                              index,
                                              fetchedGerichtList[
                                              index]
                                                  .amount),
                                          icon:
                                          Icon(CupertinoIcons.minus),
                                        ),
                                        Text(
                                          fetchedGerichtList[index]
                                              .amount
                                              .toString(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _addAmount(
                                              index,
                                              fetchedGerichtList[
                                              index]
                                                  .amount),
                                          icon: Icon(CupertinoIcons.add),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(right: 30, top: 30),
                            child: Column(
                              children: [
                                Text(
                                  '~240g',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12),
                                ),
                                Text(
                                  formatPrice(fetchedGerichtList[index]
                                      .dishPrice),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            height: 55,
            width: MediaQuery.of(context).size.width * 0.95,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('~HT45DVC8BN'),
                  MyButton(text: 'Promotioncode', onpressed: (){},)
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              Text(
                formatPrice(subtotal),
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Promotioncode',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              Text(
                formatPrice(_promoValue),
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${(subtotal - _promoValue).toStringAsFixed(2)}€',
                // Formatieren Sie den Wert als String mit zwei Dezimalstellen
                style: TextStyle(
                    color: Colors.grey.shade900,
                    fontSize: 17,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 15),
          Container(
              height: 45,
              width: MediaQuery.of(context).size.width,
              child: MyButton(text: 'Order', onpressed: _completeOrder,)
          )
        ],
      ),
    );
  }
}
