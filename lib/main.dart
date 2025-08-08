import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'business_layer/location_cubit.dart';
import 'data_layer/repositories/location_repository.dart';
import 'presentation_layer/pages/location/location_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final locationRepository = LocationRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blank Street',
      home: BlocProvider(
        create: (_) => LocationCubit(locationRepository)..loadInitial(),
        child: LocationScreen(),
      ),
    );
  }
}
