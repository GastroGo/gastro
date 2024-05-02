import 'package:flutter/material.dart';

class DishTile extends StatelessWidget {
  const DishTile({super.key, required this.name, required this.price});

  final String name;
  final double price;

  String formatPrice(double price) {
    return '${price.toStringAsFixed(2)}€';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Align(child: Icon(Icons.fastfood_rounded, size: 100,), alignment: Alignment.bottomCenter,),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: TextStyle(
                  fontWeight: FontWeight.w500
                ),),
                Text(formatPrice(price).toString())
              ],
            ),
          )
        ],
    ),
    );
  }
}
