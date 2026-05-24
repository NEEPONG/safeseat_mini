import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeseat_mini/core/controllers/user_controller.dart';
import 'package:safeseat_mini/core/controllers/profile_controller.dart';
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;

  int? _selectedGender;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);

    _profileImagePath = user?.profileImagePath;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phoneNo ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController(text: user?.mainAddress ?? '');
    _selectedGender = user?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = ref.read(userProvider);
      if (currentUser == null) return;

      final updatedUser = currentUser.copyWith(
        name: _nameController.text,
        email: _emailController.text,
        gender: _selectedGender,
        mainAddress: _addressController.text,
      );

      final success = await ref.read(profileControllerProvider.notifier).editProfile(updatedUser);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อยแล้ว')),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('บันทึกข้อมูลไม่สำเร็จ กรุณาลองใหม่')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage:
                              _profileImagePath != null &&
                                  _profileImagePath!.isNotEmpty
                              ? NetworkImage(_profileImagePath!)
                              : null,
                          child:
                              (_profileImagePath == null ||
                                  _profileImagePath!.isEmpty)
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0044C9),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ภาพประจำตัว',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Personal Info Section
              const Text(
                'ข้อมูลส่วนตัว',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0044C9),
                ),
              ),
              const SizedBox(height: 16),

              _buildLabel('ชื่อ-นามสกุล'),
              _buildTextField(
                controller: _nameController,
                icon: Icons.person_outline,
                hintText: 'ชื่อ-นามสกุล',
                validator: (value) =>
                    value == null || value.isEmpty ? 'กรุณากรอกชื่อ' : null,
              ),

              _buildLabel('เบอร์มือถือ'),
              _buildTextField(
                controller: _phoneController,
                icon: Icons.phone_outlined,
                hintText: 'เบอร์มือถือ',
                readOnly: true,
              ),

              _buildLabel('อีเมล'),
              _buildTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                hintText: 'อีเมล',
                keyboardType: TextInputType.emailAddress,
              ),

              _buildLabel('เพศ'),
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedGender,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.people_outline, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  hint: const Text(
                    'ระบุเพศ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('ชาย')),
                    DropdownMenuItem(value: 1, child: Text('หญิง')),
                    DropdownMenuItem(value: 2, child: Text('อื่นๆ')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedGender = val;
                    });
                  },
                ),
              ),

              _buildLabel('ที่อยู่ตั้งต้น'),
              _buildTextField(
                controller: _addressController,
                icon: Icons.location_on_outlined,
                hintText: 'โปรดระบุที่อยู่หลักของคุณ',
                maxLines: 3,
              ),

              const SizedBox(height: 8),

              // Vehicles Section (Mock)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ยานพาหนะของฉัน',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0044C9),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    label: const Text(
                      'Add Car',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mock Car Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Color(0xFF334155),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tesla Model 3',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'สีเทาเข้ม • ABC-1234',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFFF8FAFC),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _saveProfile,
            icon: const Icon(Icons.save_outlined, color: Colors.white),
            label: const Text(
              'บันทึกการแก้ไข',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF334155),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(color: readOnly ? Colors.grey[600] : Colors.black),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.only(bottom: maxLines > 1 ? 40.0 : 0),
            child: Icon(icon, color: Colors.grey),
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
