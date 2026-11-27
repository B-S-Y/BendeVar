import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_entrance.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sheets.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/community_models.dart';
import '../../../data/models/models.dart' show AvatarTone;
import '../../../l10n/app_localizations.dart';
import '../viewmodel/auth_view_model.dart';
import '../viewmodel/community_view_model.dart';
import 'settings_widgets.dart';

String _visibilityLabel(AppLocalizations l, CommunityVisibility v) =>
    switch (v) {
      CommunityVisibility.open => l.visibilityOpen,
      CommunityVisibility.schoolOnly => l.visibilitySchool,
      CommunityVisibility.secret => l.visibilitySecret,
    };

String _visibilityDesc(AppLocalizations l, CommunityVisibility v) =>
    switch (v) {
      CommunityVisibility.open => l.visibilityOpenDesc,
      CommunityVisibility.schoolOnly => l.visibilitySchoolDesc,
      CommunityVisibility.secret => l.visibilitySecretDesc,
    };

/// 1.16 · Topluluklarım (arama yazılınca 1.16g sonuçları). 1.16b/c davet kodu
/// sheet'i, 1.16e kurucu işlemleri, 1.16f silme onayı, 1.17 ayrılma onayı.
class CommunitiesPage extends StatefulWidget {
  const CommunitiesPage({super.key});

  @override
  State<CommunitiesPage> createState() => _CommunitiesPageState();
}

class _CommunitiesPageState extends State<CommunitiesPage> {
  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    final vm = context.read<CommunityViewModel>()..resetSearch();
    if (user != null) vm.load(user);
  }

  Future<void> _leave(CommunityInfo c) async {
    final l = AppLocalizations.of(context);
    // 1.17 · Topluluktan ayrıl onayı.
    final ok = await showConfirmSheet(
      context,
      title: l.leaveCommunityTitle,
      messages: [l.leaveCommunityLine1(c.name), l.leaveCommunityLine2],
      cancelLabel: l.cancel,
      confirmLabel: l.communityLeave,
    );
    if (!ok || !mounted) return;
    await _doLeave(c);
  }

  Future<void> _doLeave(CommunityInfo c) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (await context.read<CommunityViewModel>().leave(c.id)) {
      messenger.showSnackBar(SnackBar(content: Text(l.communityLeft)));
    } else {
      showActionFailed(messenger, l, () => _doLeave(c));
    }
  }

  Future<void> _founderActions(CommunityInfo c) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    // 1.16e · Kurucu işlemleri.
    final action = await showModalBottomSheet<_FounderAction>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => _FounderSheet(community: c),
    );
    if (action == null || !mounted) return;
    switch (action) {
      case _FounderAction.copyCode:
        await Clipboard.setData(ClipboardData(text: c.inviteCode ?? ''));
        messenger.showSnackBar(SnackBar(content: Text(l.inviteCodeCopied)));
      case _FounderAction.delete:
        // 1.16f · Silme onayı.
        final ok = await showConfirmSheet(
          context,
          title: l.deleteCommunityTitle,
          messages: [l.deleteCommunityLine1(c.name), l.deleteCommunityLine2],
          cancelLabel: l.cancel,
          confirmLabel: l.deleteCommunity,
          destructive: true,
        );
        if (!ok || !mounted) return;
        await _doDelete(c);
    }
  }

  Future<void> _doDelete(CommunityInfo c) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (await context.read<CommunityViewModel>().delete(c.id)) {
      messenger.showSnackBar(SnackBar(content: Text(l.communityDeleted)));
    } else {
      showActionFailed(messenger, l, () => _doDelete(c));
    }
  }

  Future<void> _joinFromSearch(CommunityInfo c) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (await context.read<CommunityViewModel>().join(c.id)) {
      messenger.showSnackBar(SnackBar(content: Text(l.communityJoined)));
    } else {
      showActionFailed(messenger, l, () => _joinFromSearch(c));
    }
  }

  Future<void> _inviteCode() => showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => const _InviteCodeSheet(),
  );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<CommunityViewModel>();

    Widget body;
    if (!vm.loaded) {
      body = vm.loadFailed
          ? SettingsError(onRetry: vm.retryLoad)
          : const SettingsLoading();
    } else if (vm.isSearch) {
      body = vm.searchFailed
          ? SettingsError(onRetry: () => vm.setQuery(vm.query))
          : vm.searching && vm.results.isEmpty
          ? const SettingsLoading()
          : vm.results.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Text(
                l.communitiesNoResults,
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: c.textSecondary),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(l.communitiesResults),
                for (final (i, r) in vm.results.indexed)
                  AppEntrance(
                    index: i,
                    child: _CommunityRow(
                      key: Key('result-${r.id}'),
                      community: r,
                      trailing: r.joined
                          ? Text(
                              l.communityMember,
                              style: AppTypography.captionStrong.copyWith(
                                color: c.textSecondary,
                              ),
                            )
                          : PrimaryButton(
                              key: Key('join-${r.id}'),
                              label: l.communityJoin,
                              small: true,
                              expand: false,
                              onPressed: () => _joinFromSearch(r),
                            ),
                    ),
                  ),
              ],
            );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(l.communitiesMine),
          for (final (i, m) in vm.mine.indexed)
            AppEntrance(
              index: i,
              child: _CommunityRow(
                key: Key('mine-${m.id}'),
                community: m,
                trailing: m.isSchool
                    ? Text(
                        l.communitySchoolBadge,
                        style: AppTypography.captionStrong.copyWith(
                          color: c.textSecondary,
                        ),
                      )
                    : m.isFounder
                    ? AppIconButton(
                        key: Key('founder-${m.id}'),
                        icon: LucideIcons.ellipsis,
                        tooltip: l.founderActionsTitle,
                        color: c.textSecondary,
                        onPressed: () => _founderActions(m),
                      )
                    : SecondaryButton(
                        key: Key('leave-${m.id}'),
                        label: l.communityLeave,
                        small: true,
                        expand: false,
                        onPressed: () => _leave(m),
                      ),
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          SecondaryButton(
            key: const Key('join-with-code'),
            label: l.joinWithCode,
            icon: LucideIcons.keyRound,
            onPressed: _inviteCode,
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            key: const Key('create-community'),
            label: l.createCommunity,
            icon: LucideIcons.plus,
            onPressed: () => context.push('/communities/create'),
          ),
        ],
      );
    }

    return SettingsScaffold(
      title: l.myCommunities,
      child: ListView(
        padding: settingsListPadding(context),
        children: [
          AppTextField(
            fieldKey: const Key('community-search'),
            hint: l.communitiesSearchHint,
            prefixIcon: LucideIcons.search,
            textInputAction: TextInputAction.search,
            onChanged: vm.setQuery,
          ),
          const SizedBox(height: AppSpacing.xl),
          body,
        ],
      ),
    );
  }
}

