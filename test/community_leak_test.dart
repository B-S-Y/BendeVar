import 'package:bende_var/data/mock/mock_repositories.dart';
import 'package:bende_var/features/auth/viewmodel/auth_view_model.dart';
import 'package:bende_var/features/auth/viewmodel/community_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

/// Kayıt + doğrulama + ad adımı; kullanıcının kimliğiyle döner.
Future<AuthViewModel> _register(
  AuthViewModel vm,
  String email,
  String name,
) async {
  vm
    ..setSignupEmail(email)
    ..setSignupPassword('sifre123')
    ..setTermsAccepted(true);
  expect(await vm.signUp(), isTrue);
  expect(await vm.checkVerification(), isNotNull);
  expect(await vm.completeSignUp(name), isTrue);
  return vm;
}

void main() {
  setUpAll(initTestEnv);

  test(
    'Kök neden: kullanıcı kimliği tam e-postadan, yalnızca "yeni" değil',
    () async {
      final auth = MockAuthRepository(verifyAfter: Duration.zero);
      final communities = MockCommunityRepository();
      final vm = AuthViewModel(auth, communities: communities);
      await _register(vm, 'yeni@marmara.edu.tr', 'Yeni Bir');
      final first = vm.user!;
      await vm.signOut();
      await _register(vm, 'yeni@boun.edu.tr', 'Yeni Iki');
      final second = vm.user!;
      expect(first.id, isNot(second.id));
      expect(first.id, contains('marmara'));
      expect(second.id, contains('boun'));
    },
  );

  test(
    'İki yeni hesap art arda: her biri yalnızca kendi okul topluluğunu görür',
    () async {
      final auth = MockAuthRepository(verifyAfter: Duration.zero);
      final communities = MockCommunityRepository();
      final vm = AuthViewModel(auth, communities: communities);
      final list = CommunityViewModel(communities);

      await _register(vm, 'yeni@marmara.edu.tr', 'Yeni Bir');
      await list.load(vm.user!);
      expect(list.mine.map((c) => c.name), ['Marmara Üniversitesi']);

      await vm.signOut();
      list.reset(); // app.dart bunu çıkışta yapar
      await _register(vm, 'yeni@boun.edu.tr', 'Yeni Iki');
      await list.load(vm.user!);
      expect(list.mine.map((c) => c.name), ['Boğaziçi Üniversitesi']);

      // Marmara hesabıyla tekrar giriş: yine yalnızca Marmara.
      await vm.signOut();
      list.reset();
      vm
        ..setEmail('yeni@marmara.edu.tr')
        ..setPassword('sifre123');
      expect(await vm.signIn(), isTrue);
      await list.load(vm.user!);
      expect(list.mine.map((c) => c.name), ['Marmara Üniversitesi']);
    },
  );
}
