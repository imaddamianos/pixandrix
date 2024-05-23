class OwnerData {
  String name;
  String phoneNumber;
  String ownerImage;
  String password;
  double latitude;
  double longitude;
  String rate;
  bool verified;
  bool isAvailable;

  OwnerData({
    required this.name,
    required this.phoneNumber,
    required this.ownerImage,
    required this.latitude,
    required this.longitude,
    required this.rate,
    required this.password,
    required this.verified,
    required this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    return {
      'ownerID': name,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'phoneNumber': phoneNumber,
      'ownerImage': ownerImage,
      'rate': rate,
      'password': password,
      'verified': verified,
      'isAvailable': isAvailable,
    };
  }

  // Convert a Map into a OwnerData object
  static OwnerData fromJson(Map<String, dynamic> json) {
    return OwnerData(
      name: json['ownerID'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phoneNumber: json['phoneNumber'],
      ownerImage: json['ownerImage'],
      rate: json['rate'],
      password: json['password'],
      verified: json['verified'],
      isAvailable: json['isAvailable'],
    );
  }
}


