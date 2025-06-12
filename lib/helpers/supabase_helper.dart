

import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<String> uploadImages({
  required File image,
  required String bucket,
  required String path,
  bool upsert = false
}) async {
  await supabase.storage.from(bucket).upload(
    path,
    image,
    fileOptions:  FileOptions(cacheControl: 'no-store', upsert: upsert),
  );


  final String publicUrl = supabase
      .storage
      .from(bucket)
      .getPublicUrl(path);
  return publicUrl;
}

Future<String> updatedImages({
  required File image,
  required String bucket,
  required String path,
  bool upsert = false
}) async {
  await supabase.storage.from(bucket).upload(
    path,
    image,
    fileOptions:  FileOptions(cacheControl: 'no-store', upsert: upsert),
  );


  final String publicUrl = supabase
      .storage
      .from(bucket)
      .getPublicUrl(path);
  return publicUrl + "?ts=${DateTime.now().millisecondsSinceEpoch}";
}


Future<Map<int, T>> getMapData<T>({
  required String table,
  required T Function(Map<String, dynamic> json) fromJson,
  required int Function(T t) getID,
}) async{
  final supabase = Supabase.instance.client;
  var data = await supabase.from(table).select();
  var iterable = data.map((e) => fromJson(e),);
  Map<int, T> _map = Map.fromIterable(
    iterable,
    key: (t) => getID(t),
    value: (t) => t,
  );
  return _map;
}

ListenChangeDatalHelper<T>(
    Map<int, T> maps, {
      String schema = "public",
      Function()? updateUI,
      required String table,
      required String channel,
      required T Function(Map<String, dynamic> json) fromJson,
      required int Function(T t) getID,
      bool Function(T t)? filter,             // ← thêm filter
    }) {
  final client = Supabase.instance.client;
  return client
      .channel(channel)
      .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: schema,
    table: table,
    callback: (payload) {
      switch (payload.eventType) {
        case PostgresChangeEvent.insert:
        case PostgresChangeEvent.update:
          final newObj = fromJson(payload.newRecord!);
          // chỉ cập nhật nếu filter pass hoặc filter == null
          if (filter == null || filter(newObj)) {
            maps[getID(newObj)] = newObj;
            updateUI?.call();
          }
          break;
        case PostgresChangeEvent.delete:
          final oldObj = fromJson(payload.oldRecord!);
          if (filter == null || filter(oldObj)) {
            maps.remove(getID(oldObj));
            updateUI?.call();
          }
          break;
        default:
      }
    },
  )
      .subscribe();
}