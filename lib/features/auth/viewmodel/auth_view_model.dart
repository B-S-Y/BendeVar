import 'package:flutter/foundation.dart';

import '../../../core/utils/validators.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo) : _user = _repo.currentUser;

  final AuthRepository _repo;
  AppUser? _user;
  String _email = '';
  String _password = '';
  bool _showErrors = false;
  bool _loading = false;
  bool _obscure = true;

  AppUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get loading => _loading;
  bool get obscure => _obscure;

  /// Düğme, iki alan da doluyken etkinleşir.
  bool get canSubmit => _email.trim().isNotEmpty && _password.isNotEmpty;

  EmailError? get emailError => _showErrors ? Validators.email(_email) : null;
  PasswordError? get passwordError =>
      _showErrors ? Validators.password(_password) : null;

  void setEmail(String v) {
    _email = v;
    notifyListeners();
  }

  void setPassword(String v) {
    _password = v;
    notifyListeners();
  }

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  /// Sahte giriş: e-posta `.edu.tr` ile bitmeli, şifre boş olmamalı.
  Future<bool> signIn() async {
    _showErrors = true;
    if (Validators.email(_email) != null ||
        Validators.password(_password) != null) {
      notifyListeners();
      return false;
    }
    _loading = true;
    notifyListeners();
    _user = await _repo.signIn(_email.trim(), _password);
    _loading = false;
    notifyListeners();
    return true;
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _user = null;
    _email = '';
    _password = '';
    _showErrors = false;
    _obscure = true;
    notifyListeners();
  }
}
