 import 'package:food_delivery/helpers/supabase_helper.dart';
import 'package:food_delivery/model/customer_model/product_model.dart';
import 'package:food_delivery/model/customer_model/store_model.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


 class ControllerStore extends GetxController {
   final _map = <int, Store>{};
   bool isLoading = true;          // ← mới
   String? loadError;
   /// Dùng khi cần lấy list ra UI
   Iterable<Store> get stores => _map.values;

   static ControllerStore get to => Get.find();

   RealtimeChannel? _sub;

   @override
   void onReady() async {
     super.onReady();
     // 1) load initial

     try {
       isLoading = true;
       update(['loading']); // trigger UI show spinner
       final m = await StoreSnapshot.getMapStores();
       _map
         ..clear()
         ..addAll(m);
     } catch (e) {
       loadError = e.toString();
     } finally {
       isLoading = false;
       update(['loading', 'stores']); // trigger UI ẩn spinner & render
     }


     // 2) realtime listen
     _sub = StoreSnapshot.ListenChangeData(
       _map,
       updateUI: () => update(['stores']),
     );
   }

   @override
   void onClose() {
     super.onClose();
     // hủy subscription
     _sub?.unsubscribe();
   }
 }

