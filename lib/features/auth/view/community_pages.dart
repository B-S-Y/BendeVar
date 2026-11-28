import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/community_icons.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_entrance.dart';
import '../../../core/widgets/app_radio.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/community_icon_tile.dart';
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

String _visibilityHint(AppLocalizations l, CommunityVisibility v) =>
    switch (v) {
      CommunityVisibility.open => l.visibilityOpenHint,
      CommunityVisibility.schoolOnly => l.visibilitySchoolHint,
      CommunityVisibility.secret => l.visibilitySecretHint,
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
      builder: (_) => _FounderSheet(communityId: c.id),
    );
    if (action == null || !mounted) return;
    // Görünürlük sheet'te değişmiş olabilir: güncel kayıt.
    final current = context.read<CommunityViewModel>().mine.firstWhere(
      (m) => m.id == c.id,
      orElse: () => c,
    );
    switch (action) {
      case _FounderAction.copyCode:
        await Clipboard.setData(ClipboardData(text: current.inviteCode ?? ''));
        messenger.showSnackBar(SnackBar(content: Text(l.inviteCodeCopied)));
      case _FounderAction.share:
        // Paylaşım paketi yok: hazır davet metni panoya kopyalanır.
        await Clipboard.setData(
          ClipboardData(
            text: l.inviteShareText(current.name, current.inviteCode ?? ''),
          ),
        );
        messenger.showSnackBar(SnackBar(content: Text(l.inviteShareCopied)));
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
                isNew: vm.isNew(m),
                trailing: m.isSchool
                    ? null
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
            // Liste yüklenene kadar arama pasif: önceki kullanıcının bağlamıyla
            // aranmasın (hesap değişiminden hemen sonra).
            enabled: vm.loaded,
            onChanged: vm.setQuery,
          ),
          const SizedBox(height: AppSpacing.xl),
          body,
        ],
      ),
    );
  }
}

/// Topluluk satırı: seçilen simge, ad (+ "Yeni" rozeti), "üye · görünürlük",
/// sağda eylem.
class _CommunityRow extends StatelessWidget {
  const _CommunityRow({
    super.key,
    required this.community,
    this.trailing,
    this.isNew = false,
  });

  final CommunityInfo community;
  final Widget? trailing;

  /// Katılalı 24 saatten az: "Yeni" rozeti ve vurgulu çerçeve.
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    // Okul topluluğu: tür/"Okulun" etiketi yok; daha koyu çerçeveyle ayrılır.
    final info = [
      l.communityMembers(community.memberCount),
      if (!community.isSchool) _visibilityLabel(l, community.visibility),
      if (community.isFounder) l.communityFounderBadge,
    ].join(' · ');
    final row = Row(
      children: [
        CommunityIconTile(iconKey: community.iconKey),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      community.name,
                      style: AppTypography.bodyStrong.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  if (isNew) ...[
                    const SizedBox(width: AppSpacing.sm),
                    StatusPill(
                      key: Key('new-${community.id}'),
                      label: l.communityNewBadge,
                      fg: c.onPrimary,
                      bg: c.accent,
                    ),
                  ],
                ],
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
    );
    final framed = community.isSchool || isNew;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: framed
          ? Container(
              key: Key(
                community.isSchool ? 'school-row-frame' : 'new-row-frame',
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: AppRadius.cardLargeR,
                border: Border.all(
                  color: community.isSchool ? c.secondaryBorder : c.accent,
                  width: AppSizes.borderStrong,
                ),
              ),
              child: row,
            )
          : row,
    );
  }
}

enum _FounderAction { copyCode, share, delete }

/// 1.16e · Kurucu işlemleri: davet kodu (Kopyala, Paylaş), "Kim görebilir?"
/// (değişince hemen kaydedilir), Kapat, Topluluğu sil. Davet kodu yalnızca
/// gizli topluluklarda vardır.
class _FounderSheet extends StatelessWidget {
  const _FounderSheet({required this.communityId});

  final String communityId;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<CommunityViewModel>();
    final community = vm.mine.where((m) => m.id == communityId).firstOrNull;
    if (community == null) return const SizedBox.shrink();
    final code = community.inviteCode;

    Future<void> setVisibility(CommunityVisibility v) async {
      if (v == community.visibility) return;
      final messenger = ScaffoldMessenger.of(context);
      if (!await vm.setVisibility(community.id, v)) {
        showActionFailed(messenger, l, () => setVisibility(v));
      }
    }

