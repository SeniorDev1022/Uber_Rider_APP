import 'package:flutter/material.dart';
import 'package:uber_josh/services/api_servies.dart';
import '../models/user_model.dart'; // Adjust the import path as needed
import 'package:shared_preferences/shared_preferences.dart';
class UserViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final UserModel _user = UserModel();
  String? _errorMessage;
  bool _isRegistrationSuccessful = false;
  bool get isLoginSuccessful => _isLoginSuccessful;
  bool _isLoginSuccessful = false;
  UserModel get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isRegistrationSuccessful => _isRegistrationSuccessful;
  bool _flag = false;
  bool get flag => _flag;

  void setFlag(bool value) {
    _flag = value;
    notifyListeners();
  }
  void setUserID(int userID){
    _user.userID = userID;
  }
  void setFirstName(String firstName) {
    _user.firstName = firstName;
    notifyListeners();
  }
  void setLastName(String lastName) {
    _user.lastName = lastName;
    notifyListeners();
  }
  void setEmail(String email) {
    _user.email = email;
    notifyListeners();
  }

  // void setToken(String token) {
  //   _user.riderToken = token;
  //   notifyListeners();
  // }
  void setPassword(String password) {
    _user.password = password;
    notifyListeners();
  }

  void setPhoneNumber(String phoneNumber) {
    _user.phoneNumber = phoneNumber;
    notifyListeners();
  }

  Future<void> clearLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }

  Future<void> registerUser() async {
    try {
      final result = await _apiService.registerUser(_user);
      if (result['statusCode'] == 200) {
        _isRegistrationSuccessful = true;
        await clearLocalData();
      } else {
        _isRegistrationSuccessful = false;
        _errorMessage = result['message'];
      }
    } catch (e) {
      _isRegistrationSuccessful = false;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }
}
