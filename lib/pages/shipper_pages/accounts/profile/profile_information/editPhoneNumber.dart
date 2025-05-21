import 'package:flutter/material.dart';

class EditPhonePage extends StatefulWidget {
  const EditPhonePage({super.key});

  @override
  State<EditPhonePage> createState() => _EditPhonePageState();
}

class _EditPhonePageState extends State<EditPhonePage> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _savePhone() {
    final newPhone = _phoneController.text.trim();
    // Validate không được để trống và phải đúng định dạng đơn giản
    if (!_formKey.currentState!.validate()) return;

    // TODO: Gọi API cập nhật số điện thoại tại đây nếu cần
    print('📱 Số điện thoại mới: $newPhone');

    Navigator.pop(context, newPhone);
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    // Ví dụ: kiểm tra còn chỉ gồm chữ số, độ dài 9–15
    final phone = value.trim();
    final regex = RegExp(r'^\+?[0-9]{9,15}$');
    if (!regex.hasMatch(phone)) {
      return 'Định dạng số điện thoại không hợp lệ';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thay đổi số điện thoại"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hãy nhập số điện thoại của bạn khi có nhu cầu thay đổi số điện thoại của mình",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  prefixIcon: const Icon(Icons.phone_android),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: _validatePhone,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _savePhone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffef2b39),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Lưu",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
