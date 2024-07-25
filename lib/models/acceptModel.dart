// ignore: file_names
class AcceptModel {
  String? driverName;
  double? driverRating;
  int? driverID;
  String? carType;
  String? carNumber;
  String? status;
  double? longitude;
  double? latitude;
  String?  phoneNumber;

  AcceptModel({this.driverID,this.phoneNumber,this.latitude, this.longitude,this.carNumber,this.status, this.carType, this.driverName, this.driverRating});

  AcceptModel.fromJson(Map<String, dynamic> json) {
    driverName = json['driverName'];
    longitude = json['longitude'];
    latitude = json['latitude'];
    driverID = json['driverID'];
    driverRating = json['driverRating'];
    carType = json['carType'];
    carNumber = json['carNumber'];
    phoneNumber = json['phoneNumber'];
    status = json['status'];
  }
}