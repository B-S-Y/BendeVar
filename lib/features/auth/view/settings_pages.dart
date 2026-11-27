import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/sheets.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/settings_models.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import '../viewmodel/settings_view_model.dart';
import 'settings_widgets.dart';

/// 1.15 · Ayarlar. Tema/dil satırı bottom sheet açar; çıkış 1.15b onayını açar.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    Future<void> logout() async {
      final auth = context.read<AuthViewModel>();
      final ok = await showConfirmSheet(
        context,
        title: l.logoutTitle,
        messages: [l.logoutLine1],
        cancelLabel: l.cancel,
        confirmLabel: l.logout,
      );
      if (ok && context.mounted) {
        await auth.signOut();
        if (context.mounted) context.go('/welcome');
      }
    }

    return SettingsScaffold(
      title: l.settings,
      child: ListView(
        padding: settingsListPadding(context),
        children: staggerRows([
          SettingsRow(
            icon: LucideIcons.sunMoon,
            label: l.themeAndLanguage,
            onTap: () => showThemeLanguageSheet(context),
          ),
          SettingsRow(
            icon: LucideIcons.bell,
            label: l.notificationSettings,
            onTap: () => context.push('/settings/notifications'),
          ),
          SettingsRow(
            icon: LucideIcons.users,
            label: l.myCommunities,
            onTap: () => context.push('/communities'),
          ),
          // Engellenenler ilk seviyede (Gizlilik içinde 3 seviye derindeydi).
          SettingsRow(
            key: const Key('settings-blocked'),
            icon: LucideIcons.userX,
            label: l.blockedAccounts,
            onTap: () => context.push('/settings/blocked'),
          ),
          SettingsRow(
            icon: LucideIcons.shieldCheck,
            label: l.privacySupport,
            onTap: () => context.push('/settings/privacy'),
          ),
          SettingsRow(
            icon: LucideIcons.logOut,
            label: l.logout,
            destructive: true,
            onTap: logout,
          ),
        ]),
      ),
    );
  }
}

/// 1.18 · Bildirim ayarları.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsViewModel>().loadPrefs();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<SettingsViewModel>();
    final p = vm.prefs;

    Widget toggle({
      required Key key,
      required IconData icon,
      required String label,
      required String description,
      required bool value,
      required ValueChanged<bool> onChanged,
    }) => SettingsRow(
      icon: icon,
      label: label,
      description: description,
      onTap: () => onChanged(!value),
      trailing: Switch(
        key: key,
        value: value,
        onChanged: onChanged,
        activeTrackColor: c.primary,
        activeThumbColor: c.onPrimary,
        inactiveTrackColor: c.silver,
        inactiveThumbColor: c.card,
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );

    // Ayarlar yüklenene kadar anahtarlar gösterilmez.
    if (!vm.loadedPrefs) {
      return SettingsScaffold(
        title: l.notificationSettings,
        child: vm.prefsFailed
            ? SettingsError(onRetry: vm.retryPrefs)
            : const SettingsLoading(),
      );
    }

    Future<void> save(NotificationPrefs next) async {
      final messenger = ScaffoldMessenger.of(context);
      if (!await vm.setPrefs(next)) {
        showActionFailed(messenger, l, () => save(next));
      }
    }

    return SettingsScaffold(
      title: l.notificationSettings,
      child: ListView(
        padding: settingsListPadding(context),
        children: staggerRows([
          toggle(
            key: const Key('notif-messages'),
            icon: LucideIcons.messageCircle,
            label: l.notifMessages,
            description: l.notifMessagesDesc,
            value: p.messages,
            onChanged: (v) => save(p.copyWith(messages: v)),
          ),
          toggle(
            key: const Key('notif-responses'),
            icon: LucideIcons.handHelping,
            label: l.notifResponses,
            description: l.notifResponsesDesc,
            value: p.responses,
            onChanged: (v) => save(p.copyWith(responses: v)),
          ),
          toggle(
            key: const Key('notif-reminders'),
            icon: LucideIcons.clockAlert,
            label: l.notifReminders,
            description: l.notifRemindersDesc,
            value: p.reminders,
            onChanged: (v) => save(p.copyWith(reminders: v)),
          ),
          toggle(
            key: const Key('notif-announcements'),
            icon: LucideIcons.megaphone,
            label: l.notifAnnouncements,
            description: l.notifAnnouncementsDesc,
            value: p.announcements,
            onChanged: (v) => save(p.copyWith(announcements: v)),
          ),
        ]),
      ),
    );
  }
}

/// 1.19 · Gizlilik ve destek: şartlar/gizlilik (1.19a/b) ve yardım.
/// Engellenenler (1.20) Ayarlar'ın ilk seviyesinde.
class PrivacySupportPage extends StatelessWidget {
  const PrivacySupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SettingsScaffold(
      title: l.privacySupport,
      child: ListView(
        padding: settingsListPadding(context),
        children: staggerRows([
          SettingsRow(
            icon: LucideIcons.fileText,
            label: l.legalTermsTitle,
            onTap: () => context.push('/settings/terms'),
          ),
          SettingsRow(
            icon: LucideIcons.lock,
            label: l.legalPrivacyTitle,
            onTap: () => context.push('/settings/privacy-policy'),
          ),
          SettingsRow(
            icon: LucideIcons.lifeBuoy,
            label: l.helpSupport,
            onTap: () => context.push('/settings/help'),
          ),
        ]),
      ),
    );
  }
}

/// 1.20 · Engellenen hesaplar; "Engeli kaldır" 1.21 onayını açar.
class BlockedAccountsPage extends StatefulWidget {
  const BlockedAccountsPage({super.key});

  @override
  State<BlockedAccountsPage> createState() => _BlockedAccountsPageState();
}

class _BlockedAccountsPageState extends State<BlockedAccountsPage> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsViewModel>().loadBlocked();
  }

  Future<void> _unblock(BlockedUser user) async {
    final l = AppLocalizations.of(context);
    // 1.21 · Engeli kaldır onayı.
    final ok = await showConfirmSheet(
      context,
      title: l.unblockTitle,
      messages: [l.unblockLine1(user.name), l.unblockLine2],
      cancelLabel: l.cancel,
      confirmLabel: l.unblock,
    );
    if (!ok || !mounted) return;
    await _doUnblock(user);
  }

  Future<void> _doUnblock(BlockedUser user) async {
    final l = AppLocalizations.of(context);
    final vm = context.read<SettingsViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    if (await vm.unblock(user.id)) {
      messenger.showSnackBar(SnackBar(content: Text(l.unblocked)));
    } else {
      showActionFailed(messenger, l, () => _doUnblock(user));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<SettingsViewModel>();

    return SettingsScaffold(
      title: l.blockedAccounts,
      child: !vm.loadedBlocked
          ? (vm.blockedFailed
                ? SettingsError(onRetry: vm.retryBlocked)
                : const SettingsLoading())
          : vm.blocked.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Text(
                  l.blockedEmpty,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: c.textSecondary),
                ),
              ),
            )
          : ListView(
              padding: settingsListPadding(context),
              children: [
                for (final u in vm.blocked)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        AppAvatar(initials: u.initials),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.name,
                                key: Key('blocked-name-${u.id}'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyStrong.copyWith(
                                  color: c.textPrimary,
                                ),
                              ),
                              Text(
                                u.communityName,
                                key: Key('blocked-community-${u.id}'),
                                // Büyük yazıda düğme yanında 3+ satıra bölünmesin.
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SecondaryButton(
                          key: Key('unblock-${u.id}'),
                          label: l.unblock,
                          small: true,
                          expand: false,
                          onPressed: () => _unblock(u),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
