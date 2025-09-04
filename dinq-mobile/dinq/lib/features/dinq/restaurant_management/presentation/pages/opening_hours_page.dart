import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/opening_hours/opening_hours_bloc.dart';
import '../bloc/opening_hours/opening_hours_event.dart';
import '../bloc/opening_hours/opening_hours_state.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/special_day_item.dart';
import '../widgets/time_picker_widget.dart';

class OpeningHoursPage extends StatefulWidget {
  const OpeningHoursPage({super.key});

  @override
  State<OpeningHoursPage> createState() => OpeningHoursPageState();
}

// Make the state class public so it can be accessed from time_picker_widget.dart

class OpeningHoursPageState extends State<OpeningHoursPage> {
  DateTime _selectedDate = DateTime.now();
  int _selectedDayIndex = 0; // 0 = Monday, 1 = Tuesday, etc.
  // Make this field public so it can be accessed from time_picker_widget.dart
  bool showTimePicker = false;
  bool _showAddSpecialDay = false;
  bool _isOpeningTime = true; // Whether we're selecting opening or closing time
  
  // Controllers for adding special days
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  
  late OpeningHoursBloc _openingHoursBloc;
  
  @override
  void initState() {
    super.initState();
    _openingHoursBloc = OpeningHoursBloc();
    _openingHoursBloc.add(const LoadOpeningHours());
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _statusController.dispose();
    _openingHoursBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OpeningHoursBloc>(
      create: (_) => _openingHoursBloc,
      child: BlocConsumer<OpeningHoursBloc, OpeningHoursState>(
        listener: (context, state) {
          if (state is OpeningHoursSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Changes saved successfully')),
            );
          } else if (state is OpeningHoursError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Settings'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              actions: [
                if (state is OpeningHoursLoaded)
                  TextButton(
                    onPressed: state.hasChanges
                        ? () {
                            context.read<OpeningHoursBloc>().add(const SaveOpeningHours());
                          }
                        : null,
                    child: state is OpeningHoursSaving
                        ? const CircularProgressIndicator(color: Colors.orange)
                        : const Text('Save Changes', style: TextStyle(color: Colors.orange)),
                  ),
              ],
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Stack(
              children: [
                if (state is OpeningHoursLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.orange))
                else if (state is OpeningHoursLoaded)
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Opening and closing hours',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        _buildCalendar(state),
                        const SizedBox(height: 24),
                        _buildSpecialDaysSection(state),
                      ],
                    ),
                  ),
                if (showTimePicker && state is OpeningHoursLoaded) _buildTimePickerOverlay(state),
                if (_showAddSpecialDay) _buildAddSpecialDayOverlay(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_border),
                  label: 'Favorites',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics_outlined),
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Menu',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              currentIndex: 4, // Settings tab
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar(OpeningHoursLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CalendarWidget(
          initialDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
              showTimePicker = true;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildWeeklyHours(state),
      ],
    );
  }
  
  Widget _buildWeeklyHours(OpeningHoursLoaded state) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Hours',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...List.generate(7, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(days[index], style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                        _isOpeningTime = true;
                        showTimePicker = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        state.openingTimes[index] != null
                            ? '${state.openingTimes[index]!.hour}:${state.openingTimes[index]!.minute.toString().padLeft(2, '0')}'
                            : 'Set time',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('to'),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                        _isOpeningTime = false;
                        showTimePicker = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        state.closingTimes[index] != null
                            ? '${state.closingTimes[index]!.hour}:${state.closingTimes[index]!.minute.toString().padLeft(2, '0')}'
                            : 'Set time',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSpecialDaysSection(OpeningHoursLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Special days',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {
                setState(() {
                  _showAddSpecialDay = true;
                  _titleController.clear();
                  _statusController.clear();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Add holiday closures or happy hours.',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...state.specialDays.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;
          return SpecialDayItem(
              date: '${day.date.month}/${day.date.day}/${day.date.year}',
              title: day.title,
              status: day.status,
              onDelete: () {
                context.read<OpeningHoursBloc>().add(RemoveSpecialDay(index));
              },
            );
        }),
        if (state.specialDays.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No special days added yet',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimePickerOverlay(OpeningHoursLoaded state) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showTimePicker = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: TimePickerWidget(
            openingTime: _isOpeningTime ? state.openingTimes[_selectedDayIndex] : null,
            closingTime: !_isOpeningTime ? state.closingTimes[_selectedDayIndex] : null,
            onOpeningTimeChanged: (time) {
              if (_isOpeningTime) {
                context.read<OpeningHoursBloc>().add(UpdateOpeningTime(time, _selectedDayIndex));
                setState(() {
                  showTimePicker = false;
                });
              }
            },
            onClosingTimeChanged: (time) {
              if (!_isOpeningTime) {
                context.read<OpeningHoursBloc>().add(UpdateClosingTime(time, _selectedDayIndex));
                setState(() {
                  showTimePicker = false;
                });
              }
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildAddSpecialDayOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAddSpecialDay = false;
        });
      },
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Special Day',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title (e.g. Holiday name)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _statusController,
                  decoration: const InputDecoration(
                    labelText: 'Status (e.g. Closed, Open 10AM-2PM)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAddSpecialDay = false;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_titleController.text.isNotEmpty && _statusController.text.isNotEmpty) {
                          context.read<OpeningHoursBloc>().add(AddSpecialDay(
                            date: _selectedDate,
                            title: _titleController.text,
                            status: _statusController.text,
                          ));
                          setState(() {
                            _showAddSpecialDay = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}