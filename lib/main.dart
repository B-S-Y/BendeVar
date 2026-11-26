import 'package:material_ui/material_ui.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'app/locale_controller.dart';
import 'app/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  final theme = ThemeController();
  final locale = LocaleController();
  await Future.wait([theme.load(), locale.load()]);
  runApp(
    BendeVarApp(
      deps: AppDependencies(),
      themeController: theme,
      localeController: locale,
    ),
  );
}
