import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeseat_mini/core/controllers/request_driver_controller.dart';
import 'package:safeseat_mini/core/controllers/profile_controller.dart';
import 'package:safeseat_mini/core/controllers/user_controller.dart';
import 'package:safeseat_mini/core/models/car_model.dart';
import 'package:safeseat_mini/core/theme/app_theme.dart';
import 'package:safeseat_mini/core/services/route_service.dart';
import 'package:safeseat_mini/features/request_driver/screens/payment_method_screen.dart';
import 'package:safeseat_mini/features/request_driver/screens/waiting_driver_screen.dart';

class RequestDriverDetailsScreen extends ConsumerStatefulWidget {
  const RequestDriverDetailsScreen({super.key});

  @override
  ConsumerState<RequestDriverDetailsScreen> createState() =>
      _RequestDriverDetailsScreenState();
}

class _RequestDriverDetailsScreenState
    extends ConsumerState<RequestDriverDetailsScreen> {
  CarModel? _selectedCar;
  bool _ladyMode = false;
  final TextEditingController _remarksController = TextEditingController();
  String _paymentMethod = 'เงินสด';
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  double _estimatedPrice = 300.0;
  double _distanceInKm = 0.0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRoute();
    });
  }

  Future<void> _loadRoute() async {
    final reqState = ref.read(requestDriverControllerProvider);
    final pickup = reqState.pickupLatLng;
    final dropoff = reqState.dropoffLatLng;

    if (pickup == null || dropoff == null) return;

    final routeDetails = await RouteService.getRouteDetails(pickup, dropoff);

    if (mounted) {
      double calculatedPrice = 300.0;
      double distanceKm = 0.0;
      List<LatLng> points = [pickup, dropoff];

      if (routeDetails != null) {
        points = routeDetails.points.isNotEmpty ? routeDetails.points : [pickup, dropoff];
        distanceKm = routeDetails.distance / 1000.0;
        calculatedPrice = 300.0 + (distanceKm * 10.0);
      } else {
        // Fallback using straight-line distance if API fails
        final distanceMeters = const Distance().as(LengthUnit.Meter, pickup, dropoff);
        distanceKm = distanceMeters / 1000.0;
        calculatedPrice = 300.0 + (distanceKm * 10.0);
      }

      setState(() {
        _routePoints = points;
        _estimatedPrice = calculatedPrice;
        _distanceInKm = distanceKm;
      });

      // Fit map bounds to show both pins and the route, ensuring non-zero area
      if (pickup.latitude != dropoff.latitude || pickup.longitude != dropoff.longitude) {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds(pickup, dropoff),
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 50.0),
          ),
        );
      } else {
        _mapController.move(pickup, 15.0);
      }
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _showCarSelectionSheet(List<CarModel> cars) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'เลือกยานพาหนะของคุณ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              if (cars.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'คุณยังไม่มีรถที่ลงทะเบียน\nกรุณาเพิ่มข้อมูลรถในหน้าโปรไฟล์',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cars.length,
                    itemBuilder: (context, index) {
                      final car = cars[index];
                      final isSelected =
                          _selectedCar?.userCarId == car.userCarId;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.directions_car,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.grey,
                          ),
                        ),
                        title: Text(
                          '${car.carBrand} ${car.carModel}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('${car.carColor} • ${car.carPlate}'),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppTheme.primaryColor,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedCar = car;
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showInsufficientBalanceDialog(num balance) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text(
              'ยอดเงินไม่เพียงพอ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'ยอดเงินคงเหลือใน SafeSeat Wallet (฿${balance.toStringAsFixed(2)}) '
          'ไม่เพียงพอสำหรับค่าบริการการเรียกรถครั้งนี้ (฿${_estimatedPrice.toStringAsFixed(0)})\n\n'
          'กรุณาเปลี่ยนวิธีการชำระเงินเป็นเงินสด หรือเติมเงินเข้าสู่ Wallet ของคุณ',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Change to Cash payment directly
              setState(() {
                _paymentMethod = 'เงินสด';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('เปลี่ยนช่องทางการชำระเงินเป็น เงินสด เรียบร้อยแล้ว')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('ใช้เงินสดแทน'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reqState = ref.watch(requestDriverControllerProvider);
    final user = ref.watch(userProvider);
    final phoneNo = user?.phoneNo ?? '';

    // Load user's cars
    final carListAsync = ref.watch(userCarListProvider(phoneNo));

    // Auto-select first car as default once data loaded
    carListAsync.whenData((cars) {
      if (_selectedCar == null && cars.isNotEmpty) {
        // Run after build pass to avoid setState during build compile warnings
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedCar = cars.first;
            });
          }
        });
      }
    });

    // Default coordinates
    final pickupLatLng =
        reqState.pickupLatLng ?? const LatLng(18.8972, 99.0112);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Scrollable content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Mini Map
                SizedBox(
                  height: 280,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: pickupLatLng,
                          initialZoom: 15.0,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.safeseat.mini',
                          ),
                          if (_routePoints.isNotEmpty)
                            PolylineLayer(
                              polylines: [
                                Polyline(
                                  points: _routePoints,
                                  color: AppTheme.primaryColor,
                                  strokeWidth: 4.0,
                                ),
                              ],
                            ),
                          MarkerLayer(
                            markers: [
                              if (reqState.pickupLatLng != null)
                                Marker(
                                  point: reqState.pickupLatLng!,
                                  width: 100,
                                  height: 80,
                                  child: Column(
                                    children: [
                                      // Custom label bubble
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'รับที่นี่',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                ),
                              if (reqState.dropoffLatLng != null)
                                Marker(
                                  point: reqState.dropoffLatLng!,
                                  width: 100,
                                  height: 80,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          'ส่งที่นี่',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFF10B981),
                                        size: 32,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      // Floating Back button
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Color(0xFF1E293B),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Selection Form Content
                Container(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vehicle Selection Section
                      const Text(
                        'กรุณาเลือกยานพาหนะของท่าน',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      carListAsync.when(
                        loading: () => Container(
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (error, stack) => Container(
                          height: 72,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Center(
                            child: Text(
                              'ไม่สามารถโหลดข้อมูลยานพาหนะได้',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        data: (cars) {
                          final displayedText = _selectedCar != null
                              ? '${_selectedCar!.carBrand} ${_selectedCar!.carModel} (${_selectedCar!.carPlate})'
                              : 'กรุณาเลือกยานพาหนะ';
                          final displayedType =
                              _selectedCar?.carTypeName ?? 'ไม่มีประเภทระบุ';

                          return InkWell(
                            onTap: () => _showCarSelectionSheet(cars),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.directions_car,
                                      color: AppTheme.primaryColor,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          displayedText,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          displayedType,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF64748B),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Lady Mode Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDF2F8), // Light pink
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.female,
                                color: Color(0xFFEC4899), // Pink
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'เลดี้โหมด',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFECFDF5,
                                          ), // Light green
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'FREE',
                                          style: TextStyle(
                                            color: Color(0xFF10B981),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: _ladyMode,
                              activeThumbColor: const Color(0xFFEC4899),
                              onChanged: (val) {
                                setState(() {
                                  _ladyMode = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Remarks Section
                      const Text(
                        'หมายเหตุ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _remarksController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText:
                              'ระบุหมายเหตุเช่น ที่ต้องการให้ผู้บริการทราบ',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.all(16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Payment Method Section
                      const Text(
                        'การชำระเงิน',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () async {
                          final selected = await Navigator.of(context).push<String>(
                            MaterialPageRoute(
                              builder: (context) => PaymentMethodScreen(initialMethod: _paymentMethod),
                            ),
                          );
                          if (selected != null) {
                            setState(() {
                              _paymentMethod = selected;
                            });
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _paymentMethod.startsWith('เงินสด')
                                    ? Icons.payments
                                    : Icons.account_balance_wallet,
                                color: const Color(0xFF64748B),
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _paymentMethod,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color(0xFF64748B),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Empty space to prevent bottom navigation overlaps
                      const SizedBox(height: 170),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Button Panel (Overlayed at bottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Estimated Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ยอดรวมโดยประมาณ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          if (_distanceInKm > 0)
                            Text(
                              'ระยะทาง ${_distanceInKm.toStringAsFixed(1)} กม.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        '฿${_estimatedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Call Driver Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _selectedCar == null || _isSubmitting
                          ? null
                          : () async {
                              final user = ref.read(userProvider);
                              final balance = user?.walletBalance ?? 0.0;
                              final isWallet = !_paymentMethod.startsWith('เงินสด');
                              
                              if (isWallet && balance < _estimatedPrice) {
                                _showInsufficientBalanceDialog(balance);
                                return;
                              }

                              setState(() {
                                _isSubmitting = true;
                              });

                              try {
                                final requestId = await ref
                                    .read(requestDriverControllerProvider.notifier)
                                    .createRequest(
                                      dropoffLatitude: reqState.dropoffLatLng!.latitude,
                                      dropoffLongitude: reqState.dropoffLatLng!.longitude,
                                      isLadyMode: _ladyMode,
                                      note: _remarksController.text.trim(),
                                      paymentMethod: _paymentMethod,
                                      pickupLatitude: reqState.pickupLatLng!.latitude,
                                      pickupLongitude: reqState.pickupLatLng!.longitude,
                                      reqDistance: _distanceInKm,
                                      requestFee: _estimatedPrice,
                                      userId: phoneNo,
                                      userCarId: _selectedCar!.userCarId,
                                    );

                                if (requestId != null) {
                                  if (context.mounted) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => WaitingDriverScreen(
                                          requestId: requestId,
                                          pickupAddress: reqState.pickupAddress ?? 'ตำแหน่งปัจจุบัน',
                                          dropoffAddress: reqState.dropoffAddress ?? 'ปลายทาง',
                                          carDetails: '${_selectedCar!.carBrand} ${_selectedCar!.carModel}',
                                          price: _estimatedPrice,
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  throw Exception('ไม่สามารถส่งข้อมูลเพื่อจับคู่กับคนขับได้ กรุณาลองใหม่อีกครั้ง');
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('ไม่สามารถส่งคำขอเรียกรถได้: $e')),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() {
                                    _isSubmitting = false;
                                  });
                                }
                              }
                            },
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.bolt, color: Colors.white),
                      label: Text(
                        _isSubmitting ? 'กำลังส่งคำขอ...' : 'เรียกคนขับ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
