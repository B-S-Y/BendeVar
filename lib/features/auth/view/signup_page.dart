import 'package:material_ui/material_ui.dart';

import 'auth_stage.dart';

/// 1.08 · Kayıt ol. Doğrudan açılırsa panel kayıt formuyla açık gelir.
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const AuthStage(initialMode: AuthMode.signup);
}
