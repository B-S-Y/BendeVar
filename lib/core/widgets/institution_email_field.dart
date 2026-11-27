import 'package:material_ui/material_ui.dart';

import 'dart:async';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_text_field.dart';

/// Kurum e-postası denetleyicisi: kullanıcı `ad.soyad@` yazınca `.edu.tr`
/// alanın içinde sabit sonek olarak kendiliğinden gelir, imleç okul kısmında
/// kalır. Gerçek e-posta = [text] (sonek dahil).
class InstitutionEmailController extends TextEditingController {
  InstitutionEmailController({super.text});

  static const String suffix = '.edu.tr';

  /// Türkçe karakterleri ASCII'ye çevirip küçültür (ı→i, ğ→g, ü→u, ş→s,
  /// ö→o, ç→c, İ→i). Harf sayısı değişmez, imleç yerinde kalır.
  static String toAscii(String text) {
    const map = {
      'ı': 'i',
      'İ': 'i',
      'I': 'i',
      'ğ': 'g',
      'Ğ': 'g',
      'ü': 'u',
      'Ü': 'u',
      'ş': 's',
      'Ş': 's',
      'ö': 'o',
      'Ö': 'o',
      'ç': 'c',
      'Ç': 'c',
    };
    final b = StringBuffer();
    for (final ch in text.split('')) {
      b.write(map[ch] ?? ch.toLowerCase());
    }
    return b.toString();
  }

  /// İlk ASCII/küçük harf çevirisinde bir kez true olur (kısa ipucu için).
  final ValueNotifier<bool> conversionHint = ValueNotifier(false);
  bool _hintUsed = false;

  @override
  void dispose() {
    conversionHint.dispose();
    super.dispose();
  }

  /// Kurum dışı bir e-posta yapıştırıldı: olduğu gibi bırakılır (hata gösterilir).
  bool _foreign = false;
  bool get isForeign => _foreign;

  @override
  set value(TextEditingValue newValue) {
    super.value = _normalize(value, newValue);
  }

  TextEditingValue _normalize(TextEditingValue old, TextEditingValue now) {
    // Boşluk e-postada olmaz.
    final raw = now.text.replaceAll(RegExp(r'\s'), '');
    var text = toAscii(raw);
    if (!_hintUsed && text != raw) {
      _hintUsed = true;
      conversionHint.value = true;
    }
    var cursor = now.selection.isValid
        ? now.selection.baseOffset.clamp(0, text.length)
        : text.length;

    final at = text.indexOf('@');
    if (at < 0) {
      _foreign = false;
      // '@' silindi: kendiliğinden gelen sonek de gider.
      if (old.text.contains('@') && text.toLowerCase().endsWith(suffix)) {
        text = text.substring(0, text.length - suffix.length);
        cursor = cursor.clamp(0, text.length);
      }
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: cursor),
      );
    }

    final pasted = text.length - old.text.length > 1;
    final lower = text.toLowerCase();
    if (pasted && !lower.endsWith(suffix) && !_foreign) {
      // gmail gibi kurum dışı e-posta yapıştırıldı: dokunma.
      _foreign = true;
    }
    if (_foreign) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: cursor),
      );
    }

    final local = text.substring(0, at);
    var school = text.substring(at + 1).replaceAll('@', '');
    school = school.replaceAll(RegExp(r'\.edu\.tr', caseSensitive: false), '');
    final end = (at + 1 + school.length);
    return TextEditingValue(
      text: '$local@$school$suffix',
      // İmleç sonekin önünde kalır.
      selection: TextSelection.collapsed(offset: cursor.clamp(0, end).toInt()),
    );
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final t = text;
    if (!_foreign && t.contains('@') && t.endsWith(suffix)) {
      final muted = style?.copyWith(color: context.colors.textSecondary);
      return TextSpan(
        style: style,
        children: [
          TextSpan(text: t.substring(0, t.length - suffix.length)),
          TextSpan(text: suffix, style: muted),
        ],
      );
    }
    return super.buildTextSpan(
      context: context,
      style: style,
      withComposing: withComposing,
    );
  }
}

/// Giriş (1.02) ve kayıt (1.08) için ortak kurum e-postası alanı.
class InstitutionEmailField extends StatefulWidget {
  const InstitutionEmailField({
    super.key,
    this.fieldKey,
    this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.label,
    this.errorSignal,
    this.focusNode,
  });

  final Key? fieldKey;
  final InstitutionEmailController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  /// Verilmezse "Kurum e-postası".
  final String? label;
  final Object? errorSignal;
  final FocusNode? focusNode;

  @override
  State<InstitutionEmailField> createState() => _InstitutionEmailFieldState();
}

class _InstitutionEmailFieldState extends State<InstitutionEmailField> {
  late final InstitutionEmailController _own = InstitutionEmailController();
  InstitutionEmailController get _ctrl => widget.controller ?? _own;

  bool _showHint = false;
  Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _ctrl.conversionHint.addListener(_onConversion);
  }

  void _onConversion() {
    if (!_ctrl.conversionHint.value) return;
    _hintTimer?.cancel();
    setState(() => _showHint = true);
    _hintTimer = Timer(AppMotion.hintVisible, () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _ctrl.conversionHint.removeListener(_onConversion);
    _own.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = context.colors;
    final fade = AppMotion.reduce(context) ? Duration.zero : AppMotion.hintFade;
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        // '@' yazılmadan önce ipucu "ad.soyad@okul", sonra alan dolu.
        final field = AppTextField(
          fieldKey: widget.fieldKey,
          controller: _ctrl,
          label: widget.label ?? l.emailLabel,
          hint: l.emailHintShort,
          keyboardType: TextInputType.emailAddress,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          errorText: widget.errorText,
          errorSignal: widget.errorSignal,
          focusNode: widget.focusNode,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            field,
            _MaybeAnimatedSize(
              animate: fade != Duration.zero,
              duration: fade,
              child: AnimatedOpacity(
                duration: fade,
                opacity: _showHint ? 1 : 0,
                child: _showHint
                    ? Padding(
                        key: const Key('email-convert-hint'),
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              LucideIcons.info,
                              size: AppSizes.iconField,
                              color: c.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                l.emailAsciiHint,
                                style: AppTypography.caption.copyWith(
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Animasyonlar azaltıldıysa boyut animasyonu hiç kurulmaz.
class _MaybeAnimatedSize extends StatelessWidget {
  const _MaybeAnimatedSize({
    required this.animate,
    required this.duration,
    required this.child,
  });

  final bool animate;
  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) => animate
      ? AnimatedSize(
          duration: duration,
          alignment: Alignment.topCenter,
          child: child,
        )
      : child;
}
