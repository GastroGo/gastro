import 'package:flutter/material.dart';

import '../utils/helpers/snackbar_helper.dart';
import '../values/app_strings.dart';

class EmployeesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: SnackbarHelper.key,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.employees),
        ),
      ),
    );
  }
}
