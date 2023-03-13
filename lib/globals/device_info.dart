import 'package:flutter/services.dart';
// import 'package:get_mac_address/get_mac_address.dart';
import 'package:platform_device_id/platform_device_id.dart';

class MyDeviceInfo {
  // static final GetMacAddress _getMacAddressPlugin = GetMacAddress();
  Future<String?> getMacAddress() async {
    try {
      return null;
      // return await _getMacAddressPlugin.getMacAddress();
    } on PlatformException {
      print("UNABLE TO GET MAC ADDRESS");
      return null;
    } catch (e, s) {
      print("ERROR : $e");
      print("Stacktrace : $s");
      return null;
    }
  }

  Future<String?> getUniqueID() async {
    try {
      return await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      return null;
    } catch (e, s) {
      print("ERROR : $e");
      print("Stacktrace : $s");
      return null;
    }
  }
}
