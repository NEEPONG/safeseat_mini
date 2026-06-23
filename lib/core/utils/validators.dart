class AppValidators {
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกเบอร์มือถือ';
    }
    final regex = RegExp(r'^[0-9]{10}$');
    if (!regex.hasMatch(value.trim())) {
      return 'เบอร์มือถือต้องเป็นตัวเลข 10 หลัก และไม่มีช่องว่าง';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกชื่อ-นามสกุล';
    }
    final regex = RegExp(r'^[a-zA-Zก-๙\s]{2,50}$');
    if (!regex.hasMatch(value.trim())) {
      return 'ชื่อ-นามสกุลต้องเป็นภาษาไทยหรืออังกฤษ ความยาว 2-50 ตัวอักษร';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกอีเมล';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    final regex = RegExp(r'^[A-Za-z0-9!#_.]{8,16}$');
    if (!regex.hasMatch(value)) {
      return 'รหัสผ่านต้องมีความยาว 8-16 ตัวอักษร, ประกอบด้วยภาษาอังกฤษ\nตัวเลข หรืออักขระพิเศษ !#_. และไม่มีช่องว่าง';
    }
    return null;
  }
}
