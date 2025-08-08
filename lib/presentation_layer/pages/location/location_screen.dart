import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

import '../../../business_layer/location_cubit.dart';
import '../../../business_layer/location_state.dart';
import 'location_tile.dart';

/// A screen that displays a map and a list of locations (branches).
///
/// - The map uses [flutter_map] and is enhanced with [flutter_map_animations]
///   for smooth transitions when selecting a location.
/// - Users can scroll through a draggable bottom sheet to browse and search locations.
/// - Selecting a location from the list will:
///   1. Center the map on that location with a smooth animation.
///   2. Update the selected state in the [LocationCubit].
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen>
    with TickerProviderStateMixin {
  /// Animated controller for the map.
  /// Used to animate smooth movement between location markers.
  late final AnimatedMapController _animatedMapController;

  /// Search query entered by the user.
  String _query = '';

  /// Whether the search input field is active.
  bool _isSearchActive = false;

  /// Text controller for the search input field.
  late TextEditingController _controller;

  /// Timer to debounce list scroll-based pagination requests.
  Timer? _debounceTimer;

  /// Default map center (New York City coordinates as fallback).
  static const _defaultLatLng = LatLng(40.728119, -73.994443);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _animatedMapController = AnimatedMapController(vsync: this);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌍 Map Section
          BlocBuilder<LocationCubit, LocationState>(
            builder: (context, state) {
              final locations = state.locations;
              final selectedId = state.selectedLocationId;

              return FlutterMap(
                mapController: _animatedMapController.mapController,
                options: MapOptions(
                  initialCenter: _defaultLatLng,
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  /// OpenStreetMap tile provider
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.blank_street',
                  ),

                  /// Markers for all available locations
                  MarkerLayer(
                    key: ValueKey(selectedId),
                    markers: locations.map((location) {
                      return Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(location.latitude, location.longitude),
                        child: GestureDetector(
                          onTap: () {
                            final cubit = context.read<LocationCubit>();
                            final isAlreadySelected =
                                cubit.state.selectedLocationId == location.id;

                            cubit.selectLocation(location.id);

                            if (!isAlreadySelected) {
                              cubit.search(location.name);
                              setState(() {
                                _query = location.name;
                                _controller.text = location.name;
                                _isSearchActive = true;
                              });
                            } else {
                              cubit.clearSearch();
                              setState(() {
                                _query = '';
                                _controller.clear();
                                _isSearchActive = false;
                              });
                            }
                          },
                          child: BlocBuilder<LocationCubit, LocationState>(
                            buildWhen: (prev, curr) =>
                                prev.selectedLocationId !=
                                curr.selectedLocationId,
                            builder: (context, state) {
                              final isSelected =
                                  state.selectedLocationId == location.id;

                              return Icon(
                                Icons.location_pin,
                                color: isSelected ? Colors.red : Colors.grey,
                                size: 36,
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  )
                ],
              );
            },
          ),

          /// Draggable Bottom Sheet for Location List
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              scrollController.addListener(() {
                if (_isSearchActive) return;

                if (scrollController.position.pixels >=
                    scrollController.position.maxScrollExtent - 200) {
                  _debounceTimer?.cancel();
                  _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                    context.read<LocationCubit>().loadMore();
                  });
                }
              });

              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  children: [
                    _isSearchActive
                        ? _buildSearchField()
                        : _buildSearchToggle(),
                    const SizedBox(height: 8),
                    const Divider(),

                    /// Main list area
                    Expanded(
                      child: BlocBuilder<LocationCubit, LocationState>(
                        builder: (context, state) {
                          final locations = state.locations;
                          final filtered = state.filteredLocations;
                          final isQuerying = _query.isNotEmpty;

                          if (state.isLoading && locations.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (state.error != LocationError.none &&
                              locations.isEmpty) {
                            return Center(
                              child: Text(state.errorMessage ?? 'Error'),
                            );
                          }

                          // Search results view
                          if (_isSearchActive) {
                            if (!isQuerying) {
                              final shuffled = [...locations]..shuffle();
                              final suggestions = shuffled.take(3).toList();

                              return ListView.builder(
                                controller: scrollController,
                                itemCount: suggestions.length + 1,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  if (index == 0) {
                                    return const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'SUGGESTIONS',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  }

                                  final suggestion = suggestions[index - 1];
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _query = suggestion.name;
                                        _controller.text = suggestion.name;
                                      });
                                      context
                                          .read<LocationCubit>()
                                          .search(suggestion.name);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.search,
                                              color: Colors.brown),
                                          const SizedBox(width: 12),
                                          Text(suggestion.name,
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Text(
                                      '${filtered.length} result(s) nearby',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: filtered.length,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final location = filtered[index];
                                        return LocationTile(
                                          location: location,
                                          selected: location.id ==
                                              state.selectedLocationId,
                                          onTap: () {
                                            final cubit =
                                                context.read<LocationCubit>();
                                            final wasSelected = cubit
                                                    .state.selectedLocationId ==
                                                location.id;

                                            cubit.selectLocation(location.id);

                                            // Smoothly animate to the new location
                                            if (!wasSelected) {
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 300), () {
                                                final target = LatLng(
                                                    location.latitude,
                                                    location.longitude);

                                                _animatedMapController
                                                    .animateTo(
                                                  dest: target,
                                                  zoom: _animatedMapController
                                                      .mapController
                                                      .camera
                                                      .zoom,
                                                  curve: Curves.easeInOut,
                                                );
                                              });
                                            }
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }
                          }

                          // Default non-search list
                          final showLoader =
                              !_query.isNotEmpty && state.hasMore;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8.0, top: 4),
                                child: Text(
                                  '${locations.length} result(s) nearby',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  controller: scrollController,
                                  itemCount: showLoader
                                      ? locations.length + 1
                                      : locations.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    if (index >= locations.length) {
                                      return const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }

                                    final location = locations[index];
                                    return LocationTile(
                                      location: location,
                                      selected: location.id ==
                                          state.selectedLocationId,
                                      onTap: () {
                                        final cubit =
                                            context.read<LocationCubit>();
                                        final wasSelected =
                                            cubit.state.selectedLocationId ==
                                                location.id;

                                        cubit.selectLocation(location.id);

                                        if (!wasSelected) {
                                          Future.delayed(
                                              const Duration(milliseconds: 300),
                                              () {
                                            final target = LatLng(
                                                location.latitude,
                                                location.longitude);

                                            _animatedMapController.animateTo(
                                              dest: target,
                                              zoom: _animatedMapController
                                                  .mapController.camera.zoom,
                                              curve: Curves.easeInOut,
                                            );
                                          });
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the header row when search is inactive.
  Widget _buildSearchToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Branches',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          color: Colors.brown,
          onPressed: () => setState(() => _isSearchActive = true),
        ),
      ],
    );
  }

  /// Builds the search input field with a cancel button.
  Widget _buildSearchField() {
    return Row(
      children: [
        const Icon(Icons.search, color: Colors.brown),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (query) {
              setState(() => _query = query);
              context.read<LocationCubit>().search(query);
            },
            decoration: const InputDecoration(
              hintText: 'Search Branches...',
              border: InputBorder.none,
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _isSearchActive = false;
              _query = '';
              _controller.clear();
              FocusScope.of(context).unfocus();
            });
            context.read<LocationCubit>().clearSearch();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.brown)),
        ),
      ],
    );
  }
}
