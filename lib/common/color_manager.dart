import 'package:flutter/material.dart';

class ColorManager{
  //hex to color method
  static Color hextocolor(String code){
     return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  //Define your favorite colors as static properties
  static Color button_signup_text_color = hextocolor("#00393B");
  static Color button_login_background_color = hextocolor("#0090A0");
  static const Color appbar_gradient_left_color = Color(0xFF0090A0);
  static const Color appbar_gradient_right_color = Color(0xFF00343A);
  static Color button_mainuser_left_color = hextocolor("#00393B");
  static Color button_mainuser_right_color = hextocolor("#009CA1");
  static Color button_mainuser_other_color = hextocolor("#EAEEF1");
  static Color estimated_color = hextocolor("#00393B");
  static Color button_red_color = hextocolor("#EF0909");
  static Color button_call_color = hextocolor("#000000");
  static Color policy_des_color = hextocolor("#16191D");
  static Color button_no_decoration_color = hextocolor("#BCECF1");
  static const Color submitButton_gradient_left_color = Color(0xFFE8EAE9);
  static const Color submitButton_gradient_right_color = Color(0xFF838483);
  static Color verification_description_color = hextocolor("#808893");
  static Color button_resend_color = hextocolor("#C5F9FF");
  static Color button_star_color = hextocolor("#FFC107");
}