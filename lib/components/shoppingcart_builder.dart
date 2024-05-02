import 'package:flutter/material.dart';
import 'package:gastro/components/shoppingcart_tile.dart';
import 'package:gastro/data/models.dart';

class ShoppingCartBuilder extends StatefulWidget {
  ShoppingCartBuilder({super.key, required this.restaurant, required this.fetchedGerichtList, required this.amount});
  final Restaurant restaurant;
  late List<Gericht> fetchedGerichtList;
  late int amount;

  @override
  State<ShoppingCartBuilder> createState() => _ShoppingCartBuilderState();
}

class _ShoppingCartBuilderState extends State<ShoppingCartBuilder> {

  double _calculateSubtotal() {
    double subAmount = 0;
    for (Gericht gericht in widget.fetchedGerichtList) {
      subAmount += gericht.dishPrice * gericht.amount;
    }
    return double.parse(subAmount.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = _calculateSubtotal();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Divider(),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)
            ),
            height: 55,
            width: MediaQuery.of(context).size.width * 0.9,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('~HT45DVC8BN'),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 1,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      onPressed: (){},
                      child: Text(
                        'Promotion Code',
                        style: TextStyle(
                            color: Colors.grey.shade100,
                            fontWeight: FontWeight.w600,
                            fontSize: 14
                        ),
                      )
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              Text('Subtotal'),
              Text(subtotal.toString()),
            ],
          )
        ],
      ),
    );
  }

}
