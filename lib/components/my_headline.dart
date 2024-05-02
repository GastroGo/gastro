import 'package:flutter/material.dart';

class MyHeadline extends StatelessWidget {
  MyHeadline({super.key, required this.headline});

  String headline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          headline,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text('View all'),
            SizedBox(width: 10),
            Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ],
    );
  }
}
