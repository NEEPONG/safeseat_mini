import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

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
}

final requestDriverControllerProvider =
    NotifierProvider<RequestDriverController, RequestDriverState>(() {
  return RequestDriverController();
});
