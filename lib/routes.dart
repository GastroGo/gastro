import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastro/screens/create_restaurant_screen.dart';
import 'package:gastro/screens/dasboard_screen.dart';
import 'package:gastro/screens/employees_screen.dart';
import 'package:gastro/screens/home_screen.dart';
import 'package:gastro/screens/login_screen.dart';
import 'package:gastro/screens/menu_screen.dart';
import 'package:gastro/screens/qr_scanner_screen.dart';
import 'package:gastro/screens/qrcodes_screen.dart';
import 'package:gastro/screens/register_screen.dart';
import 'package:gastro/screens/tables_screen.dart';
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
            widget: Dashboard(user: FirebaseAuth.instance.currentUser!, id: ''));

      case AppRoutes.menu:
        return getRoute(widget: MenuScreen());

      case AppRoutes.tables:
        return getRoute(widget: TablesScreen());

      case AppRoutes.employees:
        return getRoute(widget: EmployeesScreen());

      case AppRoutes.qrcodes:
        return getRoute(widget: QRCodesScreen());

      case AppRoutes.qrcodescanner:
        return getRoute(widget: QRScanner());

      /// An invalid route. User shouldn't see this,
      /// it's for debugging purpose only.
      default:
        return getRoute(widget: Login());
    }
  }
}