/// Topluluk satırı: baş harfli avatar, ad, "üye · görünürlük", sağda eylem.
class _CommunityRow extends StatelessWidget {
  const _CommunityRow({super.key, required this.community, this.trailing});

  final CommunityInfo community;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final info = [
      l.communityMembers(community.memberCount),
      _visibilityLabel(l, community.visibility),
      if (community.isFounder) l.communityFounderBadge,
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          AppAvatar(initials: community.initials, tone: AvatarTone.info),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  community.name,
                  style: AppTypography.bodyStrong.copyWith(
                    color: c.textPrimary,
                  ),
                ),
                Text(
                  info,
                  style: AppTypography.caption.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.sm),
            trailing!,
          ],
        ],
      ),
    );
  }
}

enum _FounderAction { copyCode, delete }

/// 1.16e · Kurucu işlemleri.
class _FounderSheet extends StatelessWidget {
  const _FounderSheet({required this.community});

  final CommunityInfo community;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Text(
              community.name,
              style: AppTypography.title2.copyWith(color: c.textPrimary),
            ),
            if (community.inviteCode != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                community.inviteCode!,
                style: AppTypography.body.copyWith(color: c.textSecondary),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            // Davet kodu yalnızca gizli topluluklarda var.
            if (community.inviteCode != null)
              SettingsRow(
                key: const Key('founder-copy'),
                icon: LucideIcons.copy,
                label: l.copyInviteCode,
                onTap: () => Navigator.pop(context, _FounderAction.copyCode),
              ),
            SettingsRow(
              key: const Key('founder-delete'),
              icon: LucideIcons.trash2,
              label: l.deleteCommunity,
              destructive: true,
              onTap: () => Navigator.pop(context, _FounderAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

/// 1.16b/1.16c · Davet koduyla katıl. Hata kodun altında; başarıda özet.
class _InviteCodeSheet extends StatefulWidget {
  const _InviteCodeSheet();

  @override
  State<_InviteCodeSheet> createState() => _InviteCodeSheetState();
}

class _InviteCodeSheetState extends State<_InviteCodeSheet> {
  final _controller = TextEditingController();
  CommunityInfo? _joined;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final vm = context.read<CommunityViewModel>();
    final info = await vm.joinByCode(_controller.text);
    if (info != null && mounted) setState(() => _joined = info);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<CommunityViewModel>();
    final failure = vm.codeFailure;
    final error = switch (failure) {
      CommunityFailure.invalidCode => l.inviteCodeInvalid,
      CommunityFailure.alreadyMember => l.inviteCodeAlready,
      CommunityFailure.unknown => l.actionFailed,
      null => null,
    };
    final joined = _joined;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screen,
          0,
          AppSpacing.screen,
          AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            if (joined != null) ...[
              // 1.16b · Katıldın.
              Center(
                child: AppAvatar(
                  size: AppSizes.avatarLg,
                  tone: AvatarTone.success,
                  initials: joined.initials,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.inviteCodeSuccessTitle,
                textAlign: TextAlign.center,
                style: AppTypography.title2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.inviteCodeSuccessBody(joined.name),
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                key: const Key('invite-done'),
                label: l.done,
                onPressed: () => Navigator.pop(context),
              ),
            ] else ...[
              Text(
                l.inviteCodeTitle,
                style: AppTypography.title2.copyWith(color: c.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.inviteCodeBody,
                style: AppTypography.body.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                fieldKey: const Key('invite-code'),
                controller: _controller,
                hint: l.inviteCodeHint,
                prefixIcon: LucideIcons.keyRound,
                errorText: error, // 1.16c
                textInputAction: TextInputAction.done,
                onChanged: (_) => vm.clearCodeFailure(),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                key: const Key('invite-submit'),
                label: l.communityJoin,
                loading: vm.busy,
                onPressed: vm.busy ? null : _submit,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 1.16d · Topluluk oluştur.
class CreateCommunityPage extends StatefulWidget {
  const CreateCommunityPage({super.key});

  @override
  State<CreateCommunityPage> createState() => _CreateCommunityPageState();
}

class _CreateCommunityPageState extends State<CreateCommunityPage> {
  final _name = TextEditingController();
  final _desc = TextEditingController();
  CommunityVisibility _visibility = CommunityVisibility.open;
  bool _showErrors = false;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!CommunityViewModel.validName(_name.text)) {
      setState(() => _showErrors = true);
      return;
    }
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final created = await context.read<CommunityViewModel>().create(
      name: _name.text,
      description: _desc.text,
      visibility: _visibility,
    );
    if (!mounted) return;
    if (created == null) {
      showActionFailed(messenger, l, _create);
      return;
    }
    router.pop();
    messenger.showSnackBar(SnackBar(content: Text(l.communityCreated)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final busy = context.watch<CommunityViewModel>().busy;

    return SettingsScaffold(
      title: l.createCommunityTitle,
      child: ListView(
        padding: settingsListPadding(context),
        children: [
          AppTextField(
            fieldKey: const Key('community-name'),
            label: l.communityNameLabel,
            hint: l.communityNameHint,
            controller: _name,
            textInputAction: TextInputAction.next,
            errorText: _showErrors && !CommunityViewModel.validName(_name.text)
                ? l.communityNameError
                : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            fieldKey: const Key('community-desc'),
            label: l.communityDescLabel,
            hint: l.communityDescHint,
            controller: _desc,
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionLabel(l.communityVisibilityLabel),
          for (final v in CommunityVisibility.values)
            SettingsRow(
              key: Key('visibility-${v.name}'),
              icon: switch (v) {
                CommunityVisibility.open => LucideIcons.globe,
                CommunityVisibility.schoolOnly => LucideIcons.graduationCap,
                CommunityVisibility.secret => LucideIcons.lock,
              },
              label: _visibilityLabel(l, v),
              description: _visibilityDesc(l, v),
              onTap: () => setState(() => _visibility = v),
              trailing: Icon(
                v == _visibility ? LucideIcons.circleCheck : LucideIcons.circle,
                size: AppSizes.iconAppBar,
                color: v == _visibility ? c.primary : c.textSecondary,
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            key: const Key('create-submit'),
            label: l.createCommunity,
            loading: busy,
            onPressed: busy ? null : _create,
          ),
        ],
      ),
    );
  }
}
