import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/view_models/user_view_model.dart';
import 'package:uber_josh/views/homepage.dart';
import 'dart:ui';

class AcceptTermsPage extends StatefulWidget {
  @override
  _AcceptTermsPageState createState() => _AcceptTermsPageState();
}

class _AcceptTermsPageState extends State<AcceptTermsPage> {
  bool isChecked = false;
  bool isLoading = false;

  void navigateToTermsOfUse() {
    // Navigate to Terms of Use page
  }

  void navigateToPrivacyNotice() {
    // Navigate to Privacy Notice page
  }

  Future<void> _onPressedDonebutton() async {
    setState(() {
      isLoading = true;
    });

    await context.read<UserViewModel>().registerUser();

    setState(() {
      isLoading = false;
    });

    if (context.read<UserViewModel>().isRegistrationSuccessful) {
      // Navigate to HomePage if registration is successful
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // Show error message if registration fails
      final errorMessage =
          context.read<UserViewModel>().errorMessage ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final userViewModel = Provider.of<UserViewModel>(context);
    // print('User Information:');
    // print('Name: ${userViewModel.user.name}');
    // print('Email: ${userViewModel.user.email}');
    // print('Password: ${userViewModel.user.password}');
    // print('Phone Number: ${userViewModel.user.phoneNumber}');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(Apptext.backIcon_image),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Image.asset("assets/images/policy_image.png"),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Accept KenoRide's",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const Text(
                  "Terms & Review Privacy Notice",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                        color: ColorManager.policy_des_color, fontSize: 16),
                    children: [
                      const TextSpan(
                          text:
                              'By selecting "I Agree" below, I have reviewed and agree to the '),
                      TextSpan(
                        text: 'Terms of Use',
                        recognizer: TapGestureRecognizer()
                          ..onTap = navigateToTermsOfUse,
                      ),
                      const TextSpan(text: ' and acknowledge the '),
                      TextSpan(
                        text: 'Privacy Notice',
                        recognizer: TapGestureRecognizer()
                          ..onTap = navigateToPrivacyNotice,
                      ),
                      const TextSpan(text: '. I am at least 18 years of age.'),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
                // Checkbox and "I Agree" text
                Row(
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                      activeColor: ColorManager.button_login_background_color,
                    ),
                    Expanded(
                      child: Text(
                        'I agree to the Terms & Review',
                        style: TextStyle(
                            fontSize: 16, color: ColorManager.policy_des_color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                    height: 50), // Add some space to avoid overlap with button
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isChecked
                    ? () async {
                        await _onPressedDonebutton();
                      }
                    : null,
                style: continueButtonStyle(),
                child: Ink(
                  decoration: isChecked
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
          ),
          if (isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Registering...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
