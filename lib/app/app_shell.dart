import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/widgets/bende_var_bottom_nav.dart';
import '../data/models/models.dart';
import '../features/create_listing/view/create_sheet.dart';
import '../features/messages/viewmodel/messages_view_models.dart';

/// Alt menülü kabuk. Ortadaki logo sekme değil, 3.01 panelini açar.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.shell, required this.branchKeys});

  final StatefulNavigationShell shell;
  final List<GlobalKey<NavigatorState>> branchKeys;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _sheetOpen = false;

  Future<void> _openCreate() async {
    final branchContext =
        widget.branchKeys[widget.shell.currentIndex].currentContext;
    if (branchContext == null) return;
    setState(() => _sheetOpen = true);
    final kind = await showCreateSheet(branchContext);
    if (!mounted) return;
    setState(() => _sheetOpen = false);
    if (kind != null) {
      context.push(
        kind == ListingKind.ilan ? '/create/ilan' : '/create/ihtiyac',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final badge = context.watch<NotificationsViewModel>().unreadCount;
    return Scaffold(
      body: widget.shell,
      bottomNavigationBar: BendeVarBottomNav(
        selectedIndex: _sheetOpen ? null : widget.shell.currentIndex,
        notificationBadge: badge,
        onSelect: (i) => widget.shell.goBranch(
          i,
          initialLocation: i == widget.shell.currentIndex,
        ),
        onLogoTap: _openCreate,
      ),
    );
  }
}
