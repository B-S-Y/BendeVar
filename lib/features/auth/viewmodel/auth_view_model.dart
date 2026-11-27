import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/utils/validators.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(
    this._repo, {
    required this._communities,
    this.schoolLookupDelay = const Duration(milliseconds: 500),
  }) : _user = _repo.currentUser;

  /// Yazma durduktan bu kadar sonra okul kartı aranır (kart yazarken çıkmaz).
  final Duration schoolLookupDelay;

  final AuthRepository _repo;
  final CommunityRepository _communities;
  AppUser? _user;
  String _email = '';
  String _password = '';
  bool _showErrors = false;
  bool _loading = false;
  bool _obscure = true;
  AuthFailure? _failure;

  AppUser? get user => _user;
  bool get isSignedIn => _user != null;
  bool get loading => _loading;
  bool get obscure => _obscure;

  /// Son giriş denemesinin hatası (1.03b/c, 1.04); girdi değişince temizlenir.
  AuthFailure? get failure => _failure;
  String get email => _email;

  /// Düğme, iki alan da doluyken etkinleşir.
  bool get canSubmit => _email.trim().isNotEmpty && _password.isNotEmpty;

  EmailError? get emailError => _showErrors ? Validators.email(_email) : null;
  PasswordError? get passwordError =>
      _showErrors ? Validators.password(_password) : null;

  void setEmail(String v) {
    _email = v;
    _failure = null;
    notifyListeners();
  }

  void setPassword(String v) {
    _password = v;
    _failure = null;
    notifyListeners();
  }

  bool _restored = false;

  /// Açılışta kalıcı oturum kontrolü bitti mi (Beni hatırla).
  bool get restored => _restored;

  /// Açılış kapısı (SplashPage) için: kalıcı oturumu geri yükler.
  Future<void> restore() async {
    try {
      final user = await _repo.restoreSession();
      if (user != null) _user = user;
    } catch (_) {
      // Okunamadı: oturumsuz devam (Karşılama). Açılış kapısı takılmaz.
    } finally {
      _restored = true;
      notifyListeners();
    }
  }

  /// Açılış → Ana Sayfa geçişi giriş sonrası geçişle aynı olsun (sessiz).
  void requestFadeToHome() => _fadeToHome = true;

  bool _fadeToHome = false;

  /// Giriş yeni başarılı oldu: Ana Sayfa'ya solma/büyüme geçişi oynatılır.
  /// Geçiş bitince (ya da animasyonlar azaltılmışsa hemen) [endFadeToHome].
  bool get fadeToHome => _fadeToHome;

  /// Sessiz (build sırasında çağrılabilir; dinleyicileri uyandırmaz).
  void endFadeToHome() => _fadeToHome = false;

  bool _remember = false;

  /// "Beni hatırla" (varsayılan kapalı).
  bool get remember => _remember;

  void setRemember(bool v) {
    _remember = v;
    notifyListeners();
  }

  int _errorSeq = 0;

  /// Her başarısız giriş denemesinde artar (alan titremesi için).
  int get errorSeq => _errorSeq;

  void toggleObscure() {
    _obscure = !_obscure;
    notifyListeners();
  }

  /// Sahte giriş: e-posta `.edu.tr` ile bitmeli, şifre boş olmamalı.
  Future<bool> signIn() async {
    _showErrors = true;
    if (Validators.email(_email) != null ||
        Validators.password(_password) != null) {
      _errorSeq++;
      notifyListeners();
      return false;
    }
    _loading = true;
    _failure = null;
    notifyListeners();
    try {
      final user = await _repo.signIn(
        _email.trim(),
        _password,
        remember: _remember,
      );
      // Yönlendirme (refreshListenable) bunu görsün diye kullanıcıdan önce.
      _fadeToHome = true;
      _user = user;
      return true;
    } on AuthException catch (e) {
      _failure = e.failure;
      _errorSeq++;
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 1.04: doğrulama bağlantısını yeniden gönderir.
  Future<void> resendVerification() => _repo.sendVerification(_email.trim());

  // ───────────────────────── Kayıt (1.08 – 1.12) ─────────────────────────

  /// 1.09'daki "Tekrar gönder" bekleme süresi (sn).
  static const int resendCooldownSeconds = 45;

  String _signupEmail = '';
  String _signupPassword = '';
  bool _signupObscure = true;
  bool _termsAccepted = false;
  bool _signupShowErrors = false;
  bool _signupLoading = false;
  AuthFailure? _signupFailure;
  Community? _schoolCommunity;
  bool _schoolLookedUp = false;
  DateTime? _linkSentAt;
  bool _completing = false;
  int _lookupToken = 0;
  Timer? _lookupTimer;
  bool _emailBlurred = false;

  String get signupEmail => _signupEmail;
  String get signupPassword => _signupPassword;
  bool get signupObscure => _signupObscure;
  bool get termsAccepted => _termsAccepted;
  bool get signupLoading => _signupLoading;
  bool get completing => _completing;

  /// 1.08'de e-posta hatası (1.08a: kurum dışı e-posta).
  EmailError? get signupEmailError =>
      _signupShowErrors ||
          (_emailBlurred && Validators.isPersonalProvider(_signupEmail))
      ? Validators.email(_signupEmail)
      : null;
  NewPasswordError? get signupPasswordError =>
      _signupShowErrors ? Validators.newPassword(_signupPassword) : null;
  bool get termsError => _signupShowErrors && !_termsAccepted;

  /// Kayıt hatası (şimdilik yalnızca [AuthFailure.emailInUse]).
  AuthFailure? get signupFailure => _signupFailure;

  /// E-postadaki okulun topluluğu; okul geçerliyse ve topluluk yoksa null,
  /// [schoolLookedUp] true (ilk kayıtta açılır).
  Community? get schoolCommunity => _schoolCommunity;
  bool get schoolLookedUp => _schoolLookedUp;

  /// Geçerli kurum e-postası girildi mi? (Okul kartını gösterir.)
  bool get signupEmailValid => Validators.email(_signupEmail) == null;

  /// Okul kartı görünür mü (yazma durduktan [schoolLookupDelay] sonra):
  /// - bilinen okulda (alias'lar dahil, harf sayısına bakmadan) okul adı;
  /// - bilinmeyen okulda "topluluğun ilk kayıtla açılacak" notu yalnızca alan
  ///   odağı kaybedince ya da Kayıt ol'a basılınca (yazarken yok).
  bool get showSchoolCard =>
      signupEmailValid &&
      _schoolLookedUp &&
      ((_schoolCommunity != null) || _emailBlurred || _signupShowErrors);

  void setSignupEmail(String v) {
    _signupEmail = v;
    _signupFailure = null;
    _emailBlurred = false;
    _scheduleLookup();
    notifyListeners();
  }

  /// E-posta alanı odağı kaybetti.
  void signupEmailBlurred() {
    if (_emailBlurred) return;
    _emailBlurred = true;
    notifyListeners();
  }

  /// Yazarken kart gizlenir; yazma durunca ([schoolLookupDelay]) aranır.
  void _scheduleLookup() {
    _lookupTimer?.cancel();
    _lookupToken++;
    _schoolLookedUp = false;
    _schoolCommunity = null;
    final id = Validators.schoolId(_signupEmail);
    if (id == null ||
        id.length < Validators.minSchoolIdLength ||
        Validators.isPersonalProvider(_signupEmail)) {
      return;
    }
    _lookupTimer = Timer(schoolLookupDelay, _lookupSchool);
  }

  @override
  void dispose() {
    _lookupTimer?.cancel();
    super.dispose();
  }

  void setSignupPassword(String v) {
    _signupPassword = v;
    notifyListeners();
  }

  void toggleSignupObscure() {
    _signupObscure = !_signupObscure;
    notifyListeners();
  }

  void setTermsAccepted(bool v) {
    _termsAccepted = v;
    notifyListeners();
  }

  Future<void> _lookupSchool() async {
    final token = ++_lookupToken;
    final id = Validators.schoolId(_signupEmail);
    if (id == null || id.length < Validators.minSchoolIdLength) {
      _schoolCommunity = null;
      _schoolLookedUp = false;
      return;
    }
    final found = await _communities.findBySchool(id);
    if (token != _lookupToken) return;
    _schoolCommunity = found;
    _schoolLookedUp = true;
    notifyListeners();
  }

  /// 1.08 → hesabı açar, doğrulama bağlantısı gönderilir. Başarılıysa true.
  Future<bool> signUp() async {
    _signupShowErrors = true;
    if (Validators.email(_signupEmail) != null ||
        Validators.newPassword(_signupPassword) != null ||
        !_termsAccepted) {
      notifyListeners();
      return false;
    }
    _signupLoading = true;
    _signupFailure = null;
    notifyListeners();
    try {
      await _repo.signUp(_signupEmail.trim(), _signupPassword);
      _linkSentAt = DateTime.now();
      return true;
    } on AuthException catch (e) {
      _signupFailure = e.failure;
      return false;
    } finally {
      _signupLoading = false;
      notifyListeners();
    }
  }

  /// 1.09 "Tekrar gönder" için kalan saniye (0 = gönderilebilir).
  int resendRemaining([DateTime? now]) {
    final sent = _linkSentAt;
    if (sent == null) return 0;
    final left =
        resendCooldownSeconds -
        (now ?? DateTime.now()).difference(sent).inSeconds;
    return left < 0 ? 0 : left;
  }

  Future<void> resendLink() async {
    await _repo.sendVerification(_signupEmail.trim());
    _linkSentAt = DateTime.now();
    notifyListeners();
  }

  /// Bağlantıya tıklandı mı? (Uygulama öne dönünce ve "Bağlantıya tıkladım".)
  Future<VerificationStatus> checkVerification() =>
      _repo.checkVerification(_signupEmail.trim());

  /// 1.10'daki hazır ad (e-postadan çıkarılır, düzenlenebilir).
  String get suggestedName => Validators.nameFromEmail(_signupEmail);

  /// 1.10 → okul topluluğuna katılır (yoksa açar), kaydı bitirir.
  Future<bool> completeSignUp(String displayName) async {
    if (Validators.requiredText(displayName) != null) return false;
    final id = Validators.schoolId(_signupEmail);
    if (id == null) return false;
    _completing = true;
    notifyListeners();
    try {
      final community = await _communities.joinOrCreate(id);
      _user = await _repo.completeSignUp(
        email: _signupEmail.trim(),
        displayName: displayName,
        community: community,
      );
      return true;
    } finally {
      _completing = false;
      notifyListeners();
    }
  }

  void resetSignup() {
    _signupEmail = '';
    _signupPassword = '';
    _termsAccepted = false;
    _signupShowErrors = false;
    _signupFailure = null;
    _schoolCommunity = null;
    _schoolLookedUp = false;
    _emailBlurred = false;
    _lookupTimer?.cancel();
    _linkSentAt = null;
    notifyListeners();
  }

  // ───────────────────── Şifre sıfırlama (1.05 – 1.07) ─────────────────────

  String _resetEmail = '';
  bool _resetShowErrors = false;
  bool _resetLoading = false;
  DateTime? _resetSentAt;
  String _newPassword = '';
  String _confirmPassword = '';
  bool _newObscure = true;
  bool _confirmObscure = true;
  bool _newShowErrors = false;
  bool _savingPassword = false;

  String get resetEmail => _resetEmail;
  bool get resetLoading => _resetLoading;
  bool get newObscure => _newObscure;
  bool get confirmObscure => _confirmObscure;
  bool get savingPassword => _savingPassword;

  EmailError? get resetEmailError =>
      _resetShowErrors ? Validators.email(_resetEmail) : null;
  NewPasswordError? get newPasswordError =>
      _newShowErrors ? Validators.newPassword(_newPassword) : null;
  bool get passwordMismatch =>
      _newShowErrors &&
      Validators.newPassword(_newPassword) == null &&
      _newPassword != _confirmPassword;

  /// 1.05'e girişte yazılan e-posta hazır gelir. (Sayfa kurulurken çağrılır;
  /// bu yüzden dinleyicilere haber vermez.)
  void startReset() {
    if (_resetEmail.isEmpty) _resetEmail = _email;
    _resetShowErrors = false;
  }

  void setResetEmail(String v) {
    _resetEmail = v;
    notifyListeners();
  }

  /// 1.05 → bağlantı gönderilir. Başarılıysa true.
  Future<bool> sendReset() async {
    _resetShowErrors = true;
    if (Validators.email(_resetEmail) != null) {
      notifyListeners();
      return false;
    }
    _resetLoading = true;
    notifyListeners();
    try {
      await _repo.requestPasswordReset(_resetEmail.trim());
      _resetSentAt = DateTime.now();
      return true;
    } finally {
      _resetLoading = false;
      notifyListeners();
    }
  }

  int resetResendRemaining([DateTime? now]) {
    final sent = _resetSentAt;
    if (sent == null) return 0;
    final left =
        resendCooldownSeconds -
        (now ?? DateTime.now()).difference(sent).inSeconds;
    return left < 0 ? 0 : left;
  }

  Future<void> resendReset() async {
    await _repo.requestPasswordReset(_resetEmail.trim());
    _resetSentAt = DateTime.now();
    notifyListeners();
  }

  Future<VerificationStatus> checkReset() =>
      _repo.checkPasswordReset(_resetEmail.trim());

  void setNewPassword(String v) {
    _newPassword = v;
    notifyListeners();
  }

  void setConfirmPassword(String v) {
    _confirmPassword = v;
    notifyListeners();
  }

  void toggleNewObscure() {
    _newObscure = !_newObscure;
    notifyListeners();
  }

  void toggleConfirmObscure() {
    _confirmObscure = !_confirmObscure;
    notifyListeners();
  }

  /// 1.07 → yeni şifreyi kaydeder. Başarılıysa true.
  Future<bool> savePassword() async {
    _newShowErrors = true;
    if (Validators.newPassword(_newPassword) != null ||
        _newPassword != _confirmPassword) {
      notifyListeners();
      return false;
    }
    _savingPassword = true;
    notifyListeners();
    try {
      await _repo.confirmPasswordReset(_resetEmail.trim(), _newPassword);
      return true;
    } finally {
      _savingPassword = false;
      notifyListeners();
    }
  }

  void resetPasswordFlow() {
    _resetEmail = '';
    _resetShowErrors = false;
    _resetSentAt = null;
    _newPassword = '';
    _confirmPassword = '';
    _newShowErrors = false;
    _newObscure = true;
    _confirmObscure = true;
    _failure = null;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _repo.signOut();
    _user = null;
    _fadeToHome = false;
    _remember = false;
    _email = '';
    _password = '';
    _showErrors = false;
    _failure = null;
    _obscure = true;
    notifyListeners();
  }
}