    return SafeArea(
      child: SingleChildScrollView(
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
            Row(
              children: [
                CommunityIconTile(iconKey: community.iconKey),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.founderActionsTitle,
                        style: AppTypography.title2.copyWith(
                          color: c.textPrimary,
                        ),
                      ),
                      Text(
                        community.name,
                        style: AppTypography.body.copyWith(
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (code != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                key: const Key('founder-code-card'),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: AppRadius.cardLargeR,
                  border: Border.all(color: c.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.inviteCodeLabel,
                      style: AppTypography.body.copyWith(
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Text(
                          code,
                          key: const Key('founder-code'),
                          style: AppTypography.title1.copyWith(
                            color: c.textPrimary,
                            letterSpacing: AppSpacing.xs,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SecondaryButton(
                              key: const Key('founder-copy'),
                              label: l.inviteCopyAction,
                              small: true,
                              expand: false,
                              onPressed: () => Navigator.pop(
                                context,
                                _FounderAction.copyCode,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            SecondaryButton(
                              key: const Key('founder-share'),
                              label: l.inviteShareAction,
                              small: true,
                              expand: false,
                              onPressed: () =>
                                  Navigator.pop(context, _FounderAction.share),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.communityVisibilityLabel,
              style: AppTypography.label.copyWith(color: c.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            _VisibilitySegments(
              value: community.visibility,
              onChanged: setVisibility,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _visibilityHint(l, community.visibility),
              key: const Key('founder-visibility-hint'),
              style: AppTypography.caption.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              key: const Key('founder-close'),
              label: l.close,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: AppSpacing.md),
            DangerButton(
              key: const Key('founder-delete'),
              label: l.deleteCommunity,
              onPressed: () => Navigator.pop(context, _FounderAction.delete),
            ),
          ],
        ),
      ),
    );
  }
}

/// Üçlü seçici (1.16e): Açık / Okula özel / Gizli.
class _VisibilitySegments extends StatelessWidget {
  const _VisibilitySegments({required this.value, required this.onChanged});

  final CommunityVisibility value;
  final ValueChanged<CommunityVisibility> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    return ClipRRect(
      borderRadius: AppRadius.buttonR,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.card,
          border: Border.all(color: c.primary, width: AppSizes.borderWidth),
          borderRadius: AppRadius.buttonR,
        ),
        child: Row(
          children: [
            for (final v in CommunityVisibility.values)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: v == value,
                  child: Material(
                    color: v == value ? c.primary : c.card,
                    child: InkWell(
                      key: Key('segment-${v.name}'),
                      onTap: () => onChanged(v),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: AppSizes.buttonHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                          ),
                          child: Center(
                            child: Text(
                              _visibilityLabel(l, v),
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyStrong.copyWith(
                                color: v == value ? c.onPrimary : c.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
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

  /// Kod girildi, önizleme gösteriliyor (henüz katılınmadı).
  CommunityInfo? _preview;

  /// Katılındı (1.16b).
  CommunityInfo? _joined;
  bool _complete = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    context.read<CommunityViewModel>().clearCodeFailure();
    final complete = v.length == kInviteCodeLength;
    if (complete != _complete) setState(() => _complete = complete);
  }

  /// Devam: önce topluluk önizlemesi.
  Future<void> _continue() async {
    final info = await context.read<CommunityViewModel>().previewByCode(
      _controller.text,
    );
    if (info != null && mounted) setState(() => _preview = info);
  }

  /// Önizlemede Katıl: üye ol.
  Future<void> _join() async {
    final info = await context.read<CommunityViewModel>().joinByCode(
      _controller.text,
    );
    if (!mounted) return;
    if (info != null) {
      setState(() {
        _joined = info;
        _preview = null;
      });
    } else {
      // Kod arada geçersizleşti / hata: koda dön, hata görünür.
      setState(() => _preview = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<CommunityViewModel>();
    final error = switch (vm.codeFailure) {
      CommunityFailure.invalidCode => l.inviteCodeInvalid,
      CommunityFailure.alreadyMember => l.inviteCodeAlready,
      CommunityFailure.unknown => l.actionFailed,
      null => null,
    };
    final joined = _joined;
    final preview = _preview;

    Widget body;
    if (joined != null) {
      // 1.16b · Katıldın.
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
        ],
      );
    } else if (preview != null) {
      // Önizleme: ad, baş harf, üye sayısı, tür; altında Katıl ve Vazgeç.
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppAvatar(
              size: AppSizes.avatarLg,
              tone: AvatarTone.info,
              initials: preview.initials,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            preview.name,
            key: const Key('invite-preview-name'),
            textAlign: TextAlign.center,
            style: AppTypography.title2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            [
              l.communityMembers(preview.memberCount),
              _visibilityLabel(l, preview.visibility),
            ].join(' · '),
            key: const Key('invite-preview-meta'),
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            key: const Key('invite-join'),
            label: l.communityJoin,
            loading: vm.busy,
            onPressed: vm.busy ? null : _join,
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            key: const Key('invite-cancel'),
            label: l.cancel,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    } else {
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.inviteCodeTitle,
            style: AppTypography.title2.copyWith(color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            fieldKey: const Key('invite-code'),
            controller: _controller,
            hint: l.inviteCodeHint,
            prefixIcon: LucideIcons.keyRound,
            errorText: error, // 1.16c
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: kInviteCodeLength,
            textInputAction: TextInputAction.done,
            onChanged: _onChanged,
            onSubmitted: (_) => _complete && !vm.busy ? _continue() : null,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            key: const Key('invite-submit'),
            label: l.inviteContinue,
            loading: vm.busy,
            // Kullanıcı isteği: 6 hane dolmadan bilinçli olarak pasif.
            onPressed: _complete && !vm.busy ? _continue : null,
          ),
        ],
      );
    }

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
          children: [const SheetHandle(), body],
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
  CommunityVisibility _visibility = CommunityVisibility.open;
  String _iconKey = kDefaultCommunityIcon;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    context.read<CommunityViewModel>().resetNameCheck();
  }

  @override
  void dispose() {
    _name.dispose();
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
    final vm = context.read<CommunityViewModel>();
    final created = await vm.create(
      name: _name.text,
      description: '',
      visibility: _visibility,
      iconKey: _iconKey,
    );
    if (!mounted) return;
    if (created == null) {
      // Ad kullanımdaysa hata alanın altında zaten görünür.
      if (vm.nameAvailable != false) showActionFailed(messenger, l, _create);
      return;
    }
    router.pop();
    messenger.showSnackBar(SnackBar(content: Text(l.communityCreated)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<CommunityViewModel>();
    final busy = vm.busy;
    final taken = vm.nameAvailable == false;

    return SettingsScaffold(
      title: l.createCommunityTitle,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: settingsListPadding(context),
              children: [
                AppTextField(
                  fieldKey: const Key('community-name'),
                  label: l.communityNameLabel,
                  hint: l.communityNameHint,
                  controller: _name,
                  textInputAction: TextInputAction.done,
                  errorText: taken
                      ? l.communityNameTaken
                      : _showErrors && !CommunityViewModel.validName(_name.text)
                      ? l.communityNameError
                      : null,
                  // Ad boşsa ya da kısaysa gösterilmez.
                  successText: vm.nameAvailable == true
                      ? l.communityNameAvailable
                      : null,
                  onChanged: (v) {
                    setState(() {});
                    vm.checkName(v);
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l.communityIconLabel,
                  style: AppTypography.label.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                _IconGrid(
                  selected: _iconKey,
                  onSelected: (k) => setState(() => _iconKey = k),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l.communityVisibilityLabel,
                  style: AppTypography.label.copyWith(color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final v in CommunityVisibility.values)
                  _VisibilityCard(
                    key: Key('visibility-${v.name}'),
                    label: _visibilityLabel(l, v),
                    description: _visibilityDesc(l, v),
                    selected: v == _visibility,
                    onTap: () => setState(() => _visibility = v),
                  ),
              ],
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: c.background,
              border: Border(top: BorderSide(color: c.divider)),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.lg,
                AppSpacing.screen,
                AppSpacing.lg + MediaQuery.paddingOf(context).bottom,
              ),
              child: PrimaryButton(
                key: const Key('create-submit'),
                label: l.communityCreateSubmit,
                loading: busy,
                onPressed: busy ? null : _create,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 6×2 simge ızgarası (1.16d). Seçili: açık mavi dolgu + lacivert çerçeve.
class _IconGrid extends StatelessWidget {
  const _IconGrid({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  /// Izgara sütun sayısı (görselde 6×2).
  static const int columns = 6;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: kCommunityIconKeys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisExtent: AppSizes.buttonHeight,
      ),
      itemBuilder: (_, i) {
        final key = kCommunityIconKeys[i];
        final on = key == selected;
        return Semantics(
          button: true,
          selected: on,
          child: Material(
            color: on ? c.infoBg : c.card,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonR,
              side: BorderSide(
                color: on ? c.primary : c.cardBorder,
                width: on ? AppSizes.focusRing : AppSizes.borderWidth,
              ),
            ),
            child: InkWell(
              key: Key('icon-$key'),
              customBorder: RoundedRectangleBorder(
                borderRadius: AppRadius.buttonR,
              ),
              onTap: () => onSelected(key),
              child: Center(
                child: Icon(
                  communityIcon(key),
                  size: AppSizes.iconAppBar,
                  color: c.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "Kim görebilir?" seçeneği: radyo + ad + açıklama. Seçili: kalın lacivert
/// çerçeve.
class _VisibilityCard extends StatelessWidget {
  const _VisibilityCard({
    super.key,
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        inMutuallyExclusiveGroup: true,
        checked: selected,
        child: Material(
          color: c.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardLargeR,
            side: BorderSide(
              color: selected ? c.primary : c.cardBorder,
              width: selected ? AppSizes.focusRing : AppSizes.borderWidth,
            ),
          ),
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: AppRadius.cardLargeR,
            ),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  AppRadioDot(selected: selected),
                  const SizedBox(width: AppSpacing.lg),
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
                          style: AppTypography.body.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
