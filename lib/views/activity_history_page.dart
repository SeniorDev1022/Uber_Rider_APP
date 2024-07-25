import 'package:flutter/material.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/views/message_page.dart';
import 'package:uber_josh/views/rider_main_page.dart';

class ActivityHistoryPage extends StatelessWidget {
  final List<Map<String, String>> activityHistory = [
    {
      'status': 'SUCCEED',
      'route': 'Spe Ornamental Corp to Miami Senior High School',
      'date': '8 Jun 2024 - 15:42',
      'price': '\$12.08',
    },
    {
      'status': 'SUCCEED',
      'route': 'Miami Senior High School to Bayside Marketplace',
      'date': '8 Jun 2024 - 18:07',
      'price': '\$27.82',
    },
    {
      'status': 'CANCELLED',
      'route': 'Miami Design District to Spe Ornamental Corp',
      'date': '8 Jun 2024 - 15:42',
      'price': '\$20.65',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(16.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Colors.grey, width: 1.0), 
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Activity History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.0),
                itemCount: activityHistory.length,
                itemBuilder: (context, index) {
                  final activity = activityHistory[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset("assets/images/car_icon.png", width: 40, height: 40),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['status'] ?? '',
                                style: TextStyle(
                                  color: activity['status'] == 'SUCCEED' ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                activity['route'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    activity['date'] ?? '',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 15
                                    ),
                                  ),
                                  Spacer(),
                                  Text(
                                    activity['price'] ?? '',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15
                                    ),
                                  ),
                                ],
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    child: IconButton(
                      icon: Image.asset(Apptext.home_icon_image),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RiderMainPage(),
                          ),
                        );
                      },
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      
                    },
                    icon: Image.asset(Apptext.activity_white_icon_image),
                    label: Text('ACTIVITY', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.button_login_background_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
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
            )

          ],
        ),
      ),
    );
  }
}
