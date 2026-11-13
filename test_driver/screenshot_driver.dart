import 'dart:io';

import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver(
  writeResponseOnFailure: true,
  responseDataCallback: (data) async {
    final screenshots = data?['screenshots'] as List<dynamic>? ?? [];
    for (final shot in screenshots) {
      final file = File('docs/screenshots/${shot['screenshotName']}.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes((shot['bytes'] as List<dynamic>).cast<int>());
    }
    await File('docs/screenshot-count.txt').writeAsString(
      '${screenshots.length} Android emulator screenshots captured.\n',
    );
  },
);
