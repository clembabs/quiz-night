import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/platform/haptics.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/qn/answer_button.dart';
import '../../../widgets/qn/buzzer.dart';
import '../../../widgets/qn/finalist_desk.dart';
import '../../../widgets/qn/notices.dart';
import '../final/final_logic.dart';
import '../room_cubit.dart';

/// A finalist's phone in the final: the buzzer, then options once held.
class PhoneBuzzer extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final int? myChoice;
  final bool buzzing;

  const PhoneBuzzer({
    super.key,
    required this.room,
    required this.me,
    required this.myChoice,
    required this.buzzing,
  });

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final revealed = q.correctIndex != null;
    final seat = buzzerSeatFor(room, me, buzzing: buzzing);
    final cubit = context.read<RoomCubit>();
    final haptics = context.read<Haptics>();
    final holder = nicknameOf(room, room.buzzerHolderId);

    final (look, hint) = revealed
        ? (BuzzerLook.wait, finalStatusLine(room))
        : switch (seat) {
            BuzzerSeat.canBuzz || BuzzerSeat.buzzing => (
              BuzzerLook.ready,
              'Buzz first when you know the answer.',
            ),
            BuzzerSeat.holding => (BuzzerLook.first, 'You buzzed first.'),
            BuzzerSeat.otherHolding => (
              BuzzerLook.other(holder ?? 'Someone'),
              'If $holder is wrong, buzzing reopens.',
            ),
            BuzzerSeat.lockedOut => (
              BuzzerLook.locked,
              'Locked out. Next question soon.',
            ),
            BuzzerSeat.spectator => (BuzzerLook.wait, ''),
          };
    final holding = !revealed && seat == BuzzerSeat.holding;

    return LayoutBuilder(
      builder: (context, c) {
        final size = (c.maxWidth * 0.78).clamp(160.0, holding ? 170.0 : 300.0);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight - 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '★ FINALIST · BUZZER ROUND',
                  style: AppTextStyles.eyebrow.copyWith(color: AppColors.gold),
                ),
                const SizedBox(height: 4),
                Text(
                  hint,
                  key: const Key('final.prompt'),
                  style: AppTextStyles.bodySoft.copyWith(fontSize: 15),
                ),
                if (room.showQuestionOnPhones) ...[
                  const SizedBox(height: 12),
                  Text(
                    q.text,
                    style: AppTextStyles.title.copyWith(fontSize: 18),
                  ),
                ],
                const SizedBox(height: 20),
                Center(
                  child: BuzzerButton(
                    look: look,
                    size: size,
                    onPressed: !revealed && seat == BuzzerSeat.canBuzz
                        ? () {
                            haptics.play(HapticToken.medium);
                            cubit.buzz();
                          }
                        : null,
                  ),
                ),
                if (holding || revealed) ...[
                  const SizedBox(height: 20),
                  for (var i = 0; i < q.options.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    PhoneAnswerButton(
                      key: Key('final.answer.$i'),
                      index: i,
                      text: q.options[i],
                      look: answerLookFor(
                        index: i,
                        correctIndex: q.correctIndex,
                        picked: myChoice,
                      ),
                      onTap: holding && myChoice == null
                          ? () {
                              haptics.play(HapticToken.medium);
                              cubit.submitBuzzAnswer(i);
                            }
                          : null,
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A spectator's phone during the final: the question and the desks.
class PhoneWatching extends StatelessWidget {
  final RoomState room;
  final PlayerView? me;
  final int? myBackedId;

  const PhoneWatching({
    super.key,
    required this.room,
    required this.me,
    required this.myBackedId,
  });

  @override
  Widget build(BuildContext context) {
    final q = room.question!;
    final backed = nicknameOf(room, myBackedId);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          QnBanner(
            kind: BannerKind.eliminated,
            text:
                'Spectating · eliminated in Round '
                '${me?.eliminatedInRound ?? room.round}',
          ),
          const SizedBox(height: 24),
          Text(
            'FINAL · BUZZER ROUND',
            style: AppTextStyles.eyebrow.copyWith(color: AppColors.gold),
          ),
          const SizedBox(height: 6),
          Text(q.text, style: AppTextStyles.title),
          const SizedBox(height: 8),
          Text(
            finalStatusLine(room),
            key: const Key('final.prompt'),
            style: AppTextStyles.bodySoft.copyWith(fontSize: 15),
          ),
          const SizedBox(height: 20),
          for (final f in finalistsByJoin(room)) ...[
            FinalistRowTile(nickname: f.nickname, state: deskStateFor(room, f)),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          Text(
            backed == null
                ? 'You didn’t back a finalist'
                : 'You backed $backed',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
