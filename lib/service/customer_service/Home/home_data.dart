 import 'package:food_delivery/helpers/supabase_helper.dart';
import 'package:food_delivery/model/customer_model/product_model.dart';
import 'package:food_delivery/model/customer_model/store_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class HomeData{
  Stream<List<Store>> getDataHomeStream(){
    return getDataStream(
      table: "store",
      ids: ["store_id"],
      fromJson: (json) => Store.fromJson(json),);
  }

  Stream<List<Product>> getDataProductsByStore(int storeId) {
    return Supabase.instance.client
        .from('product')
        .select('''
        *,
        store:store_id (
          store_id,
          name,
          address,
          image_url,
          open_time,
          close_time,
          shipper_commission
        )
      ''')
        .eq('store_id', storeId)
        .then((response) {
      return (response as List)
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .where((p) => p.isDeleted == false)
          .toList();
    })
        .asStream();
  }
}
