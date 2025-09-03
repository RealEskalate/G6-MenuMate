import 'package:flutter/material.dart';
import '../pages/opening_hours_page.dart';

class TimePickerWidget extends StatelessWidget {
  final TimeOfDay? openingTime;
  final TimeOfDay? closingTime;
  final Function(TimeOfDay) onOpeningTimeChanged;
  final Function(TimeOfDay) onClosingTimeChanged;

  const TimePickerWidget({
    Key? key,
    this.openingTime,
    this.closingTime,
    required this.onOpeningTimeChanged,
    required this.onClosingTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimePicker('Opening', openingTime, onOpeningTimeChanged),
              const SizedBox(width: 20),
              _buildTimePicker('Closing', closingTime, onClosingTimeChanged),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Get the parent context from the opening_hours_page
                  final state = context.findAncestorStateOfType<OpeningHoursPageState>();
                  if (state != null) {
                    state.setState(() {
                      state.showTimePicker = false;
                    });
                  }
                },
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // Get the parent context from the opening_hours_page
                  final state = context.findAncestorStateOfType<OpeningHoursPageState>();
                  if (state != null) {
                    state.setState(() {
                      state.showTimePicker = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(
      String label, TimeOfDay? time, Function(TimeOfDay) onTimeChanged) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final TimeOfDay? picked = await showTimePicker(
                context: navigatorKey.currentContext!,
                initialTime: time ?? TimeOfDay.now(),
              );
              if (picked != null) {
                onTimeChanged(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time != null
                        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                        : '00:00',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    time != null
                        ? (time.period == DayPeriod.am ? 'AM' : 'PM')
                        : 'AM',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Global navigator key for accessing context from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();