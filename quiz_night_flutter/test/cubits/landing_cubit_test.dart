import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/features/landing/landing_cubit.dart';

void main() {
  group('Given the landing page', () {
    blocTest<LandingCubit, LandingState>(
      'when a code with letters and extra digits is typed then only the '
      'first four digits stay',
      build: LandingCubit.new,
      act: (c) => c.setCode('48ab219'),
      expect: () => [const LandingState(code: '4821')],
      verify: (c) => expect(c.state.codeComplete, isTrue),
    );

    blocTest<LandingCubit, LandingState>(
      'when an FAQ answer is toggled twice then it opens and closes',
      build: LandingCubit.new,
      act: (c) => c
        ..toggleFaq('0-1')
        ..toggleFaq('0-1'),
      expect: () => [
        const LandingState(openFaq: {'0-1'}),
        const LandingState(),
      ],
    );

    blocTest<LandingCubit, LandingState>(
      'when the hosts tab is picked then the typed code stays',
      build: LandingCubit.new,
      seed: () => const LandingState(code: '12'),
      act: (c) => c.pickTab(WalkthroughTab.hosts),
      expect: () => [
        const LandingState(code: '12', tab: WalkthroughTab.hosts),
      ],
    );

    blocTest<LandingCubit, LandingState>(
      'when the menu is closed while already closed then nothing changes',
      build: LandingCubit.new,
      act: (c) => c.closeMenu(),
      expect: () => <LandingState>[],
    );
  });
}
