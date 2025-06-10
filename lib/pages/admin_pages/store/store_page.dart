import 'package:flutter/material.dart';
import 'package:food_delivery/pages/admin_pages/store/store_update_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorePage extends StatefulWidget {
  StorePage({required this.storeId, super.key});
  final int storeId;

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
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
      appBar: AppBar(
        title: Text("Trang chủ cửa hàng"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => PageUpdateStore(
                        storeId: widget.storeId,
                      ), // Chuyển storeId khi cần
                ),
              );
            }, // Khi nhấn sẽ gọi hàm này
            tooltip: "Chỉnh sửa thông tin cửa hàng",
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _storeStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final storeList = snapshot.data!;
          if (storeList.isEmpty) {
            return Center(child: Text("Không tìm thấy cửa hàng"));
          }

          final store = storeList.first;

          // Hiển thị thông tin cửa hàng trực tiếp trong phần body
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị ảnh cửa hàng nếu có
                if (store['image_url'] != null &&
                    store['image_url'].toString().isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      store['image_url'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 16),

                // Tên cửa hàng
                Center(
                  child: Text(
                    store['name'] ?? 'Tên cửa hàng',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),

                // Địa chỉ cửa hàng
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        store['address'] ?? 'Địa chỉ không xác định',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Giờ mở cửa
                Row(
                  children: [
                    Icon(Icons.access_time, size: 22, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "Giờ mở cửa",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    Text(
                      store['open_time'] ?? '',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Giờ đóng cửa
                Row(
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      size: 22,
                      color: Colors.teal,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Giờ đóng cửa",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    Text(
                      store['close_time'] ?? '',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Thông tin Lat, Long và Hoa hồng shipper
                // Row(
                //   children: [
                //     Icon(Icons.location_on, size: 22, color: Colors.teal),
                //     SizedBox(width: 8),
                //     Text("Latitude", style: TextStyle(fontWeight: FontWeight.w500)),
                //     Spacer(),
                //     Text(store['latitude']?.toString() ?? 'Chưa có', style: TextStyle(color: Colors.black87)),
                //   ],
                // ),
                // SizedBox(height: 10),
                //
                // Row(
                //   children: [
                //     Icon(Icons.location_on, size: 22, color: Colors.teal),
                //     SizedBox(width: 8),
                //     Text("Longitude", style: TextStyle(fontWeight: FontWeight.w500)),
                //     Spacer(),
                //     Text(store['longitude']?.toString() ?? 'Chưa có', style: TextStyle(color: Colors.black87)),
                //   ],
                // ),
                // SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.money, size: 22, color: Colors.teal),
                    SizedBox(width: 8),
                    Text(
                      "Hoa hồng shipper",
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Spacer(),
                    Text(
                      store['shipper_commission']?.toString() ?? 'Chưa có',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
