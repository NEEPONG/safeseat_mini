import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteService {
  /// Fetches the driving path between [start] and [end] using OSRM
  static Future<List<LatLng>> getRoutePoints(LatLng start, LatLng end) async {
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
          final geometry = routes.first['geometry'] as Map<String, dynamic>?;
          if (geometry != null && geometry['coordinates'] != null) {
            final coords = geometry['coordinates'] as List;
            return coords.map<LatLng>((coord) {
              // GeoJSON coordinates are in [longitude, latitude] order
              return LatLng(
                (coord[1] as num).toDouble(),
                (coord[0] as num).toDouble(),
              );
            }).toList();
          }
        }
      }
    } catch (e) {
      // Fail silently and return empty list
    }
    return [];
  }
}
