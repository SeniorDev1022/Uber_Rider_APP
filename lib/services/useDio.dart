import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioService {
  late Dio _dio;

  DioService() {
    _dio = Dio(BaseOptions(
      baseUrl:
          'http://54.173.7.68/api/', // Update this with your actual base URL
          // 'http://127.0.0.1:8000/api/',
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options); // continue
      },
    ));
  }

  Dio get dio => _dio;

  Future<Response> getRequest(String endpoint,
      {Map<String, dynamic>? queryParams}) async {
    try {
      return await _dio.get(endpoint, queryParameters: queryParams);
    } catch (e) {
      rethrow;
    }
  }


  Future<Response> postRequest(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      return await _dio.post(endpoint, data: data);
    } catch (e) {
      rethrow;
    }
  }
}
