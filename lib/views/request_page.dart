import 'package:flutter/material.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/directions.dart' as webservice_directions;
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:flutter/services.dart' show rootBundle;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
import 'package:uber_josh/common/Global_variable.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/services/useDio.dart';
import 'package:uber_josh/view_models/order_view_model.dart';
// import 'package:uber_josh/view_models/order_view_model.dart';
import 'package:uber_josh/views/choose_driver_page.dart';


class RequestPage extends StatefulWidget {
  final String currentAddress;
  final String destinationAddress;
  final google_maps.LatLng currentPosition;
  final List<Map<String, dynamic>> stopPoints;

  RequestPage({
    required this.currentAddress,
    required this.destinationAddress,
    required this.currentPosition,
    required this.stopPoints,
  });

  @override
  _RequestPageState createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final String apiKey = 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4';
  final geocoding = GoogleMapsGeocoding(apiKey: 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4');
  final directions = webservice_directions.GoogleMapsDirections(apiKey: 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4');
  google_maps.GoogleMapController? _mapController;
  google_maps.LatLng? _destinationPosition;
  String _estimatedTime = "";
  String? _estimatedDistance = "";
  String _estimatedDollar = "";
  google_maps.Polyline? _routePolyline;
  List<google_maps.Marker> _stopMarkers = [];
  bool _isLoading = true;
  bool _isRequestingDriver = false;

  @override
  void initState() {
    super.initState();
    _calculateRoute();
  }

  List<google_maps.LatLng> _decodePolyline(String encoded) {
    List<google_maps.LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(google_maps.LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  Future<void> _calculateRoute() async {
    setState(() {
      _isLoading = true;
    });
    
    final destinationResponse = await geocoding.searchByAddress(widget.destinationAddress);
    if (destinationResponse.isOkay && destinationResponse.results.isNotEmpty) {
      final destination = destinationResponse.results[0].geometry.location;
      GlobalVariables.desLang = destination.lng;
      GlobalVariables.desLat = destination.lat;
      setState(() {
        _destinationPosition = google_maps.LatLng(destination.lat, destination.lng);
      });

     // Prepare waypoints if there are any stop points
      List<webservice_directions.Waypoint> waypoints = [];
      if (widget.stopPoints.isNotEmpty) {
        for (var stop in widget.stopPoints) {
          waypoints.add(
            webservice_directions.Waypoint(
              value: '${stop['position'].latitude},${stop['position'].longitude}',
            ),
          );
          final stopMarker = await _createStopMarker(
            stop['position'],
            'Stop ${widget.stopPoints.indexOf(stop) + 1}',
          );
          _stopMarkers.add(stopMarker);
        }
      }

      final directionsResponse = await directions.directionsWithLocation(
        webservice_directions.Location(lat: widget.currentPosition.latitude, lng: widget.currentPosition.longitude),
        webservice_directions.Location(lat: destination.lat, lng: destination.lng),
        travelMode: webservice_directions.TravelMode.driving,
        waypoints: waypoints.isNotEmpty ? waypoints : [],
      );



    if (directionsResponse.isOkay) {
      final route = directionsResponse.routes[0];
      final polylinePoints = _decodePolyline(route.overviewPolyline.points);

      setState(() {
        _routePolyline = google_maps.Polyline(
          polylineId: const google_maps.PolylineId('route'),
          points: polylinePoints,
          color: Colors.blue,
          width: 5,
        );
        _estimatedTime = route.legs[0].duration.text;
        _estimatedDistance = route.legs[0].distance.text;
        _estimatedDollar = _calculateEstimatedDollar(route.legs[0].distance.value.toInt());
        _isLoading = false;
      });
    } else {
        print('Error: ${directionsResponse.errorMessage}');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Error: ${destinationResponse.errorMessage}');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<google_maps.Marker> _createStopMarker(google_maps.LatLng position, String label) async {
    final icon = await _createCustomMarkerBitmap(label);
    return google_maps.Marker(
      markerId: google_maps.MarkerId(label),
      position: position,
      icon: icon,
      infoWindow: google_maps.InfoWindow(title: label, snippet: position.toString()),
    );
  }

  Future<google_maps.BitmapDescriptor> _createCustomMarkerBitmap(String text) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.red;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 32,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );

    textPainter.text = textSpan;
    textPainter.layout();
    final textWidth = textPainter.width;
    final textHeight = textPainter.height;

    final width = textWidth + 20;
    final height = textHeight + 20;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, width, height),
        const Radius.circular(10),
      ),
      paint,
    );

    textPainter.paint(canvas, const Offset(10, 10));

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return google_maps.BitmapDescriptor.fromBytes(uint8List);
  }


  String _calculateEstimatedDollar(int distanceMeters) {
    const double startingCharge = 7.0;
    const double chargePerUnit = 0.10;
    const double unitDistanceMeters = 33.03;

    double remainingDistance = distanceMeters - unitDistanceMeters;
    if (remainingDistance <= 0) {
      return startingCharge.toStringAsFixed(2);
    }

    double additionalCharges = (remainingDistance / unitDistanceMeters) * chargePerUnit;
    double totalCost = startingCharge + additionalCharges;

    return totalCost.toStringAsFixed(2);
  }

  Future<void> _setMapStyle() async {
    final String style = await rootBundle.loadString('assets/styles/map_style.json');
    _mapController?.setMapStyle(style);
  }
  List<Map<String, dynamic>> convertStopLocation(List<Map<String, dynamic>> stopLocations) {
    return stopLocations.map((stop) {
      final google_maps.LatLng position = stop['position'];
      return {
        'position': {
          'lat': position.latitude,
          'lng': position.longitude,
        },
        'address': stop['address'],
      };
    }).toList();
  }
  void _onRequestPress() async {
    final data = {
      "rider_id": int.parse(localStorage.getItem("riderID")!),
      "cost": _estimatedDollar,
      "rider_token":GlobalVariables.deviceToken,
      "start_location": widget.currentAddress,
      "end_location": widget.destinationAddress,
      "route_distance": _estimatedDistance,
      "period": _estimatedTime,
      "latitude":widget.currentPosition.latitude,
      "longitude":widget.currentPosition.longitude,
      "desLat": _destinationPosition?.latitude,
      "desLng":_destinationPosition?.longitude,
      "stop_position":widget.stopPoints
  };
  final DioService dioService = DioService();
  print("stop_locationdata$data");
  try {
      final response = await dioService.postRequest('order',data:data);
      if(response.statusCode == 200){
      Navigator.push(
      // ignore: use_build_context_synchronously
      context,
      MaterialPageRoute(
        builder: (context) => ChooseDriverPage(
          currentAddress: widget.currentAddress,
          destinationAddress: widget.destinationAddress,
          stopPoints: widget.stopPoints, // pass stop points if needed
          currentPosition: widget.currentPosition,
          estimatedDollar: _estimatedDollar,
          estimatedTime: _estimatedTime,
        ),
      ),
    );        
     setState(() {
      _isRequestingDriver = true;
    });
        }
      } catch (e) {
        print('POST Error: $e');
      }
     setState(() {
      _isRequestingDriver = true;
    });
  }

  // ignore: unused_element
  double _extractNumericValue(String distance) {
    final numericString = distance.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.parse(numericString);
  }

  @override
  Widget build(BuildContext context) {
    GlobalVariables.stopPoints = widget.stopPoints;
    GlobalVariables.riderLat = widget.currentPosition.latitude;
    GlobalVariables.riderLng = widget.currentPosition.longitude;
    context.read<OrderViewModel>().setPeriod(_estimatedTime);
    context.read<OrderViewModel>().setEndLocation(widget.currentAddress);
    context.read<OrderViewModel>().setStartLocation(widget.destinationAddress);
    context.read<OrderViewModel>().setCost(_estimatedDollar);
    // context.read<OrderViewModel>().setRouteDistance(_estimatedDistance);
  return Scaffold(
    body: Stack(
      children: [
        google_maps.GoogleMap(
          onMapCreated: (google_maps.GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: google_maps.CameraPosition(
            target: widget.currentPosition,
            zoom: 17,
          ),
          markers: {
            google_maps.Marker(
              markerId: const google_maps.MarkerId('current_location'),
              position: widget.currentPosition,
              icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueBlue),
            ),
            if (_destinationPosition != null)
              google_maps.Marker(
                markerId: const google_maps.MarkerId('destination'),
                position: _destinationPosition!,
                icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueGreen),
              ),
            ..._stopMarkers.map((marker) => marker).toSet(),
          },
          polylines: _routePolyline != null ? {_routePolyline!} : {},
        ),
        if (_isRequestingDriver)
          Container(
            color: Colors.black.withOpacity(0.4),
          ),
        Column(
          children: [
            if (_isRequestingDriver)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    const SizedBox(height: 50,),
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'From',
                                  style: TextStyle(color: ColorManager.button_login_background_color, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.currentAddress,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < widget.stopPoints.length; i++) ...[
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4.0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Stop ${i + 1}',
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    widget.stopPoints[i]['address'],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4.0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'To',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  widget.destinationAddress,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                color: Colors.white.withOpacity(0.5), // Background for AppBar
                child: AppBar(
                  backgroundColor: Colors.transparent, // Make AppBar transparent
                  elevation: 0, // Remove AppBar shadow
                  leading: IconButton(
                    icon: Image.asset(Apptext.backIcon_image),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  title: const Center(
                    child: Text(
                      Apptext.requestPageTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24, // Set text to bold
                      ),
                    ),
                  ),
                automaticallyImplyLeading: false,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0),
                      ),
                    ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_isRequestingDriver)
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                  Row(
                                    children: [
                                      Image.asset('assets/images/car_icon.png', width: 60, height: 60),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'Searching for a ride nearby...',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 20.0, // Custom width
                                        height: 20.0, // Custom height
                                        child: CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(ColorManager.button_login_background_color), // Set custom color
                                          strokeWidth: 3.0, // Set custom stroke width
                                        ),
                                      ),
                                      const SizedBox(width: 10,)
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _isRequestingDriver = false;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                      ),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      constraints: const BoxConstraints(maxWidth: double.infinity, minHeight: 50),
                                      child: const Text(
                                      'Cancel Order',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset('assets/images/car_icon.png', width: 50, height: 50),
                                        const SizedBox(width: 5),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'KenoRide - $_estimatedDistance',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(Icons.person, color: ColorManager.button_login_background_color, size: 20),
                                                const SizedBox(width: 4),
                                                Text('4', style: TextStyle(color: ColorManager.button_login_background_color),),
                                              ],
                                            ),
                                            const Text(
                                              'Affordable rides, all to yourself.',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '\$ $_estimatedDollar',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.access_time, size: 20),
                                                const SizedBox(width: 4),
                                                Text('$_estimatedTime'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _onRequestPress,
                                      // ignore: sort_child_properties_last
                                      child: Ink(
                                        decoration: continueButtonGradientDecoration(),
                                        child: Container(
                                          alignment: Alignment.center,
                                          constraints: const BoxConstraints(maxWidth: double.infinity, minHeight: 50),
                                          child: Text(
                                            Apptext.reqestbuttontext,
                                            style: continueButtonTextStyle(),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      style: continueButtonStyle(),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Estimating Now...'),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 200,
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
