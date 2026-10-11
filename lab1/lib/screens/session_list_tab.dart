import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../widgets/empty_state.dart';
import '../widgets/session_card.dart';

class SessionListTab extends StatefulWidget {
  const SessionListTab({
    super.key,
    required this.sessions,
    required this.onOpen,
    required this.onFavourite,
    this.favouritesOnly = false,
    this.onBrowse,
  });

  final List<StudySession> sessions;
  final ValueChanged<StudySession> onOpen;
  final ValueChanged<StudySession> onFavourite;
  final bool favouritesOnly;
  final VoidCallback? onBrowse;

  @override
  State<SessionListTab> createState() => _SessionListTabState();
}

class _SessionListTabState extends State<SessionListTab> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  SessionCategory? _category;
  bool _includePast = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  Widget _buildCard(StudySession session) {
    return SessionCard(
      session: session,
      onTap: () => widget.onOpen(session),
      onFavourite: () => widget.onFavourite(session),
    );
  }

  @override
  Widget build(BuildContext context) {
    final search = _query.trim().toLowerCase();
    final sessions = widget.sessions.where((session) {
      return (!widget.favouritesOnly || session.favourite) &&
          (_category == null || session.category == _category) &&
          (_includePast || !session.isPast) &&
          session.title.toLowerCase().contains(search);
    }).toList();

    sessions.sort((first, second) {
      if (first.isPast != second.isPast) {
        return first.isPast ? 1 : -1;
      }
      return first.when.compareTo(second.when);
    });

    final noFavourites =
        widget.favouritesOnly &&
        !widget.sessions.any((session) => session.favourite);

    return LayoutBuilder(
      builder: (context, constraints) {
        final showGrid = constraints.maxWidth >= 600;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            children: [
              TextFormField(
                controller: _searchController,
                focusNode: _searchFocus,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Search sessions',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear),
                        ),
                ),
                validator: (value) => null,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                onFieldSubmitted: (value) => _searchFocus.unfocus(),
                onTapOutside: (event) => _searchFocus.unfocus(),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: _category == null,
                      onSelected: (selected) {
                        setState(() {
                          _category = null;
                        });
                      },
                    ),
                    for (final category in SessionCategory.values)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ChoiceChip(
                          avatar: Icon(category.icon, size: 18),
                          label: Text(category.label),
                          selected: _category == category,
                          onSelected: (selected) {
                            setState(() {
                              _category = selected ? category : null;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: const Text('Include past'),
                  selected: _includePast,
                  onSelected: (selected) {
                    setState(() {
                      _includePast = selected;
                    });
                  },
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: noFavourites
                    ? EmptyState(
                        icon: Icons.favorite_border,
                        message: 'No favourites yet. Save a session you like.',
                        buttonLabel: 'Browse sessions',
                        onPressed: widget.onBrowse,
                      )
                    : sessions.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        message: 'No sessions match your search or filters.',
                        buttonLabel: 'Clear search',
                        onPressed: _clearSearch,
                      )
                    : showGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.only(bottom: 88),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 360,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 1.55,
                            ),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) =>
                            _buildCard(sessions[index]),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 88),
                        itemCount: sessions.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) =>
                            _buildCard(sessions[index]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
