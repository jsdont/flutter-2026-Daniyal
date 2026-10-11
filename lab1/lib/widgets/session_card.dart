import 'package:flutter/material.dart';

import '../models/study_session.dart';
import '../utils/format.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
    required this.onFavourite,
  });

  final StudySession session;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 27,
                      backgroundColor: scheme.surfaceContainerHighest,
                      child: Icon(
                        session.category.icon,
                        color: session.category.color(scheme),
                      ),
                    ),
                    if (session.freePlaces <= 5)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: session.isFull
                                ? scheme.errorContainer
                                : scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            session.isFull
                                ? 'FULL'
                                : '${session.freePlaces} left',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: session.isFull
                                  ? scheme.onErrorContainer
                                  : scheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDateTime(session.when),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      session.isOnline
                          ? 'Online · ${session.place}'
                          : session.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: session.favourite
                    ? 'Remove from favourites'
                    : 'Add to favourites',
                onPressed: onFavourite,
                icon: Icon(
                  session.favourite ? Icons.favorite : Icons.favorite_border,
                  color: session.favourite ? scheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
