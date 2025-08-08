import 'package:dio/dio.dart';
import '../models/location.dart';
import '../repositories/location_repository.dart';

/// Handles API calls related to fetching store locations.
class LocationProvider {
  final Dio _dio = Dio();

  /// Fetches a paginated list of locations from the Blank Street API.
  ///
  /// Defaults to page 1 if no page is specified.
  Future<LocationResult> fetchLocations({int page = 1}) async {
    final response = await _dio.get(
      'https://api.blankstreet.com/locations',
      queryParameters: {'page': page},
    );

    final data = response.data;
    final hasMore = data['hasMore'] ?? false;
    final locationsJson = data['locations'] as List;

    final locations =
        locationsJson.map((json) => Location.fromJson(json)).toList();

    return LocationResult(locations: locations, hasMore: hasMore);
  }
}
