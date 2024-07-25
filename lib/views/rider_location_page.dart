import 'dart:ui'; // Import for ImageFilter
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/geocoding.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_maps_webservice/directions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/views/pickup_page.dart';
import 'add_stop_page.dart';
import 'request_page.dart';

class RiderLocationPage extends StatefulWidget {
  @override
  _RiderLocationPageState createState() => _RiderLocationPageState();
}

class _RiderLocationPageState extends State<RiderLocationPage> with SingleTickerProviderStateMixin {
  final TextEditingController _currentLocationController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  List<Prediction> _places = [];
  List<Prediction> _currentLocationPlaces = [];
  List<String> stops = [];

  final String apiKey = 'AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4';
  final geocoding = GoogleMapsGeocoding(apiKey: "AIzaSyDSrCWuiGHc7LOyI5ZDLTDmanGNPmVDvk4");
  bool _isLoading = true; // State variable for loading
  


  final List<Map<String, String>> recentPlaces = [];
  final List<Map<String, String>> FavoritePlaces = [
    {
      'title': 'Lake of the Woods District Hospital',
      'address': '21 Sylvan st, Kenora, ON P9N 3W7',
    },
    {
      'title': "McDonald's",
      'address': '900 ON-17, Kenora, ON P9N 1L9',
    },
    {
      'title': 'Lake of the Woods  Hospital',
      'address': '21 Sylvan st, Kenora, ON P9N 3W7',
    },
    {
      'title': "McDonald's sdfgsdfg",
      'address': '900 ON-17, Kenora, ON P9N 1L9',
    },
    {
      'title': 'Lake of the  District Hospital',
      'address': '21 Sylvan st, Kenora, ON P9N 3W7',
    },
    {
      'title': "McDonald's uyuy",
      'address': '900 ON-17, Kenora, ON P9N 1L9',
    },
  ];

  final List<Map<String, String>> savedPlaces = [
    // {
    //   'title': 'Home',
    //   'address': '123 Main St, Anytown, ON A1B 2C3',
    // },
    // {
    //   'title': 'Work',
    //   'address': '456 Elm St, Anytown, ON A1B 2C3',
    // },
  ];

  late TabController _tabController;
  google_maps.LatLng? _currentPosition;
  google_maps.LatLng? _toPosition;

  final FocusNode fromLocationFocusNode = FocusNode();
  final FocusNode toLocationFocusNode = FocusNode();
  bool isConfirm = false;
  bool isLFocused = false;
  bool isTFocused = false;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _getCurrentLocation();

    fromLocationFocusNode.addListener(() {
      setState(() {
        isLFocused = fromLocationFocusNode.hasFocus;
      });
    });

    toLocationFocusNode.addListener(() {
      setState(() {
        isTFocused = toLocationFocusNode.hasFocus;
      });
    });

    _currentLocationController.addListener(() {
      setState(() {
        isConfirm = _currentLocationController.text.isNotEmpty && _destinationController.text.isNotEmpty;
      });
    });

    _destinationController.addListener(() {
      setState(() {
        isConfirm = _currentLocationController.text.isNotEmpty && _destinationController.text.isNotEmpty;
      });
    });


