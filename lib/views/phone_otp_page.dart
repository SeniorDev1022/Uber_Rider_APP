import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/view_models/user_view_model.dart';
import 'package:uber_josh/views/optional_email_page.dart';
import 'dart:ui';
import 'package:uber_josh/common/phone_number_utils.dart';
import 'package:uber_josh/views/password_page.dart';
import 'package:provider/provider.dart';

class PhoneOtpPage extends StatefulWidget {
  final String phoneNumber;
  final String frompage;
  PhoneOtpPage({Key? key, required this.phoneNumber, required this.frompage})
      : super(key: key);

  @override
  _PhoneOtpPageState createState() => _PhoneOtpPageState();
}

class _PhoneOtpPageState extends State<PhoneOtpPage> {
  bool isCheckCode = false;
  late String enteredCode;
  final TextEditingController verificationController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isFocused = false;
  bool isLoading = false;
  String? verificationId;
  String? errorMessage; // To hold error message

  int _start = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
      });
    });

    verificationController.addListener(() {
      if (verificationController.text.length == 6) {
        setState(() {
          isLoading = true;
          errorMessage = null; // Reset error message when user starts typing
        });
        verifyOtp(verificationController.text);
        Future.delayed(Duration(seconds: 1), () {
          onNextButtonPressed(widget.frompage);
        });
      }
    });

    // Request focus for the text field when the page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    sendOtp();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    verificationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void resendCode() {
    // Reset the timer
    setState(() {
      _start = 30;
    });
    startTimer();

    sendOtp();
  }

  void sendOtp() async {
    String cleanPhoneNumber = formatAndSanitizePhoneNumber(widget.phoneNumber);
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: cleanPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification or instant verification on some devices
        await FirebaseAuth.instance.signInWithCredential(credential);
        onNextButtonPressed(widget.frompage);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        } else {
          print('Verification failed: ${e.message}');
        }
        setState(() {
          isLoading = false;
          errorMessage = e.message; // Update error message
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
        setState(() {
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        this.verificationId = verificationId;
        setState(() {
          isLoading = false;
        });
      },
    );
  }

  void verifyOtp(String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId!,
      smsCode: smsCode,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      onNextButtonPressed(widget.frompage);
    } catch (e) {
      print('Failed to sign in: $e');
      setState(() {
        isLoading = false;
        errorMessage =
            "The verification code from SMS is invalid. Please check and enter the correct verification code again."; // Update error message
      });
    }
  }

  void onNextButtonPressed(String isGopage) {
    String cleanPhoneNumber = formatAndSanitizePhoneNumber(widget.phoneNumber);
    if (isGopage == "signup") {
      context.read<UserViewModel>().setPhoneNumber(cleanPhoneNumber);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OptionalEmailAddressPage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PasswordPage(loginMethod: "phone")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String cleanPhoneNumber = formatAndSanitizePhoneNumber(widget.phoneNumber);
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
            Apptext.otpPageTitle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24, // Set text to bold
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Apptext.otpPageDecsription,
                        style: TextStyle(
                          fontSize: 16,
                          color: ColorManager.verification_description_color,
                        ),
                      ),
                      Text(
                        "$cleanPhoneNumber",
                        style: AppTextStyles.TitleStyle,
                      ),
                      Row(
                        children: [
                          const Text(
                            "by ",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "SMS Services",
                            style: TextStyle(
                              fontSize: 16,
                              color: ColorManager.button_login_background_color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: verificationController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    labelText: Apptext.verificationTextFieldLabeltext,
                    labelStyle: TextStyle(
                      color: isFocused
                          ? ColorManager.button_login_background_color
                          : Colors.black,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: ColorManager.button_login_background_color,
                        width: 2.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: ColorManager.button_login_background_color,
                        width: 2.0,
                      ),
                    ),
                    errorText: errorMessage, // Display error message
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 20),
                const Spacer(),
                const Center(
                  child: Text(
                    Apptext.receiveButtonText,
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _start == 0 ? resendCode : null,
                    style: continueButtonStyle(),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: ColorManager.button_resend_color,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(
                            maxWidth: double.infinity, minHeight: 50),
                        child: Text(
                          _start > 0
                              ? 'Resend the Code in ($_start) s'
                              : 'Resend the Code',
                          style: TextStyle(
                            color: ColorManager.button_login_background_color,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
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
                    Text('Loading...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
