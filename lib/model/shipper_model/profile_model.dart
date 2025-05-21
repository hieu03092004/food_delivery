class ProfileModel {
  final int accountId;
  final String? fullName;
  final String email;
  final String? avatarUrl;
  final String? address;
  final String status;
  final int? storeId;
  final double? latitude;
  final double? longitude;
  String? phoneNumber;
  String? gender;
  DateTime? dateOfBirth;

  ProfileModel({
    required this.accountId,
    this.fullName,
    required this.email,
    this.avatarUrl,
    this.address,
    required this.status,
    this.storeId,
    this.latitude,
    this.longitude,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      accountId: json['account_id'] as int,
      fullName: json['full_name'] as String?,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] as String?,
      status: (json['status'] as String?) ?? 'active',
      storeId: json['store_id'] as int?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phoneNumber: json['phone_number'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.tryParse(json['date_of_birth'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account_id': accountId,
      'full_name': fullName,
      'email': email,
      'avatar_url': avatarUrl,
      'address': address,
      'status': status,
      'store_id': storeId,
      'latitude': latitude,
      'longitude': longitude,
      'phone_number': phoneNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
    };
  }
}

