import 'package:get/get.dart';

import '../../../model/shipper_model/income_model.dart';

class RevenueController extends GetxController {
  final _model = IncomeModel();
  final orders = <OrderShipping>[].obs;
  final isLoading = false.obs;
  final selectedDate = DateTime.now().obs;

  Future<void> loadOrders(int shipperId) async {
    try {
      isLoading.value = true;
      final result = await _model.getOrdersByDate(
        shipperId: shipperId,
        date: selectedDate.value,
      );
      orders.value = result;
    } finally {
      isLoading.value = false;
    }
  }

  void updateDate(DateTime date) {
    selectedDate.value = date;
  }
}
