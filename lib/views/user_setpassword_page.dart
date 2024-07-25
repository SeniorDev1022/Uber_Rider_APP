import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/view_models/user_view_model.dart';
import 'package:uber_josh/views/policy_page.dart';

class UserSetPasswordPage extends StatefulWidget {
    final String loginMethod;
  UserSetPasswordPage({Key? key, required this.loginMethod}) : super(key: key);
  @override
  _UserSetPasswordPageState createState() => _UserSetPasswordPageState();
}

class _UserSetPasswordPageState extends State<UserSetPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
  bool isPasswordVisible = false;
  bool isConfirmVisible = false;
  bool isFocused = false;
  bool isLFocused = false;
  bool isNext = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    passwordFocusNode.addListener(() {
      setState(() {
        isFocused = passwordFocusNode.hasFocus;
      });
    });

    confirmPasswordFocusNode.addListener(() {
      setState(() {
        isLFocused = confirmPasswordFocusNode.hasFocus;
      });
    });

    passwordController.addListener(() {
      setState(() {
        isNext = passwordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty;
      });
    });

    confirmPasswordController.addListener(() {
      setState(() {
        isNext = passwordController.text.isNotEmpty && confirmPasswordController.text.isNotEmpty;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(passwordFocusNode);
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void NextPage() {
  String password = passwordController.text;
  String confirmPassword = confirmPasswordController.text;
  if (password.length < 4) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Password must be at least 4 characters long!')),
    );
  } else if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Passwords do not match! Please try again.')),
    );
  } else {
    context.read<UserViewModel>().setPassword(passwordController.text);
    Navigator.push(context, MaterialPageRoute(builder: (context) => AcceptTermsPage()));
  }
}

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder defaultBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: BorderRadius.circular(20),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
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
        title: Center(
          child: Text(
            Apptext.emailpagetitletext,
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 24,// Set text to bold
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
              "Set your password",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(
                  color: isFocused ? ColorManager.button_login_background_color : Colors.black,
                ),
                border: defaultBorder,
                focusedBorder: focusedBorder,
                suffixIcon: IconButton(
                  icon: Image.asset(
                    isPasswordVisible
                        ? 'assets/images/password_icon.png' // Change this to an 'eye' open icon if you have one
                        : 'assets/images/password_icon.png', // 'eye' closed icon
                  ),
                  padding: EdgeInsets.only(right: 15),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              focusNode: confirmPasswordFocusNode,
              obscureText: !isConfirmVisible,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                labelStyle: TextStyle(
                  color: isLFocused ? ColorManager.button_login_background_color : Colors.black,
                ),
                border: defaultBorder,
                focusedBorder: focusedBorder,
                suffixIcon: IconButton(
                  icon: Image.asset(
                    isPasswordVisible
                        ? 'assets/images/password_icon.png' // Change this to an 'eye' open icon if you have one
                        : 'assets/images/password_icon.png', // 'eye' closed icon
                  ),
                  padding: EdgeInsets.only(right: 15),
                  onPressed: () {
                    setState(() {
                      isConfirmVisible = !isConfirmVisible;
                    });
                  },
                ),
              ),
            ),
            Spacer(),
            SizedBox(
            width: double.infinity, // Make the button fill the width of the screen
            height: 50, // Set the fixed height of the button
              child: ElevatedButton(
                onPressed: NextPage,
                style: continueButtonStyle(),
                child: Ink(
                  decoration: isNext
                        ? continueButtonGradientDecoration() : nocontinueButtonGradientDecoration(),
                  child: Container(
                    alignment: Alignment.center,
                    constraints: BoxConstraints(maxWidth: double.infinity, minHeight: 50),
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
