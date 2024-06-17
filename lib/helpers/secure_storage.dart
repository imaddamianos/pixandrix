import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pixandrix/models/owner_model.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

 
  Future<void> saveOwnerInfo(OwnerData? ownerInfo) async {
    if (ownerInfo != null) {
      await _storage.write(key: 'ownerInfo', value: jsonEncode(ownerInfo.toJson()));
    }
  }
 Future<OwnerData?> getOwnerInfo() async {
    String? ownerData = await _storage.read(key: 'ownerInfo');
    if (ownerData != null) {
      return OwnerData.fromJson(jsonDecode(ownerData));
    }
    return null;
  }

  Future<void> deleteOwnerInfo() async {
    await _storage.delete(key: 'ownerInfo');
  }

  Future<void> saveOwner(String? name, String? password)async {
    _storage.write(key: 'ownerName', value: name ?? '');
    _storage.write(key: 'ownerPassword', value: password ?? '');
  }

  Future<void> saveDriver(String? name, String? password) async {
    await _storage.write(key: 'driverName', value: name ?? '');
    await _storage.write(key: 'driverPassword', value: password ?? '');
  }

  Future<void> saveAdmin(String? password) async {
    await _storage.write(key: 'adminPassword', value: password ?? '');
  }

  Future<void> clearEmailAndPassword() async {
    await _storage.delete(key: 'ownerName');
    await _storage.delete(key: 'ownerPassword');
    await _storage.delete(key: 'driverName');
    await _storage.delete(key: 'driverPassword');
    await _storage.delete(key: 'adminPassword');
  }

  Future <String?> getOnwer() async {
    return await _storage.read(key: 'ownerName');
  }

  Future<String?> getDriver() async {
  return await _storage.read(key: 'driverName');
  }

  Future<String?> getOwnerPassword() async {
    return await _storage.read(key: 'ownerPassword');
  }

  Future<String?> getDriverPassword() async {
    return await _storage.read(key: 'driverPassword');
  }

  Future<String?> getAdminPassword() async {
    return await _storage.read(key: 'adminPassword');
  }

 Future<void> setAutoLoginStatus(bool isLoggedOut, String role) async {
  await _storage.write(key: 'islogout', value: isLoggedOut.toString());
  await _storage.write(key: 'role', value: role);
}

Future<String?> getLogoutStatus() async {
 return await _storage.read(key: 'islogout');
}

Future<String?> getAutoLoginRole() async {
 return await _storage.read(key: 'role');
}
}
