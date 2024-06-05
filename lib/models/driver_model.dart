class DriverData {
  final String name;
  final String password;
  final String phoneNumber;
  final String driverImage;
  final String driverID;
  bool verified;
  bool isAvailable;

  DriverData({
    required this.name,
    required this.password,
    required this.phoneNumber,
    required this.driverImage,
    required this.driverID,
    required this.verified,
    required this.isAvailable,
  });
}
