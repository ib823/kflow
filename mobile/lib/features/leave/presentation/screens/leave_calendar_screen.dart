import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../shared/theme/app_theme.dart';

/// Leave event status enum
enum LeaveStatus {
  approved,
  pending,
  rejected,
  publicHoliday,
}

/// Leave event model
class LeaveEvent {
  final String id;
  final String title;
  final LeaveStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final String? employeeName; // For manager view
  final bool isOwnLeave;

  LeaveEvent({
    required this.id,
    required this.title,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.employeeName,
    this.isOwnLeave = true,
  });
}

/// S-050: Leave Calendar Screen
///
/// Monthly calendar view with:
/// - Color-coded leave events (approved/pending/rejected/holiday)
/// - Tap date to show leave details
/// - Month navigation
/// - Legend for colors
/// - Pull-to-refresh
/// - Team leaves for managers
class LeaveCalendarScreen extends ConsumerStatefulWidget {
  const LeaveCalendarScreen({super.key});

  @override
  ConsumerState<LeaveCalendarScreen> createState() => _LeaveCalendarScreenState();
}

class _LeaveCalendarScreenState extends ConsumerState<LeaveCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<LeaveEvent>> _events = {};
  bool _isLoading = true;

  // Mock data
  final bool _isManager = true; // Toggle to test manager view

  @override
  void initState() {
    super.initState();
    _loadEvents(_focusedDay);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadEvents(DateTime month) async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    // Generate mock events
    final now = DateTime.now();
    final mockEvents = <DateTime, List<LeaveEvent>>{};

    // Personal leaves
    final approved1 = _normalizeDate(DateTime(now.year, now.month, 10));
    final approved2 = _normalizeDate(DateTime(now.year, now.month, 11));
    mockEvents[approved1] = [
      LeaveEvent(
        id: '1',
        title: 'Annual Leave',
        status: LeaveStatus.approved,
        startDate: approved1,
        endDate: approved2,
        isOwnLeave: true,
      ),
    ];
    mockEvents[approved2] = [
      LeaveEvent(
        id: '1',
        title: 'Annual Leave',
        status: LeaveStatus.approved,
        startDate: approved1,
        endDate: approved2,
        isOwnLeave: true,
      ),
    ];

    // Pending leave
    final pending = _normalizeDate(DateTime(now.year, now.month, 20));
    mockEvents[pending] = [
      LeaveEvent(
        id: '2',
        title: 'Medical Leave',
        status: LeaveStatus.pending,
        startDate: pending,
        endDate: pending,
        isOwnLeave: true,
      ),
    ];

    // Rejected leave
    final rejected = _normalizeDate(DateTime(now.year, now.month, 5));
    mockEvents[rejected] = [
      LeaveEvent(
        id: '3',
        title: 'Emergency Leave',
        status: LeaveStatus.rejected,
        startDate: rejected,
        endDate: rejected,
        isOwnLeave: true,
      ),
    ];

    // Public holidays
    final holiday1 = _normalizeDate(DateTime(now.year, now.month, 1));
    mockEvents[holiday1] = [
      LeaveEvent(
        id: 'ph1',
        title: 'New Year\'s Day',
        status: LeaveStatus.publicHoliday,
        startDate: holiday1,
        endDate: holiday1,
        isOwnLeave: false,
      ),
    ];

    // Team members (for manager view)
    if (_isManager) {
      final teamLeave = _normalizeDate(DateTime(now.year, now.month, 15));
      final existing = mockEvents[teamLeave] ?? [];
      mockEvents[teamLeave] = [
        ...existing,
        LeaveEvent(
          id: '4',
          title: 'Annual Leave',
          status: LeaveStatus.approved,
          startDate: teamLeave,
          endDate: teamLeave,
          employeeName: 'Ahmad bin Ali',
          isOwnLeave: false,
        ),
        LeaveEvent(
          id: '5',
          title: 'Medical Leave',
          status: LeaveStatus.pending,
          startDate: teamLeave,
          endDate: teamLeave,
          employeeName: 'Siti Nurhaliza',
          isOwnLeave: false,
        ),
      ];
    }

    setState(() {
      _events = mockEvents;
      _isLoading = false;
    });
  }

  List<LeaveEvent> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  Color _getStatusColor(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return const Color(0xFF4CAF50); // Green
      case LeaveStatus.pending:
        return const Color(0xFFFFC107); // Yellow/Amber
      case LeaveStatus.rejected:
        return const Color(0xFFF44336); // Red
      case LeaveStatus.publicHoliday:
        return const Color(0xFFFF9800); // Orange
    }
  }

  String _getStatusLabel(LeaveStatus status) {
    switch (status) {
      case LeaveStatus.approved:
        return 'Approved';
      case LeaveStatus.pending:
        return 'Pending';
      case LeaveStatus.rejected:
        return 'Rejected';
      case LeaveStatus.publicHoliday:
        return 'Public Holiday';
    }
  }

  void _showDayDetails(DateTime day, List<LeaveEvent> events) {
    if (events.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Date header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${day.day}/${day.month}/${day.year}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              // Events list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _buildEventCard(event);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventCard(LeaveEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(event.status),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.employeeName != null && !event.isOwnLeave)
              Text(event.employeeName!),
            Text(
              _getStatusLabel(event.status),
              style: TextStyle(color: _getStatusColor(event.status)),
            ),
          ],
        ),
        trailing: event.status != LeaveStatus.publicHoliday
            ? const Icon(Icons.chevron_right)
            : null,
        onTap: event.status != LeaveStatus.publicHoliday
            ? () {
                Navigator.pop(context);
                if (event.status == LeaveStatus.pending && !event.isOwnLeave && _isManager) {
                  context.push('/approval/${event.id}');
                } else {
                  context.push('/leave/request/${event.id}');
                }
              }
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            tooltip: 'Today',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadEvents(_focusedDay),
        child: Column(
          children: [
            // Calendar
            TableCalendar<LeaveEvent>(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: _getEventsForDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                final events = _getEventsForDay(selectedDay);
                if (events.isNotEmpty) {
                  _showDayDetails(selectedDay, events);
                }
              },
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadEvents(focusedDay);
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                todayTextStyle: TextStyle(color: AppColors.primary),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return null;

                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: events.take(3).map((event) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: _getStatusColor(event.status),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),

            const Divider(height: 1),

            // Legend
            _buildLegend(),

            // Event list for selected day
            Expanded(
              child: _buildEventList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: AppColors.surfaceVariant,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Approved', LeaveStatus.approved),
          _buildLegendItem('Pending', LeaveStatus.pending),
          _buildLegendItem('Rejected', LeaveStatus.rejected),
          _buildLegendItem('Holiday', LeaveStatus.publicHoliday),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, LeaveStatus status) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEventList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final events = _selectedDay != null
        ? _getEventsForDay(_selectedDay!)
        : <LeaveEvent>[];

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _selectedDay != null
                  ? 'No events on this day'
                  : 'Select a date to view events',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: events.length,
      itemBuilder: (context, index) => _buildEventCard(events[index]),
    );
  }
}
