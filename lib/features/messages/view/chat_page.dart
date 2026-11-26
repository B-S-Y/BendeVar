import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/coming_soon_page.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/messages_view_models.dart';

/// 4.05 · Sohbet · anlaşıldı
class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(ChatViewModel vm) async {
    final ok = await vm.send(_text.text);
    if (!ok) return;
    _text.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<ChatViewModel>();
    final chat = vm.chat;
    if (chat == null) {
      return Scaffold(appBar: AppBar(title: Text(l.messagesTitle)));
    }

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: c.card,
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top,
              left: AppSpacing.xs,
            ),
            height:
                MediaQuery.paddingOf(context).top +
                AppSizes.avatar +
                AppSpacing.md,
            child: Row(
              children: [
                AppIconButton(
                  icon: LucideIcons.arrowLeft,
                  tooltip: l.back,
                  onPressed: () => context.pop(),
                ),
                AppAvatar(
                  initials: chat.peerInitials,
                  tone: chat.peerTone,
                  size: AppSizes.avatar - AppSpacing.md,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    chat.peerName,
                    style: AppTypography.title2.copyWith(color: c.textPrimary),
                  ),
                ),
                AppIconButton(
                  icon: LucideIcons.ellipsisVertical,
                  tooltip: l.more,
                  onPressed: () => showComingSoonSnack(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: c.cardBorder),
          Container(
            color: c.card,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screen,
              AppSpacing.md,
              AppSpacing.screen,
              AppSpacing.md,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: c.disabledBg,
                borderRadius: AppRadius.buttonR,
              ),
              child: Row(
                children: [
                  Container(
                    width: AppSizes.avatar - AppSpacing.sm,
                    height: AppSizes.avatar - AppSpacing.sm,
                    decoration: BoxDecoration(
                      color: c.card.withValues(alpha: 0.6),
                      borderRadius: AppRadius.buttonSmallR,
                    ),
                    child: Icon(
                      LucideIcons.archive,
                      size: AppSizes.iconRow,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  ListingKindBadge(kind: chat.listingKind),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      chat.listingTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title2.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(AppSpacing.screen),
              children: [
                for (final m in chat.messages) _Bubble(chat: chat, message: m),
                if (chat.agreement != null)
                  _AgreementCard(agreement: chat.agreement!),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: c.card,
              border: Border(top: BorderSide(color: c.cardBorder)),
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md + MediaQuery.paddingOf(context).bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('message-field'),
                    controller: _text,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(vm),
                    style: AppTypography.body.copyWith(color: c.textPrimary),
                    decoration: InputDecoration(
                      hintText: l.messageHint,
                      hintStyle: AppTypography.body.copyWith(
                        color: c.textSecondary,
                      ),
                      filled: true,
                      fillColor: c.card,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md + AppSpacing.xs,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.fullR,
                        borderSide: BorderSide(color: c.fieldBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.fullR,
                        borderSide: BorderSide(color: c.fieldBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.fullR,
                        borderSide: BorderSide(
                          color: c.accent,
                          width: AppSizes.focusRing,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  key: const Key('send-button'),
                  tooltip: l.send,
                  onPressed: () => _send(vm),
                  style: IconButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: c.onPrimary,
                    fixedSize: const Size(
                      AppSizes.tapTarget + AppSpacing.sm,
                      AppSizes.tapTarget + AppSpacing.sm,
                    ),
                  ),
                  icon: const Icon(LucideIcons.send, size: AppSizes.iconAppBar),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.chat, required this.message});
  final Chat chat;
  final Message message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final mine = message.fromMe;
    final isResponse = message.kind == MessageKind.response;

    final Widget content;
    if (isResponse) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.archive,
                size: AppSizes.iconRow,
                color: c.accent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                chat.listingKind == ListingKind.ilan
                    ? l.bubbleNeedIt
                    : l.bubbleHaveIt,
                style: AppTypography.label.copyWith(color: c.accent),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message.text,
            style: AppTypography.body.copyWith(color: c.textPrimary),
          ),
          if (message.accepted) ...[
            const SizedBox(height: AppSpacing.sm),
            StatusPill(
              label: l.accepted,
              fg: c.successFg,
              bg: c.successBg,
              icon: LucideIcons.circleCheck,
            ),
          ],
        ],
      );
    } else {
      content = Text(
        message.text,
        style: AppTypography.body.copyWith(
          color: mine ? c.onPrimary : c.textPrimary,
        ),
      );
    }

    final decoration = isResponse
        ? BoxDecoration(
            color: c.card,
            borderRadius: AppRadius.cardLargeR,
            border: Border.all(
              color: mine ? c.primary : c.divider,
              width: AppSizes.borderStrong,
            ),
          )
        : BoxDecoration(
            color: mine ? c.primary : c.card,
            borderRadius: AppRadius.cardLargeR,
            border: mine ? null : Border.all(color: c.cardBorder),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.78,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: decoration,
            child: content,
          ),
        ),
      ),
    );
  }
}

/// "Anlaşma özeti" kartı: teslim yeri, süre, ücret.
class _AgreementCard extends StatelessWidget {
  const _AgreementCard({required this.agreement});
  final Agreement agreement;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    Widget row(IconData icon, String text) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconAppBar, color: c.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      label: l.agreementSummary,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: AppRadius.cardLargeR,
          border: Border.all(color: c.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row(LucideIcons.mapPin, agreement.place),
            row(
              LucideIcons.calendar,
              '${Formatters.dayMonth(agreement.from, locale)} – ${Formatters.dayMonth(agreement.to, locale)}',
            ),
            row(
              LucideIcons.banknote,
              agreement.price == null
                  ? l.priceFree
                  : Formatters.money(agreement.price!, locale),
            ),
            const SizedBox(height: AppSpacing.xs),
            SecondaryButton(
              label: l.agreementDetail,
              small: true,
              onPressed: () => showComingSoonSnack(context),
            ),
          ],
        ),
      ),
    );
  }
}
