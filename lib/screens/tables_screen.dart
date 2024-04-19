import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/helpers/snackbar_helper.dart';
import '../values/app_strings.dart';

class TablesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: SnackbarHelper.key,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.tables),
        ),
      ),
    );
  }
}
