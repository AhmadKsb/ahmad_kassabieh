import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';

import '../data_layer/core/network_exceptions.dart';
import '../data_layer/models/location.dart';
import '../data_layer/repositories/location_repository.dart';
import 'location_state.dart';

/// A Cubit that manages the state of the location list, including:
/// - Initial data fetching
/// - Pagination
/// - Search
/// - Error handling
/// - Location selection
class LocationCubit extends Cubit<LocationState> {
  /// Repository to handle API communication and data abstraction.
  final LocationRepository _repository;

  /// Creates a new [LocationCubit] with an injected [LocationRepository].
  LocationCubit(this._repository) : super(const LocationState());

  /// Loads the initial page of locations (page = 1).
  ///
  /// Emits a loading state, followed by either:
  /// - a state with locations and pagination setup, or
  /// - an error state with a user-friendly message.
  Future<void> loadInitial() async {
    emit(state.copyWith(isLoading: true, error: LocationError.none, page: 1));

    try {
      final result = await _repository.getLocations(page: 1);

      // Remove any duplicates from the result
      final uniqueLocations = _removeDuplicates(result.locations);

      emit(state.copyWith(
        locations: uniqueLocations,
        filteredLocations: uniqueLocations,
        hasMore: result.hasMore,
        isLoading: false,
        page: 2,
      ));
    } catch (e) {
      final netException = e is DioException
          ? NetException.fromDioException(e)
          : NetException("Unexpected error");

      emit(state.copyWith(
        isLoading: false,
        error: LocationError.network,
        errorMessage: netException.message,
      ));
    }
  }

  /// Loads the next page of locations if more data is available.
  ///
  /// Uses the current `page` value in state. If `hasMore` is false or
  /// a load is already in progress, it skips execution.
  ///
  /// Results are merged with the existing list and deduplicated by ID.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    emit(state.copyWith(isLoading: true));

    try {
      final result = await _repository.getLocations(page: state.page);

      final allLocations = [...state.locations, ...result.locations];
      final uniqueLocations = _removeDuplicates(allLocations);

      emit(state.copyWith(
        locations: uniqueLocations,
        filteredLocations: uniqueLocations,
        hasMore: result.hasMore,
        isLoading: false,
        page: state.page + 1,
      ));
    } catch (e) {
      final netException = e is DioException
          ? NetException.fromDioException(e)
          : NetException("Unexpected error");

      emit(state.copyWith(
        isLoading: false,
        error: LocationError.network,
        errorMessage: netException.message,
      ));
    }
  }

  /// Filters the existing location list by name using a case-insensitive search.
  ///
  /// Emits a new state with `filteredLocations` and updates `searchQuery`.
  void search(String query) {
    final results = state.locations.where((loc) {
      final lowerQuery = query.toLowerCase();
      return loc.name.toLowerCase().contains(lowerQuery);
    }).toList();

    emit(state.copyWith(
      filteredLocations: results,
      searchQuery: query,
    ));
  }

  /// Clears the current search query and restores the full location list.
  void clearSearch() {
    emit(state.copyWith(
      filteredLocations: state.locations,
      searchQuery: '',
    ));
  }

  /// Selects a specific location by its ID.
  ///
  /// Updates the `selectedLocationId` in state so it can be reflected in the UI.
  void selectLocation(String locationId) {
    final current = state.selectedLocationId;

    if (current == locationId) {
      emit(state.copyWith(selectedLocationId: ''));
    } else {
      emit(state.copyWith(selectedLocationId: locationId));
    }
  }

  /// Removes duplicate locations from a list using their `id` field.
  ///
  /// This is necessary because some results may appear on multiple pages.
  List<Location> _removeDuplicates(List<Location> locations) {
    final seen = <String>{};
    return locations.where((loc) => seen.add(loc.id)).toList();
  }
}
