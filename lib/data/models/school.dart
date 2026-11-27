/// Okul kaydı (`assets/data/tr_universities.json`). Kimlik, e-postadaki
/// `.edu.tr`'den önceki etikettir; [aliases] eski/alternatif etiketlerdir.
class School {
  const School({
    required this.id,
    required this.nameTr,
    required this.nameEn,
    this.aliases = const [],
    this.note,
  });

  factory School.fromJson(Map<String, dynamic> json) => School(
    id: json['id'] as String,
    nameTr: json['name_tr'] as String,
    nameEn: json['name_en'] as String,
    aliases: List<String>.from(json['aliases'] as List? ?? const []),
    note: json['note'] as String?,
  );

  final String id;
  final String nameTr;
  final String nameEn;
  final List<String> aliases;
  final String? note;
}
