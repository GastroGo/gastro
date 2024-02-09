import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../utils/helpers/navigation_helper.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';

class Homepage extends StatefulWidget {
  final User user;

  Homepage({super.key, required this.user});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuthService _auth = AuthService();
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(47.79497954602462, 9.481039555212321);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.homepage),
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 11.0,
          ),
        ),
      ),
    );
  }
}
