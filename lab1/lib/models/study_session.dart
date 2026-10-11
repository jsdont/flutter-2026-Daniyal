import 'package:flutter/material.dart';

enum SessionCategory {
  coding('Coding', Icons.code),
  languages('Languages', Icons.translate),
  math('Math', Icons.calculate_outlined),
  design('Design', Icons.palette_outlined),
  career('Career', Icons.work_outline);

  const SessionCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  Color color(ColorScheme scheme) => switch (this) {
    SessionCategory.coding => scheme.primary,
    SessionCategory.languages => scheme.secondary,
    SessionCategory.math => scheme.tertiary,
    SessionCategory.design => scheme.onSurfaceVariant,
    SessionCategory.career => scheme.onPrimaryContainer,
  };
}

class StudySession {
  const StudySession._({
    required this.id,
    required this.title,
    required this.category,
    required this.when,
    required this.limit,
    required this.names,
    required this.isOnline,
    required this.place,
    this.description,
    this.favourite = false,
  });

  factory StudySession({
    required String id,
    required String title,
    required SessionCategory category,
    required DateTime when,
    required int limit,
    required List<String> names,
    required bool isOnline,
    required String place,
    String? description,
    bool favourite = false,
  }) {
    return StudySession._(
      id: id,
      title: title,
      category: category,
      when: when,
      limit: limit,
      names: List<String>.unmodifiable(names),
      isOnline: isOnline,
      place: place,
      description: description,
      favourite: favourite,
    );
  }

  factory StudySession.empty() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    return StudySession(
      id: now.microsecondsSinceEpoch.toString(),
      title: '',
      category: SessionCategory.coding,
      when: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10),
      limit: 10,
      names: [],
      isOnline: false,
      place: '',
    );
  }

  final String id;
  final String title;
  final SessionCategory category;
  final DateTime when;
  final int limit;
  final List<String> names;
  final bool isOnline;
  final String place;
  final String? description;
  final bool favourite;

  int get count => names.length;
  int get freePlaces => (limit - count).clamp(0, limit);
  bool get isFull => count >= limit;
  bool get isPast => when.isBefore(DateTime.now());
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  bool contains(String name) {
    return names.any(
      (participant) =>
          participant.trim().toLowerCase() == name.trim().toLowerCase(),
    );
  }

  StudySession copyWith({
    String? id,
    String? title,
    SessionCategory? category,
    DateTime? when,
    int? limit,
    List<String>? names,
    bool? isOnline,
    String? place,
    String? description,
    bool clearDescription = false,
    bool? favourite,
  }) {
    return StudySession(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      when: when ?? this.when,
      limit: limit ?? this.limit,
      names: names ?? this.names,
      isOnline: isOnline ?? this.isOnline,
      place: place ?? this.place,
      description: clearDescription ? null : description ?? this.description,
      favourite: favourite ?? this.favourite,
    );
  }
}
