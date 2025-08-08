import '../models/location.dart';
import '../providers/location_provider.dart';

/// Contains paginated location results and metadata
class LocationResult {
  final List<Location> locations;
  final bool hasMore;

  LocationResult({
    required this.locations,
    required this.hasMore,
  });
}

/// Repository that abstracts location fetching logic
class LocationRepository {
  final LocationProvider _provider = LocationProvider();

  /// Fetches locations from the API (with optional pagination)
  Future<LocationResult> getLocations({int page = 1}) async {
    return _provider.fetchLocations(page: page);
  }
}
