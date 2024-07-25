import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/views/pickup_page.dart';
import 'package:uber_josh/views/request_page.dart';
import 'set_stop_location.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
class AddStopPage extends StatefulWidget {
  final google_maps.LatLng currentPosition;
  final google_maps.LatLng toPosition;
  final String currentAddress;
  final String toAddress;

  AddStopPage({
    required this.currentPosition,
    required this.toPosition,
    required this.currentAddress,
    required this.toAddress,
  });

  @override
  _AddStopPageState createState() => _AddStopPageState();
}

class _AddStopPageState extends State<AddStopPage> {
  final TextEditingController _currentLocationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final List<TextEditingController> _stopControllers = [TextEditingController()];
  List<Prediction> _places = [];
  google_maps.GoogleMapController? _mapController;
  google_maps.Marker? _currentMarker;
  google_maps.Marker? _destinationMarker;
  final List<google_maps.Marker> _stopMarkers = [];
  final String apiKey = 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4';
  final geocoding = GoogleMapsGeocoding(apiKey: "AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4");

  @override
  void initState() {
    super.initState();
    _currentLocationController.text = widget.currentAddress;
    _destinationController.text = widget.toAddress;

    _currentMarker = google_maps.Marker(
      markerId: const google_maps.MarkerId('current_location'),
      position: widget.currentPosition,
      icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueBlue),
    );

