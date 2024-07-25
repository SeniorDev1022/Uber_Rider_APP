class Post {
  String? startLocation;
  String? endLocation;


  Post({this.startLocation, this.endLocation});

  Post.fromJson(Map<String, dynamic> json) {
    startLocation = json['start_location'];
    endLocation = json['end_location'];
  }

  toList() {}
}