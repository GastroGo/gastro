import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastro/utils/helpers/navigation_helper.dart';

import 'routes.dart';
import 'values/app_routes.dart';
import 'values/app_strings.dart';
import 'values/app_theme.dart';

class GastroApp extends StatefulWidget {
  const GastroApp({super.key});

  @override
  _GastroAppState createState() => _GastroAppState();
}

class _GastroAppState extends State<GastroApp> {
  User? user;
  String? userType;
  final GlobalKey<NavigatorState> navigatorKey = NavigationHelper.key;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    userType = user?.displayName ?? '';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.loginAndRegister,
      theme: AppTheme.themeData,
      initialRoute: user != null
          ? userType == 'user'
              ? AppRoutes.home
              : AppRoutes.dashboard
          : AppRoutes.login,
      onGenerateRoute: Routes.generateRoute,
      navigatorKey: navigatorKey,
    );
  }
}
