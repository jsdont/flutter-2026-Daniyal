import 'package:flutter/material.dart';

import 'models/profile.dart';
import 'models/study_session.dart';

class Routes {
  static const home = '/';
  static const detail = '/detail';
  static const form = '/form';
}

class DetailArguments {
  final StudySession session;
  final Profile profile;
  final ValueChanged<StudySession> onChanged;
  final VoidCallback onDeleted;
  final VoidCallback onOpenProfile;

  const DetailArguments({
    required this.session,
    required this.profile,
    required this.onChanged,
    required this.onDeleted,
    required this.onOpenProfile,
  });
}

class FormArguments {
  final StudySession? session;

  const FormArguments({this.session});
}
