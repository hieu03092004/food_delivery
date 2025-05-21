import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditDateOfBirthPage extends StatefulWidget {
  const EditDateOfBirthPage({super.key});

  @override
  State<EditDateOfBirthPage> createState() => _EditDateOfBirthPageState();
}

class _EditDateOfBirthPageState extends State<EditDateOfBirthPage> {
  DateTime? _selectedDate;
  final DateFormat _formatter = DateFormat('dd/MM/yyyy');

  void _pickDate() async {
    final today = DateTime.now();
    final initial = _selectedDate ?? DateTime(today.year - 20);
    final firstDate = DateTime(1900);
    final lastDate = today;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Chọn ngày sinh',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveDate() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày sinh')),
      );
      return;
    }
    Navigator.pop(context, _selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ngày sinh'),
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
              'Chọn ngày sinh của bạn',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelText: 'Ngày sinh',
                ),
                child: Text(
                  _selectedDate != null
                      ? _formatter.format(_selectedDate!)
                      : 'Chưa chọn',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveDate,
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
