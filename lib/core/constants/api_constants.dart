import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  /// คืนค่า Base URL ของ Backend ให้โดยอัตโนมัติ (ขึ้นอยู่กับว่าเป็น Emulator หรือไม่)
  static String get baseUrl {
    // ใช้ 10.0.2.2 สำหรับ Android Emulator เนื่องจาก localhost บน emulator จะหมายถึงตัวมือถือเอง
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:3000';
    }
    // สำหรับ iOS Simulator และ Web สามารถใช้ localhost ได้ตามปกติ
    return 'http://localhost:3000';
  }
}
