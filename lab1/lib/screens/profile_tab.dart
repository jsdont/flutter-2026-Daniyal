import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/study_session.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.sessions,
    required this.onChanged,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final Profile profile;
  final List<StudySession> sessions;
  final ValueChanged<Profile> onChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocus = FocusNode();
  final _groupFocus = FocusNode();
  late TextEditingController _nameController;
  late TextEditingController _groupController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.name != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }
    if (oldWidget.profile.group != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    _nameFocus.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.length < 2) return 'Enter at least 2 characters.';
    return null;
  }

  String? _validateGroup(String? value) {
    final group = value?.trim() ?? '';
    final groupPattern = RegExp(r'^[A-Za-z0-9]+(?:-[A-Za-z0-9]+)*$');
    if (!groupPattern.hasMatch(group)) {
      return 'Use letters, numbers and dashes, e.g. CS-2401.';
    }
    return null;
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() != true) return;
    widget.onChanged(
      widget.profile.copyWith(
        name: _nameController.text.trim(),
        group: _groupController.text.trim(),
      ),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved.')));
  }

  @override
  Widget build(BuildContext context) {
    final joinedCount = widget.sessions.fold<int>(
      0,
      (total, session) =>
          total + (session.contains(widget.profile.name) ? 1 : 0),
    );
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Your study profile', style: textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Press Enter or Done on the keyboard to save your profile.'),
        const SizedBox(height: 24),
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: const InputDecoration(labelText: 'Name'),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: _validateName,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onFieldSubmitted: (_) {
                  _saveProfile();
                  _groupFocus.requestFocus();
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupController,
                focusNode: _groupFocus,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'CS-2401',
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                validator: _validateGroup,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                onFieldSubmitted: (_) => _saveProfile(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('You are on $joinedCount lists.', style: textTheme.titleMedium),
        const SizedBox(height: 32),
        Text('Appearance', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('System'),
              selected: widget.themeMode == ThemeMode.system,
              onSelected: (_) => widget.onThemeChanged(ThemeMode.system),
            ),
            ChoiceChip(
              label: const Text('Light'),
              selected: widget.themeMode == ThemeMode.light,
              onSelected: (_) => widget.onThemeChanged(ThemeMode.light),
            ),
            ChoiceChip(
              label: const Text('Dark'),
              selected: widget.themeMode == ThemeMode.dark,
              onSelected: (_) => widget.onThemeChanged(ThemeMode.dark),
            ),
          ],
        ),
      ],
    );
  }
}
