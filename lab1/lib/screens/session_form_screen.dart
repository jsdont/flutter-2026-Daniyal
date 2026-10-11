import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../utils/format.dart';

class SessionFormScreen extends StatefulWidget {
  const SessionFormScreen({super.key, this.session});

  final StudySession? session;

  @override
  State<SessionFormScreen> createState() => _SessionFormScreenState();
}

class _SessionFormScreenState extends State<SessionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _limitController = TextEditingController();
  final _placeController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _titleFocus = FocusNode();
  final _categoryFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _descriptionFocus = FocusNode();

  late final StudySession _original;
  SessionCategory? _category;
  DateTime? _date;
  TimeOfDay? _time;
  late bool _isOnline;
  bool _dirty = false;
  bool _saving = false;
  bool _askingDiscard = false;

  @override
  void initState() {
    super.initState();
    _original = widget.session ?? StudySession.empty();
    _titleController.text = _original.title;
    _dateController.text = formatDate(_original.when);
    _timeController.text = formatTime(_original.when);
    _limitController.text = _original.limit.toString();
    _placeController.text = _original.place;
    _descriptionController.text = _original.description ?? '';
    _category = _original.category;
    _date = DateUtils.dateOnly(_original.when);
    _time = TimeOfDay.fromDateTime(_original.when);
    _isOnline = _original.isOnline;
  }

  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _dateController,
      _timeController,
      _limitController,
      _placeController,
      _descriptionController,
    ]) {
      controller.dispose();
    }
    for (final focus in [
      _titleFocus,
      _categoryFocus,
      _dateFocus,
      _timeFocus,
      _limitFocus,
      _placeFocus,
      _descriptionFocus,
    ]) {
      focus.dispose();
    }
    super.dispose();
  }

  DateTime? get _combinedDateTime {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool get _hasChanges =>
      _titleController.text != _original.title ||
      _category != _original.category ||
      !DateUtils.isSameDay(_date, _original.when) ||
      _time != TimeOfDay.fromDateTime(_original.when) ||
      _limitController.text != _original.limit.toString() ||
      _isOnline != _original.isOnline ||
      _placeController.text != _original.place ||
      _descriptionController.text != (_original.description ?? '');

  void _updateDirty() {
    final changed = _hasChanges;
    if (_dirty == changed) return;
    setState(() {
      _dirty = changed;
    });
  }

  String? _validateTitle(String? value) {
    final title = (value ?? '').trim();
    if (title.length < 3 || title.length > 60) {
      return 'Use 3 to 60 characters.';
    }
    return null;
  }

  String? _validateLimit(String? value) {
    final limit = int.tryParse((value ?? '').trim());
    if (limit == null || limit < 1 || limit > 500) {
      return 'Enter a whole number from 1 to 500.';
    }
    if (limit < _original.names.length) {
      return 'There are already ${_original.names.length} participants.';
    }
    return null;
  }

  String? _validatePlace(String? value) {
    final place = (value ?? '').trim();
    if (place.isEmpty) {
      return _isOnline ? 'Enter a meeting link.' : 'Enter a meeting place.';
    }
    if (_isOnline && !place.contains('://')) {
      return 'The link must contain ://, for example https://.';
    }
    return null;
  }

  String? _validateDate(String? value) {
    if (_date == null || value == null || value.isEmpty) {
      return 'Choose a date.';
    }
    return _validateFuture();
  }

  String? _validateTime(String? value) {
    if (_time == null || value == null || value.isEmpty) {
      return 'Choose a time.';
    }
    return _validateFuture();
  }

  String? _validateFuture() {
    final when = _combinedDateTime;
    if (widget.session == null &&
        when != null &&
        !when.isAfter(DateTime.now())) {
      return 'Choose a future date and time.';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(_original.when.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _date = picked;
      _dateController.text = formatDate(picked);
      _dirty = _hasChanges;
    });
    _timeFocus.requestFocus();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (!mounted) return;
    if (picked == null) return;
    setState(() {
      _time = picked;
      _timeController.text = formatTime(
        DateTime(2000, 1, 1, picked.hour, picked.minute),
      );
      _dirty = _hasChanges;
    });
    _limitFocus.requestFocus();
  }

  void _popAfterRebuild(StudySession? result) {
    setState(() {
      _dirty = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(result);
    });
  }

  Future<void> _onPopInvoked(bool didPop, StudySession? result) async {
    if (didPop || _askingDiscard || _saving) return;
    _askingDiscard = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    _askingDiscard = false;
    if (discard == true) _popAfterRebuild(null);
  }

  Future<void> _save() async {
    if (_saving) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;
    final category = _category;
    final when = _combinedDateTime;
    final limit = int.tryParse(_limitController.text.trim());
    if (category == null || when == null || limit == null) return;
    final description = _descriptionController.text.trim();
    final item = _original.copyWith(
      title: _titleController.text.trim(),
      category: category,
      when: when,
      limit: limit,
      isOnline: _isOnline,
      place: _placeController.text.trim(),
      description: description.isEmpty ? null : description,
      clearDescription: description.isEmpty,
    );
    setState(() {
      _saving = true;
    });
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _popAfterRebuild(item);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<StudySession>(
      canPop: !_dirty,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.session == null ? 'New study session' : 'Edit session',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        focusNode: _titleFocus,
                        enabled: !_saving,
                        decoration: const InputDecoration(labelText: 'Title'),
                        maxLength: 60,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: _validateTitle,
                        onChanged: (_) => _updateDirty(),
                        onFieldSubmitted: (_) => _categoryFocus.requestFocus(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<SessionCategory>(
                        initialValue: _category,
                        focusNode: _categoryFocus,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        isExpanded: true,
                        items: [
                          for (final category in SessionCategory.values)
                            DropdownMenuItem(
                              value: category,
                              child: Text(category.label),
                            ),
                        ],
                        validator: (value) =>
                            value == null ? 'Choose a category.' : null,
                        onChanged: _saving
                            ? null
                            : (value) {
                                setState(() {
                                  _category = value;
                                  _dirty = _hasChanges;
                                });
                                _dateFocus.requestFocus();
                              },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        focusNode: _dateFocus,
                        enabled: !_saving,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.next,
                        validator: _validateDate,
                        onTap: _pickDate,
                        onFieldSubmitted: (_) => _timeFocus.requestFocus(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timeController,
                        focusNode: _timeFocus,
                        enabled: !_saving,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          suffixIcon: Icon(Icons.schedule),
                        ),
                        keyboardType: TextInputType.datetime,
                        textInputAction: TextInputAction.next,
                        validator: _validateTime,
                        onTap: _pickTime,
                        onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _limitController,
                        focusNode: _limitFocus,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          labelText: 'Participant limit',
                        ),
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: _validateLimit,
                        onChanged: (_) => _updateDirty(),
                        onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Online session'),
                        value: _isOnline,
                        onChanged: _saving
                            ? null
                            : (value) {
                                setState(() {
                                  _isOnline = value;
                                  _dirty = _hasChanges;
                                });
                              },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _placeController,
                        focusNode: _placeFocus,
                        enabled: !_saving,
                        decoration: InputDecoration(
                          labelText: _isOnline
                              ? 'Meeting link'
                              : 'Meeting place',
                        ),
                        keyboardType: _isOnline
                            ? TextInputType.url
                            : TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: _validatePlace,
                        onChanged: (_) => _updateDirty(),
                        onFieldSubmitted: (_) =>
                            _descriptionFocus.requestFocus(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        focusNode: _descriptionFocus,
                        enabled: !_saving,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                        ),
                        minLines: 3,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.done,
                        validator: (_) => null,
                        onChanged: (_) => _updateDirty(),
                        onFieldSubmitted: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Text('Save'),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
