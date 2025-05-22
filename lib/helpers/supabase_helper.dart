

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Stream<List<T>> getDataStream<T>({
  required String table,
  required List<String> ids,
  required T Function(Map<String, dynamic> json) fromJson,
}){
  var stream = supabase.from(table).stream(primaryKey: ids);
  return stream.map((maps) =>
    maps.map((e) => fromJson(e)).toList());
}
