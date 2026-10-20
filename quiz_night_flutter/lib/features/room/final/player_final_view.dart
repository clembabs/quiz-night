import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/answer_option.dart';
import '../../../widgets/countdown_bar.dart';
import '../../../widgets/spectator_banner.dart';
import '../room_cubit.dart';
import '../round/question_header.dart';
import 'buzz_button.dart';
import 'final_logic.dart';
import 'finalist_card.dart';

/// Phone view of a buzzer-final question: buzz, answer, or watch.
class PlayerFinalView extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final int? myChoice;
  final int? myBackedId;
  final bool buzzing;
  final Duration clockOffset;

  const PlayerFinalView({
    super.key,
    required this.room,
    required this.me,
    required this.myChoice,
    required this.myBackedId,
    required this.buzzing,
    required this.clockOffset,
  });

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final revealed = q.correctIndex != null;
    final seat = buzzerSeatFor(room, me, buzzing: buzzing);
    final cubit = context.read<RoomCubit>();
    final endsAt = room.questionEndsAt;
    final finalists = finalStandings(room)
      ..sort((a, b) => a.id.compareTo(b.id));
    final canAnswer = !revealed && seat == BuzzerSeat.holding;

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        if (SpectatorBanner.appliesTo(me)) ...[
          SpectatorBanner(me: me!),
          const SizedBox(height: AppSpacing.md),
        ],
        QuestionHeader(room: room),
        const SizedBox(height: AppSpacing.sm),
        Text(q.text, style: AppTextStyles.questionPlayer),
        const SizedBox(height: AppSpacing.lg),
        if (!revealed && endsAt != null) ...[
          CountdownBar(
            endsAt: endsAt,
            totalSeconds: q.timeLimitSeconds,
            clockOffset: clockOffset,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (!revealed) ...[
          _Prompt(seat: seat, room: room),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (!revealed &&
            (seat == BuzzerSeat.canBuzz || seat == BuzzerSeat.buzzing)) ...[
          Center(
            child: BuzzButton(
              onPressed: seat == BuzzerSeat.canBuzz ? cubit.buzz : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        for (var i = 0; i < q.options.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AnswerOption(
              key: Key('final.answer.$i'),
              index: i,
              text: q.options[i],
              look: lookFor(
                index: i,
                correctIndex: q.correctIndex,
                picked: canAnswer ? myChoice : null,
              ),
              onTap: canAnswer && myChoice == null
                  ? () => cubit.submitBuzzAnswer(i)
                  : null,
            ),
          ),
        if (revealed) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            finalStatusLine(room),
            textAlign: TextAlign.center,
            style: AppTextStyles.heading,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        FinalistRow(room: room, finalists: finalists, myId: me?.id),
        if (seat == BuzzerSeat.spectator && myBackedId != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            "You're backing ${nicknameOf(room, myBackedId) ?? 'a finalist'}",
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ],
    );
  }
}

class _Prompt extends StatelessWidget {
  final BuzzerSeat seat;
  final RoomState room;

  const _Prompt({required this.seat, required this.room});

  @override
  Widget build(BuildContext context) {
    final holder = nicknameOf(room, room.buzzerHolderId);
    final (text, color) = switch (seat) {
      BuzzerSeat.canBuzz => ('Know it? Buzz!', AppColors.gold),
      BuzzerSeat.buzzing => ('Buzzing…', AppColors.gold),
      BuzzerSeat.holding => (
        'You have the buzzer! Answer now',
        AppColors.success,
      ),
      BuzzerSeat.otherHolding => ('$holder buzzed in…', AppColors.muted),
      BuzzerSeat.lockedOut => (
        'Locked out on this one',
        AppColors.danger,
      ),
      BuzzerSeat.spectator => (
        holder == null ? 'Waiting for a buzz…' : '$holder is answering…',
        AppColors.muted,
      ),
    };
    return Text(
      text,
      key: const Key('final.prompt'),
      textAlign: TextAlign.center,
      style: AppTextStyles.verdict.copyWith(color: color),
    );
  }
}