    _destinationMarker = google_maps.Marker(
      markerId: const google_maps.MarkerId('to_location'),
      position: widget.toPosition,
      icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueGreen),
    );
    
  }

  void _addStopField() {
    setState(() {
      _stopControllers.add(TextEditingController());
    });
  }

  void _removeStopField(int index) {
    setState(() {
      if (_stopControllers.length > 1) {
        _stopControllers.removeAt(index);
        _stopMarkers.removeWhere((marker) => marker.markerId.value == 'stop_${index + 1}');
      }
      for(int i = index+1; i<_stopControllers.length; i++){
        _stopMarkers[i] = _stopMarkers[i+1];
      }
    });
  }

  Future<void> _navigateToSetStopLocation(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SetStopLocation(
          currentPosition: widget.currentPosition,
          toPosition: widget.toPosition,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _stopControllers[index].text = result['address'];
        _createStopMarker(result['location'], index + 1);
      });
    }
  }

  Future<void> _createStopMarker(google_maps.LatLng position, int index) async {
    final icon = await _createCustomMarkerBitmap('Stop $index');
    setState(() {
      _stopMarkers.add(
        google_maps.Marker(
          markerId: google_maps.MarkerId('stop_$index'),
          position: position,
          icon: icon,
          infoWindow: google_maps.InfoWindow(title: 'Stop $index'),
        ),
      );
    });
  }

  Future<google_maps.BitmapDescriptor> _createCustomMarkerBitmap(String text) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = Colors.red;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final textStyle = const TextStyle(
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

  Future<void> _navigateToPickUpPage() async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PickUpPage(
          currentPosition: widget.currentPosition,
          source: 'add_stop',
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _destinationController.text = result['address'];
        _destinationMarker = google_maps.Marker(
          markerId: const google_maps.MarkerId('destination'),
          position: result['location'],
          icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueGreen),
        );
      });
    }
  }

  void _onDonePressed() {
  // context.read<OrderViewModel>().setStopLocation(_stopMarkers
  //       .map((marker) => {
  //             'position': marker.position,
  //             'address': _stopControllers[_stopMarkers.indexOf(marker)].text,
  //           })
  //       .toList());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestPage(
          currentAddress: _currentLocationController.text,
          destinationAddress: _destinationController.text,
          currentPosition: widget.currentPosition,
          stopPoints: _stopMarkers.map((marker) => {
            'position': marker.position,
            'address': _stopControllers[_stopMarkers.indexOf(marker)].text,
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _getPlaces(String input, int index) async {
    final googleMapsPlaces = GoogleMapsPlaces(apiKey: apiKey);
    PlacesAutocompleteResponse response = await googleMapsPlaces.autocomplete(input);

    if (response.isOkay) {
      setState(() {
        _places = response.predictions;
      });
    } else {
      print(response.errorMessage);
    }
  }

  void _onMapTapped(google_maps.LatLng position) {
    setState(() {
      _currentMarker = google_maps.Marker(
        markerId: const google_maps.MarkerId('current_location'),
        position: position,
        icon: google_maps.BitmapDescriptor.defaultMarkerWithHue(google_maps.BitmapDescriptor.hueBlue),
      );
      _currentLocationController.text = '${position.latitude}, ${position.longitude}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: ColorManager.button_login_background_color, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder enabledInputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: ColorManager.button_login_background_color, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

    return Scaffold(
      body: Stack(
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6), // Adjust the opacity value as needed
              BlendMode.dstATop,
            ),
            child: google_maps.GoogleMap(
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
                if (_currentMarker != null) _currentMarker!,
                if (_destinationMarker != null) _destinationMarker!,
                ..._stopMarkers,
              },
              onTap: _onMapTapped,
            ),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                title: const Text('Add Stop'),
                elevation: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _currentLocationController,
                      decoration: InputDecoration(
                        labelText: 'Current location',
                        labelStyle: TextStyle(color: ColorManager.button_login_background_color),
                        prefixIcon: Image.asset("assets/images/from_location_icon.png"),
                        border: defaultBorder,
                        focusedBorder: focusedBorder,
                        enabledBorder: enabledInputBorder,
                      ),
                      style: const TextStyle(fontSize: 14),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    ..._buildStopFields(),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        labelText: 'Where to?',
                        labelStyle: TextStyle(color: ColorManager.button_login_background_color),
                        prefixIcon: Container(
                          padding: const EdgeInsets.all(12),
                          width: 10,
                          height: 10,
                          child: Image.asset("assets/images/to_location_icon.png"),
                        ),
                        suffixIcon: IconButton(
                          icon: Image.asset(
                            "assets/images/whereto_icon.png",
                            width: 24,
                            height: 24,
                          ),
                          onPressed: _navigateToPickUpPage,
                        ),
                        border: defaultBorder,
                        focusedBorder: focusedBorder,
                        enabledBorder: enabledInputBorder,
                      ),
                      style: const TextStyle(fontSize: 14),
                      onChanged: (value) {
                        _getPlaces(value, -1);
                      },
                    ),
                    _places.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _places.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_places[index].description ?? ''),
                                onTap: () {
                                  setState(() {
                                    _destinationController.text = _places[index].description ?? '';
                                    _places.clear();
                                  });
                                },
                              );
                            },
                          )
                        : Container(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: _onDonePressed,
                  child: Ink(
                    decoration: continueButtonGradientDecoration(),
                    child: Container(
                      alignment: Alignment.center,
                      constraints: const BoxConstraints(maxWidth: double.infinity, minHeight: 50),
                      child: Text(
                        Apptext.donebuttontext,
                        style: continueButtonTextStyle(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  style: continueButtonStyle(),
                ),
              ),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 70,
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

  List<Widget> _buildStopFields() {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: ColorManager.button_login_background_color, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder enabledInputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: ColorManager.button_login_background_color, width: 1),
      borderRadius: BorderRadius.circular(20),
    );

    List<Widget> stopFields = [];
    for (int i = 0; i < _stopControllers.length; i++) {
      stopFields.add(
        Column(
          children: [
            TextField(
              controller: _stopControllers[i],
              decoration: InputDecoration(
                labelText: 'Stop location ${i + 1}',
                labelStyle: TextStyle(color: ColorManager.button_login_background_color),
                prefixIcon: Image.asset("assets/images/from_location_icon.png"),
                border: defaultBorder,
                focusedBorder: focusedBorder,
                enabledBorder: enabledInputBorder,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Image.asset(
                        "assets/images/whereto_icon.png",
                        width: 24,
                        height: 24,
                      ),
                      onPressed: () {
                        _navigateToSetStopLocation(i);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.remove, color: ColorManager.button_login_background_color),
                      onPressed: () {
                        _removeStopField(i);
                      },
                    ),
                  ],
                ),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (value) {
                _getPlaces(value, i);
              },
            ),
            _places.isNotEmpty
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _places.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_places[index].description ?? ''),
                        onTap: () {
                          setState(() {
                            _stopControllers[i].text = _places[index].description ?? '';
                            _places.clear();
                          });
                        },
                      );
                    },
                  )
                : Container(),
            const SizedBox(height: 10),
          ],
        ),
      );
    }
    stopFields.add(
      Center(
        child: GestureDetector(
          onTap: _addStopField,
          child: SvgPicture.asset(
            'assets/images/adding_stop.svg',
            width: 70,
            height: 60,
          ),
        ),
      ),
    );
    return stopFields;
  }
}
