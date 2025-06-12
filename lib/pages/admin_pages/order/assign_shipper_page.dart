import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class AssignShipperPage extends StatelessWidget {
  const AssignShipperPage({
    super.key,
    required this.storeId,
    required this.orderId,
  });
  final int storeId;
  final int orderId;

  Future<List<dynamic>> _fetchShippers() async {
    final response = await Supabase.instance.client
        .from('shipper_assignment')
        .select('shipper_id, account(full_name, avatar_url)')
        .eq('store_id', storeId);

    return response as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Phân công shipper")),
      body: FutureBuilder<List<dynamic>>(
        future: _fetchShippers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Không có shipper nào khả dụng.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final shipperList = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: shipperList.length,
            separatorBuilder: (_, __) => SizedBox(height: 12),
            itemBuilder: (context, index) {
              final shipper = shipperList[index];
              final account = shipper['account'];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        account['avatar_url'] != null &&
                                account['avatar_url'].toString().isNotEmpty
                            ? NetworkImage(account['avatar_url'])
                            : null,
                    child:
                        account['avatar_url'] == null ||
                                account['avatar_url'].toString().isEmpty
                            ? Text(
                              account['full_name']
                                  .toString()
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),

                  title: Text(
                    account['full_name'],
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios_rounded, size: 18),
                  onTap: () async {
                    await Supabase.instance.client
                        .from('orders')
                        .update({
                          'shipper_id': shipper['shipper_id'],
                          'status': 'order_received',
                        })
                        .eq('order_id', orderId);

                    final int receptionId = shipper['shipper_id'] as int;

                    final tokenRes =
                        await Supabase.instance.client
                            .from('account')
                            .select('tokendevice')
                            .eq('account_id', receptionId)
                            .single();
                    final String? deviceToken =
                        tokenRes['tokendevice'] as String?;

                    String titleNotifications = 'Đơn hàng mới';
                    String content =
                        'Bạn có 1 đơn hàng mới với mã vận đơn $orderId';
                    await Supabase.instance.client.from('notification').insert({
                      'recipient_id': receptionId,
                      'order_id': orderId,
                      'message': content,
                      'title': titleNotifications,
                    });
                    try {
                      print(content);
                      final response = await http.post(
                        Uri.parse(
                          'https://flutter-notifications.vercel.app/send',
                        ), // Thêm cổng 3000
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'deviceToken': deviceToken,
                          'title': 'Đơn hàng mới',
                          'body': content,
                        }),
                      );
                      print(response);
                      // Kiểm tra trạng thái HTTP response
                      if (response.statusCode >= 200 &&
                          response.statusCode < 300) {
                        // Thành công - mã trạng thái 2xx
                        print('Gửi FCM thành công: ${response.body}');

                        // Nếu cần phân tích thêm nội dung phản hồi JSON
                        try {
                          final responseData = jsonDecode(response.body);
                          // Xử lý dữ liệu phản hồi nếu cần
                          print('Chi tiết phản hồi: $responseData');
                        } catch (jsonError) {
                          print('Lỗi phân tích JSON phản hồi: $jsonError');
                        }
                      } else {
                        // Thất bại - mã trạng thái không phải 2xx
                        print(
                          'Gửi FCM thất bại: ${response.statusCode} - ${response.body}',
                        );
                      }
                    } catch (httpError) {
                      // Bắt lỗi khi gửi request HTTP (lỗi kết nối, timeout, v.v.)
                      print('Lỗi kết nối khi gửi FCM: $httpError');
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Đã phân công đơn cho shipper"),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      Navigator.pop(context, true);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
