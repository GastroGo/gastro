import 'package:flutter/material.dart';

import '../utils/helpers/snackbar_helper.dart';
import '../values/app_strings.dart';

class MenuScreen extends StatelessWidget {
  final List<String> dishes = ['Dish 1', 'Dish 2', 'Dish 3', 'Dish 4', 'Dish 5'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.menu),
      ),
      body: ListView.builder(
        itemCount: dishes.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(dishes[index]),
            // onTap: () => navigateToDishDetails(dishes[index]),
          );
        },
      ),
    );
  }
}
