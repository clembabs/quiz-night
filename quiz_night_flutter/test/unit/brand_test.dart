import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/core/platform/haptics.dart';
import 'package:quiz_night_flutter/core/theme/app_colors.dart';
import 'package:quiz_night_flutter/widgets/brand/crest.dart';
import 'package:quiz_night_flutter/widgets/brand/initial_badge.dart';
import 'package:quiz_night_flutter/widgets/brand/option_shape.dart';

void main() {
  group('Given badge tones', () {
    test('when the same name is seen twice then it gets the same tone', () {
      expect(badgeToneFor('Adéwálé'), badgeToneFor('Adéwálé'));
    });

    test('when hashing then it matches the design system algorithm', () {
      // Sum of code points mod 8: "Ab" = 65 + 98 = 163, 163 % 8 = 3.
      expect(badgeToneFor('Ab'), AppColors.badgeTones[3]);
    });

    test('when names differ then tones come from the board-safe set', () {
      for (final n in [
        'Ngọzi',
        'Ɗanjuma',
        'Ṣeun',
        'Zainab Abubakar-Mohammed',
      ]) {
        expect(AppColors.badgeTones, contains(badgeToneFor(n)));
      }
    });
  });

  group('Given initials', () {
    test('when a name starts with a Nigerian letter then it stays whole', () {
      expect(initialOf('Ọlá'), 'Ọ');
      expect(initialOf('Ɗanjuma'), 'Ɗ');
      expect(initialOf('Ƙasimu'), 'Ƙ');
    });

    test('when a letter carries a combining tone mark then the mark stays', () {
      // O + combining dot below + combining grave: one grapheme.
      expect(initialOf('Ọ̀ṣun'), 'Ọ̀');
    });

    test('when lower case then the initial is upper case', () {
      expect(initialOf('ngọzi'), 'N');
    });

    test('when blank then a placeholder shows', () {
      expect(initialOf('   '), '?');
    });
  });

  group('Given option shapes', () {
    test('when mapping A-D then triangle, diamond, circle, square', () {
      expect([0, 1, 2, 3].map(optionShapeFor), [
        OptionShapeKind.triangle,
        OptionShapeKind.diamond,
        OptionShapeKind.circle,
        OptionShapeKind.square,
      ]);
      expect(optionShapeName(2), 'circle');
    });

    test('when colours are chosen then every option has its own ink', () {
      expect(AppColors.options, hasLength(4));
      expect(AppColors.optionInk, hasLength(4));
      expect(AppColors.optionPressed, hasLength(4));
    });
  });

  group('Given haptic tokens', () {
    test('when read then patterns match the design system', () {
      expect(HapticToken.tick.pattern, [10]);
      expect(HapticToken.medium.pattern, [25]);
      expect(HapticToken.success.pattern, [20, 60, 20]);
      expect(HapticToken.heavy.pattern, [300]);
      expect(HapticToken.celebrate.pattern, [30, 50, 30, 50, 60]);
    });

    test('when silent haptics are disabled then playing does nothing', () {
      final h = SilentHaptics()..enabled = false;
      h.play(HapticToken.error);
      expect(h.enabled, isFalse);
    });
  });

  group('Given the crest outline', () {
    test('when built then the top is near-square and the bottom round', () {
      const rect = Rect.fromLTWH(0, 0, 64, 76);
      final path = const CrestBorder().getOuterPath(rect);
      // Inside near the top corner, outside near the bottom corner.
      expect(path.contains(const Offset(4, 4)), isTrue);
      expect(path.contains(const Offset(2, 74)), isFalse);
      expect(path.contains(const Offset(32, 74)), isTrue);
    });
  });
}
