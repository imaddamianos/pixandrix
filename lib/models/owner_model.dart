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
}
