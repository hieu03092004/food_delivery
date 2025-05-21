class Store {
  final int id;
  final String name;
  final String address;
  final String imageUrl;
  final String openTime;
  final String closeTime;
  final double latitude;
  final double longitude;
  final double shipperCommission;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.imageUrl,
    required this.openTime,
    required this.closeTime,
    required this.latitude,
    required this.longitude,
    required this.shipperCommission,
  });

  Map<String, dynamic> toMap() {
    return {
      'store_id': id,
      'name': name,
      'address': address,
      'image_url': imageUrl,
      'open_time': openTime,
      'close_time': closeTime,
      'latitude': latitude,
      'longitude': longitude,
      'shipper_commission': shipperCommission,
    };
  }

  factory Store.fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['store_id'] as int,
      name: map['name'] as String,
      address: map['address'] as String,
      imageUrl: map['image_url'] ?? '',
      openTime: map['open_time'] ?? '',
      closeTime: map['close_time'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      shipperCommission: (map['shipper_commission'] ?? 0).toDouble(),
    );
  }
}
