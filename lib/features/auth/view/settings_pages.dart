import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_radio.dart';
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

    final timings = {
      ReminderTiming.twoDaysBefore: l.notifRemindTwoDays,
      ReminderTiming.dayBeforeAndDay: l.notifRemindDayBefore,
      ReminderTiming.dayOf: l.notifRemindDayOf,
    };

    return SettingsScaffold(
      title: l.notificationSettings,
      child: ListView(
        padding: settingsListPadding(context),
        children: staggerRows([
          _PrefSwitchRow(
            switchKey: const Key('notif-responses'),
            label: l.notifResponses,
            description: l.notifResponsesDesc,
            value: p.responses,
            onChanged: (v) => save(p.copyWith(responses: v)),
          ),
          Divider(color: c.divider, height: AppSizes.borderWidth),
          _PrefSwitchRow(
            switchKey: const Key('notif-messages'),
            label: l.notifMessages,
            description: l.notifMessagesDesc,
            value: p.messages,
            onChanged: (v) => save(p.copyWith(messages: v)),
          ),
          Divider(color: c.divider, height: AppSizes.borderWidth),
          _PrefSwitchRow(
            switchKey: const Key('notif-reminders'),
            label: l.notifReminders,
            description: l.notifRemindersDesc,
            value: p.reminders,
            onChanged: (v) => save(p.copyWith(reminders: v)),
          ),
          // Hatırlatma zamanı yalnızca iade hatırlatması açıkken.
          if (p.reminders)
            _TimingGroup(
              title: l.notifRemindWhen,
              children: [
                for (final e in timings.entries)
                  _TimingOption(
                    key: Key('remind-${e.key.name}'),
                    label: e.value,
                    selected: p.reminderTiming == e.key,
                    onTap: () => save(p.copyWith(reminderTiming: e.key)),
                  ),
              ],
            ),
        ]),
      ),
    );
  }
}

/// Düz anahtar satırı (1.18): başlık, açıklama, sağda anahtar.
class _PrefSwitchRow extends StatelessWidget {
  const _PrefSwitchRow({
    required this.switchKey,
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final Key switchKey;
  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyStrong.copyWith(
                      color: c.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Switch(
              key: switchKey,
              value: value,
              onChanged: onChanged,
              activeTrackColor: c.primary,
              activeThumbColor: c.onPrimary,
              inactiveTrackColor: c.silver,
              inactiveThumbColor: c.card,
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Başlığı çerçevenin üst çizgisine oturan seçenek grubu ("Ne zaman
/// hatırlatalım?").
class _TimingGroup extends StatelessWidget {
  const _TimingGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: AppSpacing.md),
            padding: const EdgeInsets.only(top: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.cardLargeR,
              border: Border.all(color: c.cardBorder),
            ),
            child: Column(children: children),
          ),
          Positioned(
            left: AppSpacing.lg,
            top: 0,
            child: Container(
              color: c.background,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                title,
                key: const Key('remind-title'),
                style: AppTypography.label.copyWith(color: c.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Radyo seçeneği satırı.
class _TimingOption extends StatelessWidget {
  const _TimingOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.tapTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                AppRadioDot(selected: selected),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.body.copyWith(color: c.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
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
