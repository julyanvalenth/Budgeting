import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../domain/user_model.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<UserModel> getMe() async {
    final response = await _dio.get(ApiConstants.authMe);
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _dio.post(ApiConstants.authLogout);
  }

  Future<void> updateFcmToken(String token) async {
    await _dio.put(
      ApiConstants.authFcmToken,
      data: {'fcmToken': token},
    );
  }
}

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(dioProvider)),
);
