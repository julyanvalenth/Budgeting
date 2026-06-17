import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/secure_storage.dart';
import '../data/auth_api.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final AuthApi _api;
  final SecureStorageService _storage;

  AuthRepository(this._api, this._storage);

  Future<UserModel?> getCurrentUser() async {
    final hasToken = await _storage.hasToken();
    if (!hasToken) return null;
    try {
      return await _api.getMe();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.saveToken(token);
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return _storage.hasToken();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authApiProvider),
    ref.watch(secureStorageProvider),
  );
});
