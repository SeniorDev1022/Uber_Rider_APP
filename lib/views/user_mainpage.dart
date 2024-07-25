import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:uber_josh/common/color_manager.dart';
import 'package:uber_josh/common/styles.dart';
import 'package:uber_josh/common/text_content.dart';
import 'package:uber_josh/views/phone_otp_page.dart';
import 'package:uber_josh/views/email_address_page.dart';

class UserMainpage extends StatefulWidget {
  final String frommain_value;

  UserMainpage ({required this.frommain_value});

  @override
  UserMainpageState createState() => UserMainpageState();
}

class UserMainpageState extends State<UserMainpage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController phoneNumberController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'CA');
  String? errorMessage;
  bool isValid = false;
  bool showError = false;
  bool emptyError = false;
  String? emptyerrorMessage;


  void checkPhoneNumber(String value) {
    if (value.length == 10 && RegExp(r'^\d{10}$').hasMatch(value)) {
      setState(() {
        isValid = true;
        showError = false;
        emptyError = false;
      });
    } else {
      setState(() {
        isValid = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Add listener to controller to handle phone number changes
    phoneNumberController.addListener(() {
      checkPhoneNumber(phoneNumberController.text);
    });
  }

  void onContinueButtonPressed(String isGopage) {               
    if (isValid) {
      String numbers = phoneNumberController.text;
      if(isGopage == "signup"){
        Navigator.push(context, 
              MaterialPageRoute(builder: (context) => PhoneOtpPage(phoneNumber: numbers, frompage: widget.frommain_value)));
      } else{
        Navigator.push(context, 
              MaterialPageRoute(builder: (context) => PhoneOtpPage(phoneNumber: numbers, frompage: widget.frommain_value)));
      }
    }else if(phoneNumberController.text.length == 0){
      setState(() { 
        emptyError = true;
        showError = false;
        emptyerrorMessage = 'Please enter your phone number!';
      });
    } 
    
    else {
      // Show error message or handle invalid phone number
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(errorMessage ?? 'Please enter a valid phone number')),
      // );
      setState(() {
        showError = true;
        emptyError = false;
        errorMessage = 'Double-check the number for any missing or extra digits.';
      });
    }
  }

  void onWithMailButtonPressed(String isGopage){
    print(isGopage);
    Navigator.push(context, 
          MaterialPageRoute(builder: (context) => EmailAddressPage(beforePageValue: isGopage)));
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    InputDecoration inputDecoration = InputDecoration(
      labelText: Apptext.phonetextfilehinttext,
      labelStyle: TextStyle(
        color: Colors.black, // Set the initial label text color here
      ),
      floatingLabelStyle: TextStyle(
        color: ColorManager.button_login_background_color, // Set the label text color when focused
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: ColorManager.button_login_background_color, // Set the focused border color here
          width: 1.0, // Set the border width if needed
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: showError || emptyError ? Colors.red : Colors.transparent, // Conditionally set the error border color
          width: 1.0, // Set the border width if needed
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: showError || emptyError ? Colors.red : Colors.transparent, // Conditionally set the focused error border color
          width: 1.0, // Set the border width if needed
        ),
      ),
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
            widget.frommain_value == 'login' ? 'Login' : 'Register',
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 26,// Set text to bold
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10,),
            Text(Apptext.phonenumberpagetiletext,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 20),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber value) {
                setState(() {
                  number = value;
                });
              },
              onInputValidated: (bool value) {
                print(value ? 'Valid' : 'Invalid');
              },
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.DROPDOWN,
                showFlags: true,
                leadingPadding: 16.0,
                trailingSpace: false,
                setSelectorButtonAsPrefixIcon: false,
              ),
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.disabled,
              selectorTextStyle: TextStyle(color: Colors.black),
              initialValue: number,
              textFieldController: phoneNumberController,
              formatInput: false,
              maxLength: 15, // Limit overall length if no country code is considered
              keyboardType:
                  TextInputType.numberWithOptions(signed: true, decimal: true),
              inputDecoration: inputDecoration,
              onSaved: (PhoneNumber value) {
                print('On Saved: $value');
              },
            ),
            if (showError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 140),
              child: Text(
                errorMessage ?? '',
                style: TextStyle(
                  color: Colors.red, // Set the error text color here
                  fontSize: 13,
                ),
              ),
            ),
            if(emptyError)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 140),
              child: Text(
                emptyerrorMessage ?? '',
                style: TextStyle(
                  color: Colors.red, // Set the error text color here
                  fontSize: 13,
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
            width: double.infinity, // Make the button fill the width of the screen
            height: 50, // Set the fixed height of the button
            child: ElevatedButton(
              onPressed: () => onContinueButtonPressed(widget.frommain_value),
              style: continueButtonStyle(),
              child: Ink(
                decoration: continueButtonGradientDecoration(),
                child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(maxWidth: double.infinity, minHeight: 50),
                  child: Text(
                    Apptext.continuebuttontext,
                    style: continueButtonTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            ),
            Padding(
              padding: dividerPadding(), // Add some vertical space before and after the divider
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: dividerStyle(),
                  ),
                  Padding(
                    padding: dividerTextPadding(), // Add space around the "or" text
                    child: Text(
                      'or',
                      style: dividerTextStyle(),
                    ),
                  ),
                  Expanded(
                    child: dividerStyle(),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity, // Make the button fill the width
              height: 50.0,
              child: ElevatedButton.icon(
                style: googleButtonStyle(),
                onPressed: () {
                  // Handle the button press
                  // Navigator.push(context,
                  //  MaterialPageRoute(builder: (context) => HomePage()));
                },
                icon: Image.asset(Apptext.facebookIcon_image, // The icon data
                  width: 20.0,
                  height: 20.0,
                ),
                // The icon data
                label: Text(
                  Apptext.googlebuttontext,
                  style: AppTextStyles.textMiddleStyle
                ), // The text label
              ),
            ),
            SizedBox(height: 15.0,),
            Container(
              width: double.infinity, // Make the button fill the width
              height: 50.0,
              child: ElevatedButton.icon(
                style: googleButtonStyle(),
                onPressed: () => onWithMailButtonPressed(widget.frommain_value),
                icon: Image.asset(Apptext.mailicon, // The icon data
                  width: 20.0,
                  height: 20.0,
                ),
                // The icon data
                label: Text(
                  Apptext.emailbuttontext,
                  style: AppTextStyles.textMiddleStyle
                ), // The text label
              ),
            ),
            Padding(
              padding: dividerPadding(), // Add some vertical space before and after the divider
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: dividerStyle(),
                  ),
                  Padding(
                    padding: dividerTextPadding(), // Add space around the "or" text
                    child: Text(
                      'or',
                      style: dividerTextStyle(),
                    ),
                  ),
                  Expanded(
                    child: dividerStyle(),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10), // Add padding around the container
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.search
                  ),
                  SizedBox(width: 8), // Spacing between the icon and text
                  Text(
                    Apptext.findaccounttext,
                    style: AppTextStyles.textMiddleStyle,
                  ),
                ],
              ),
            ),
            Text(
              Apptext.findAccountDecsription,
              style: AppTextStyles.textSmallStyle,
            ),
          ],
        ),
      ),
    );
  }
}
