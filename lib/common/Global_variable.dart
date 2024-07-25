import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalVariables {
  static String? deviceToken = '';
  static String username = '';
  static List<File> mainImage = [];
  static List<File> mainImage2 = [];
  static String avatarImage = '1';
  static String avatarImage1 = '1';
  static double space = 0;
  static bool accepted = false;
  static String reservationStart = '';
  static String reservationEnd = '';
  static String landingavatar = "";
  static String landingurl = "";
  static List<Map<String, dynamic>> stopPoints = [];
  static String landingname = "";
  static var memberlist = [];
  static List<String> messages = [];
  static var chatroom = [];
  static List<String> imageUrls = List.filled(22, '');
  static List<String> imageUrls1 = List.filled(21, '');
  static var idCard = [];
  static var idCard1 = [];
  static int index = 0;
  static var tabArray = [];
  static bool isTyping = false;
  static List<String> tabs = [];
  static List<Widget> tabScreens = [];
  static bool status = false;
  static String driverestimatedTime = '';
  static String dirverestimatedDistance = '';
  static String currentAddress = "";
  static String destinationAddress = "";
  static double desLat = 0.0;
  static double desLang = 0.0;
  static double riderLat = 0.0;
  static double riderLng = 0.0;
  static String dragFlag = '';
  static void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}
