import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/models/community_models.dart';

/// Topluluk simgeleri (1.16d): anahtar → Lucide ikonu. Anahtarlar ve sıra
/// `community_models.dart`ta (`kCommunityIconKeys`).
const Map<String, IconData> _icons = {
  'book-open': LucideIcons.bookOpen,
  'coffee': LucideIcons.coffee,
  'house': LucideIcons.house,
  'laptop': LucideIcons.laptop,
  'gamepad-2': LucideIcons.gamepad2,
  'trophy': LucideIcons.trophy,
  'music': LucideIcons.music,
  'palette': LucideIcons.palette,
  'utensils': LucideIcons.utensils,
  'bike': LucideIcons.bike,
  'flask-conical': LucideIcons.flaskConical,
  'users': LucideIcons.users,
  kSchoolCommunityIcon: LucideIcons.graduationCap,
};

/// Anahtarın ikonu; bilinmeyen anahtarda `users`.
IconData communityIcon(String key) => _icons[key] ?? LucideIcons.users;
