import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:google_maps_webservice/geocoding.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui';

class PickUpPage extends StatefulWidget {
  final google_maps.LatLng currentPosition;
  final String source;

  PickUpPage({required this.currentPosition, required this.source});

  @override
  _PickUpPageState createState() => _PickUpPageState();
}

class _PickUpPageState extends State<PickUpPage> {
  TextEditingController _pickUpLocationController = TextEditingController();
  google_maps.GoogleMapController? _mapController;
  google_maps.Marker? _currentMarker;
  google_maps.Marker? _selectedMarker;
  bool _isLoading = true; // State variable for loading
  final String apiKey = 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4';
  final geocoding = GoogleMapsGeocoding(apiKey: 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4');
  String? _pickupAddress;
  bool _showInstructionsField = false;
  double? _distance;
  String basicName = "";
  String address = "";

  @override
  void initState() {
    super.initState();
    _fetchAddress(widget.currentPosition);
  }

  Future<void> _fetchAddress(google_maps.LatLng position) async {
    final response = await geocoding.searchByLocation(
      Location(lat: position.latitude, lng: position.longitude),
    );

    if (response.isOkay && response.results.isNotEmpty) {
      String formattedAddress = response.results[0].formattedAddress ?? 'Unknown location';
      setState(() {
        _pickUpLocationController.text = formattedAddress;
        _pickupAddress = formattedAddress;
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

  void _setMarker(google_maps.LatLng position) async {
    setState(() {
      _selectedMarker = google_maps.Marker(
        markerId: const google_maps.MarkerId('selected_location'),
        position: position,
        icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueRed),
      );
    });

    await _fetchAddress(position);
  }

  void _onConfirmPressed() {
    if (_pickupAddress != null && _selectedMarker != null) {
      Navigator.pop(context, {
        'address': _pickupAddress,
        'location': _selectedMarker!.position,
        'source': widget.source,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map as the background
          google_maps.GoogleMap(
            onMapCreated: (controller) {
              _mapController = controller;
              _mapController?.moveCamera(
                google_maps.CameraUpdate.newLatLng(widget.currentPosition),
              );
              setState(() {
                _currentMarker = google_maps.Marker(
                  markerId: const google_maps.MarkerId('current_location'),
                  position: widget.currentPosition,
                  icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueBlue),
                );
              });
            },
            initialCameraPosition: google_maps.CameraPosition(
              target: widget.currentPosition,
              zoom: 18,
            ),
            markers: {
              if (_currentMarker != null) _currentMarker!,
              if (_selectedMarker != null) _selectedMarker!,
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
          Column(
            children: [
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
                      Apptext.pickUpPageTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24, // Set text to bold
                      ),
                    ),
                  ),
                  automaticallyImplyLeading: false,
                ),
              ),
              const Spacer(),
              if (_pickupAddress != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
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
                                offset: const Offset(0, 3), // changes position of shadow
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
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  address,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.symmetric(vertical: 10.0),
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
                                  const Text('Add details for driver (e.g. in the lobby)'),
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
                                onPressed: _onConfirmPressed,
                                // ignore: sort_child_properties_last
                                child: Ink(
                                  decoration: continueButtonGradientDecoration(),
                                  child: Container(
                                    alignment: Alignment.center,
                                    constraints: const BoxConstraints(maxWidth: double.infinity, minHeight: 50),
                                    child: Text(
                                      Apptext.confirmPickUpButtontext,
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
                    Text('Fetching pick up location...'),
                  ],
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 400,
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
