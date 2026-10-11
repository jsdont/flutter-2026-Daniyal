import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/profile.dart';
import '../models/study_session.dart';
import '../routes.dart';
import 'profile_tab.dart';
import 'session_list_tab.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  List<StudySession> _sessions = createSeedSessions();
  Profile _profile = const Profile.empty();
  int _selectedTab = 0;
  int _resetVersion = 0;

  void _selectTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  void _updateSession(StudySession updated) {
    final sessions = _sessions
        .map((session) => session.id == updated.id ? updated : session)
        .toList();
    setState(() {
      _sessions = sessions;
    });
  }

  void _deleteSession(String id) {
    final sessions = _sessions.where((session) => session.id != id).toList();
    setState(() {
      _sessions = sessions;
    });
  }

  void _toggleFavourite(StudySession session) {
    _updateSession(session.copyWith(favourite: !session.favourite));
  }

  void _openProfile() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _selectTab(2);
  }

  void _openSession(StudySession session) {
    Navigator.pushNamed<void>(
      context,
      Routes.detail,
      arguments: DetailArguments(
        session: session,
        profile: _profile,
        onChanged: _updateSession,
        onDeleted: () => _deleteSession(session.id),
        onOpenProfile: _openProfile,
      ),
    );
  }

  Future<void> _createSession() async {
    final result = await Navigator.pushNamed<StudySession>(
      context,
      Routes.form,
      arguments: const FormArguments(),
    );
    if (!mounted || result == null) return;
    setState(() {
      _sessions = [..._sessions, result];
    });
  }

  void _showAbout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Study Meet'),
        content: const Text(
          'Study Meet helps students find and join study sessions. '
          'You can create sessions, save favourites and manage your profile. '
          'Data stays in memory and is cleared when the app restarts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'Restore the sample sessions and clear your profile? '
          'Your changes will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final sessions = createSeedSessions();
    setState(() {
      _sessions = sessions;
      _profile = const Profile.empty();
      _selectedTab = 0;
      _resetVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    const titles = ['Study Meet', 'Favourites', 'Profile'];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedTab])),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Study Meet',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              ListTile(
                title: const Text('About'),
                onTap: () {
                  Navigator.pop(context);
                  _showAbout();
                },
              ),
              ListTile(
                title: const Text('Reset data'),
                onTap: () {
                  Navigator.pop(context);
                  _resetData();
                },
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: IndexedStack(
          key: ValueKey(_resetVersion),
          index: _selectedTab,
          children: [
            SessionListTab(
              sessions: _sessions,
              onOpen: _openSession,
              onFavourite: _toggleFavourite,
            ),
            SessionListTab(
              sessions: _sessions,
              favouritesOnly: true,
              onOpen: _openSession,
              onFavourite: _toggleFavourite,
              onBrowse: () => _selectTab(0),
            ),
            ProfileTab(
              profile: _profile,
              sessions: _sessions,
              onChanged: (profile) {
                setState(() {
                  _profile = profile;
                });
              },
              themeMode: widget.themeMode,
              onThemeChanged: widget.onThemeChanged,
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTab == 2
          ? null
          : FloatingActionButton(
              tooltip: 'New session',
              onPressed: _createSession,
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
