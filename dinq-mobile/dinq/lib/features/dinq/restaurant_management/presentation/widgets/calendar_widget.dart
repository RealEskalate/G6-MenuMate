import 'package:flutter/material.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;

  const CalendarWidget({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMonthHeader(),
              const SizedBox(height: 8),
              _buildCalendarGrid(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _displayedMonth = DateTime(
                  _displayedMonth.year, _displayedMonth.month - 1, 1);
            });
          },
        ),
        Row(
          children: [
            Text(
              _getMonthName(_displayedMonth.month),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Text(
              _displayedMonth.year.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _displayedMonth = DateTime(
                  _displayedMonth.year, _displayedMonth.month + 1, 1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    return Column(
      children: [
        _buildWeekdayHeader(),
        const SizedBox(height: 8),
        _buildDaysGrid(),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    final weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map((day) => Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final firstWeekdayOfMonth = firstDayOfMonth.weekday % 7; // 0 for Sunday

    // Previous month days
    final previousMonthDays = firstWeekdayOfMonth;
    final previousMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    final daysInPreviousMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 0).day;

    // Next month days
    final totalCells = 42; // 6 rows of 7 days
    final nextMonthDays = totalCells - daysInMonth - previousMonthDays;

    List<Widget> dayWidgets = [];

    // Add previous month days
    for (int i = 0; i < previousMonthDays; i++) {
      final day = daysInPreviousMonth - previousMonthDays + i + 1;
      dayWidgets.add(_buildDayCell(
        day,
        DateTime(previousMonth.year, previousMonth.month, day),
        isCurrentMonth: false,
      ));
    }

    // Add current month days
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, i);
      dayWidgets.add(_buildDayCell(
        i,
        date,
        isCurrentMonth: true,
        isSelected: _isSameDay(date, _selectedDate),
      ));
    }

    // Add next month days
    final nextMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    for (int i = 1; i <= nextMonthDays; i++) {
      dayWidgets.add(_buildDayCell(
        i,
        DateTime(nextMonth.year, nextMonth.month, i),
        isCurrentMonth: false,
      ));
    }

    // Get screen width to make calendar responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final cellSize = (screenWidth - 32) / 7; // 32 for padding
    
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      childAspectRatio: 1.0,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: const NeverScrollableScrollPhysics(),
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(int day, DateTime date, {
    bool isCurrentMonth = true,
    bool isSelected = false,
  }) {
    final isToday = _isSameDay(date, DateTime.now());

    return GestureDetector(
      onTap: () {
        if (isCurrentMonth) {
          setState(() {
            _selectedDate = date;
          });
          widget.onDateSelected(date);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isToday && !isSelected
              ? Border.all(color: Colors.orange, width: 1)
              : null,
        ),
        child: Center(
          child: Text(
            day.toString(),
            style: TextStyle(
              fontSize: 13,
              color: !isCurrentMonth
                  ? Colors.grey.shade400
                  : isSelected
                      ? Colors.white
                      : Colors.black,
              fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}