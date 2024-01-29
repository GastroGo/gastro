import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastro/screens/Homepage.dart';

import 'screens/Login.dart';
import 'screens/Register.dart';
import 'app_routes.dart';

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

      case AppRoutes.home:
        return getRoute(widget: Homepage(user: FirebaseAuth.instance.currentUser!));

    /// An invalid route. User shouldn't see this,
    /// it's for debugging purpose only.
      default:
        return getRoute(widget: Login());
    }
  }
}
