import 'package:flutter/material.dart';

class EditGenderPage extends StatefulWidget {
  const EditGenderPage({super.key});

  @override
  State<EditGenderPage> createState() => _EditGenderPageState();
}

class _EditGenderPageState extends State<EditGenderPage> {
  String? _selectedGender;
  final Map<String, String> _uiToValue = {
    'Nam': 'male',
    'Nữ': 'female',
  };

  void _saveGender() {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giới tính')),
      );
      return;
    }
    final value = _uiToValue[_selectedGender]!;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thay đổi giới tính'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
        elevation: 1,
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
              'Chọn giới tính nếu bạn cần thay đổi',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              items: _uiToValue.keys.map((label) {
                return DropdownMenuItem<String>(
                  value: label,
                  child: Text(label),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              hint: const Text('Chọn Nam hoặc Nữ'),
              onChanged: (val) => setState(() => _selectedGender = val),
              validator: (val) {
                if (val == null) return 'Vui lòng chọn giới tính';
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveGender,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffef2b39),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
