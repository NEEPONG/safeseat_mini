import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safeseat_mini/core/constants/api_constants.dart';
import 'package:safeseat_mini/core/theme/app_theme.dart';

class WaitingDriverScreen extends StatefulWidget {
  final int requestId;
  final String pickupAddress;
  final String dropoffAddress;
  final String carDetails;
  final double price;

  const WaitingDriverScreen({
    super.key,
    required this.requestId,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.carDetails,
    required this.price,
  });

  @override
  State<WaitingDriverScreen> createState() => _WaitingDriverScreenState();
}

class _WaitingDriverScreenState extends State<WaitingDriverScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _statusTimer;
  bool _isCancelling = false;
  String _statusMessage = 'กำลังค้นหาคนขับรถที่ดีที่สุดสำหรับคุณ...';
  Map<String, dynamic>? _acceptedDriverInfo;

  @override
  void initState() {
    super.initState();
    // Setup matching animation (concentric radar rings pulsing)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Start polling status every 3 seconds
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkRequestStatus();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkRequestStatus() async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/request/${widget.requestId}');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final request = data['request'];
        if (request != null) {
          final status = request['requeststatus'] as String;
          if (status != 'pending') {
            _statusTimer?.cancel();
            setState(() {
              _statusMessage = 'พบคนขับและรับงานเรียบร้อยแล้ว!';
              _acceptedDriverInfo = {
                'status': status,
                'leader': request['leader'],
                'follower': request['follower'],
              };
            });
            _showSuccessDialog();
          }
        }
      }
    } catch (e) {
      // Fail silently
      debugPrint('Error polling request status: $e');
    }
  }

  Future<void> _cancelRequest() async {
    if (_isCancelling) return;
    setState(() {
      _isCancelling = true;
    });

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/request/${widget.requestId}');
      final response = await http.delete(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        _statusTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ยกเลิกรายการเรียกรถสำเร็จ')),
          );
          Navigator.of(context).pop(); // Go back to details
        }
      } else {
        throw Exception('Failed to cancel request');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาดในการยกเลิก: $e')),
        );
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    final leader = _acceptedDriverInfo?['leader'];
    final leaderName = leader != null ? '${leader['firstname']} ${leader['lastname']}' : 'คนขับของ SafeSeat';
    final licensePlate = leader != null && leader['license_plate'] != null
        ? leader['license_plate']
        : 'ไม่ระบุ';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            Text(
              'พบคู่หูคนขับแล้ว!',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'คนขับได้ทำการตอบรับงานของคุณเรียบร้อยแล้วและกำลังเดินทางมาหาคุณ',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'คนขับหลัก: $leaderName',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.directions_car, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('หมายเลขทะเบียนรถไล่ตาม: $licensePlate'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // pop dialog
              Navigator.of(context).pop(); // pop waiting
              Navigator.of(context).pop(); // pop details
              Navigator.of(context).pop(); // pop map (return to home)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = AppTheme.primaryColor;

    return PopScope(
      canPop: false, // Prevent physical back button, user must explicitly cancel
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Premium matching header
                const Text(
                  'กำลังจับคู่คนขับรถ',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
                
                const Spacer(),

                // Pulsing Radar Search Animation
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return SizedBox(
                      width: 200,
                      height: 200,
                      child: CustomPaint(
                        painter: RadarPainter(_animationController.value, themeColor),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  spreadRadius: 3,
                                )
                              ],
                            ),
                            child: const Icon(
                              Icons.location_searching,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                // Ride details summary card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Pickup Location
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.pickupAddress,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Dropoff Location
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.dropoffAddress,
                              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Vehicle and fare
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.carDetails,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            '฿${widget.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isCancelling ? null : _cancelRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFFEF4444),
                      disabledBackgroundColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                            ),
                          )
                        : const Text(
                            'ยกเลิกการเรียก',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double animationValue;
  final Color themeColor;

  RadarPainter(this.animationValue, this.themeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final value = (animationValue + i / 3.0) % 1.0;
      final radius = maxRadius * value;
      final opacity = 1.0 - value;

      final paint = Paint()
        ..color = themeColor.withValues(alpha: opacity * 0.15)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, radius, paint);

      final strokePaint = Paint()
        ..color = themeColor.withValues(alpha: opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
