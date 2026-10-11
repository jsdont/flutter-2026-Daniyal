import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/profile.dart';
import '../models/study_session.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({
    super.key,
    required this.session,
    required this.profile,
    required this.onChanged,
    required this.onDeleted,
    required this.onOpenProfile,
  });

  final StudySession session;
  final Profile profile;
  final ValueChanged<StudySession> onChanged;
  final VoidCallback onDeleted;
  final VoidCallback onOpenProfile;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late StudySession _session;
  late Countdown _countdown;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    _countdown = Countdown.fromDate(_session.when);
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _countdown = Countdown.fromDate(_session.when);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateSession(StudySession session) {
    setState(() {
      _session = session;
      _countdown = Countdown.fromDate(session.when);
    });
    widget.onChanged(session);
  }

  Future<void> _editSession() async {
    final result = await Navigator.pushNamed<StudySession>(
      context,
      Routes.form,
      arguments: FormArguments(session: _session),
    );
    if (!mounted || result == null) return;
    _updateSession(result);
  }

  Future<void> _deleteSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete session?'),
        content: const Text('This study session will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    widget.onDeleted();
    Navigator.pop(context);
  }

  Future<void> _joinSession() async {
    final name = widget.profile.name.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first.'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: widget.onOpenProfile,
          ),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join this session?'),
        content: Text('Add $name to the participant list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _updateSession(_session.copyWith(names: [..._session.names, name]));
  }

  void _leaveSession() {
    final name = widget.profile.name.trim().toLowerCase();
    _updateSession(
      _session.copyWith(
        names: _session.names
            .where((participant) => participant.trim().toLowerCase() != name)
            .toList(),
      ),
    );
  }

  String _countdownText() {
    return switch (_countdown) {
      Upcoming(:final remaining) =>
        remaining.inDays > 0
            ? 'In ${remaining.inDays} days'
            : remaining.inHours > 0
            ? 'In ${remaining.inHours} h ${remaining.inMinutes % 60} min'
            : 'In ${remaining.inMinutes} min',
      Started(:final elapsed) => 'Started ${elapsed.inMinutes} min ago',
      Ended() => 'Ended',
    };
  }

  Widget _buildHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/study_header.png', fit: BoxFit.cover),
        Positioned(
          left: 16,
          bottom: 16,
          child: Chip(
            avatar: Icon(
              _session.category.icon,
              color: _session.category.color(colors),
            ),
            label: Text(_session.category.label),
          ),
        ),
        Positioned(
          right: 16,
          top: 16,
          child: Chip(label: Text(_countdownText())),
        ),
      ],
    );
  }

  Widget _buildAbout() {
    final (:taken, :free) = _session.places;
    final description = _session.description;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(_session.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Date and time'),
          subtitle: Text(formatDateTime(_session.when)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_session.isOnline ? 'Meeting link' : 'Meeting place'),
          subtitle: SelectableText(_session.place),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Places'),
          subtitle: Text('$taken of ${_session.limit} taken · $free free'),
        ),
        if (description != null) ...[
          const SizedBox(height: 16),
          Text(
            'About the session',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(description),
        ],
      ],
    );
  }

  Widget _buildParticipants() {
    if (_session.names.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        message: 'Nobody has joined this session yet.',
      );
    }
    final colors = Theme.of(context).colorScheme;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _session.names.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final name = _session.names[index];
        final isYou =
            name.trim().toLowerCase() ==
            widget.profile.name.trim().toLowerCase();
        return ListTile(
          tileColor: isYou ? colors.primaryContainer : null,
          title: Text(
            name,
            style: isYou
                ? Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)
                : null,
          ),
          trailing: isYou ? const Text('You') : null,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasJoined = _session.contains(widget.profile.name.trim());
    final canJoin = !_session.isFull && !_session.isPast;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study session'),
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') _editSession();
                if (value == 'delete') _deleteSession();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(flex: 2, child: _buildHeader(context)),
              TabBar(
                tabs: [
                  const Tab(text: 'About'),
                  Tab(text: 'Participants (${_session.count})'),
                ],
              ),
              Expanded(
                flex: 3,
                child: TabBarView(
                  children: [_buildAbout(), _buildParticipants()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: hasJoined
                        ? _leaveSession
                        : canJoin
                        ? _joinSession
                        : null,
                    icon: Icon(
                      hasJoined ? Icons.person_remove : Icons.person_add,
                    ),
                    label: Text(
                      hasJoined
                          ? 'Leave session'
                          : _session.isPast
                          ? 'Session has started'
                          : _session.isFull
                          ? 'Session is full'
                          : 'Join session',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
