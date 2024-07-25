import 'package:flutter/material.dart';
import '../models/order_model.dart'; // Adjust the import path as needed

class OrderViewModel extends ChangeNotifier {
  // final ApiService _apiService = ApiService();
  final OrderModel _order = OrderModel(stopLocation: []);

  String? _errorMessage;
  final bool _isFetchSuccessful = false;
  final bool _isPostSuccessful = false;
  OrderModel get order => _order;
  String? get errorMessage => _errorMessage;
  bool get isFetchSuccessful => _isFetchSuccessful;
  bool get isPostSuccessful => _isPostSuccessful;


  void setRiderId(int riderId) {
    _order.riderId = riderId;
    notifyListeners();
  }
  void setToken(String token){
    _order.riderToken = token;
    notifyListeners();
  }
  void setStartLocation(String startLocation) {
    _order.startLocation = startLocation;
    notifyListeners();
  }
  void setPeriod(String period) {
    _order.period = period;
    notifyListeners();
  }

  void setStopLocation(List<Map<String, Object>> stopLocation) {
    _order.stopLocation = stopLocation;
    notifyListeners();
  }

  void setCost(String cost) {
    _order.cost = cost;
    notifyListeners();
  }

  void setEndLocation(String endLocation) {
    _order.endLocation = endLocation;
    notifyListeners();
  }

  void setStartAddress(String startAddress){
    _order.startAddress = startAddress;
    notifyListeners();
  }

  void setEndAddress(String endAddress){
    _order.endAddress = endAddress;
    notifyListeners();
  }
  void setRouteDistance(String routeDistance) {
    _order.routeDistance = routeDistance;
    notifyListeners();
  }

  void setArrivedDate(DateTime arrivedDate) {
    _order.arrivedDate = arrivedDate;
    notifyListeners();
  }

  void setStartDate(DateTime startDate) {
    _order.startDate = startDate;
    notifyListeners();
  }

  void setRating(int rating) {
    _order.rating = rating;
    notifyListeners();
  }

  void setEndDate(DateTime endDate) {
    _order.endDate = endDate;
    notifyListeners();
  }

  void setStatus(int status) {
    _order.status = status;
    notifyListeners();
  }

  // Future<void> clearLocalData() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('order');
  //   await prefs.remove('token');
  // }

}