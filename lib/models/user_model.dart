class UserModel {
  int? userID;
  String? firstName;
  String? lastName;
  String? email;
  String? password;
  String? phoneNumber;
  // String? riderToken;

  UserModel({this.userID,this.firstName, this.lastName, this.email, this.password, this.phoneNumber});

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'first_name': firstName,
      'last_name' : lastName,
      'email': email,
      'password': password,
      'phone_number': phoneNumber,
      // 'rederToken':riderToken
    };
  }

  UserModel.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    password = json['password'];
    phoneNumber = json['phone_number'];
    // riderToken = json['riderToken'];
  }
}
