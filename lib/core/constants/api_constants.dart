import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  /// คืนค่า Base URL ของ Backend จากไฟล์ .env
  static String get baseUrl {
    return dotenv.env['API_BASE_URL']!;
  }
}
