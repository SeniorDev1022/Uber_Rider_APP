import 'package:uber_josh/common/Global_variable.dart';
import 'package:uber_josh/services/useDio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/acceptModel.dart'; // Adjust the import path as needed
import 'package:localstorage/localstorage.dart';
class AcceptViewModel extends ChangeNotifier {

  final AcceptModel _accept = AcceptModel();
  AcceptModel get accept => _accept;

  String _moveTo = '';
  String get moveTo => _moveTo;

  void setFlag(String moveTo){
    _moveTo = moveTo;
    notifyListeners();
  }
  Map<String, dynamic> _data = {};

  Map<String, dynamic> get data => _data;

  void updateFromData(Map<String, dynamic> newData) {
    if (newData.containsKey('carType')) {
      setCarType(newData['carType'].toString());
    }
    if (newData.containsKey('carNumber')) {
      setCarNumber(newData['carNumber'].toString());
    }
    if (newData.containsKey('phoneNumber')) {
      setPhoneNumber(newData['phoneNumber'].toString());
    }
    if (newData.containsKey('driverName')) {
      setDriverName(newData['driverName'].toString());
    }  
    if (newData.containsKey('driverRating')) {
      setDriverRating(double.parse(newData['driverRating'].toString()));
    }
    if (newData.containsKey("latitude")){
      setLatitude(double.parse(newData['latitude']));
    }
    if(newData.containsKey("longitude")){
      setLongitude(double.parse(newData['longitude']));
    }
    if (newData.containsKey('driverID')) {
      setDriverID(int.parse(newData['driverID']));
    }
    if (newData.containsKey('status')){
      setFlag(newData['status']);
    }
    // Add other fields as needed
    notifyListeners();
  }
  void setData(Map<String, dynamic> newData) {
    _data = newData;
    notifyListeners();
    updateFromData(newData);
  }
  void setDriverID(int driverID){
    _accept.driverID = driverID;
    notifyListeners();
  }
  void setDriverRating(double rating){
    _accept.driverRating = rating;
    notifyListeners();
  }
  void setPhoneNumber(String phone){
    _accept.phoneNumber = phone;
    notifyListeners();
  }
  void setCarType(String type){
    _accept.carType = type;
    notifyListeners();
  }
  void setLongitude(double longitude){
    _accept.longitude = longitude;
    notifyListeners();
  }
  void setLatitude(double latitude){
    _accept.latitude = latitude;
    notifyListeners();
  }
  void setCarNumber(String number){
    _accept.carNumber = number;
    notifyListeners();
  }
  void setDriverName(String driverName){
    _accept.driverName = driverName;
    notifyListeners();
  }
  void setStatus(String status){
    if(status == 'accepted') {
      GlobalVariables.accepted = true;
    }
    notifyListeners();
  }
  
  Future<int> contactRequest() async{
  final DioService dioService = DioService();
  final data = {
    'driverID': accept.driverID,
    'riderID': int.parse(localStorage.getItem('riderID')!),
  };
  print(data);
    try {
      final response =
          await dioService.postRequest('/contact', data: data);
      if (response.statusCode == 200) {
          return 200;
      } else {
        // Handle error response
        return 404;
      }
    } catch (e) {
      return 501;
    }
  }
}
