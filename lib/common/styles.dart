import 'package:flutter/material.dart';
import 'color_manager.dart';


class AppTextStyles{
  static const TextStyle appBarTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle appBarDescriptionStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,  // Smaller font size
    fontWeight: FontWeight.normal,
  );

  static const TextStyle mainButtonStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  static const TextStyle TitleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle textMiddleStyle = TextStyle(
    fontSize: 18,
  );

  static const TextStyle textSmallStyle = TextStyle(
    fontSize: 13,
  );
}

class AppbarStyles{

  static const CircleAvatar appbarImage = CircleAvatar(
    radius: 70,
    backgroundColor: Colors.transparent,
    backgroundImage: AssetImage('assets/images/appbar_image.png'),
  );

}

class GredientStyles{
  static const BoxDecoration appbarBackgroundDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [ColorManager.appbar_gradient_left_color, 
      ColorManager.appbar_gradient_right_color],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );
}

ButtonStyle nextButtonStyle({required bool isEmailValid}){
  return ElevatedButton.styleFrom(
    backgroundColor: isEmailValid ? Colors.black : ColorManager.button_mainuser_other_color,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
    textStyle: TextStyle(fontSize: 16),
  );
}

ButtonStyle NoNnextButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
    textStyle: TextStyle(fontSize: 16),
  );
}

ButtonStyle singupButtonStyle() {
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.white),
    foregroundColor: WidgetStateProperty.all(ColorManager.button_signup_text_color),
    padding: WidgetStateProperty.all(EdgeInsets.only(
      left: 45.0, top: 10.0, right: 45.0, bottom: 10.0))
  );
}

ButtonStyle beforeButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.grey[200],
    shape: CircleBorder(),
    padding: EdgeInsets.all(20),
  );
}

ButtonStyle loginButtonStyle() {
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.all(ColorManager.button_login_background_color),
    foregroundColor: WidgetStateProperty.all(Colors.white),
    padding: WidgetStateProperty.all(EdgeInsets.only(
      left: 30.0, right: 30.0, top: 10.0, bottom: 10.0))
  );
}

ButtonStyle googleButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: ColorManager.button_mainuser_other_color, // Background color of the button
    foregroundColor: Colors.black, // Text and icon color
    shape: RoundedRectangleBorder(
      // Rounded Rectangle Border
      borderRadius: BorderRadius.circular(30), // Custom radius size
    ),
  );
}

ButtonStyle continueButtonStyle() {
  return ElevatedButton.styleFrom(
    shadowColor: Colors.transparent,
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );
}

BoxDecoration continueButtonGradientDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: <Color>[
        ColorManager.button_mainuser_left_color,
        ColorManager.button_mainuser_right_color
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(30),
  );
}

BoxDecoration nocontinueButtonGradientDecoration() {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: <Color>[
        ColorManager.button_no_decoration_color,
        ColorManager.button_no_decoration_color
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(30),
  );
}

TextStyle nextButtonTextStyle({required bool isEmailValid}) {
  return TextStyle(
    color: isEmailValid ? Colors.white : Colors.grey, 
    fontSize: 18.0,
  );
}

TextStyle continueButtonTextStyle() {
  return TextStyle(
    color: Colors.white, 
    fontSize: 18,
    fontWeight: FontWeight.bold
  );
}

TextStyle dividerTextStyle() {
  return const TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
  );
}

Divider dividerStyle() {
  return const Divider(
    color: Colors.grey,
    thickness: 1.5,
  );
}

EdgeInsets dividerPadding() {
  return const EdgeInsets.symmetric(vertical: 20.0);
}

EdgeInsets appbarPadding() {
  return const EdgeInsets.symmetric(horizontal: 20);
}

EdgeInsets dividerTextPadding() {
  return const EdgeInsets.symmetric(horizontal: 8.0);
}

Color nextButtonIconColor({required bool isEmailValid}) {
  return isEmailValid ? Colors.white : Colors.grey;
}