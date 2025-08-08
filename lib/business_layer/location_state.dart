import 'package:equatable/equatable.dart';
import '../../data_layer/models/location.dart';

/// Enum representing types of possible errors when loading locations.
enum LocationError {
  /// No error occurred.
  none,

  /// A network error occurred (e.g. no internet, timeout).
  network,

  /// A generic, non-specific error occurred.
  generic,
}

/// Immutable state class used by [LocationCubit] to manage:
/// - Fetched and filtered location data
/// - Search input
/// - Loading and pagination control
/// - Selection tracking
/// - Error handling
class LocationState extends Equatable {
  /// The complete list of fetched locations from the API.
  final List<Location> locations;

  /// The list of locations after applying search filters.
  ///
  /// This may be equal to [locations] if no search query is applied.
  final List<Location> filteredLocations;

  /// The current search query string, if any.
  final String? searchQuery;

  /// Whether a data fetch is currently in progress.
  final bool isLoading;

  /// Whether there are more pages of data to fetch.
  final bool hasMore;

  /// The current pagination page (starts from 1).
  final int page;

  /// ID of the currently selected location, if any.
  final String? selectedLocationId;

  /// The current error state of the Cubit.
  final LocationError error;

  /// Optional error message, typically used for UI display.
  final String? errorMessage;

  /// Constructs a new immutable [LocationState] with default or provided values.
  const LocationState({
    this.locations = const [],
    this.filteredLocations = const [],
    this.searchQuery,
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.selectedLocationId,
    this.error = LocationError.none,
    this.errorMessage,
  });

  /// Returns a new [LocationState] with updated values.
  ///
  /// Any parameter left `null` will retain its current value.
  LocationState copyWith({
    List<Location>? locations,
    List<Location>? filteredLocations,
    String? searchQuery,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? selectedLocationId,
    LocationError? error,
    String? errorMessage,
  }) {
    return LocationState(
      locations: locations ?? this.locations,
      filteredLocations: filteredLocations ?? this.filteredLocations,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      selectedLocationId: selectedLocationId ?? this.selectedLocationId,
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Equatable override for state comparisons.
  ///
  /// Ensures UI only rebuilds when a field actually changes.
  @override
  List<Object?> get props => [
        locations,
        filteredLocations,
        searchQuery,
        isLoading,
        hasMore,
        page,
        selectedLocationId,
        error,
        errorMessage,
      ];
}
