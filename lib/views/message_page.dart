import 'package:flutter/material.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/views/activity_history_page.dart';
import 'package:uber_josh/views/rider_main_page.dart';

class MessagePage extends StatelessWidget {
  final List<Map<String, String>> messages = [
    {
      'name': 'George Einstein',
      'route': 'Spe Ornamental Corp - Miami Senior High School',
      'time': '12:00 PM',
      'status': 'Online',
      'messageCount': '2',
    },
    {
      'name': 'Darlene Warren',
      'route': 'Miami Senior High School - Miami Design District',
      'time': 'Yesterday',
      'status': 'Offline',
      'messageCount': '',
    },
    // Add more messages here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(color: Colors.grey, width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(Apptext.user_avatar_image),
                      ),
                      title: Text(message['name'] ?? ''),
                      subtitle: Text(message['route'] ?? ''),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(message['time'] ?? ''),
                          SizedBox(height: 10,),
                          if (message['messageCount']?.isNotEmpty ?? false)
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.teal,
                              child: Text(
                                message['messageCount']!,
                                style: TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
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
                      color: ColorManager.button_mainuser_other_color,
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
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: Image.asset(Apptext.message_white_icon_image),
                    label: Text('MESSAGES', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorManager.button_login_background_color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
