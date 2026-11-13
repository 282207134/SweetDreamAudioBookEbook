import 'package:flutter/material.dart';

import 'app.dart';
import 'core/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.restore();
  runApp(SweetDreamApp(state: state));
}
