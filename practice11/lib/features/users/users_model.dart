import 'package:flutter/foundation.dart';

import '../../core/api/api_exception.dart';
import 'user.dart';
import 'user_repository.dart';

class UsersModel extends ChangeNotifier {
  UsersModel(this._repo);

  final UserRepository _repo;
  List<User> items = const [];
  ApiException? error;
  bool loading = false;
  bool saving = false;
  bool _disposed = false;

  Future<void> load() async {
    if (_disposed || loading || saving) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final users = await _repo.getAll();
      if (_disposed) return;
      items = users;
    } on ApiException catch (e) {
      if (_disposed) return;
      error = e;
    } finally {
      if (!_disposed) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> create(User draft) async {
    if (_disposed || saving || loading) return;
    saving = true;
    notifyListeners();
    try {
      final user = await _repo.create(draft);
      if (_disposed) return;
      items = [user, ...items];
      error = null;
    } on ApiException {
      rethrow;
    } finally {
      if (!_disposed) {
        saving = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _repo.dispose();
    super.dispose();
  }
}
