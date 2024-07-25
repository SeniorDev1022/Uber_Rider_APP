import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:provider/provider.dart';
import 'package:uber_josh/common/Global_variable.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/view_models/accept_view_modal.dart';
import 'package:uber_josh/view_models/order_view_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:uber_josh/views/driver_arrived_page.dart';

class ChooseDriverPage extends StatefulWidget {
  final String currentAddress;
  final String destinationAddress;
  final String estimatedDollar;
  final String estimatedTime;
  final List<Map<String, dynamic>> stopPoints;
  final google_maps.LatLng currentPosition;

  ChooseDriverPage({
    required this.currentAddress,
    required this.destinationAddress,
    required this.estimatedDollar,
    required this.estimatedTime,
    required this.stopPoints,
    required this.currentPosition,
  });

  @override
  _ChooseDriverPageState createState() => _ChooseDriverPageState();
}
void _makingPhoneCall(String phone) async {
  var url = Uri.parse("tel:$phone");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
void _makingPhoneSMS(String phone) async {
  var url = Uri.parse("sms:$phone");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

 
class _ChooseDriverPageState extends State<ChooseDriverPage> {
  bool _isDetail = false;
  String currentbasicName = "";
  String currentaddress = "";
  String tobasicName = "";
  String toaddress = "";
  String driverDistance = "";
  String driverTime ="";
  google_maps.GoogleMapController? _mapController;
  google_maps.Marker? _driverMarker;
  google_maps.Marker? _currentPositionMarker;
  google_maps.Polyline? _routePolyline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final acceptmodel = Provider.of<AcceptViewModel>(context, listen: false);
      acceptmodel.addListener(_updateDriverMarker);
    });

    _currentPositionMarker = google_maps.Marker(
      markerId: const google_maps.MarkerId('currentPosition'),
      position: widget.currentPosition,
      icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
        google_maps.BitmapDescriptor.hueRed,
      ),
    );
  }

  @override
  void dispose() {
    final acceptmodel = Provider.of<AcceptViewModel>(context, listen: false);
    acceptmodel.removeListener(_updateDriverMarker);
    super.dispose();
  }

  void _onPressedDetailIcon() {
    setState(() {
      _isDetail = !_isDetail;
    });
  }

  void _updateDriverMarker() {
    final acceptmodel = Provider.of<AcceptViewModel>(context, listen: false);
    final latitude = acceptmodel.accept.latitude;
    final longitude = acceptmodel.accept.longitude;

    if (latitude != null && longitude != null) {
      final driverLatLng = google_maps.LatLng(latitude, longitude);
      setState(() {
        _driverMarker = google_maps.Marker(
          markerId: const google_maps.MarkerId('driver'),
          position: driverLatLng,
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(
            google_maps.BitmapDescriptor.hueBlue,
          ),
        );
        _updateRoutePolyline();
      });
    double distance = _calculateDistance(driverLatLng, widget.currentPosition);
    driverTime = _calculateEstimatedTime(distance);
    driverDistance = distance.toStringAsFixed(2);

    print('Distance: $driverDistance km');
    print('Estimated Time: $driverTime');
      if (_mapController != null) {
        _mapController!.animateCamera(
          google_maps.CameraUpdate.newLatLng(driverLatLng),
        );
      }
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
    if (_driverMarker != null && _currentPositionMarker != null) {
      final route = await _getRouteCoordinates(
        _currentPositionMarker!.position,
        _driverMarker!.position,
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
  String phone = "1234123412";
 
  @override
  Widget build(BuildContext context) {
    final acceptmodel = Provider.of<AcceptViewModel>(context);
    final ordermodel = Provider.of<OrderViewModel>(context);
    // acceptmodel.setFlag(true);
    String? driverName = acceptmodel.accept.driverName;
    String? carType = acceptmodel.accept.carType;
    String? carNumber = acceptmodel.accept.carNumber;
    double? rating = acceptmodel.accept.driverRating;
    String? startPosition = ordermodel.order.startLocation;
    String? endPosition = ordermodel.order.endLocation;
    String? phoneNumber = acceptmodel.accept.phoneNumber;
    print("=================>${widget.currentPosition}");
    return Scaffold(
      body: Stack(
        children: [
          google_maps.GoogleMap(
            initialCameraPosition: google_maps.CameraPosition(
              target: widget.currentPosition,
              zoom: 13,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
              _updateDriverMarker(); // Ensure marker is set when map is created
            },
            markers: {
              if (_driverMarker != null) _driverMarker!,
              _currentPositionMarker!,
            },
            polylines: _routePolyline != null ? {_routePolyline!} : {},
          ),
          if (_isDetail)
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
          Consumer<AcceptViewModel>(builder: (context, model, child) {
            if (model.moveTo == "Accepted") {
              return Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage:
                                AssetImage('assets/images/user_image.png'),
                            radius: 30,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    ' $driverName',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const Text(' . ',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  Text('$rating',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                ],
                              ),
                              Row(
                                children: [
                                  Text('on the way...  $driverDistance KM',
                                      style:
                                          const TextStyle(color: Colors.grey)),
                                  Text(
                                    "($driverTime)",
                                    style: TextStyle(
                                        color: ColorManager
                                            .button_login_background_color,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: _onPressedDetailIcon,
                            child: Icon(
                                _isDetail
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: ColorManager.button_call_color,
                                size: 35),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$carType'),
                                Text(
                                  '$carNumber',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Image.asset('assets/images/car_image1.png',
                                width: 100),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () => _makingPhoneCall(phoneNumber!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0), // Add padding for spacing
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min, // Wrap content
                                children: [
                                  Text(
                                    'Text your driver',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  SizedBox(
                                      width: 8), // Space between text and icon
                                  Icon(
                                    Icons.message,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              onPressed:() => _makingPhoneCall(phoneNumber!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    ColorManager.button_login_background_color,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 10.0), // Add padding for spacing
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min, // Wrap content
                                children: [
                                  Text(
                                    'Call',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  SizedBox(
                                      width: 8), // Space between text and icon
                                  Icon(
                                    Icons.call,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      if (_isDetail)
                        Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 8.0),
                                    width: 30,
                                    child: Column(
                                      children: [
                                        Image.asset(
                                            "assets/images/from_location_icon.png"),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Image.asset('assets/images/line.png'),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Image.asset(
                                            'assets/images/to_location_icon.png'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'From',
                                          style: TextStyle(
                                              color: ColorManager
                                                  .button_login_background_color,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        // Text(
                                        //   currentbasicName,
                                        //   style: const TextStyle(
                                        //       fontSize: 16,
                                        //       fontWeight: FontWeight.bold),
                                        // ),
                                        Text(
                                          '$startPosition',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 10),
                                        const Text(
                                          'To',
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        // Text(
                                        //   tobasicName,
                                        //   style: const TextStyle(
                                        //       fontSize: 16,
                                        //       fontWeight: FontWeight.bold),
                                        // ),
                                        Text(
                                          '$endPosition',
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color: Colors.grey.shade200, width: 1.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Payment Type',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.attach_money,
                                                color: ColorManager
                                                    .button_login_background_color,
                                                size: 16),
                                            const SizedBox(width: 4),
                                            const Text('CASH',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          'Fare Total',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '\$ ${widget.estimatedDollar}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  GlobalVariables.accepted = false;
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  constraints: const BoxConstraints(
                                    maxWidth: double.infinity, minHeight: 50),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            //   const SizedBox(height: 16), // Add some space between the buttons
                            //   ElevatedButton(
                            //     onPressed: () {
                            //       _onConfirmPress(context);
                            //     },
                            //     style: ElevatedButton.styleFrom(
                            //       backgroundColor: Colors.green, // Change the color as needed
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius: BorderRadius.circular(30.0),
                            //       ),
                            //     ),
                            //     child: Container(
                            //       alignment: Alignment.center,
                            //       constraints: const BoxConstraints(
                            //         maxWidth: double.infinity, minHeight: 50),
                            //       child: const Text(
                            //         'Confirm', // Change the text as needed
                            //         style: TextStyle(
                            //           color: Colors.white,
                            //           fontSize: 18,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              );
            } 
            if (model.moveTo != "Accepted" && model.moveTo != "arrived"){
              return Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white.withOpacity(0.8), // Background color
                  child: const Text(
                    'Looking for a driver...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } 
            if(model.moveTo=="arrived"){
              print('=========================>${model.moveTo}');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => DriverArrivedPage()),
                    );
                  });
            }
            return Container();
          }),
            Positioned(
            right: 16,
            top: 100,
            child: Column(  
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _mapController?.animateCamera(
                      google_maps.CameraUpdate.zoomIn(),
                    );
                  },
                  child: const Icon(Icons.zoom_in),
                ),
                const SizedBox(height: 5),
                FloatingActionButton(
                  onPressed: () {
                    _mapController?.animateCamera(
                      google_maps.CameraUpdate.zoomOut(),
                    );
                  },
                  child: const Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
