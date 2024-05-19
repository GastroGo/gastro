import 'package:flutter/material.dart';

class MySlider extends StatefulWidget {
  final ValueChanged<int> onChanged;

  const MySlider({Key? key, required this.onChanged}) : super(key: key);

  @override
  _MySliderState createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  int _value = 2;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: _value.toDouble(),
      min: 2,
      max: 200,
      divisions: 99,
      label: _value.toString(),
      onChanged: (value) {
        setState(() {
          _value = value.round();
        });
        widget.onChanged(_value);
      },
    );
  }
}
