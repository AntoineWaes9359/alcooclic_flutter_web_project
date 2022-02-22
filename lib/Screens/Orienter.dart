import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:alcooclic/constant.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'Components/App_bar.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;
import 'dart:html';
import 'package:flutter_google_places/flutter_google_places.dart';

class Orienter extends StatefulWidget {
  static const String route = '/overview';

  @override
  State<Orienter> createState() => _OrienterState();
}

class _OrienterState extends State<Orienter> {
  late GoogleMapController mapsController;

  List _items = [];

  _getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData);

    var newPosition = CameraPosition(
        target: LatLng(_locationData.latitude!, _locationData.longitude!),
        zoom: 13);

    CameraUpdate update = CameraUpdate.newCameraPosition(newPosition);
    CameraUpdate zoom = CameraUpdate.zoomTo(16);

    mapsController.moveCamera(update);
  }

  Future<void> readJson() async {
    final String response = await rootBundle.loadString('data.json');
    final data = await json.decode(response);
    _items = data["data"];

    print("ajoute des markers");

    for (var mark in _items) {
      _markers.add(Marker(
          markerId: MarkerId(mark['name']),
          position: LatLng(mark['lat'], mark['long']),
          infoWindow: InfoWindow(title: mark['name'])));
    }

    _markers.add(
      Marker(
          markerId: MarkerId("myLocation"),
          position: LatLng(48.90624, 2.3134208),
          infoWindow: InfoWindow(title: "Ma position", snippet: "tre")),
    );
  }

  List<Marker> _markers = [];
  bool showMaps = true;
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    readJson();

    return Scaffold(
      body: Container(
        height: screenSize.height,
        width: screenSize.width,
        child: Column(
          children: [
            CustomAppBar(
              isHovering: [false, false, true, false],
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                children: [
                  SizedBox(
                      height: 500,
                      width: 1100,
                      child: GoogleMap(
                        onMapCreated: (controller) {
                          setState(() {
                            mapsController = controller;
                          });
                        },
                        markers: Set<Marker>.of(_markers),
                        mapType: MapType.normal,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(43.448411, 5.248321), zoom: 8),
                      )),
                  SizedBox(
                    width: 40,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OutlinedButton(
                          onPressed: () {
                            _getLocation();
                          },
                          child: Text("Localiser moi")),
                      SizedBox(
                        height: 20,
                      ),
                      Container(height: 40, width: 100, child: TextField()),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
