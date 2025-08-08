import 'package:flutter/material.dart';
import '../../../data_layer/models/location.dart';

/// A UI tile that displays a single location with image, address, status, and a SELECT button.
class LocationTile extends StatelessWidget {
  final Location location;
  final bool selected;
  final VoidCallback onTap;

  const LocationTile({
    super.key,
    required this.location,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusText = getStatusText(location);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.brown.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.brown : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            )
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Store image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                location.imgUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 14),

            // Store info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    location.shortAddress,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),

                  // Optional status badge
                  if (statusText != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusText == 'Closed Temporarily'
                            ? Colors.red.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: statusText == 'Closed Temporarily'
                              ? Colors.red
                              : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // SELECT button
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor:
                    selected ? Colors.brown : Colors.brown.shade300,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('SELECT'),
            ),
          ],
        ),
      ),
    );
  }

  /// Returns a status label based on the location's [isEnabled] state and `disableUntil` timestamp.
  ///
  /// - "Closed Temporarily" if disabled and still within the disabled time window
  /// - "Closing Soon" if now is past the disableUntil date
  String? getStatusText(Location location) {
    final now = DateTime.now();
    final disableUntil = DateTime.tryParse(location.disableUntil ?? '');

    if (location.isEnabled == false &&
        disableUntil != null &&
        now.isBefore(disableUntil)) {
      return 'Closed Temporarily';
    }

    if (location.isEnabled &&
        disableUntil != null &&
        now.isAfter(disableUntil)) {
      return 'Closing Soon';
    }

    return null;
  }
}
