import 'package:flutter/material.dart';
import 'package:safeseat_mini/core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String? profileImagePath = user['profileimagepath'];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: profileImagePath != null && profileImagePath.isNotEmpty
                        ? NetworkImage(profileImagePath) // Or handle Supabase storage URL properly
                        : null,
                    child: (profileImagePath == null || profileImagePath.isEmpty)
                        ? const Icon(Icons.person, color: Colors.grey, size: 28)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('สวัสดีตอนเช้า', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        Text('SafeSeat', style: TextStyle(color: AppTheme.primaryColor, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none, color: Color(0xFF1E293B)),
                      onPressed: () {},
                    ),
                  )
                ],
              ),
              const SizedBox(height: 32),

              // Trusted Safety Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0E7FF), Color(0xFFF1F5F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.security, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 8),
                            const Text('TRUSTED SAFETY', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('ให้เราได้ดูแล\nคุณ', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF1E293B), height: 1.2)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('เรียกรถเลย', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Icon(Icons.directions_car, size: 80, color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Recommended Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ค้นหาอะไรที่ชอบ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  TextButton(
                    onPressed: () {},
                    child: const Text('ดูทั้งหมด', style: TextStyle(color: AppTheme.primaryColor)),
                  )
                ],
              ),
              const Text('โฆษณา เลือกดูเลย', style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildRecommendedCard(
                      title: 'Safe Trip',
                      subtitle: 'การเดินทางที่ปลอดภัยที่สุดสำหรับคุณ',
                      isRecommended: true,
                    ),
                    const SizedBox(width: 16),
                    _buildRecommendedCard(
                      title: 'Schedule Trip',
                      subtitle: 'จองล่วงหน้า สะดวกสบาย',
                      isRecommended: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Promotion Section (Replacing Popular Services)
              const Text('โปรโมชั่นแอป', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFEDD5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFB923C).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_offer, color: Color(0xFFEA580C), size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ลด 50% สำหรับผู้ใช้ใหม่', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF9A3412))),
                          SizedBox(height: 4),
                          Text('เพียงใช้โค้ด SAFENEW50 ในการเรียกรถครั้งแรก', style: TextStyle(color: Color(0xFFC2410C), fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedCard({required String title, required String subtitle, required bool isRecommended}) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE2E8F0),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  const Center(child: Text('img', style: TextStyle(color: Color(0xFF94A3B8)))),
                  if (isRecommended)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('RECOMMENDED', style: TextStyle(color: AppTheme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
