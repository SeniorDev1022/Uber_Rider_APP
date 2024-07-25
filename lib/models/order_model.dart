class OrderModel {
  int? riderId;
  int? driverId;
  String? cost;
  String? period;
  String? startLocation;
  List<Map<String, Object>>? stopLocation;
  String? startAddress;
  String? endAddress;
  String? endLocation;
  String? routeDistance;
  DateTime? orderDate;
  DateTime? arrivedDate;
  DateTime? startDate;
  DateTime? endDate;
  DateTime? stopDate;
  int? rating;
  int? status;
  String? riderToken;

  OrderModel({
    this.riderId,
    this.riderToken,
    this.driverId,
    this.period,
    this.cost,
    this.routeDistance,
    this.startLocation,
    this.stopLocation,
    this.endLocation,
    this.orderDate,
    this.arrivedDate,
    this.startDate,
    this.rating,
    this.endDate,
    this.endAddress,
    this.startAddress,
    this.stopDate,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'rider_id': riderId,
      'user_token': riderToken,
      'driver_id': driverId,
      'period': period,
      'cost': cost,
      'start_location': startLocation,
      'stop_location': stopLocation,
      'start_address': startAddress,
      'end_address': endAddress,
      'route_distance': routeDistance,
      'end_location': endLocation,
      'order_date': orderDate?.toIso8601String(),
      'arrived_date': arrivedDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'rating': rating,
      'end_date': endDate?.toIso8601String(),
      'stop_date': stopDate?.toIso8601String(),
      'status': status,
    };
  }

  OrderModel.fromJson(Map<String, dynamic> json) {
    riderId = json['riderID'];
    riderToken = json['riderToken'];
    driverId = json['driverID'];
    cost = json['cost'];
    period = json['period'];
    startLocation = json['start_location'];
    routeDistance = json['route_distance'];
    stopLocation = List<Map<String, Object>>.from(json['stop_location']);
    endLocation = json['end_location'];
    orderDate = DateTime.tryParse(json['order_date'] ?? '');
    arrivedDate = DateTime.tryParse(json['arrived_date'] ?? '');
    startDate = DateTime.tryParse(json['start_date'] ?? '');
    rating = json['rating'];
    endDate = DateTime.tryParse(json['end_date'] ?? '');
    endAddress = json['end_address'];
    startAddress = json['start_address'];
    stopDate = DateTime.tryParse(json['stop_date'] ?? '');
    status = json['status'];
  }
}