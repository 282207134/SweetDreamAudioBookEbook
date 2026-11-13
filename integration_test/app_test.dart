import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sweet_dream/app.dart';
import 'package:sweet_dream/core/app_state.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Full workflow and screenshot matrix on the existing Android emulator',
    (tester) async {
      AppState? state;
      var sequence = 0;
      Future<void> mount(String view, {bool dark = false}) async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(milliseconds: 300));
        state?.dispose();
        state = AppState()
          ..dark = dark
          ..welcomed = true;
        await tester.pumpWidget(
          SweetDreamApp(
            key: ValueKey(sequence++),
            state: state!,
            initialView: view,
          ),
        );
        await tester.pumpAndSettle();
      }

      Future<void> capture(String name) async {
        await tester.pump(const Duration(milliseconds: 400));
        expect(
          tester.takeException(),
          isNull,
          reason: 'No layout or framework errors in $name',
        );
        await binding.takeScreenshot(name);
      }

      await mount('home');
      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('nav-1')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('search-field')),
        'unknown book',
      );
      await tester.pumpAndSettle();
      expect(find.text('No books found'), findsOneWidget);
      await capture('extra-search-empty');
      await tester.enterText(find.byKey(const Key('search-field')), 'Kubo');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('book-kubo')), findsOneWidget);
      expect(find.byKey(const Key('book-prince')), findsNothing);
      await tester.tap(find.text('Buy book'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('save-card')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-purchase')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to library'));
      await tester.pumpAndSettle();
      expect(state!.library.contains('kubo'), isTrue);
      expect(find.text('Listen now'), findsWidgets);
      await state!.save();
      final restored = AppState();
      await restored.restore();
      expect(restored.library.contains('kubo'), isTrue);
      restored.dispose();

      await mount('player');
      await tester.tap(find.byKey(const Key('play-toggle')));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 3)),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(state!.playing, isTrue);
      expect(state!.duration.inSeconds, greaterThan(10));
      expect(state!.position.inMilliseconds, greaterThan(0));
      await state!.seek(10);
      await tester.pump(const Duration(seconds: 1));
      expect(state!.position.inSeconds, greaterThanOrEqualTo(9));
      await tester.tap(find.byKey(const Key('play-toggle')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(state!.playing, isFalse);
      await tester.tap(find.byKey(const Key('read-ebook')));
      await tester.pumpAndSettle();
      expect(find.textContaining('The Starlight Garden'), findsOneWidget);
      await capture('extra-reader');

      await mount('filter');
      await tester.tap(find.byKey(const Key('reset-filter')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Free'));
      await tester.tap(find.byKey(const Key('apply-filter')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('book-coco')), findsOneWidget);
      expect(find.byKey(const Key('book-kubo')), findsNothing);

      await mount('register');
      await tester.ensureVisible(find.byKey(const Key('auth-submit')));
      await tester.tap(find.byKey(const Key('auth-submit')));
      await tester.pumpAndSettle();
      expect(find.text('Please enter password'), findsOneWidget);
      await capture('extra-auth-validation');
      await tester.enterText(
        find.byKey(const Key('auth-Password')),
        'dream1234',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('auth-submit')));
      await tester.tap(find.byKey(const Key('auth-submit')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('auth-submit')), findsNothing);

      const cases = [
        ('01-welcome', 'welcome'),
        ('02-home', 'home'),
        ('03-home-playing', 'home'),
        ('04-search', 'search'),
        ('05-search-scrolled', 'search'),
        ('06-filter', 'filter'),
        ('07-library', 'library'),
        ('08-profile', 'profile'),
        ('09-profile-expanded', 'profile-expanded'),
        ('10-profile-scrolled', 'profile'),
        ('11-player-paused', 'player'),
        ('12-player-playing', 'player'),
        ('13-checkout-save', 'checkout'),
        ('14-checkout-unsaved', 'checkout'),
        ('15-about', 'about'),
        ('16-registration', 'register'),
        ('17-login', 'login'),
        ('18-reset', 'reset'),
        ('19-password', 'password'),
        ('20-registration-full', 'register-full'),
        ('21-login-full', 'login-full'),
      ];
      for (final dark in [false, true]) {
        for (final item in cases) {
          await mount(item.$2, dark: dark);
          if (item.$1.contains('playing')) {
            await state!.togglePlayback();
            await tester.pump(const Duration(milliseconds: 800));
            expect(state!.playing, isTrue);
          }
          if (item.$1.contains('search-scrolled')) {
            await tester.drag(
              find.byKey(const Key('search-list')),
              const Offset(0, -230),
            );
            await tester.pumpAndSettle();
          }
          if (item.$1.contains('profile-scrolled')) {
            await tester.drag(
              find.byKey(const Key('profile-list')),
              const Offset(0, -600),
            );
            await tester.pumpAndSettle();
          }
          if (item.$1.contains('unsaved')) {
            await tester.ensureVisible(find.byKey(const Key('save-card')));
            await tester.tap(find.byKey(const Key('save-card')));
            await tester.pumpAndSettle();
          }
          if (item.$1.contains('-full')) {
            await tester.enterText(
              find.byKey(const Key('auth-Password')),
              'dream1234',
            );
            await tester.testTextInput.receiveAction(TextInputAction.done);
            FocusManager.instance.primaryFocus?.unfocus();
            await tester.pumpAndSettle();
          }
          await capture('${dark ? 'dark' : 'light'}-${item.$1}');
        }
      }
      await mount('profile');
      await tester.ensureVisible(find.byKey(const Key('dark-theme')));
      await tester.tap(find.byKey(const Key('dark-theme')));
      await tester.pumpAndSettle();
      expect(state!.dark, isTrue);
      await state!.save();
      final persisted = AppState();
      await persisted.restore();
      expect(persisted.dark, isTrue);
      persisted.dispose();
      await state!.prefs.clear();
      await tester.pumpWidget(const SizedBox.shrink());
      state!.dispose();
    },
  );
}
