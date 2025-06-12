import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_delivery/model/admin_model/store_model.dart';
import 'package:food_delivery/pages/admin_pages/store/store_update_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorePage extends StatefulWidget {
  final int storeId;
  StorePage({required this.storeId, Key? key}) : super(key: key);

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  Future<Store?>? _storeFuture;

  @override
  void initState() {
    super.initState();
    _storeFuture = _fetchStore();
  }

  void _loadStore() {
    _storeFuture = _fetchStore();
  }

  Future<Store?> _fetchStore() async {
    final response = await Supabase.instance.client
        .from('store')
        .select()
        .eq('store_id', widget.storeId)
        .maybeSingle();

    print('DEBUG: Response from supabase: $response');
    if (response == null) return null;

    return Store.fromMap(response as Map<String, dynamic>);
  }

  Future<void> _navigateToUpdatePage() async {
    // Giả sử trang update trả về true nếu cập nhật thành công
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PageUpdateStore(storeId: widget.storeId),
      ),
    );

    if (updated == true) {
      // Reload dữ liệu nếu có cập nhật
      setState(() {
        _loadStore();
      });
    }
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
            tooltip: "Chỉnh sửa thông tin cửa hàng",
            onPressed: _navigateToUpdatePage,
          ),
        ],
      ),
      body: FutureBuilder<Store?>(
        future: _storeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("Không tìm thấy cửa hàng"));
          }

          final store = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (store.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      store.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 16),
                Center(
                  child: Text(
                    store.name,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        store.address,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 22, color: Colors.teal),
                    SizedBox(width: 8),
                    Text("Giờ mở cửa", style: TextStyle(fontWeight: FontWeight.w500)),
                    Spacer(),
                    Text(store.openTime, style: TextStyle(color: Colors.black87)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.access_time_filled, size: 22, color: Colors.teal),
                    SizedBox(width: 8),
                    Text("Giờ đóng cửa", style: TextStyle(fontWeight: FontWeight.w500)),
                    Spacer(),
                    Text(store.closeTime, style: TextStyle(color: Colors.black87)),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.money, size: 22, color: Colors.teal),
                    SizedBox(width: 8),
                    Text("Hoa hồng shipper", style: TextStyle(fontWeight: FontWeight.w500)),
                    Spacer(),
                    Text(store.shipperCommission.toString(), style: TextStyle(color: Colors.black87)),
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
