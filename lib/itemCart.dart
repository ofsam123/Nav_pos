import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'API.dart';
import 'Models/itemsModel2.dart';

class ItemCartLine {
  ItemCartLine(this.item);

  final itemsModel2 item;
  int quantity = 1;
  String? unit;
  List<String> units = const [];
  bool unitsLoading = true;
  bool unitsFailed = false;

  String get no => item.No ?? '';

  bool get needsUnit => !unitsLoading && units.isNotEmpty && unit == null;
}

/// Cart for selling straight from the Items page. Kept for the whole app
/// session so it survives switching tabs.
class ItemCart extends ChangeNotifier {
  ItemCart._();

  static final ItemCart instance = ItemCart._();

  final List<ItemCartLine> _lines = [];

  List<ItemCartLine> get lines => List.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;
  int get itemCount => _lines.length;
  int get totalUnits => _lines.fold(0, (sum, l) => sum + l.quantity);
  bool get unitsLoading => _lines.any((l) => l.unitsLoading);
  int get missingUnits => _lines.where((l) => l.needsUnit).length;

  ItemCartLine? lineFor(String? itemNo) {
    for (final line in _lines) {
      if (line.no == itemNo) return line;
    }
    return null;
  }

  void add(itemsModel2 item) {
    final existing = lineFor(item.No);
    if (existing != null) {
      existing.quantity++;
      notifyListeners();
      return;
    }
    final line = ItemCartLine(item);
    _lines.add(line);
    notifyListeners();
    loadUnits(line);
  }

  void remove(ItemCartLine line) {
    if (_lines.remove(line)) notifyListeners();
  }

  void setQuantity(ItemCartLine line, int quantity) {
    if (quantity < 1 || line.quantity == quantity) return;
    line.quantity = quantity;
    notifyListeners();
  }

  void setUnit(ItemCartLine line, String unit) {
    line.unit = unit;
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }

  Future<void> loadUnits(ItemCartLine line) async {
    line
      ..unitsLoading = true
      ..unitsFailed = false;
    notifyListeners();

    final basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final itemNo = line.no.replaceAll("'", "''");

    try {
      final response = await http.get(
        Uri.parse(ApiUrl.MainIP +
            "ItemUnitofMeasureAPI?\$filter=Item_No eq '$itemNo'"),
        headers: {
          'Content': 'application/x-www-form-urlencoded',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': basicAuth,
          "Access-Control-Allow-Origin": "*",
        },
      );
      if (response.statusCode != 200) throw Exception(response.statusCode);

      final rows = jsonDecode(response.body)["value"] as List;
      line.units = [for (final row in rows) row["Code"].toString()];
      line.unit ??= _defaultUnit(line);
    } catch (_) {
      line.unitsFailed = true;
    }
    line.unitsLoading = false;
    if (_lines.contains(line)) notifyListeners();
  }

  String? _defaultUnit(ItemCartLine line) {
    for (final preferred in [
      line.item.Sales_Unit_of_Measure,
      line.item.Base_Unit_of_Measure,
    ]) {
      if (preferred != null && line.units.contains(preferred)) return preferred;
    }
    return line.units.length == 1 ? line.units.first : null;
  }
}
