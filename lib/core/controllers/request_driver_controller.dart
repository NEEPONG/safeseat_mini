import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:safeseat_mini/core/constants/api_constants.dart';

class RequestDriverState {
  final String? pickupAddress;
  final LatLng? pickupLatLng;
  final String? dropoffAddress;
  final LatLng? dropoffLatLng;
  final bool isLoading;

  RequestDriverState({
    this.pickupAddress,
    this.pickupLatLng,
    this.dropoffAddress,
    this.dropoffLatLng,
    this.isLoading = false,
  });

  RequestDriverState copyWith({
    String? pickupAddress,
    LatLng? pickupLatLng,
    String? dropoffAddress,
    LatLng? dropoffLatLng,
    bool? isLoading,
  }) {
    return RequestDriverState(
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLatLng: pickupLatLng ?? this.pickupLatLng,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      dropoffLatLng: dropoffLatLng ?? this.dropoffLatLng,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RequestDriverController extends Notifier<RequestDriverState> {
  @override
  RequestDriverState build() {
    return RequestDriverState(
      pickupAddress: 'แม่โจ้, หอพักพนม',
      pickupLatLng: const LatLng(18.8972, 99.0112), // default Maejo University area
    );
  }

  void setPickup(String address, LatLng latLng) {
    state = state.copyWith(pickupAddress: address, pickupLatLng: latLng);
  }

  void setDropoff(String address, LatLng latLng) {
    state = state.copyWith(dropoffAddress: address, dropoffLatLng: latLng);
  }

  void clearRequest() {
    state = RequestDriverState(
      pickupAddress: 'แม่โจ้, หอพักพนม',
      pickupLatLng: const LatLng(18.8972, 99.0112),
    );
  }

  /// Sends the designated driver request to the backend
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
    state = state.copyWith(isLoading: true);
    try {
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
        final int? requestId = request != null ? request['requestid'] as int? : null;
        state = state.copyWith(isLoading: false);
        return requestId;
      }
    } catch (e) {
      debugPrint('Error creating request: $e');
    }
    state = state.copyWith(isLoading: false);
    return null;
  }

  /// Polls the backend to check the request status and assigned driver info
  Future<Map<String, dynamic>?> checkRequestStatus(int requestId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/request/$requestId');
      final response = await http.get(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['request'] as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('Error checking request status: $e');
    }
    return null;
  }

  /// Deletes the request from the backend
  Future<bool> cancelRequest(int requestId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/api/user/request/$requestId');
      final response = await http.delete(url, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        clearRequest();
        return true;
      }
    } catch (e) {
      debugPrint('Error canceling request: $e');
    }
    return false;
  }
}

final requestDriverControllerProvider =
    NotifierProvider<RequestDriverController, RequestDriverState>(() {
  return RequestDriverController();
});
