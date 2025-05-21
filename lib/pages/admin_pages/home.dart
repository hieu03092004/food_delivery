import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_delivery/pages/admin_pages/supabase_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../permission/permission_helper.dart';

class HomePages extends StatefulWidget {
  final int storeId;
  const HomePages({required this.storeId, Key? key});

  @override
  State<HomePages> createState() => _HomePagesState();
}

class _HomePagesState extends State<HomePages> {
  late final Stream<List<Map<String, dynamic>>> _storeStream;

  @override
  void initState() {
    super.initState();
    _storeStream = Supabase.instance.client
        .from('store')
        .stream(primaryKey: ['store_id'])
        .eq('store_id', widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _storeStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final storeList = snapshot.data!;
          if (storeList.isEmpty) return const Center(child: Text("Không tìm thấy cửa hàng"));

          final store = storeList.first;

          return Scaffold(
            appBar: AppBar(
              title: const Text("Trang chủ cửa hàng"),
              backgroundColor: Colors.teal,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditDialog(context, store),
                )
              ],
            ),
            body: _buildStoreDetails(store),
          );
        },
      ),
    );
  }

  //phần body
  Widget _buildStoreDetails(Map<String, dynamic> store) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (store['image_url'] != null && store['image_url'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                store['image_url'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                store['name'] ?? 'Tên cửa hàng',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      store['address'] ?? 'Địa chỉ không xác định',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 32),
          _infoRow(Icons.access_time, "Giờ mở cửa", store['open_time'] ?? ''),
          const SizedBox(height: 10),
          _infoRow(Icons.access_time_filled, "Giờ đóng cửa", store['close_time'] ?? ''),
        ],
      ),
    );
  }

  //hiển thị thông tin giờ đóng/mở cửa
  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 22, color: Colors.teal),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }

  //hiển thị dialog chỉnh sửa thông tin
  void _showEditDialog(BuildContext context, Map<String, dynamic> storeData) {
    final nameController = TextEditingController(text: storeData['name']);
    final addressController = TextEditingController(text: storeData['address']);
    final openTimeController = TextEditingController(text: storeData['open_time']);
    final closeTimeController = TextEditingController(text: storeData['close_time']);
    final latitudeController = TextEditingController(text: storeData['latitude']?.toString() ?? '');
    final longitudeController = TextEditingController(text: storeData['longitude']?.toString() ?? '');
    final commissionController = TextEditingController(text: storeData['shipper_commission']?.toString() ?? '');

    XFile? _xFile;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Chỉnh sửa thông tin cửa hàng"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Hiển thị ảnh
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: _xFile == null
                      ? (storeData['image_url'] != null
                      ? Image.network(storeData['image_url'], fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 60))
                      : Image.file(File(_xFile!.path), fit: BoxFit.cover),
                ),
                TextButton.icon(
                  onPressed: () async {
                    var hasPermission = await requestPermission(Permission.photos);
                    if (hasPermission) {
                      var picked = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setState(() {
                          _xFile = picked;
                        });
                      }
                    }
                  },
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Chọn ảnh"),
                ),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Tên cửa hàng")),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: "Địa chỉ")),
                TextField(controller: openTimeController, decoration: const InputDecoration(labelText: "Giờ mở cửa")),
                TextField(controller: closeTimeController, decoration: const InputDecoration(labelText: "Giờ đóng cửa")),
                TextField(controller: latitudeController, decoration: const InputDecoration(labelText: "Latitude"), keyboardType: TextInputType.number),
                TextField(controller: longitudeController, decoration: const InputDecoration(labelText: "Longitude"), keyboardType: TextInputType.number),
                TextField(controller: commissionController, decoration: const InputDecoration(labelText: "Hoa hồng shipper"), keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(child: const Text("Hủy"), onPressed: () => Navigator.pop(context)),
            ElevatedButton(
              child: const Text("Lưu"),
                onPressed: () async {
                  Navigator.pop(context); // Đóng dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đang cập nhật...")),
                  );

                  String finalImageUrl = storeData['image_url'] ?? '';

                  if (_xFile != null) {
                    final file = File(_xFile!.path);
                    finalImageUrl = await uploadImage(
                      image: file,
                      bucket: 'images',
                      path: 'store_image/store_${storeData['store_id']}.jpg',
                      upsert: true, // Ghi đè nếu đã tồn tại
                    );
                  }

                  await Supabase.instance.client.from('store').update({
                    'name': nameController.text,
                    'address': addressController.text,
                    'image_url': finalImageUrl,
                    'open_time': openTimeController.text,
                    'close_time': closeTimeController.text,
                    'latitude': double.tryParse(latitudeController.text),
                    'longitude': double.tryParse(longitudeController.text),
                    'shipper_commission': double.tryParse(commissionController.text),
                  }).eq('store_id', storeData['store_id']);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Đã cập nhật cửa hàng")),
                  );
                }

            ),
          ],
        ),
      ),
    );
  }

}
