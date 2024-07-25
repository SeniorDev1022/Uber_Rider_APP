import 'dart:ui'; // Import for ImageFilter
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:google_maps_webservice/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';

class SetStopLocation extends StatefulWidget {
  final google_maps.LatLng currentPosition;
  final google_maps.LatLng toPosition;

  SetStopLocation({required this.currentPosition, required this.toPosition});

  @override
  _SetStopLocationState createState() => _SetStopLocationState();
}

class _SetStopLocationState extends State<SetStopLocation> {
  final TextEditingController _stopLocationController = TextEditingController();
  google_maps.GoogleMapController? _mapController;
  google_maps.Marker? _selectedMarker;
  google_maps.Marker? _destinationMarker;
  bool _isLoading = false; // State variable for loading
  final String apiKey = 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4';
  final geocoding = GoogleMapsGeocoding(apiKey: 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4');
  bool _showInstructionsField = false;
  double? _distance;
  String basicName = "";
  String address = "";

  @override
  void initState() {
    super.initState();

    _selectedMarker = google_maps.Marker(
      markerId: google_maps.MarkerId('selected_location'),
      position: widget.currentPosition,
      icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueRed),
      draggable: true,
      onDragEnd: _onMarkerDragEnd,
    );

    
    _destinationMarker = google_maps.Marker(
      markerId: google_maps.MarkerId('to_location'),
      position: widget.toPosition,
      icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueGreen),
    );

    _fetchAddress(widget.currentPosition);
  }

  Future<void> _fetchAddress(google_maps.LatLng position) async {
    final response = await geocoding.searchByLocation(
      Location(lat: position.latitude, lng: position.longitude),
    );

    if (response.isOkay && response.results.isNotEmpty) {
      String formattedAddress = response.results[0].formattedAddress ?? 'Unknown location';
      setState(() {
        _stopLocationController.text = formattedAddress;
        _isLoading = false; // Stop loading once address is fetched
        _calculateDistance(position);
        _splitAddress(formattedAddress);
      });
    } else {
      print('Error: ${response.errorMessage}');
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
    }
  }

  void _splitAddress(String fullAddress) {
    List<String> parts = fullAddress.split(',');
    if (parts.length > 1) {
      setState(() {
        basicName = parts[0];
        address = parts.sublist(1).join(',').trim();
      });
    } else {
      setState(() {
        basicName = fullAddress;
        address = '';
      });
    }
  }

  void _calculateDistance(google_maps.LatLng targetPosition) {
    double distanceInMeters = Geolocator.distanceBetween(
      widget.currentPosition.latitude,
      widget.currentPosition.longitude,
      targetPosition.latitude,
      targetPosition.longitude,
    );
    setState(() {
      _distance = distanceInMeters / 1000; // convert to kilometers
    });
  }

  void _onMarkerDragEnd(google_maps.LatLng position) async {
    await _fetchAddress(position);
  }

  void _onDonePressed() {
    if (_selectedMarker != null) {
      Navigator.pop(context, {
        'address': _stopLocationController.text,
        'location': _selectedMarker!.position,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(Apptext.backIcon_image),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Center(
          child: Text(
            'Set Stop Location',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, // Set text to bold
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          google_maps.GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController?.moveCamera(
                google_maps.CameraUpdate.newLatLng(widget.currentPosition),
              );
            },
            initialCameraPosition: google_maps.CameraPosition(
              target: widget.currentPosition,
              zoom: 16,
            ),
            markers: {
              if (_selectedMarker != null) _selectedMarker!,
              if (_destinationMarker != null) _destinationMarker!,
              google_maps.Marker(
                markerId: google_maps.MarkerId('current_location'),
                position: widget.currentPosition,
                icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueBlue),
              ),
            },
            onTap: (position) {
              setState(() {
                _selectedMarker = google_maps.Marker(
                  markerId: google_maps.MarkerId('selected_location'),
                  position: position,
                  icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueRed),
                  draggable: true,
                  onDragEnd: _onMarkerDragEnd,
                );
              });
              _fetchAddress(position);
            },
            onCameraMove: (position) {
              setState(() {
                _selectedMarker = google_maps.Marker(
                  markerId: const google_maps.MarkerId('selected_location'),
                  position: position.target,
                  icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueRed),
                );
              });
            },
            onCameraIdle: () {
              if (_selectedMarker != null) {
                _fetchAddress(_selectedMarker!.position);
              }
            },
          ),
          
          if (_stopLocationController.text.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 10,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/atoms.png"),
                            if (_distance != null) Text("${_distance!.toStringAsFixed(1)} km",),
                          ],
                        ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              basicName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              address,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(16.0),
                      margin:const EdgeInsets.symmetric(vertical: 10.0),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Add details for driver (e.g. in the lobby)'),
                              IconButton(
                                icon: Image.asset(
                                  'assets/images/plus_icon.png', // Replace with your actual image path
                                  width: 26, // Set the width as needed
                                  height: 26, // Set the height as needed
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showInstructionsField = !_showInstructionsField;
                                  });
                                },
                              ),
                            ],
                          ),
                          if (_showInstructionsField)
                            const TextField(
                              maxLines: 4,
                              decoration: InputDecoration(
                                labelText: 'Would you like to add instructions?',
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _onDonePressed,
                              // ignore: sort_child_properties_last
                              child: Ink(
                                decoration: continueButtonGradientDecoration(),
                                child: Container(
                                  alignment: Alignment.center,
                                  constraints: const BoxConstraints(maxWidth: double.infinity, minHeight: 50),
                                  child: Text(
                                    Apptext.confirmStopLocationButtontext,
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
                  ],
                ),
              ),
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
                    Text('Fetching stop location...'),
                  ],
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 300,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    _mapController?.animateCamera(
                      google_maps.CameraUpdate.zoomIn(),
                    );
                  },
                  child: Icon(Icons.zoom_in),
                ),
                SizedBox(height: 5),
                FloatingActionButton(
                  onPressed: () {
                    _mapController?.animateCamera(
                      google_maps.CameraUpdate.zoomOut(),
                    );
                  },
                  child: Icon(Icons.zoom_out),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
