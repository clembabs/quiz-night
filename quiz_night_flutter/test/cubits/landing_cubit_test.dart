import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_night_flutter/features/landing/landing_cubit.dart';

void main() {
  group('Given the landing page', () {
    blocTest<LandingCubit, LandingState>(
      'when a code is typed in lower case with symbols then capitals and '
      'letters and digits stay, at most five',
      build: LandingCubit.new,
      act: (c) => c
        ..setCode('k7-qm')
        ..setCode('k7qm2x9'),
      expect: () => [
        const LandingState(code: 'K7QM'),
        const LandingState(code: 'K7QM2'),
      ],
      verify: (c) => expect(c.state.codeComplete, isTrue),
    );

    blocTest<LandingCubit, LandingState>(
      'when only three characters are typed then the code is not complete',
      build: LandingCubit.new,
      act: (c) => c.setCode('K7Q'),
      verify: (c) => expect(c.state.codeComplete, isFalse),
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
