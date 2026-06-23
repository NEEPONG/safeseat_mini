import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:safeseat_mini/core/constants/api_constants.dart';
import 'package:safeseat_mini/data/models/request_driver_model.dart';

class RequestDriverRepository {
  Future<int?> createRequest({
    required double dropoffLatitude,
    required double dropoffLongitude,
    required bool isLadyMode,
    required String note,
    required String paymentMethod,
    required double pickupLatitude,
    required double pickupLongitude,
    required double reqDistance,
    required double requestFee,
    required String userId,
    required int userCarId,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/user/request');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'dropofflatitude': dropoffLatitude,
        'dropofflongitude': dropoffLongitude,
        'isladymode': isLadyMode,
        'note': note,
        'paymentmethod': paymentMethod,
        'pickuplatitude': pickupLatitude,
        'pickuplongitude': pickupLongitude,
        'reqdistance': reqDistance,
        'requestfee': requestFee,
        'user_id': userId,
        'user_car_id': userCarId,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final request = data['request'];
      return request != null ? request['requestid'] as int? : null;
    }
    throw Exception('Failed to create request');
  }

  Future<RequestDriverModel?> checkRequestStatus(int requestId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/user/request/$requestId');
    final response = await http.get(url, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final requestJson = data['request'] as Map<String, dynamic>?;
      if (requestJson != null) {
        return RequestDriverModel.fromJson(requestJson);
      }
    }
    return null;
  }

  Future<bool> cancelRequest(int requestId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/api/user/request/$requestId');
    final response = await http.delete(url, headers: {'Content-Type': 'application/json'});

    return response.statusCode == 200;
  }
}

final requestDriverRepositoryProvider = Provider<RequestDriverRepository>((ref) {
  return RequestDriverRepository();
});
