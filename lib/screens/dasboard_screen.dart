import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/screens/manage_screen.dart';
import 'package:gastro/values/app_theme.dart';
import 'package:gastro/widgets/navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/helpers/navigation_helper.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';
import 'notifications_screen.dart';

class Dashboard extends StatefulWidget {
  final User user;
  final String id;

  Dashboard({required this.user, required this.id});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthService _auth = AuthService();
  int currentPageIndex = 0;
  String? restaurantId;

  @override
  void initState() {
    super.initState();
    loadRestaurantId();
  }

  Future<void> loadRestaurantId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      restaurantId = prefs.getString('restaurantId');
    });
  }

  final List<Widget> _pages = [
    Card(
      shadowColor: Colors.black,
      color: Colors.white70,
      margin: const EdgeInsets.all(8.0),
      child: SizedBox.expand(
        child: Center(
          child: Text(AppStrings.dashboard,
              style: AppTheme.titleLarge.copyWith(color: Colors.black)),
        ),
      ),
    ),
    ManageScreen(),
    NotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(Duration.zero),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (restaurantId == null) {
          return CircularProgressIndicator(); // Show a loading spinner while waiting
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Id: $restaurantId'),
              actions: <Widget>[
                TextButton.icon(
                  icon: Icon(Icons.person),
                  label: Text(AppStrings.logout),
                  onPressed: () async {
                    await _auth.signOut();
                    NavigationHelper.pushReplacementNamed(
                      AppRoutes.login,
                    );
                  },
                ),
              ],
            ),
            body: _pages[currentPageIndex],
            bottomNavigationBar: CustomNavigationBar(
              currentPageIndex: currentPageIndex,
              onTabSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
            ),
          );
        }
      },
    );
  }
}
