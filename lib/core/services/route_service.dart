import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteDetails {
  final List<LatLng> points;
  final double distance; // in meters
  final double duration; // in seconds

  RouteDetails({
    required this.points,
    required this.distance,
    required this.duration,
  });
}

class RouteService {
  /// Fetches the driving path, distance, and duration between [start] and [end] using OSRM
  static Future<RouteDetails?> getRouteDetails(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?geometries=geojson&overview=full'
      );

      final response = await http.get(url, headers: {
        'User-Agent': 'SafeSeatMiniApp/1.0',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final firstRoute = routes.first;
          final distance = (firstRoute['distance'] as num?)?.toDouble() ?? 0.0;
          final duration = (firstRoute['duration'] as num?)?.toDouble() ?? 0.0;
          
          final geometry = firstRoute['geometry'] as Map<String, dynamic>?;
          List<LatLng> points = [];
          if (geometry != null && geometry['coordinates'] != null) {
            final coords = geometry['coordinates'] as List;
            points = coords.map<LatLng>((coord) {
              // GeoJSON coordinates are in [longitude, latitude] order
              return LatLng(
                (coord[1] as num).toDouble(),
                (coord[0] as num).toDouble(),
              );
            }).toList();
          }
          return RouteDetails(
            points: points,
            distance: distance,
            duration: duration,
          );
        }
      }
    } catch (e) {
      // Fail silently
    }
    return null;
  }

  /// Deprecated: Use [getRouteDetails] instead. Fetches the driving path between [start] and [end] using OSRM
  static Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
    final details = await getRouteDetails(start, end);
    return details?.points ?? [];
  }
}
