import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final String category;
  final Color backgroundColor;

  CategoryTile({required this.category, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: backgroundColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty),
                Text(category),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
