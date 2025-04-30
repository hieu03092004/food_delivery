import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../model/shipper_model/IncomeEntry.dart';
Future<List<IncomeEntry>> getIncomeByFilters({
  required int year,
  required DateTime date,
  required int week,
  required int shipperId,
}) async {
  final SupabaseClient _supabase = Supabase.instance.client;
  final res = await _supabase.rpc(
    'get_income_by_year_date_week',  // ← đúng tên
    params: {
      'p_year':       year,
      'p_date':       date.toIso8601String().split('T').first,
      'p_week':       week,
      'p_shipper_id': shipperId,      // ← thêm tham số này
    },
  );

  final List raw = res.data as List<dynamic>;
  print(raw);
  return raw.map((e) => IncomeEntry(
    day:    e['day']    as String,
    income: (e['income'] as num).toDouble(),
  )).toList();
}

