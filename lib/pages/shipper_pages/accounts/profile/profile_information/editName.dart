import 'package:flutter/material.dart';


class EditNamePage extends StatefulWidget {
  const EditNamePage({super.key});

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  final TextEditingController _nameController = TextEditingController();
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveName() async{
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên không được để trống')),
      );
      return;
    }
    // TODO: Gửi name mới lên Supabase ở đây
    print('📝 Tên mới: $newName');
    Navigator.pop(context, newName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thay đổi tên"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sử dụng tên thật của bạn giúp quá trình xác thực diễn ra dễ dàng hơn.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffef2b39), // Màu xanh nút Save
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Lưu", style: TextStyle(fontSize: 16,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

