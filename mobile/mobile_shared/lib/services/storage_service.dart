import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
  }

  Future<void> saveUserId(int id) async {
    await _storage.write(key: 'userId', value: id.toString());
  }

  Future<int?> getUserId() async {
    final str = await _storage.read(key: 'userId');
    return str != null ? int.tryParse(str) : null;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
