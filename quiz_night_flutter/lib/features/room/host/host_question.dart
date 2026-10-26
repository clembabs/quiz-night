import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/answer_button.dart';
import '../../../widgets/qn/countdown.dart';
import '../../../widgets/qn/host_stage.dart';
import '../round/host_step_button.dart';
import '../round/question_header.dart';
import '../round_logic.dart';

/// The projector during a question: text, countdown, count and options.
class HostQuestion extends StatelessWidget {
  final RoomState room;
  final Duration clockOffset;

  const HostQuestion({
    super.key,
    required this.room,
    required this.clockOffset,
  });

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final endsAt = room.questionEndsAt;
    final portrait = HostLayout.isPortrait(context);
    final prompt = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          QuestionHeader.textFor(room),
          style: AppProjectorText.label.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: 3.2,
            color: AppColors.mint,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          q.text,
          style: AppProjectorText.title.copyWith(
            fontSize: portrait ? 56 : 76,
            height: 1.12,
          ),
        ),
      ],
    );
    final answered = Text(
      '${answeredCount(room)}/${activeCount(room)} answered',
      key: const Key('host.answered'),
      style: AppProjectorText.label.copyWith(
        fontSize: 32,
        color: AppColors.chalk,
        letterSpacing: 0,
      ),
    );
    Widget ring(double size) => endsAt == null
        ? SizedBox.square(dimension: size)
        : CountdownBuilder(
            endsAt: endsAt,
            totalSeconds: q.timeLimitSeconds,
            clockOffset: clockOffset,
            builder: (context, frame) =>
                CountdownRing(frame: frame, size: size),
          );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (portrait) ...[
          // Phone: the clock and count above the question, full width.
          Row(
            children: [
              ring(160),
              const SizedBox(width: 28),
              Expanded(child: answered),
            ],
          ),
          const SizedBox(height: 28),
          prompt,
        ] else
          Row(
            children: [
              Expanded(child: prompt),
              const SizedBox(width: 56),
              SizedBox(
                width: 260,
                child: Column(
                  children: [ring(240), const SizedBox(height: 16), answered],
                ),
              ),
            ],
          ),
        const SizedBox(height: 40),
        Expanded(
          child: OptionGrid(question: q, columns: portrait ? 1 : 2),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: HostStepButton(room: room),
        ),
      ],
    );
  }
}

/// Four projector tiles, 2×2, staggering in 60 ms apart.
class OptionGrid extends StatelessWidget {
  final QuestionView question;

  /// 2 on the projector (2×2); 1 on a portrait phone (a stack of four).
  final int columns;

  const OptionGrid({super.key, required this.question, this.columns = 2});

  @override
  Widget build(BuildContext context) {
    final q = question;
    Widget tile(int i) => _Enter(
      delay: AppDurations.stagger * i,
      child: HostAnswerTile(
        index: i,
        text: q.options[i],
        look: answerLookFor(
          index: i,
          correctIndex: q.correctIndex,
          picked: null,
        ),
      ),
    );
    final rows = <Widget>[];
    for (var r = 0; r < q.options.length; r += columns) {
      if (r > 0) rows.add(const SizedBox(height: 24));
      rows.add(
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var c = 0; c < columns; c++) ...[
                if (c > 0) const SizedBox(width: 24),
                Expanded(
                  child: r + c < q.options.length
                      ? tile(r + c)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _Enter extends StatelessWidget {
  final Duration delay;
  final Widget child;

  const _Enter({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final total = AppDurations.slow + delay;
    final start = delay.inMilliseconds / total.inMilliseconds;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (context, t, child) {
        final e = AppCurves.decelerate.transform(
          ((t - start) / (1 - start)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: e,
          child: Transform.translate(
            offset: Offset(0, 32 * (1 - e)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
