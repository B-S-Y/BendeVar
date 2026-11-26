import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/small_widgets.dart';
import '../../../data/models/models.dart';
import '../../../l10n/app_localizations.dart';
import '../viewmodel/messages_view_models.dart';

/// 4.01 · Mesajlar
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final vm = context.watch<MessagesViewModel>();
    final chats = vm.visible;

    return Column(
      children: [
        Container(
          width: double.infinity,
          color: c.appBar,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            MediaQuery.paddingOf(context).top + AppSpacing.lg,
            AppSpacing.screen,
            AppSpacing.lg,
          ),
          child: Text(
            l.messagesTitle,
            style: AppTypography.title1.copyWith(color: c.onAppBar),
          ),
        ),
        Container(
          color: c.card,
          padding: const EdgeInsets.all(AppSpacing.screen),
          child: AppSegmented<MessageFilter>(
            bordered: true,
            value: vm.filter,
            onChanged: vm.setFilter,
            items: [
              SegmentItem(value: MessageFilter.all, label: l.filterAll),
              SegmentItem(
                value: MessageFilter.unread,
                label: l.filterUnread,
                count: vm.unreadCount,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: c.cardBorder),
        Expanded(
          child: chats.isEmpty
              ? Center(
                  child: Text(
                    l.emptyMessages,
                    style: AppTypography.body.copyWith(color: c.textSecondary),
                  ),
                )
              : ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, color: c.cardBorder),
                  itemBuilder: (_, i) => _ChatRow(chat: chats[i]),
                ),
        ),
      ],
    );
  }
}

class _ChatRow extends StatelessWidget {
  const _ChatRow({required this.chat});
  final Chat chat;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final unread = chat.unread > 0;
    final last = chat.last;
    final preview = last.kind == MessageKind.response && !last.fromMe
        ? (chat.listingKind == ListingKind.ilan
              ? l.respondedNeedIt
              : l.respondedHaveIt)
        : last.text;

    return Material(
      color: unread ? c.unreadTint : c.card,
      child: InkWell(
        onTap: () => context.push('/chat/${chat.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screen,
            vertical: AppSpacing.md + AppSpacing.xs,
          ),
          child: Row(
            children: [
              AppAvatar(
                initials: chat.peerInitials,
                tone: chat.peerTone,
                size: AppSizes.avatar + AppSpacing.sm,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.peerName,
                            style: AppTypography.title2.copyWith(
                              color: c.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          Formatters.chatTime(
                            l,
                            last.sentAt,
                            DateTime.now(),
                            locale,
                          ),
                          style: AppTypography.caption.copyWith(
                            color: unread ? c.accent : c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        ListingKindBadge(kind: chat.listingKind),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                (unread
                                        ? AppTypography.bodyStrong
                                        : AppTypography.body)
                                    .copyWith(
                                      color: unread
                                          ? c.textPrimary
                                          : c.textSecondary,
                                    ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: AppSizes.badge + AppSpacing.xs,
                            height: AppSizes.badge + AppSpacing.xs,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: c.accent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${chat.unread}',
                              style: AppTypography.captionStrong.copyWith(
                                color: c.onBadge,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
