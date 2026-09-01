import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:c_qube/core/constants/app_colors.dart';
import 'package:c_qube/core/constants/app_constants.dart';
import 'package:c_qube/core/constants/app_typography.dart';
import 'package:c_qube/core/utils/validator_utils.dart';
import 'package:c_qube/models/event_model.dart';
import 'package:c_qube/shared/widgets/custom_button.dart';
import 'package:c_qube/shared/widgets/custom_text_field.dart';
import 'package:c_qube/state/auth_state.dart';
import 'package:c_qube/state/club_state.dart';
import 'package:c_qube/state/student_state.dart';

class HostEventScreen extends StatefulWidget {
  const HostEventScreen({super.key});

  @override
  State<HostEventScreen> createState() => _HostEventScreenState();
}

class _HostEventScreenState extends State<HostEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController(text: '100');

  EventCategory _selectedCategory = EventCategory.workshop;
  DateTime _eventDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _startTime = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  bool _isOnline = false;
  bool _isBeginnerFriendly = true;
  final String _bannerUrl = 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1200&q=80';

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _handlePublish() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = Provider.of<AuthState>(context, listen: false);
    final clubState = Provider.of<ClubState>(context, listen: false);
    final club = authState.currentClub;

    if (club == null) return;

    final startDateTime = DateTime(
      _eventDate.year,
      _eventDate.month,
      _eventDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    final endDateTime = DateTime(
      _eventDate.year,
      _eventDate.month,
      _eventDate.day,
      _endTime.hour,
      _endTime.minute,
    );

    final newEvent = EventModel(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      clubId: club.id,
      clubName: club.name,
      clubLogoUrl: club.logoUrl,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      bannerUrl: _bannerUrl,
      category: _selectedCategory,
      date: _eventDate,
      startTime: startDateTime,
      endTime: endDateTime,
      location: _isOnline ? 'Online Google Meet' : _locationController.text.trim(),
      capacity: int.tryParse(_capacityController.text) ?? 100,
      registrationDeadline: _eventDate.subtract(const Duration(hours: 12)),
      isOnline: _isOnline,
      isBeginnerFriendly: _isBeginnerFriendly,
    );

    await clubState.createEvent(newEvent);

    if (mounted) {
      final studentState = Provider.of<StudentState>(context, listen: false);
      await studentState.loadAllEvents();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Event "${newEvent.title}" published to Campus Calendar!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Host Campus Event'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                label: 'Event Title',
                hintText: 'e.g. Flutter Mobile Dev Hackathon 2026',
                controller: _titleController,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Event title'),
              ),
              const SizedBox(height: 18),

              CustomTextField(
                label: 'Description & Agenda',
                hintText: 'Detailed itinerary, requirements, and takeaways for students...',
                controller: _descController,
                maxLines: 4,
                validator: (v) => ValidatorUtils.validateRequired(v, 'Description'),
              ),
              const SizedBox(height: 18),

              // Category Selector
              Text('Event Category', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              DropdownButtonFormField<EventCategory>(
                value: _selectedCategory,
                items: EventCategory.values
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase(), style: AppTypography.bodyMedium)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 18),

              // Date Picker
              Text('Date of Event', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _eventDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 180)),
                  );
                  if (picked != null) setState(() => _eventDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(DateFormat('EEEE, MMM d, yyyy').format(_eventDate), style: AppTypography.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Start & End Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Time', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _startTime);
                            if (picked != null) setState(() => _startTime = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Text(_startTime.format(context), style: AppTypography.bodyMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('End Time', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(context: context, initialTime: _endTime);
                            if (picked != null) setState(() => _endTime = picked);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                            child: Text(_endTime.format(context), style: AppTypography.bodyMedium),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Venue & Capacity
              if (!_isOnline)
                CustomTextField(
                  label: 'Campus Location / Room',
                  hintText: 'e.g. CS Seminar Hall B, 3rd Floor',
                  controller: _locationController,
                  validator: (v) => _isOnline ? null : ValidatorUtils.validateRequired(v, 'Venue location'),
                ),
              if (!_isOnline) const SizedBox(height: 18),

              CustomTextField(
                label: 'Max Seat Capacity',
                hintText: '100',
                controller: _capacityController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 18),

              // Toggles
              SwitchListTile(
                title: const Text('Online Event (Virtual Room)'),
                value: _isOnline,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isOnline = v),
              ),
              SwitchListTile(
                title: const Text('Beginner Friendly (No prior experience)'),
                value: _isBeginnerFriendly,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isBeginnerFriendly = v),
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'Publish Event to Calendar',
                onPressed: _handlePublish,
                variant: ButtonVariant.primary,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
