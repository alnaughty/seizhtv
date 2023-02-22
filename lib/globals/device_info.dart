import 'package:flutter/services.dart';
import 'package:platform_device_id/platform_device_id.dart';

class MyDeviceInfo {
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
