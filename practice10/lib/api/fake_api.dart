import 'package:flutter/foundation.dart';

class Student {
  const Student({required this.name, required this.group, this.gpa});

  final String name;
  final String group;
  final double? gpa;
}

class NoConnectionException implements Exception {}

const _seed = [
  Student(name: 'Aida Nurlanova', group: 'IT-2301', gpa: 3.7),
  Student(name: 'Dias Seitkali', group: 'IT-2301', gpa: 3.1),
  Student(name: 'Aruzhan Bek', group: 'IT-2302'),
  Student(name: 'Timur Alibekov', group: 'IT-2302', gpa: 2.9),
  Student(name: 'Dana Omarova', group: 'IT-2303', gpa: 3.9),
  Student(name: 'Alikhan Kairatuly', group: 'IT-2303', gpa: 3.4),
];

class FakeApi {
  FakeApi({this.empty = false});

  final bool empty;
  int calls = 0;
  int _saves = 0;

  Future<List<Student>> fetchStudents() async {
    final request = ++calls;
    debugPrint('fetchStudents #$request');
    await Future<void>.delayed(const Duration(seconds: 2));
    if (request % 3 == 0) throw NoConnectionException();
    return empty ? const [] : _seed;
  }

  Future<void> save(int value) async {
    final request = ++_saves;
    await Future<void>.delayed(const Duration(seconds: 1));
    if (request.isEven) throw StateError('server rejected $value');
  }
}
