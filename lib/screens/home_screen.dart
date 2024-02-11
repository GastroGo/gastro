import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
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
  LatLng? _currentP = null;
  Location _locationController = Location();
  final LatLng _center = const LatLng(47.79497954602462, 9.481039555212321);
  List<String> addresses = [];
  List<Marker> markers = [];
  String searchAddr = '';

  void populateMarkers() async {
    List<String> addresses = await getAddresses();
    List<String> names = await getNames();
    for (int i = 0; i < addresses.length; i++) {
      LatLng latLng = await getLatLng(addresses[i]);
      markers.add(Marker(
        markerId: MarkerId(addresses[i]),
        position: latLng,
        infoWindow: InfoWindow(title: names[i]),
      ));
    }
  }

  void searchAndNavigate() {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Restaurants');
    ref.orderByChild('daten/name').equalTo(searchAddr).once().then((DatabaseEvent event) {
      Map<dynamic, dynamic> values = (event.snapshot.value as Map<dynamic, dynamic>);
      String address = '';
      values.forEach((key, value) {
        address = '${value['daten']['strasse']} ${value['daten']['hausnr']}, ${value['daten']['plz']} ${value['daten']['ort']}';
      });
      geo.locationFromAddress(address).then((result) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(result[0].latitude, result[0].longitude), zoom: 14.0)));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    populateMarkers();
    getLocationUpdates();
  }

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
      body: Stack(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: _currentP == null ? const Center(child: Text('Loading...'),): GoogleMap(
              onMapCreated: _onMapCreated,
              myLocationEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: Set<Marker>.of(markers), // use the list of markers here
            ),
          ),
          Positioned(
            top: 15.0,
            right: 15.0,
            left: 15.0,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Enter Restaurant',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      width: 0,
                      style: BorderStyle.none,
                    ),
                  ),
                  contentPadding: EdgeInsets.only(left: 15.0, top: 15.0),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: Colors.blue),
                    onPressed: searchAndNavigate,
                    iconSize: 30.0,
                  ),
                ),
                style: TextStyle(color: Colors.black),
                onChanged: (val) {
                  setState(() {
                    searchAddr = val;
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<List<String>> getNames() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Restaurants');
    DatabaseEvent event = await ref.once();
    Map<dynamic, dynamic> values = (event.snapshot.value as Map<dynamic, dynamic>);
    List<String> names = [];

    values.forEach((key, value) {
      String name = value['daten']['name'];
      names.add(name);
    });

    return names;
  }

  Future<List<String>> getAddresses() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Restaurants');
    DatabaseEvent event = await ref.once();
    Map<dynamic, dynamic> values = (event.snapshot.value as Map<dynamic, dynamic>);
    List<String> addresses = [];

    values.forEach((key, value) {
      String address = '${value['daten']['strasse']} ${value['daten']['hausnr']}, ${value['daten']['plz']} ${value['daten']['ort']}';
      addresses.add(address);
    });

    return addresses;
  }

  Future<LatLng> getLatLng(String address) async {
    List<geo.Location> locations = await geo.locationFromAddress(address);
    return LatLng(locations.first.latitude, locations.first.longitude);
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
    } else {
      return;
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
        if (currentLocation.latitude != null && currentLocation.longitude != null) {
          setState(() {
            _currentP = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          });
        }
    });
  }
}

