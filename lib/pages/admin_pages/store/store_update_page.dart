import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../permission/permission_helper.dart';
import '../supabase_helper.dart';

class PageUpdateStore extends StatefulWidget {
  PageUpdateStore({super.key, required this.storeId});
  final int storeId;

  @override
  State<PageUpdateStore> createState() => _PageUpdateStoreState();
}

class _PageUpdateStoreState extends State<PageUpdateStore> {
  final txtName = TextEditingController();
  final txtAddress = TextEditingController();
  final txtOpenTime = TextEditingController();
  final txtCloseTime = TextEditingController();
  final txtCommission = TextEditingController();

  Map<String, dynamic>? storeData;
  XFile? _xFile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final response = await Supabase.instance.client
        .from('store')
        .select()
        .eq('store_id', widget.storeId)
        .maybeSingle();

    if (response != null) {
      storeData = response;
      txtName.text = storeData!['name'] ?? '';
      txtAddress.text = storeData!['address'] ?? '';
      txtOpenTime.text = storeData!['open_time'] ?? '';
      txtCloseTime.text = storeData!['close_time'] ?? '';
      txtCommission.text = storeData!['shipper_commission']?.toString() ?? '';
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (isLoading) {
    //   return Scaffold(body: Center(child: CircularProgressIndicator()));
    // }
    final imageUrl = storeData?['image_url'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text("Cập nhật cửa hàng")
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _xFile != null
                  ? Image.file(File(_xFile!.path), fit: BoxFit.cover)
                  : imageUrl.isNotEmpty
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Icon(Icons.image, size: 80, color: Colors.grey),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final hasPermission = await requestPermission(Permission.photos);
                    if (hasPermission) {
                      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() {
                          _xFile = picked;
                        });
                      }
                    }
                  },
                  child: Text("Chọn ảnh"),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextFormField(controller: txtName, decoration: InputDecoration(labelText: "Tên cửa hàng", border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextFormField(controller: txtAddress, decoration: InputDecoration(labelText: "Địa chỉ", border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextFormField(controller: txtOpenTime, decoration: InputDecoration(labelText: "Giờ mở cửa", border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextFormField(controller: txtCloseTime, decoration: InputDecoration(labelText: "Giờ đóng cửa", border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextFormField(controller: txtCommission, decoration: InputDecoration(labelText: "Hoa hồng shipper", border: OutlineInputBorder()), keyboardType: TextInputType.number),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String finalImageUrl = imageUrl;

                if (_xFile != null) {
                  final file = File(_xFile!.path);
                  finalImageUrl = await updateImage(
                    image: file,
                    bucket: 'images',
                    path: 'store_image/store_${widget.storeId}.jpg',
                    upsert: true,
                  );
                }

                await Supabase.instance.client.from('store').update({
                  'name': txtName.text,
                  'address': txtAddress.text,
                  'open_time': txtOpenTime.text,
                  'close_time': txtCloseTime.text,
                  // 'latitude': double.tryParse(txtLatitude.text),
                  // 'longitude': double.tryParse(txtLongitude.text),
                  'shipper_commission': double.tryParse(txtCommission.text),
                  'image_url': finalImageUrl,
                }).eq('store_id', widget.storeId);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã cập nhật cửa hàng")),
                );
                Navigator.pop(context, true);
              },
              child: Text("Cập nhật"),
            )
          ],
        ),
      ),
    );
  }
}
