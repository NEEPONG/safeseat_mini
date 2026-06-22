import 'package:flutter/material.dart';
import 'package:safeseat_mini/core/theme/app_theme.dart';
import 'package:safeseat_mini/core/utils/validators.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeseat_mini/controllers/auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final PageController _pageController = PageController();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _acceptTerms = false;
  int? _selectedGender;

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeyStep1.currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentStep = 0;
    });
  }

  Future<void> _register() async {
    if (!_formKeyStep2.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกเพศของคุณ')));
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณายอมรับข้อกำหนดและนโยบายก่อนดำเนินการ'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final errorMsg = await ref
        .read(authControllerProvider.notifier)
        .register(
          _phoneController.text.trim(),
          _nameController.text.trim(),
          _selectedGender!,
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (errorMsg == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('สร้างบัญชีสำเร็จ')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 18),
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          errorStyle: const TextStyle(height: 0.8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E293B)),
          onPressed: () {
            if (_currentStep == 1) {
              _previousStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [_buildStep1(), _buildStep2()],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'STEP 1 OF 2',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'สร้างบัญชีผู้ใช้ของคุณ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'กรุณาป้อนหมายเลขโทรศัพท์มือถือของคุณเพื่อเริ่มต้น\nเราจะส่งรหัสยืนยันให้คุณเพื่อรักษาความปลอดภัยบัญชี\nของคุณ',
              style: TextStyle(color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 40),

            _buildTextFormField(
              controller: _phoneController,
              hintText: 'เบอร์มือถือ (ตัวเลข 10 หลัก)',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: AppValidators.validatePhone,
            ),

            const Spacer(),
            const Text(
              'เมื่อดำเนินการต่อหมายถึงคุณยอมรับข้อกำหนดในการให้บริการและนโยบายความเป็นส่วนตัวของเรา',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                ),
                child: const Text(
                  'ดำเนินการต่อ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'FINAL STEP',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ตั้งค่าโปรไฟล์ของคุณ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'นี่เป็นเพียงรายละเอียดเพิ่มเติมเล็กน้อยที่จะช่วยให้คุณ\nเดินทางได้อย่างปลอดภัย',
              style: TextStyle(color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 40),

            _buildTextFormField(
              controller: _nameController,
              hintText: 'ชื่อ-นามสกุล',
              icon: Icons.person_outline,
              validator: AppValidators.validateName,
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.inputColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Padding(
                    padding: EdgeInsets.only(left: 56.0),
                    child: Text(
                      'กรุณาเลือกเพศของคุณ',
                      style: TextStyle(color: Color(0xFF94A3B8)),
                    ),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  value: _selectedGender,
                  items: const [
                    DropdownMenuItem(
                      value: 1,
                      child: Padding(
                        padding: EdgeInsets.only(left: 56.0),
                        child: Text('ชาย'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Padding(
                        padding: EdgeInsets.only(left: 56.0),
                        child: Text('หญิง'),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Padding(
                        padding: EdgeInsets.only(left: 56.0),
                        child: Text('อื่นๆ'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildTextFormField(
              controller: _emailController,
              hintText: 'อีเมล (example@gmail.com)',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: AppValidators.validateEmail,
            ),
            const SizedBox(height: 16),

            _buildTextFormField(
              controller: _passwordController,
              hintText: 'รหัสผ่าน',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              validator: AppValidators.validatePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: const Color(0xFF94A3B8),
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptTerms = value ?? false;
                      });
                    },
                    activeColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ยอมรับข้อกำหนดและนโยบาย',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'กรุณาอ่านก่อนยอมรับ',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppTheme.primaryColor.withValues(alpha: 0.5),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'เริ่มใช้งานเลย',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
