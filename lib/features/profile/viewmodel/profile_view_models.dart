import 'package:flutter/foundation.dart';

import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._users) {
    _load();
  }

  final UserRepository _users;
  List<PendingItem> pending = const [];
  int borrowedCount = 0;
  int lentCount = 0;
  bool loading = true;

  Future<void> _load() async {
    pending = await _users.pending();
    borrowedCount = await _users.count(LoanDirection.borrowed);
    lentCount = await _users.count(LoanDirection.lent);
    loading = false;
    notifyListeners();
  }
}

enum LoanFilter { all, active, past }

class LoansViewModel extends ChangeNotifier {
  LoansViewModel(this._users, {LoanDirection initial = LoanDirection.borrowed})
    : _direction = initial {
    _load();
  }

  final UserRepository _users;
  LoanDirection _direction;
  LoanFilter _filter = LoanFilter.all;
  List<Loan> _loans = const [];
  bool loading = true;

  LoanDirection get direction => _direction;
  LoanFilter get filter => _filter;

  List<Loan> get visible => _loans.where((l) {
    switch (_filter) {
      case LoanFilter.all:
        return true;
      case LoanFilter.active:
        return l.isActive;
      case LoanFilter.past:
        return !l.isActive;
    }
  }).toList();

  Future<void> _load() async {
    loading = true;
    notifyListeners();
    _loans = await _users.loans(_direction);
    loading = false;
    notifyListeners();
  }

  void setDirection(LoanDirection d) {
    if (d == _direction) return;
    _direction = d;
    _load();
  }

  void setFilter(LoanFilter f) {
    _filter = f;
    notifyListeners();
  }
}
