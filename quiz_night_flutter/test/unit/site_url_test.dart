import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/app/app_paths.dart';
import 'package:quiz_night_flutter/core/platform/site_url.dart';

void main() {
  group('Given the site address', () {
    test('when the host is deep in a room then the root drops the path', () {
      expect(
        siteRoot(Uri.parse('https://quiz.example.com:8443/room/4821?x=1')),
        Uri.parse('https://quiz.example.com:8443/'),
      );
    });

    test('when there is no web origin then the address is kept', () {
      final file = Uri.parse('file:///tmp/app');
      expect(siteRoot(file), file);
    });
  });

  group('Given the app paths', () {
    test('when joining with or without a code then the link fits', () {
      expect(AppPaths.joinWith('4821'), '/join?code=4821');
      expect(AppPaths.joinWith(null), '/join');
      expect(AppPaths.joinWith(''), '/join');
      expect(AppPaths.roomFor('4821'), '/room/4821');
    });
  });
}
