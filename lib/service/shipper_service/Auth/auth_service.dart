import 'package:get/get.dart';

class AuthService extends GetxService {
  final accountId = 0.obs;

  Future<void> initialize() async {
    // TODO: Implement actual authentication logic
    // For now, we'll just set a default account ID
    accountId.value = 2;
  }

  @override
  void onClose() {
    accountId.close();
    super.onClose();
  }
}
