import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'numbers.dart';

class BoqItem {
  BoqItem({
    required this.id,
    required this.title,
    required this.unit,
    required this.qty,
    required this.unitPrice,
    this.projectId,
  });

  final String id;
  String title;
  String unit;
  double qty;
  double unitPrice;
  String? projectId;

  double get total => qty * unitPrice;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'unit': unit,
        'qty': qty,
        'price': unitPrice,
        'project': projectId,
      };

  factory BoqItem.fromJson(Map<String, dynamic> j) => BoqItem(
        id: j['id']?.toString() ?? '',
        title: j['title']?.toString() ?? '',
        unit: j['unit']?.toString() ?? '',
        qty: (j['qty'] as num?)?.toDouble() ?? 0,
        unitPrice: (j['price'] as num?)?.toDouble() ?? 0,
        projectId: j['project']?.toString(),
      );
}

double boqTotal(Iterable<BoqItem> items) =>
    items.fold(0.0, (s, e) => s + e.total);

/// Tab-separated text that pastes straight into Excel, with a header and a
/// totals row.
String boqToTsv(List<BoqItem> items) {
  final b = StringBuffer('ردیف\tشرح\tواحد\tمقدار\tقیمت واحد\tقیمت کل\n');
  for (var i = 0; i < items.length; i++) {
    final e = items[i];
    b.writeln('${i + 1}\t${_clean(e.title)}\t${_clean(e.unit)}\t${_num(e.qty)}\t${_num(e.unitPrice)}\t${_num(e.total)}');
  }
  b.write('\t\t\t\tجمع کل\t${_num(boqTotal(items))}');
  return b.toString();
}

String _clean(String s) => s.replaceAll('\t', ' ').replaceAll('\n', ' ');

String _num(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');
}

/// First number found in an estimate result such as "۱۲٫۵ مترمکعب بتن",
/// with the text after it as the unit. Returns null when there is none.
({double qty, String unit})? parseResultQuantity(String result) {
  final m = RegExp(r'([0-9۰-۹٠-٩][0-9۰-۹٠-٩,٬]*(?:[.٫][0-9۰-۹٠-٩]+)?)')
      .firstMatch(result);
  if (m == null) return null;
  try {
    final q = parseEstimateNumber(m.group(1)!, label: 'مقدار', allowZero: true);
    final rest = result.substring(m.end).trim();
    final unit = rest.split(RegExp(r'\s+')).first;
    return (qty: q, unit: unit);
  } catch (_) {
    return null;
  }
}

class BoqStore {
  static const _key = 'boq.v1';

  static Future<List<BoqItem>> all() async {
    final p = await SharedPreferences.getInstance();
    try {
      return (jsonDecode(p.getString(_key) ?? '[]') as List)
          .map((e) => BoqItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _save(List<BoqItem> a) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(a.map((e) => e.toJson()).toList()));
  }

  static Future<void> upsert(BoqItem v) async {
    final a = await all();
    final i = a.indexWhere((x) => x.id == v.id);
    if (i < 0) {
      a.add(v);
    } else {
      a[i] = v;
    }
    await _save(a);
  }

  static Future<void> remove(String id) async {
    final a = await all()
      ..removeWhere((x) => x.id == id);
    await _save(a);
  }

  static Future<void> removeForProject(String projectId) async {
    final a = await all()
      ..removeWhere((x) => x.projectId == projectId);
    await _save(a);
  }
}

/// Whole numbers without decimals, otherwise up to three decimals.
String formatBoqNumber(double v) => _num(v);
