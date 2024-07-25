import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/views/user_mainpage.dart';
import 'dart:ui';
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? mapController;
  late LatLng _currentPosition;
  late Marker _currentLocationMarker;
  bool _locationInitialized = false;// Add this line to declare the _isLoading variable

  @override
  void initState() {
    super.initState();
    _determinePosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _currentLocationMarker = Marker(
          markerId: MarkerId("current_location"),
          position: _currentPosition,
        );
        _locationInitialized = true;// Set _isLoading to false when the position is determined
      });
    }).catchError((e) {
      print("Error getting location: $e");
    });
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
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 14.0));
  }

  void onLoginButtonPress() {
    String valueToSend = "login";
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => UserMainpage(
                  frommain_value: valueToSend,
                )));
  }

  void onSignupButtonPress() {
    String valueToSend = "signup";
    Navigator.push(context, MaterialPageRoute(builder: (context) => UserMainpage(frommain_value: valueToSend,)));
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
                zoom: 14.0,
              ),
              markers: {_currentLocationMarker},
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
            ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30.0),
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Apptext.mainpagetitletext1,
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            Apptext.mainpagetitletext2,
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            Apptext.mainpagedescriptiontext,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Image.asset(
                        Apptext.appbar_image, // Add your image path here
                        width: 100.0,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                  TextField(
                    style: TextStyle(
                      color: ColorManager.button_login_background_color, // Set the text color here
                    ),
                    decoration: InputDecoration(
                      hintText: Apptext.mainSearchhinttext,
                      hintStyle: TextStyle(
                        color: ColorManager.button_login_background_color, // Set the hint text color here
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      prefixIcon: Icon(
                        Icons.search,
                        color: ColorManager.button_login_background_color,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: ColorManager.button_login_background_color, // Set the border color here
                          width: 2.0, // Set the border width if needed
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: ColorManager.button_login_background_color, // Set the focused border color here
                          width: 2.0, // Set the border width if needed
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: ColorManager.button_login_background_color, // Set the enabled border color here
                          width: 2.0, // Set the border width if needed
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.7),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30.0),
                ),
              ),
              padding: const EdgeInsets.all(20), // Add padding to the container
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onSignupButtonPress,
                    child: Text(Apptext.signupbuttontext,
                        style: AppTextStyles.mainButtonStyle),
                    style: singupButtonStyle(),
                  ),
                  ElevatedButton(
                    onPressed: onLoginButtonPress,
                    child: Text(Apptext.loginbuttontext,
                        style: AppTextStyles.mainButtonStyle),
                    style: loginButtonStyle(),
                  ),
                ],
              ),
            ),
          ),
          if (!_locationInitialized)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Fetching current location...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
