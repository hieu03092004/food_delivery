import 'package:food_delivery/helpers/supabase_helper.dart';

class Store {
  final int id;
  final String name;
  final String address;
  final String imageURL;
  final String openTime;
  final String closedTime;
  final double shipperCommission;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.imageURL,
    required this.openTime,
    required this.closedTime,
    required this.shipperCommission
  });

  factory Store.fromJson(Map<String,dynamic> json) {
    return Store(
      id: json['store_id'] is String ? int.parse(json['store_id']) : json['store_id'],
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      imageURL: json['image_url'] as String? ?? '',
      openTime: json['open_time'] as String? ?? '',
      closedTime: json['close_time'] as String? ?? '',
      shipperCommission: json['shipper_commission'] is String
          ? double.parse(json['shipper_commission'])
          : (json['shipper_commission'] as num).toDouble(),
    );
  }
}
class StoreSnapshot{
  static Future<Map<int, Store>> getMapStores() {
    return getMapData<Store>(
      table: 'store',
      fromJson: (json) => Store.fromJson(json),
      getID: (store) => store.id,
    );
  }
  static ListenChangeData(Map<int, Store> maps,{Function()? updateUI}){
    return ListenChangeDatalHelper(
      maps,
      table: "store",
      channel: "public:store",
      fromJson: (json) => Store.fromJson(json),
      getID: (t) => t.id,
    );
  }
}