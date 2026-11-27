import 'package:material_ui/material_ui.dart';

import 'auth_stage.dart';

/// 1.02 · Giriş yap. Doğrudan açılırsa panel açık gelir (animasyonsuz).
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const AuthStage(initialMode: AuthMode.login);
}
