
import 'package:food_delivery/model/customer_model/product_model.dart';
import 'package:get/get.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class ControllerProduct extends GetxController {
  final int storeId;
  final _map = <int, Product>{};
  bool isLoading = true; // ← mới
  String? loadError;

  Iterable<Product> get products => _map.values;

  static ControllerProduct of(int storeId) {
    return Get.put(ControllerProduct(storeId: storeId), tag: '$storeId');
  }

  static ControllerProduct find(int storeId) {
    return Get.find(tag: '$storeId');
  }

  RealtimeChannel? _sub;

  ControllerProduct({ required this.storeId });

  @override
  void onReady() async {
    super.onReady();

    // 1) Load initial data - CẦN rebuild
    try {
      isLoading = true;
      update(); // rebuild để show loading

      final m = await ProductSnapShot.getMapProductsByStore(storeId);
      _map
        ..clear()
        ..addAll(m);
    } catch (e) {
      loadError = e.toString();
    } finally {
      isLoading = false;
      update(); // rebuild để show data
    }

    // 2) Listen realtime changes từ restaurant - CẦN rebuild
    _sub = ProductSnapShot.listenProductChangesByStore(
      _map,
      storeId,
      updateUI: () {
        // CHỈ rebuild khi restaurant thực sự thay đổi data
        print('Restaurant updated products, rebuilding UI...');
        update();
      },
    );

    @override
    void onClose() {
      super.onClose();
      _sub?.unsubscribe();
    }
  }
}