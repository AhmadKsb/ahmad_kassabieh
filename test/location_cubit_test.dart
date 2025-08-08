import 'package:blank_street/business_layer/location_cubit.dart';
import 'package:blank_street/business_layer/location_state.dart';
import 'package:blank_street/data_layer/models/location.dart';
import 'package:blank_street/data_layer/repositories/location_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// This file tests the LocationCubit:
/// - loading initial and paginated location data
/// - handling API errors
/// - updating selection state
/// - applying and clearing search filters

/// Mocked repository to simulate API calls
class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  late MockLocationRepository mockRepo;
  late LocationCubit cubit;

  /// Sample data for mocking
  final sampleLocationsPage1 = [
    Location(
      id: '1',
      name: 'Blank Street A',
      address: '123 Coffee Lane',
      shortAddress: 'Coffee Lane',
      latitude: 0.0,
      longitude: 0.0,
      imgUrl: 'https://example.com/a.jpg',
      status: null,
      isEnabled: true,
      disableUntil: null,
    ),
    Location(
      id: '2',
      name: 'Blank Street B',
      address: '456 Espresso Blvd',
      shortAddress: 'Espresso Blvd',
      latitude: 0.0,
      longitude: 0.0,
      imgUrl: 'https://example.com/b.jpg',
      status: null,
      isEnabled: true,
      disableUntil: null,
    ),
  ];

  final sampleLocationsPage2 = [
    Location(
      id: '3',
      name: 'Blank Street C',
      address: '789 Mocha Road',
      shortAddress: 'Mocha Road',
      latitude: 0.0,
      longitude: 0.0,
      imgUrl: 'https://example.com/c.jpg',
      status: null,
      isEnabled: true,
      disableUntil: null,
    ),
  ];

  setUp(() {
    mockRepo = MockLocationRepository();
    cubit = LocationCubit(mockRepo);
  });

  tearDown(() async {
    await cubit.close();
  });

  test('Initial state should match default values', () {
    expect(cubit.state, const LocationState());
  });

  blocTest<LocationCubit, LocationState>(
    'emits [loading, loaded] on successful loadInitial',
    build: () {
      when(() => mockRepo.getLocations(page: 1)).thenAnswer(
        (_) async => LocationResult(
          locations: sampleLocationsPage1,
          hasMore: true,
        ),
      );
      return cubit;
    },
    act: (cubit) => cubit.loadInitial(),
    expect: () => [
      const LocationState(isLoading: true, page: 1, error: LocationError.none),
      LocationState(
        isLoading: false,
        locations: sampleLocationsPage1,
        filteredLocations: sampleLocationsPage1,
        hasMore: true,
        page: 2,
        error: LocationError.none,
      ),
    ],
  );

  blocTest<LocationCubit, LocationState>(
    'emits [loading, error] on failed loadInitial',
    build: () {
      when(() => mockRepo.getLocations(page: 1))
          .thenThrow(Exception("network error"));
      return cubit;
    },
    act: (cubit) => cubit.loadInitial(),
    expect: () => [
      const LocationState(isLoading: true, page: 1, error: LocationError.none),
      isA<LocationState>().having(
        (s) => s.error,
        'error',
        LocationError.network,
      ),
    ],
  );

  blocTest<LocationCubit, LocationState>(
    'updates selectedLocationId when selectLocation is called',
    build: () => cubit,
    act: (cubit) => cubit.selectLocation('2'),
    expect: () => [
      const LocationState(selectedLocationId: '2'),
    ],
  );

  blocTest<LocationCubit, LocationState>(
    'merges new page on successful loadMore',
    build: () {
      when(() => mockRepo.getLocations(page: 1)).thenAnswer(
        (_) async => LocationResult(
          locations: sampleLocationsPage1,
          hasMore: true,
        ),
      );
      when(() => mockRepo.getLocations(page: 2)).thenAnswer(
        (_) async => LocationResult(
          locations: sampleLocationsPage2,
          hasMore: false,
        ),
      );
      return cubit;
    },
    act: (cubit) async {
      await cubit.loadInitial();
      await cubit.loadMore();
    },
    skip: 1, // Skip the first loading state
    expect: () => [
      // After loadInitial
      LocationState(
        isLoading: false,
        locations: sampleLocationsPage1,
        filteredLocations: sampleLocationsPage1,
        hasMore: true,
        page: 2,
        error: LocationError.none,
      ),
      // While loading more
      LocationState(
        isLoading: true,
        locations: sampleLocationsPage1,
        filteredLocations: sampleLocationsPage1,
        hasMore: true,
        page: 2,
        error: LocationError.none,
      ),
      // After loadMore
      LocationState(
        isLoading: false,
        locations: [...sampleLocationsPage1, ...sampleLocationsPage2],
        filteredLocations: [...sampleLocationsPage1, ...sampleLocationsPage2],
        hasMore: false,
        page: 3,
        error: LocationError.none,
      ),
    ],
  );

  blocTest<LocationCubit, LocationState>(
    'filters results correctly on search',
    build: () {
      cubit.emit(
        LocationState(
          locations: sampleLocationsPage1,
          filteredLocations: sampleLocationsPage1,
        ),
      );
      return cubit;
    },
    act: (cubit) => cubit.search('Blank Street B'),
    expect: () => [
      LocationState(
        locations: sampleLocationsPage1,
        filteredLocations: [sampleLocationsPage1[1]],
        searchQuery: 'Blank Street B',
      ),
    ],
  );

  blocTest<LocationCubit, LocationState>(
    'resets search and restores full list when clearSearch is called',
    build: () {
      cubit.emit(
        LocationState(
          locations: sampleLocationsPage1,
          filteredLocations: [sampleLocationsPage1[1]],
          searchQuery: 'B',
        ),
      );
      return cubit;
    },
    act: (cubit) => cubit.clearSearch(),
    expect: () => [
      LocationState(
        locations: sampleLocationsPage1,
        filteredLocations: sampleLocationsPage1,
        searchQuery: '',
      ),
    ],
  );
}
