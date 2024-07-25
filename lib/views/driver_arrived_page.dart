
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_josh/view_models/accept_view_modal.dart';
import 'package:uber_josh/views/tracking_location_page.dart';

class DriverArrivedPage extends StatefulWidget {
  @override
  _DriverArrivedPageState createState() => _DriverArrivedPageState();
}

class _DriverArrivedPageState extends State<DriverArrivedPage> {
  bool hasNavigated = false; // Flag to check if navigation has occurred

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/arrived_image.png'), 
            Consumer<AcceptViewModel>(
              builder: (context, acceptViewModel, child) {
                if (acceptViewModel.moveTo == "started") {
                  // Set the flag to true to prevent multiple navigations
                  hasNavigated = true;
                  // Navigate to the ArrivedPage
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => TrackingLocationPage()),
                    );
                  });
                }

                print(acceptViewModel.moveTo);
                return Text(
                  acceptViewModel.moveTo == "arrived"
                      ? 'Your driver has arrived!'
                      : "Driver is on the way...",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                );
              }
            )
          ],
        ),
      ),
    );
  }
}