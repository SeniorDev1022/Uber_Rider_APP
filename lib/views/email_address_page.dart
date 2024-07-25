import 'package:flutter/material.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/view_models/user_view_model.dart';
import 'package:uber_josh/views/password_page.dart';
// import 'package:uber_josh/views/phone_otp_page.dart';
import 'package:uber_josh/views/user_name_page.dart';

import 'package:provider/provider.dart';

class EmailAddressPage extends StatefulWidget {
  final String beforePageValue;

  EmailAddressPage({required this.beforePageValue});

  @override
  _EmailAddressPageState createState() => _EmailAddressPageState();
}

class _EmailAddressPageState extends State<EmailAddressPage> {
  final TextEditingController emailController = TextEditingController();
  bool isEmailValid = false;
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });

    // Request focus for the text field when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    emailController.dispose();
    super.dispose();
  }

  void validateEmail(String email) {
    setState(() {
      isEmailValid = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
      ).hasMatch(email);
    });
  }

  void onNextButtonPressed(String isGopage) {
    context.read<UserViewModel>().setEmail(emailController.text);
    if (isGopage == "signup") {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => UserNamePage()));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PasswordPage(
                    loginMethod: "email",
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
            Apptext.emailpagetitletext,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, // Set text to bold
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        height: screenHeight,
        child: Column(
          children: [
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    Apptext.emailpagedescriptiontext,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      labelText: Apptext.emailTextFieldLabeltext,
                      labelStyle: TextStyle(
                          color: ColorManager.button_login_background_color),
                      hintText: Apptext.emailtextfilehinttext,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: ColorManager
                              .button_login_background_color, // Set the border color here
                          width: 2.0, // Set the border width if needed
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: ColorManager
                              .button_login_background_color, // Set the focused border color here
                          width: 2.0, // Set the border width if needed
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    onChanged: validateEmail,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double
                  .infinity, // Make the button fill the width of the screen
              height: 50, // Set the fixed height of the button
              child: ElevatedButton(
                onPressed: isEmailValid
                    ? () => onNextButtonPressed(widget.beforePageValue)
                    : null,
                style: continueButtonStyle(),
                child: Ink(
                  decoration: isEmailValid
                      ? continueButtonGradientDecoration()
                      : nocontinueButtonGradientDecoration(),
                  child: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(
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
