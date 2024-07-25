import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import '../models/user_model.dart';
class ApiService {
  final String baseUrl =
      "http://54.173.7.68/api/"; // Replace with your actual base URL
      // "http://127.0.0.1:8000/api/";


 Future<Map<String, dynamic>> registerUser(UserModel user) async {
  print("${user.email}");
    final response = await http.post(
      Uri.parse('${baseUrl}registerUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'email': user.email,
        'password': user.password,
        'first_name': user.firstName,
        'last_name' : user.lastName,
        'phone_number': user.phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register user');
    }
  }

  static Future<int> loginUser(String email, String password, String method) async {
    final String flag = method == 'email' ? 'email' : 'phone_number'; // Determine the flag based on the method
    final url = Uri.parse('http://54.173.7.68/api/loginUser');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'method': flag, flag: email, 'password': password});
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      // ignore: non_constant_identifier_names
      String ID = responseData['riderID'].toString();
      await initLocalStorage();
      localStorage.setItem('riderID', ID);
      localStorage.setItem('riderName', responseData['riderName']);
      localStorage.setItem('access_token', responseData['access_token']);
      return response.statusCode;
    } else {
      throw Exception('Failed to login: ${response.reasonPhrase}');
    }
  }
}
