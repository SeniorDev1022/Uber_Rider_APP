import 'package:flutter/material.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/views/activity_history_page.dart';
import 'package:uber_josh/views/message_page.dart';
import 'package:uber_josh/views/rider_location_page.dart';

class RiderMainPage extends StatefulWidget {
  @override
  _RiderMainPageState createState() => _RiderMainPageState();
}

class _RiderMainPageState extends State<RiderMainPage> {
  final List<Map<String, String>> mostFavorites = [
    {
      'title': 'Vizcaya Museum & Gardens',
      'address': '3251 S Miami Ave, Miami, FL 33129, United States',
    },
    {
      'title': 'Bayside Marketplace',
      'address': '401 Biscayne Blvd, Miami, FL 33132, United States',
    },
    {
      'title': 'Miami Design District',
      'address': '4000 NE 1st Ave, Miami, FL 33137, United States',
    },
    {
      'title': 'Miami Design District',
      'address': '4000 NE 1st Ave, Miami, FL 33137, United States',
    },
    {
      'title': 'Miami Design District',
      'address': '4000 NE 1st Ave, Miami, FL 33137, United States',
    },
    {
      'title': 'Miami Design District',
      'address': '4000 NE 1st Ave, Miami, FL 33137, United States',
    },
    {
      'title': 'Miami Design District',
      'address': '4000 NE 1st Ave, Miami, FL 33137, United States',
    },
    {
      'title': 'Miami Design District',
      'address': '4000 NE 1st Ave, Miami, FL 33137, United States',
    },
    {
      'title': 'Miami Design District',
      'address': '4000 NE 1st Ave, Miami, FL 33137, United States',
    },
  ];

  void onWheretoPress() {
    Navigator.push(context, 
      MaterialPageRoute(builder: (context) => RiderLocationPage())
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 30,),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Hello Haziq,',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            Apptext.riderMainPageDecsription,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(Apptext.user_avatar_image),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GestureDetector(
                    onTap: onWheretoPress,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 2,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8.0),
                          Text(
                            'Enter your destination...',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Most Favorites',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(Icons.star, color: Colors.amber, size: 20),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: mostFavorites.length,
                                itemBuilder: (context, index) {
                                  final place = mostFavorites[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.teal.withOpacity(0.1),
                                          child: const Icon(Icons.location_on, color: Colors.teal),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                place['title']!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                place['address']!,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: Image.asset(Apptext.home_white_icon_image),
                      label: const Text('HOME', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorManager.button_login_background_color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                      ),
                    ),
                    Container(
                      width: 60, // Set the desired width
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorManager.button_mainuser_other_color,
                      ),
                      child: IconButton(
                        icon: Image.asset(Apptext.activity_icon_image),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityHistoryPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 60, // Set the desired width
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorManager.button_mainuser_other_color,
                      ),
                      child: IconButton(
                        icon: Image.asset(Apptext.message_icon_image),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MessagePage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
