import 'package:flutter/foundation.dart';

import '../../../core/utils/validators.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

/// 3.02 (ilan) ve 3.11 (ihtiyaç) formlarının ortak ViewModel'i.
class CreateListingViewModel extends ChangeNotifier {
  CreateListingViewModel({
    required this.kind,
    required this.repo,
    required this.ownerName,
  });

  final ListingKind kind;
  final ListingRepository repo;
  final String ownerName;

  String title = '';
  String description = '';
  ListingCategory? category;
  ListingCondition? condition;
  ListingMode mode = ListingMode.lend;
  Urgency urgency = Urgency.thisWeek;
  bool paid = false;
  String priceText = '';
  PriceUnit priceUnit = PriceUnit.daily;
  DateTime? from;
  DateTime? to;

  bool _submitted = false;
  bool _saving = false;

  bool get saving => _saving;
  bool get isIlan => kind == ListingKind.ilan;

  RequiredError? get titleError =>
      _submitted ? Validators.requiredText(title) : null;
  bool get categoryError => _submitted && category == null;
  bool get conditionError => _submitted && isIlan && condition == null;
  bool get datesError =>
      _submitted && (from == null || to == null || to!.isBefore(from!));
  bool get priceError =>
      _submitted && paid && !Validators.validPrice(priceText);

  bool get isValid =>
      Validators.requiredText(title) == null &&
      category != null &&
      (!isIlan || condition != null) &&
      from != null &&
      to != null &&
      !to!.isBefore(from!) &&
      (!paid || Validators.validPrice(priceText));

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  void setTitle(String v) => update(() => title = v);
  void setDescription(String v) => description = v;
  void setCategory(ListingCategory c) => update(() => category = c);
  void setCondition(ListingCondition c) => update(() => condition = c);
  void setMode(ListingMode m) => update(() => mode = m);
  void setUrgency(Urgency u) => update(() => urgency = u);
  void setPaid(bool v) => update(() => paid = v);
  void setPriceText(String v) => update(() => priceText = v);
  void setPriceUnit(PriceUnit u) => update(() => priceUnit = u);
  void setFrom(DateTime d) => update(() {
    from = d;
    if (to != null && to!.isBefore(d)) to = d;
  });
  void setTo(DateTime d) => update(() => to = d);

  /// Doğrulama başarısızsa null döner (hatalar gösterilir).
  Future<Listing?> publish() async {
    _submitted = true;
    if (!isValid) {
      notifyListeners();
      return null;
    }
    _saving = true;
    notifyListeners();
    final id = await repo.nextId();
    final price = paid
        ? double.parse(priceText.trim().replaceAll(',', '.'))
        : null;
    final listing = Listing(
      id: id,
      kind: kind,
      title: title.trim(),
      category: category!,
      condition: isIlan ? condition : null,
      mode: isIlan ? mode : ListingMode.lend,
      price: price,
      priceUnit: paid && !isIlan ? priceUnit : null,
      description: description.trim(),
      availableFrom: from,
      availableTo: to,
      urgency: isIlan ? null : urgency,
      ownerName: ownerName,
      postedAt: DateTime.now(),
    );
    await repo.add(listing);
    _saving = false;
    notifyListeners();
    return listing;
  }
}
