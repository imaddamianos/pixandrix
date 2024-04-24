class OwnerData {
  String name;
  String phoneNumber;
  String location;
  String ownerImage;
  double? latitude;
  double? longitude;

  OwnerData({
    required this.name,
    required this.phoneNumber,
    required this.location,
    required this.ownerImage,
    this.latitude,
    this.longitude,
  });
}
