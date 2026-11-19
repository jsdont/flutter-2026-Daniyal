import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  factory UserRepository.network() {
    return UserRepository(ApiClient(http.Client()));
  }

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final data = await _api.get('/users');
    try {
      return (data as List<dynamic>)
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } on TypeError catch (error) {
      throw BadResponseException('users: $error');
    } on FormatException catch (error) {
      throw BadResponseException('users: $error');
    }
  }

  Future<User> getById(int id) async {
    final path = '/users/$id';
    final data = await _api.get(path);
    return _parseUser(data, path);
  }

  Future<User> create(User draft) async {
    final data = await _api.post('/users', draft.toJson());
    return _parseUser(data, '/users');
  }

  User _parseUser(dynamic data, String path) {
    try {
      return User.fromJson(data as Map<String, dynamic>);
    } on TypeError catch (error) {
      throw BadResponseException('$path: $error');
    } on FormatException catch (error) {
      throw BadResponseException('$path: $error');
    }
  }

  void dispose() {
    _api.close();
  }
}
