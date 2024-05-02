import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  MyButton({super.key, required this.text, required this.onpressed});

  VoidCallback onpressed;

  String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 1,
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
          ),
        ),
        onPressed: onpressed,
        child: Text(
          text,
          style: TextStyle(
              color: Theme.of(context).primaryColorLight,
              fontWeight: FontWeight.w600,
              fontSize: 16
          ),
        )
    );
  }
}
