import 'package:flutter/material.dart';

import 'api/fake_api.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/student_list.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, required this.api});

  final FakeApi api;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<Student>? _students;
  Object? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _students = null;
      _error = null;
    });
    try {
      final students = await widget.api.fetchStudents();
      if (!mounted) return;
      setState(() => _students = students);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  Future<void> _save(BuildContext context) async {
    if (_saving || _students == null) return;
    setState(() => _saving = true);
    try {
      await widget.api.save(_students!.length);
      if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) return;
      Navigator.pop(context);
    } on StateError catch (e) {
      if (!context.mounted || ModalRoute.of(context)?.isCurrent != true) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Widget _body() {
    if (_error != null) return ErrorView(onRetry: _load);
    if (_students == null) return const LoadingView();
    if (_students!.isEmpty) return const EmptyView();
    return StudentList(students: _students!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('By hand'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: _students != null && !_saving ? _load : null,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _body(),
      floatingActionButton: _students == null
          ? null
          : FloatingActionButton(
              tooltip: 'Save',
              onPressed: _saving ? null : () => _save(context),
              child: _saving
                  ? const SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
            ),
    );
  }
}
