import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/helpers/snackbar_helper.dart';
import '../values/app_strings.dart';

class OrderScreen extends StatefulWidget {
  final String tableNum;

  OrderScreen({required this.tableNum});

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.table + " " + widget.tableNum),
      ),
    );
  }
}