import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastro/screens/create_restaurant_screen.dart';
import 'package:gastro/screens/dasboard_screen.dart';
import 'package:gastro/screens/home_screen.dart';
import 'package:gastro/screens/login_screen.dart';
import 'package:gastro/screens/register_screen.dart';
import 'package:gastro/values/app_routes.dart';

class Routes {
  const Routes._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Route<dynamic> getRoute({
      required Widget widget,
      bool fullscreenDialog = false,
    }) {
      return MaterialPageRoute<void>(
        builder: (context) => widget,
        settings: settings,
        fullscreenDialog: fullscreenDialog,
      );
    }

    switch (settings.name) {
      case AppRoutes.login:
        return getRoute(widget: Login());

      case AppRoutes.register:
        return getRoute(widget: Register());

      case AppRoutes.createRestaurant:
        return getRoute(widget: CreateRestaurant());

      case AppRoutes.home:
        return getRoute(
            widget: Homepage(user: FirebaseAuth.instance.currentUser!));

      case AppRoutes.dashboard:
        return getRoute(
            widget: Dashboard(user: FirebaseAuth.instance.currentUser!));

      /// An invalid route. User shouldn't see this,
      /// it's for debugging purpose only.
      default:
        return getRoute(widget: Login());
    }
  }
}
