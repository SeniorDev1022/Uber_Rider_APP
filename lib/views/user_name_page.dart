import 'package:flutter/material.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/view_models/user_view_model.dart';
import 'package:uber_josh/views/user_setpassword_page.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:provider/provider.dart';

class UserNamePage extends StatefulWidget {
  @override
  _UserNamePageState createState() => _UserNamePageState();
}

class _UserNamePageState extends State<UserNamePage> {
  String? errorMessage;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  bool isFocused = false;
  bool isLFocused = false;
  bool isNext = false;

  @override
  void initState() {
    super.initState();
    firstNameFocusNode.addListener(() {
      setState(() {
        isFocused = firstNameFocusNode.hasFocus;
      });
    });

    lastNameFocusNode.addListener(() {
      setState(() {
        isLFocused = lastNameFocusNode.hasFocus;
      });
    });

    firstNameController.addListener(() {
      setState(() {
        isNext = firstNameController.text.isNotEmpty &&
            lastNameController.text.isNotEmpty;
      });
    });

    lastNameController.addListener(() {
      setState(() {
        isNext = firstNameController.text.isNotEmpty &&
            lastNameController.text.isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(firstNameFocusNode);
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    super.dispose();
  }

  void NextPage() {
    String firstname = firstNameController.text;
    String lastname = lastNameController.text;
    if (firstname.isNotEmpty && lastname.isNotEmpty) {
      context.read<UserViewModel>().setFirstName(firstname);
      context.read<UserViewModel>().setLastName(lastname);
      
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserSetPasswordPage(
                    loginMethod: "phone",
                  )));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Please enter a your name!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(
          color: ColorManager.button_login_background_color, width: 1),
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
        title: Center(
          child: Text(
            Apptext.emailpagetitletext,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, // Set text to bold
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What's your name?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: firstNameController,
              focusNode: firstNameFocusNode,
              decoration: InputDecoration(
                labelText: "First Name",
                labelStyle: TextStyle(
                  color: isFocused
                      ? ColorManager.button_login_background_color
                      : Colors.black,
                ),
                border: defaultBorder,
                focusedBorder: focusedBorder,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: lastNameController,
              focusNode: lastNameFocusNode,
              decoration: InputDecoration(
                labelText: "Last Name",
                labelStyle: TextStyle(
                  color: isLFocused
                      ? ColorManager.button_login_background_color
                      : Colors.black,
                ),
                border: defaultBorder,
                focusedBorder: focusedBorder,
              ),
            ),
            Spacer(),
            SizedBox(
              width: double
                  .infinity, // Make the button fill the width of the screen
              height: 50, // Set the fixed height of the button
              child: ElevatedButton(
                onPressed: NextPage,
                style: continueButtonStyle(),
                child: Ink(
                  decoration: isNext
                      ? continueButtonGradientDecoration()
                      : nocontinueButtonGradientDecoration(),
                  child: Container(
                    alignment: Alignment.center,
                    constraints: BoxConstraints(
                        maxWidth: double.infinity, minHeight: 50),
                    child: Text(
                      Apptext.nextbuttontext,
                      style: continueButtonTextStyle(),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
