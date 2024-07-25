import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:provider/provider.dart';
import 'package:uber_josh/common/Global_variable.dart';
import 'dart:async';

import 'package:uber_josh/view_models/accept_view_modal.dart';
import 'package:uber_josh/views/arrived_page.dart';

class TrackingLocationPage extends StatefulWidget {
  @override
  _TrackingLocationPageState createState() => _TrackingLocationPageState();
}

class _TrackingLocationPageState extends State<TrackingLocationPage> {
  late GoogleMapController mapController;
  // ignore: prefer_const_constructors
  LatLng _currentPosition = LatLng(0, 0);
  LatLng _destinationPosition = const LatLng(0, 0);
  late Marker _currentLocationMarker;
  late Marker _destinationLocationMarker;
  late bool _locationInitialized = false;
  Timer? _timer;
  bool hasNavigated = false;
  google_maps.Polyline? _routePolyline;
  String driverDistance = "";
  String driverTime = "";
  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final acceptViewModel =
          Provider.of<AcceptViewModel>(context, listen: false);
      acceptViewModel.addListener(_checkMoveTo);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    mapController.dispose();
    final acceptViewModel =
        Provider.of<AcceptViewModel>(context, listen: false);
    acceptViewModel.removeListener(_checkMoveTo);
    super.dispose();
  }

  void _startLocationUpdates() {
    _determinePosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _currentLocationMarker = Marker(
          markerId: const MarkerId("current_location"),
          position: _currentPosition,
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
              google_maps.BitmapDescriptor.hueBlue),
        );
        _destinationLocationMarker = Marker(
          markerId: const MarkerId("destination_location"),
          position: LatLng(GlobalVariables.desLat, GlobalVariables.desLang),
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
              google_maps.BitmapDescriptor.hueRed),
        );
        _locationInitialized = true;
        _updateRoutePolyline();
      });
      _destinationPosition =
          LatLng(GlobalVariables.desLat, GlobalVariables.desLang);
      double distance =
          _calculateDistance(_currentPosition, _destinationPosition);
      driverTime = _calculateEstimatedTime(distance);
      driverDistance = distance.toStringAsFixed(2);
      print('Distance: $driverDistance km');
      print('Estimated Time: $driverTime');
    }).catchError((e) {
      // ignore: avoid_print
      print("Error getting location: $e");
    });
    _timer = Timer.periodic(
        const Duration(seconds: 15), (Timer t) => _updateLocation());
  }

  Future<void> _updateLocation() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _currentLocationMarker = Marker(
          markerId: const MarkerId("current_location"),
          position: _currentPosition,
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
              google_maps.BitmapDescriptor.hueBlue),
        );
        if (_locationInitialized) {
          mapController.animateCamera(
              CameraUpdate.newLatLngZoom(_currentPosition, 18.0));
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print("Error updating location: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 18.0));
  }

  void _checkMoveTo() {
    final acceptViewModel =
        Provider.of<AcceptViewModel>(context, listen: false);
    if (acceptViewModel.moveTo == "finished" && !hasNavigated) {
      hasNavigated = true;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ArrivedPage()),
      );
    }
  }

  double _calculateDistance(google_maps.LatLng start, google_maps.LatLng end) {
    const earthRadiusKm = 6371;

    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLon = _degreesToRadians(end.longitude - start.longitude);

    double lat1 = _degreesToRadians(start.latitude);
    double lat2 = _degreesToRadians(end.latitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  String _calculateEstimatedTime(double distance) {
    const speedKmPerHour = 40;
    double timeInHours = distance / speedKmPerHour;
    int hours = timeInHours.floor();
    int minutes = ((timeInHours - hours) * 60).round();
    return '${hours}h ${minutes}m';
  }

  Future<void> _updateRoutePolyline() async {
    final route = await _getRouteCoordinates(
      _currentLocationMarker.position,
      _destinationLocationMarker.position,
    );
    if (route != null) {
      setState(() {
        _routePolyline = google_maps.Polyline(
          polylineId: const google_maps.PolylineId('route'),
          points: route,
          color: Colors.blue,
          width: 5,
        );
      });
    }
  }

  Future<List<google_maps.LatLng>?> _getRouteCoordinates(
      google_maps.LatLng start, google_maps.LatLng end) async {
    const String apiKey = 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<google_maps.LatLng> route = [];
      if (data['routes'].isNotEmpty) {
        final steps = data['routes'][0]['legs'][0]['steps'];
        for (var step in steps) {
          route.add(google_maps.LatLng(
            step['start_location']['lat'],
            step['start_location']['lng'],
          ));
          route.add(google_maps.LatLng(
            step['end_location']['lat'],
            step['end_location']['lng'],
          ));
        }
      }
      return route;
    } else {
      print('Failed to load directions');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_locationInitialized)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 16.0,
              ),
              markers: {_currentLocationMarker, _destinationLocationMarker},
              polylines: _routePolyline != null ? {_routePolyline!} : {},
            ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Colors.black,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (driverDistance.isNotEmpty)
                    Text('Distance: $driverDistance Km',
                        style: TextStyle(fontSize: 16)),
                  if (driverTime.isNotEmpty)
                    Text('Duration: $driverTime',
                        style: TextStyle(fontSize: 16)),
                  Consumer<AcceptViewModel>(
                      builder: (context, acceptViewModel, child) {
                    if (acceptViewModel.moveTo == "finished" && !hasNavigated) {
                      // Set the flag to true to prevent multiple navigations
                      hasNavigated = true;
                      // Navigate to the ArrivedPage
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ArrivedPage()),
                        );
                      });
                    }
                    return Container();
                  })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
