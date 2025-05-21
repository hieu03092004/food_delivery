import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/profile/profile_information/editDateOfBirthPage.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/profile/profile_information/editGender.dart';
import 'package:food_delivery/pages/shipper_pages/accounts/profile/profile_information/editPhoneNumber.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../model/shipper_model/profile_model.dart';
import '../../../../../service/shipper_service/Profile/profile_data.dart';
import '../../../../authentication/authenticaion_state/authenticationCubit.dart';
import 'editEmail.dart';
import 'editName.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late Future<ProfileModel> _profileFuture;
  final ProfileService _service = ProfileService();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedFile;
  String? _uploadedImageUrl;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthenticationCubit>().state;
    final int userId = authState.user!.uid;  // chắc chắn không null
    _profileFuture = _service.getProfile(userId);
  }
  Future<void> _navigateByLabel(BuildContext context, String label) async {
    // Lấy userId
    final authState = context.read<AuthenticationCubit>().state;
    final int userId = authState.user!.uid;

    if (label == 'Tên') {
      // 1) Push sang trang edit và chờ tên mới trả về
      final String? newName = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const EditNamePage()),
      );

      // 2) Nếu người dùng bấm Save (newName != null), update Supabase và reload
      if (newName != null && newName.isNotEmpty) {
        final ok = await _service.updateProfileField(
          accountId: userId,
          name: 'full_name',
          value: newName,
        );
        if (ok) {
          setState(() {
            // Ép FutureBuilder chạy lại
            _profileFuture = _service.getProfile(userId);
          });
        }
      }
      return;
    }

    if (label == 'Email') {
      final String? newEmail = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const EditEmailPage()),
      );
      if (newEmail != null && newEmail.isNotEmpty) {
        final ok = await _service.updateProfileField(
          accountId: userId,
          name: 'email',
          value: newEmail,
        );
        if (ok) {
          setState(() {
            _profileFuture = _service.getProfile(userId);
          });
        }
      }
      return;
    }
    if (label == 'Số điện thoại') {
      final String? newPhone = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const EditPhonePage()),
      );
      if (newPhone != null && newPhone.isNotEmpty) {
        final ok = await _service.updateProfileField(
          accountId: userId,
          name: 'phone_number',
          value: newPhone,
        );
        if (ok) {
          setState(() {
            _profileFuture = _service.getProfile(userId);
          });
        }
      }
      return;
    }
    if (label == 'Giới tính') {
      final String? newGender = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const EditGenderPage()),
      );
      if (newGender != null && newGender.isNotEmpty) {
        final ok = await _service.updateProfileField(
          accountId: userId,
          name: 'gender',
          value: newGender,
        );
        if (ok) {
          setState(() {
            _profileFuture = _service.getProfile(userId);
          });
        }
      }
      return;
    }
    //
    if (label == 'Ngày sinh') {
      final DateTime? newDob = await Navigator.push<DateTime?>(
        context,
        MaterialPageRoute(builder: (_) => const EditDateOfBirthPage()),
      );
      if (newDob != null) {
        final ok = await _service.updateProfileField(
          accountId: userId,
          name: 'date_of_birth',
          value: newDob.toIso8601String(),
        );
        if (ok) {
          setState(() {
            _profileFuture = _service.getProfile(userId);
          });
        }
      }
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => Scaffold(
        appBar: AppBar(title: Text(label)),
        body: Center(child: Text('Chưa có trang cho "$label"')),
      )),
    );
  }

    // các label khác nếu cần...

    // Mặc định: push page trống


  Future<void> _pickAndUploadImage() async {
    print('⏳ Bắt đầu chọn ảnh...');
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 600,
    );
    if (picked == null) {
      print('❌ Người dùng đã huỷ chọn ảnh.');
      return;
    }

    print('✅ Đã chọn ảnh: ${picked.path}');
    setState(() {
      _pickedFile = picked;
      _uploading = true;
    });

    final authState = context.read<AuthenticationCubit>().state;
    final int? userId = authState.user?.uid;
    if (userId == null) {
      print('❌ Không tìm thấy userId, abort.');
      setState(() => _uploading = false);
      return;
    }

    try {
      // Tạo tên file duy nhất
      final String path = "users/user_${userId}.jpg";

      // Gọi thẳng hàm updateImage đã có, upsert = true để ghi đè
      final String publicUrl = await _service.updateImage(
        image: File(picked.path),
        bucket: 'images',
        path: path,
        upsert: true,
      );

      print('🌐 Public URL: $publicUrl');

      // Update vào bảng account
      final response = await Supabase.instance.client
          .from('account')
          .update({'avatar_url': publicUrl})
          .eq('account_id', userId)
          .select()
          .single();

      if (response != null) {
        print('✅ Cập nhật avatar_url thành công');
        setState(() {
          _uploadedImageUrl = publicUrl;
        });
      }
    } catch (e) {
      print('❌ Lỗi trong quá trình upload hoặc update: $e');
    } finally {
      setState(() => _uploading = false);
    }
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget buildInfoTile(BuildContext context, String label, String value) {
    return InkWell(
      onTap: () => _navigateByLabel(context, label),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(width: 20),
            Text(value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarProvider;
    if (_pickedFile != null) {
      avatarProvider = FileImage(File(_pickedFile!.path));
    } else {
      avatarProvider = const AssetImage('assets/avatar.png');
    }
    return  Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa trang cá nhân'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay về màn hình trước
          },
        ),
      ),
      body: FutureBuilder<ProfileModel>(
        future: _profileFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final p = snap.data!;
          // avatar
          final ImageProvider avatarProvider =
          _uploadedImageUrl != null
              ? NetworkImage(_uploadedImageUrl!)
              : (p.avatarUrl != null
              ? NetworkImage(p.avatarUrl!)
              : const AssetImage('assets/avatar.png'))
          as ImageProvider;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarProvider,
                  ),
                ),
                const SizedBox(height: 8),
                Center(child: TextButton(
                  onPressed: () => _pickAndUploadImage(),
                  child: const Text('Thay đổi avatar', style: TextStyle(color: Color(0xffef2b39))),
                )),
                const Divider(),
                // Profile Information
                buildSectionTitle('Thông tin tài khoản'),
                buildInfoTile(context,'Tên', p.fullName ?? '—'),
                const Divider(),
                // Personal Information
                buildSectionTitle('Thông tin cá nhân'),
                buildInfoTile(context,'Email', p.email),
                buildInfoTile(context,'Số điện thoại',p.phoneNumber?? ''),
                buildInfoTile(context,'Giới tính', p.gender == null
                    ? 'Chưa có'
                    : (p.gender == 'male' ? 'Nam' : 'Nữ')),
                buildInfoTile(context,'Ngày sinh', p.dateOfBirth == null ? '' : p.dateOfBirth!.toLocal().toString().split(' ')[0],),
                const Divider(),
                Center(
                  child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Đóng',style: TextStyle(color: Color(0xffef2b39)),)),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}