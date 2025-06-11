import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<void> deleteImage({required String bucket, required String path}) async {
  await supabase
      .storage
      .from(bucket)
      .remove([path]);
}

Future<String> uploadImage({
  required File image,
  required String bucket,
  required String path,
  bool upsert = false
}) async{
  final String fullPath = await supabase.storage.from(bucket).upload(
    path,
    image,
    fileOptions: FileOptions(cacheControl: '3600', upsert: upsert),
  );
  final String publicUrl = supabase
      .storage
      .from(bucket)
      .getPublicUrl(path);
  return publicUrl;
}

Future<String> updateImage({
  required File image,
  required String bucket,
  required String path,
  bool upsert = false
}) async{
  final String fullPath = await supabase.storage.from(bucket).update(
    path,
    image,
    fileOptions: FileOptions(cacheControl: '3600', upsert: upsert),
  );
  final String publicUrl = supabase
      .storage
      .from(bucket)
      .getPublicUrl(path);
  return publicUrl + "?ts=${DateTime.now().microsecond}";
}

Future<Map<int, T>> getMapData<T>({
  required String table,
  required T Function(Map<String, dynamic> json) fromJson,
  required int Function(T t) getID
}) async{
  Map<int, T> _map = {};
  var data = await supabase.from(table).select();
  var iterable = data.map((e) => fromJson(e),);

  _map = Map.fromIterable(
    iterable,
    key: (t) => getID(t),
    value: (t) => t,
  );
  return _map;
}

Stream<List<T>> getDataStream<T>({
  required String table,
  required List<String> ids,
  required T Function(Map<String, dynamic> json) fromJson
}){
  var stream = supabase.from(table).stream(primaryKey: ids);
  return stream.map((maps) => maps.map(
        (e) => fromJson(e),
  ).toList());
}

listenDataChangeHelper<T>(Map<int, T> maps, {
  required String table,
  required String channel,
  String? schema = "public",
  required T Function(Map<String, dynamic> json) fromJson,
  required int Function(T t) getID,
  Function()? updateUI,
}){
  supabase
      .channel(channel)
      .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: schema,
      table: table,
      callback: (payload) {
        print('Change received: ${payload.toString()}');
        switch(payload.eventType){
          case PostgresChangeEvent.insert:
          case PostgresChangeEvent.update:{
            T t = fromJson(payload.newRecord);
            maps[getID(t)] = t;
            updateUI?.call();
            break;
          }
          case PostgresChangeEvent.delete: {
            maps.remove(payload.oldRecord["id"]);
            updateUI?.call();
            break;
          }
          default: {}
        }
      })
      .subscribe();

}