import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final _api = ApiService();

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _api.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'confirmPassword': confirmPassword,
      });

      final data = response.data['data'] ?? response.data;
      if (data['token'] != null) {
        await _api.saveToken(data['token']);
      }

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _api.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data['data'] ?? response.data;
      if (data['token'] != null) {
        await _api.saveToken(data['token']);
      }

      return data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _api.dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _api.dio.post('/auth/reset-password', data: {
        'token': token,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _api.clearToken();
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
        return data['message'] ?? 'Erro desconhecido';
      }
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Tempo de conexão esgotado. Verifique sua internet';
    }
    return 'Erro de conexão com o servidor';
  }
}
