import 'package:flutter/material.dart';
import 'package:gastro/components/my_category_tile.dart';

class MyCategories extends StatelessWidget {
  final List<String> allCategories = ['vegan', 'coffee', 'meat', 'pasta', 'fish'];

  final Color backgroundColor;

  MyCategories({this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 35,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: allCategories.length,
            itemBuilder: (BuildContext context, int index) {
              return CategoryTile(category: allCategories[index], backgroundColor: backgroundColor);
            },
          ),
        ),


      ],
    );
  }
}