    // Request focus after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(toLocationFocusNode);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
    _currentLocationController.dispose();
    _destinationController.dispose();
    fromLocationFocusNode.dispose();
    toLocationFocusNode.dispose();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = google_maps.LatLng(position.latitude, position.longitude);
    });
    await _getAddressFromLatLng(position.latitude, position.longitude);
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    final response = await geocoding.searchByLocation(
      Location(lat: lat, lng: lng),
    );
    if (response.isOkay && response.results.isNotEmpty) {
      setState(() {
        _currentLocationController.text = response.results[0].formattedAddress ?? 'Unknown location';
        _isLoading = false; // Stop loading once address is fetched
      });
    } else {
      print('Error: ${response.errorMessage}');
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
    }
  }

  Future<void> _getPlaces(String input) async {
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

  Future<void> _getCurrentLocationPlaces(String input) async {
    final googleMapsPlaces = GoogleMapsPlaces(apiKey: apiKey);
    PlacesAutocompleteResponse response = await googleMapsPlaces.autocomplete(input);

    if (response.isOkay) {
      setState(() {
        _currentLocationPlaces = response.predictions;
      });
    } else {
      print(response.errorMessage);
    }
  }

  Future<void> _navigateToAddStopPage() async {
    if (_toPosition != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddStopPage(
            currentPosition: _currentPosition!,
            toPosition: _toPosition!,
            currentAddress: _currentLocationController.text,
            toAddress: _destinationController.text,
          ),
        ),
      );

      if (result != null) {
        setState(() {
          stops.add(result);
        });
      }
    } else {
      // Handle the case when _toPosition is null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set a destination first.')),
      );
    }
  }

  Future<void> _navigateToPickUpPage() async {
    final result = await Navigator.push(
      context,
            MaterialPageRoute(builder: (context) => PickUpPage(
              currentPosition: _currentPosition!,
              source: "rider_location")),

    );

    if (result != null) {
      setState(() {
        _destinationController.text = result['address'];
        _toPosition = result['location'];
      });
    }
  }

  void _navigateToRequestPage() {
    if (_destinationController.text.isEmpty) {
      // Handle null case or empty destination
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please ensure current location and destination are set')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestPage(
          currentAddress: _currentLocationController.text,
          destinationAddress: _destinationController.text,
          currentPosition: _currentPosition!,
          stopPoints: [],
        ),
      ),
    );
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
      appBar: AppBar(
          leading: IconButton(
          icon: Image.asset(Apptext.backIcon_image),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Center(
          child: Text(
            Apptext.riderLocationPagetitletext,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 24,// Set text to bold
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8.0),
                            width: 30,
                            child: Column(
                              children: [
                                Image.asset("assets/images/from_location_icon.png"),
                                const SizedBox(height: 10,),
                                Image.asset('assets/images/line.png'),
                                Image.asset('assets/images/line.png'),
                                const SizedBox(height: 10,),
                                Image.asset('assets/images/to_location_icon.png'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _currentLocationController,
                                  focusNode: fromLocationFocusNode,
                                  decoration: InputDecoration(
                                    labelText: 'From',
                                    labelStyle: TextStyle(
                                      // color: isLFocused ? ColorManager.button_login_background_color : Colors.black,
                                      color: ColorManager.button_login_background_color
                                    ),
                                    border: defaultBorder,
                                    focusedBorder: focusedBorder,
                                    enabledBorder: enabledInputBorder
                                  ),
                                  onChanged: (value) {
                                    _getCurrentLocationPlaces(value);
                                  },
                                ),
                                if (_currentLocationPlaces.isNotEmpty)
                                  Container(
                                    height: 200, // Adjust the height as needed
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: _currentLocationPlaces.length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(_currentLocationPlaces[index].description ?? ''),
                                          onTap: () {
                                            setState(() {
                                              _currentLocationController.text = _currentLocationPlaces[index].description ?? '';
                                              _currentLocationPlaces.clear();
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 10),
                                Container(
                                  child: Center(
                                    child: ElevatedButton(
                                      onPressed: _navigateToAddStopPage,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ColorManager.button_mainuser_other_color,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                        minimumSize: const Size(double.infinity, 40),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Add Multiple Stops', 
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16)),
                                          const SizedBox(width: 8.0), // Space between text and icon
                                          Image.asset("assets/images/plus_icon.png"),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _destinationController,
                                  focusNode: toLocationFocusNode,
                                  decoration: InputDecoration(
                                    labelText: 'To',
                                    labelStyle: TextStyle(
                                      // color: isTFocused ? ColorManager.button_login_background_color : Colors.black,
                                      color: ColorManager.button_login_background_color
                                    ),
                                    hintText: 'Choose your destination',
                                    hintStyle: const TextStyle(
                                      color: Colors.grey,
                                    ),  
                                    border: defaultBorder,
                                    focusedBorder: focusedBorder,
                                    enabledBorder: enabledInputBorder,
                                    suffixIcon: IconButton(
                                      icon: Image.asset(
                                        "assets/images/whereto_icon.png",
                                        width: 24,
                                        height: 24,  
                                      ),
                                      onPressed: _navigateToPickUpPage,
                                      padding: const EdgeInsets.only(right: 5),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _getPlaces(value);
                                  },
                                ),
                                if (_places.isNotEmpty)
                                  Container(
                                    height: 200, // Adjust the height as needed
                                    child: ListView.builder(
                                      shrinkWrap: true,
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
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      const SizedBox(height: 20),
                      TabBar(
                        controller: _tabController,
                        tabs: [
                          const Tab(text: 'Recent'),
                          const Tab(text: 'Favorites'),
                          const Tab(text: 'Saved'),
                        ],
                        labelColor: ColorManager.button_login_background_color,
                        unselectedLabelColor: Colors.black,
                        indicatorColor: ColorManager.button_login_background_color,
                      ),
                      Container(
                        height: 300, // Fixed height for the TabBarView
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildListView(recentPlaces),
                            _buildListView(FavoritePlaces),
                            _buildSavedListView(savedPlaces),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                    Text('Fetching current location...'),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
            width: double.infinity, // Make the button fill the width of the screen
            height: 50, // Set the fixed height of the button
              child: ElevatedButton(
                onPressed: _navigateToRequestPage,
                style: continueButtonStyle(),
                child: Ink(
                  decoration: isConfirm
                        ? continueButtonGradientDecoration() : nocontinueButtonGradientDecoration(),
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(maxWidth: double.infinity, minHeight: 50),
                    child: Text(
                      Apptext.confrimButtonText,
                      style: continueButtonTextStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildListView(List<Map<String, String>> places) {
    if (places.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_recent_list_image.png', // Replace with your actual image path
              width: 200,
              height: 200,
            ),
            const SizedBox(height: 16),
            const Text(
              'No recent locations',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Schedule your ride now and find your previous\n'
              'destinations easily in the future!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            title: Text(place['title'] ?? ''),
            subtitle: Text(place['address'] ?? ''),
            trailing: place.containsKey('distance')
                ? Text(
                    place['distance'] ?? '',
                    style: const TextStyle(color: Colors.teal),
                  )
                : null,
            onTap: () {
              setState(() {
                _destinationController.text = place['title'] ?? '';
              });
            },
          );
        },
      );
    }
  }

  Widget _buildSavedListView(List<Map<String, String>> places) {
  return ListView(
    children: [
      ListTile(
        title: Text(
          'Add New', 
          style: TextStyle(color: ColorManager.button_login_background_color)),
        trailing: Image.asset("assets/images/saved_add_icon.png"),
        onTap: () {
          // Add action for "Add New"
        },
      ),
      ListTile(
        title: const Text('Add Home', style: TextStyle(color: Colors.teal)),
        trailing: Image.asset("assets/images/saved_home_icon.png"),
        onTap: () {
          // Add action for "Add Home"
        },
      ),
      ListTile(
        title: const Text('Add Work', style: TextStyle(color: Colors.teal)),
        trailing: Image.asset("assets/images/saved_work_icon.png"),
        onTap: () {
          // Add action for "Add Work"
        },
      ),
    ],
  );
}
}
