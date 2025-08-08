# Blank Street Store Locator

A Flutter demo app that displays store locations on an interactive map. Users can search, select, and explore branches using a draggable list and animated map markers. Built with clean architecture, Bloc state management, and comprehensive unit testing.

---

## Folder Structure

```
lib/
├── business_layer/        # Cubit & State for location logic
├── data_layer/            # Models, providers, and repository
├── presentation_layer/    # UI widgets and pages
└── main.dart              # Entry point
```

---

## Tech Stack

- **Flutter SDK:** 3.27.4
- **State Management:** flutter_bloc (Cubit)
- **Map:** flutter_map + flutter_map_animations
- **Networking:** Dio
- **Model Equality:** Equatable
- **Testing:** flutter_test, bloc_test, mocktail

---

## Features

- Interactive map powered by OpenStreetMap
- Smooth zoom & pan animations with `flutter_map_animations`
- Draggable bottom sheet for browsing locations
- Infinite scroll pagination with debounce
- Case-insensitive location search
- Marker tap syncs with list (and vice versa)
- Toggle selection with visual feedback
- Graceful error handling and messaging
- Clean architecture with clear separation of concerns
- Comprehensive unit tests with mocked APIs

---

## Testing

Run all tests:

```bash
flutter test
```

Includes unit tests for:
- Initial loading
- Pagination
- Search and clear logic
- Error handling
- Location selection toggle

---