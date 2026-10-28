import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/platform/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/answer_button.dart';
import '../../../widgets/qn/countdown.dart';
import '../../../widgets/qn/loaders.dart';
import '../../../widgets/qn/notices.dart';
import '../room_cubit.dart';
import '../round/question_header.dart';
import '../round_logic.dart';

/// An open round question on a phone: answer, locked in, or too late.
class PhoneQuestion extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final int? myChoice;
  final Duration clockOffset;

  const PhoneQuestion({
    super.key,
    required this.room,
    required this.me,
    required this.myChoice,
    required this.clockOffset,
  });

  bool get _spectator => me?.status == PlayerStatus.eliminated;

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final endsAt = room.questionEndsAt;
    // After a reload the local pick is gone, but the server still knows.
    final locked = myChoice != null || (me?.hasAnswered ?? false);
    final haptics = context.read<Haptics>();
    if (endsAt == null) return _Answer(room: room, me: me, frame: null);
    return CountdownBuilder(
      endsAt: endsAt,
      totalSeconds: q.timeLimitSeconds,
      clockOffset: clockOffset,
      onLastSecondsTick: locked ? null : () => haptics.play(HapticToken.tick),
      builder: (context, frame) {
        if (locked) {
          return _Locked(room: room, myChoice: myChoice, frame: frame);
        }
        if (!frame.running && !_spectator) return const _TooLate();
        return _Answer(room: room, me: me, frame: frame);
      },
    );
  }
}

/// Tallest an answer button gets (design system, 430 px phones).
const _maxAnswer = 120.0;

class _Answer extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final CountdownFrame? frame;

  const _Answer({required this.room, required this.me, required this.frame});

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final spectator = me?.status == PlayerStatus.eliminated;
    final showText = room.showQuestionOnPhones || spectator;
    final frame = this.frame;
    final cubit = context.read<RoomCubit>();
    final haptics = context.read<Haptics>();
    void pick(int i) {
      haptics.play(HapticToken.medium);
      cubit.submitAnswer(i);
    }

    return LayoutBuilder(
      builder: (context, c) {
        final landscape = c.maxWidth > c.maxHeight;
        final options = [
          for (var i = 0; i < q.options.length; i++)
            _Staggered(
              index: i,
              child: PhoneAnswerButton(
                key: Key('answer.$i'),
                index: i,
                text: q.options[i],
                onTap: () => pick(i),
              ),
            ),
        ];
        Widget slot(int i) => ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: SizedBox.expand(child: options[i]),
        );
        // Portrait: one column. Landscape: 2×2, as in the prototype.
        final answers = landscape
            ? Column(
                children: [
                  for (var r = 0; r < options.length; r += 2) ...[
                    if (r > 0) const SizedBox(height: 10),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: slot(r)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: r + 1 < options.length
                                ? slot(r + 1)
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              )
            : Column(
                children: [
                  for (var i = 0; i < options.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    Expanded(child: slot(i)),
                  ],
                ],
              );
        // Answers fill what the question leaves; scrolls only if nothing fits.
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (frame != null) CountdownBar(frame: frame),
                    if (spectator && me != null) ...[
                      const SizedBox(height: 12),
                      QnBanner(
                        kind: BannerKind.eliminated,
                        text:
                            '${joinedLate(me) ? 'Joined late' : 'Eliminated in '
                                      'Round ${me!.eliminatedInRound ?? room.round}'}'
                            ' · answers count for a shadow score',
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            QuestionHeader.textFor(room),
                            style: AppTextStyles.eyebrow,
                          ),
                        ),
                        if (frame != null) CountdownSeconds(frame: frame),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      showText ? q.text : 'Question is on the big screen',
                      style: showText
                          ? AppTextStyles.title.copyWith(fontSize: 19)
                          : AppTextStyles.body.copyWith(
                              color: AppColors.muted,
                              fontSize: 15,
                            ),
                    ),
                    const SizedBox(height: 16),
                    // Spare room goes above buttons, keeping them in reach.
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: landscape
                                ? 2 * _maxAnswer + 10
                                : options.length * _maxAnswer +
                                      (options.length - 1) * 10,
                          ),
                          child: answers,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Options slide in 60 ms apart.
class _Staggered extends StatelessWidget {
  final int index;
  final Widget child;

  const _Staggered({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final start = index * 60 / 450;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      builder: (context, t, child) {
        final local = ((t - start) / (1 - start)).clamp(0.0, 1.0);
        final e = AppCurves.decelerate.transform(local);
        return Opacity(
          opacity: e,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - e)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _Locked extends StatelessWidget {
  final RoomState room;
  final int? myChoice;
  final CountdownFrame frame;

  const _Locked({
    required this.room,
    required this.myChoice,
    required this.frame,
  });

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final choice = myChoice;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CountdownBar(frame: frame),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1),
                  duration: AppDurations.slow,
                  curve: AppCurves.stamp,
                  builder: (context, s, child) =>
                      Transform.scale(scale: s, child: child),
                  child: Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.chalk, width: 4),
                    ),
                    child: Text(
                      '✓',
                      style: AppTextStyles.displayL.copyWith(fontSize: 40),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ANSWER LOCKED IN',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayL.copyWith(fontSize: 34),
                ),
                if (choice != null && choice < q.options.length) ...[
                  const SizedBox(height: 20),
                  OptionChip(index: choice, text: q.options[choice]),
                ],
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PulsingDots(),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  '${answeredCount(room)}/${activeCount(room)} answered · '
                  'waiting for others',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 15,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TooLate extends StatelessWidget {
  const _TooLate();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.maroonDeep,
              border: Border.all(color: AppColors.wrong, width: 4),
            ),
            child: Text(
              '0',
              style: AppTextStyles.numeric.copyWith(
                fontSize: 40,
                color: AppColors.errorText,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'TOO LATE',
            style: AppTextStyles.displayL.copyWith(fontSize: 34),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'Time ran out before you answered. No points this question.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySoft,
            ),
          ),
        ],
      ),
    ),
  );
}
