import 'package:material_ui/material_ui.dart';

import 'auth_stage.dart';

/// 1.01 · Karşılama (açılış animasyonu ve giriş geçişi: [AuthStage]).
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => const AuthStage();
}
