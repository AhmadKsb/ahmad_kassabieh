/// Model class representing a store location returned by the Blank Street API.
///
/// This model contains information about the store's identity, address,
/// coordinates, availability, and current status.
class Location {
  /// Unique identifier for the location.
  final String id;

  /// Full name of the store (e.g., "Blank Street A").
  final String name;

  /// Full street address of the store.
  final String address;

  /// Shorter or localized version of the address (e.g., neighborhood).
  final String shortAddress;

  /// Geographic latitude of the store location.
  final double latitude;

  /// Geographic longitude of the store location.
  final double longitude;

  /// URL pointing to an image of the store or map marker.
  final String imgUrl;

  /// Optional status indicator (e.g., "Open", "Temporarily Closed").
  final String? status;

  /// Indicates whether this location is enabled and selectable.
  final bool isEnabled;

  /// Optional timestamp (ISO8601) indicating when a disabled location becomes active again.
  final String? disableUntil;

  /// Creates a new [Location] instance with all required and optional fields.
  Location({
    required this.id,
    required this.name,
    required this.address,
    required this.shortAddress,
    required this.latitude,
    required this.longitude,
    required this.imgUrl,
    required this.status,
    required this.isEnabled,
    required this.disableUntil,
  });

  /// Factory constructor to build a [Location] from a JSON object.
  ///
  /// Example API response:
  /// ```json
  /// {
  ///   "id": "1",
  ///   "name": "Blank Street A",
  ///   "address": "123 Coffee Lane",
  ///   "shortAddress": "Coffee Lane",
  ///   "latitude": 40.7128,
  ///   "longitude": -74.0060,
  ///   "imgUrl": "https://example.com/image.jpg",
  ///   "status": "Open",
  ///   "isEnabled": true,
  ///   "_disableUntil": null
  /// }
  /// ```
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      shortAddress: json['shortAddress'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imgUrl: json['imgUrl'],
      status: json['status'],
      isEnabled: json['isEnabled'],
      disableUntil: json['_disableUntil'],
    );
  }
}
