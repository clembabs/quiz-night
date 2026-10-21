import 'package:flutter/material.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/chalk_background.dart';
import '../../../widgets/brand/crest.dart';
import '../../../widgets/qn/answer_button.dart';
import '../../room/host/host_question.dart';
import '../landing_content.dart';
import 'landing_parts.dart';

/// A projector and a phone mid-question, drawn with the game's own widgets,
/// so visitors see what the game looks like before they play.
class GamePreview extends StatelessWidget {
  const GamePreview({super.key});

  /// The sample question both screens show.
  static final question = QuestionView(
    id: 0,
    round: 1,
    indexInRound: 2,
    isFinal: false,
    text: 'Which river gives Nigeria its name?',
    options: ['The Benue', 'The Niger', 'The Kaduna', 'The Ogun'],
    timeLimitSeconds: 20,
  );

  /// The phone's locked-in pick.
  static const picked = 1;

  @override
  Widget build(BuildContext context) => LandingSection(
    top: 24,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label:
              'Preview: the projector shows a question and four coloured '
              'answers; a phone shows the same four answers as buttons, with '
              'one locked in.',
          excludeSemantics: true,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              // Narrow: the phone sits under the projector.
              if (w < 600) {
                return Column(
                  children: [
                    const _Projector(),
                    const SizedBox(height: 20),
                    SizedBox(width: w * 0.6, child: const _Phone()),
                  ],
                );
              }
              // Wide: the phone overlaps the projector's right edge.
              return SizedBox(
                height: w * 0.5,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      width: w * 0.8,
                      child: const _Projector(),
                    ),
                    Positioned(
                      right: 0,
                      top: w * 0.04,
                      width: w * 0.22,
                      child: const _Phone(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            LandingContent.previewCaption,
            style: AppWebText.body,
          ),
        ),
      ],
    ),
  );
}

/// The 1920×1080 host screen, scaled into a rounded frame.
class _Projector extends StatelessWidget {
  const _Projector();

  @override
  Widget build(BuildContext context) => _Frame(
    radius: 16,
    border: 6,
    aspectRatio: 16 / 9,
    child: FittedBox(
      child: SizedBox(
        width: 1920,
        height: 1080,
        child: ChalkBackground(
          spacing: 12,
          child: Padding(
            padding: const EdgeInsets.all(72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ROUND 1 · QUESTION 2 OF 5',
                            style: AppProjectorText.label.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 3.2,
                              color: AppColors.mint,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            GamePreview.question.text,
                            style: AppProjectorText.title.copyWith(
                              fontSize: 76,
                              height: 1.12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 56),
                    const _StaticClock(seconds: 12),
                  ],
                ),
                const SizedBox(height: 48),
                Expanded(child: OptionGrid(question: GamePreview.question)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// The countdown ring, frozen at [seconds].
class _StaticClock extends StatelessWidget {
  final int seconds;

  const _StaticClock({required this.seconds});

  @override
  Widget build(BuildContext context) => Container(
    width: 220,
    height: 220,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: AppColors.chalk, width: 16),
    ),
    child: Text(
      '$seconds',
      style: AppProjectorText.numeric.copyWith(fontSize: 96),
    ),
  );
}

/// A 390×800 player screen, scaled into a phone outline.
class _Phone extends StatelessWidget {
  const _Phone();

  @override
  Widget build(BuildContext context) => _Frame(
    radius: 28,
    border: 6,
    aspectRatio: 390 / 800,
    child: FittedBox(
      child: SizedBox(
        width: 390,
        height: 800,
        child: ChalkBackground(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Crest(width: 30),
                    const Spacer(),
                    Text(
                      'Code 4821',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.chalkSoft,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text('ROUND 1 · Q2', style: AppTextStyles.eyebrow),
                const SizedBox(height: 8),
                Text(
                  GamePreview.question.text,
                  style: AppTextStyles.title.copyWith(fontSize: 24),
                ),
                const Spacer(),
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  SizedBox(
                    height: 84,
                    child: PhoneAnswerButton(
                      index: i,
                      text: GamePreview.question.options[i],
                      look: answerLookFor(
                        index: i,
                        correctIndex: null,
                        picked: GamePreview.picked,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Locked in. Waiting for the clock…',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySoft,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _Frame extends StatelessWidget {
  final Widget child;
  final double radius;
  final double border;
  final double aspectRatio;

  const _Frame({
    required this.child,
    required this.radius,
    required this.border,
    required this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspectRatio,
    child: Container(
      // Inset by the border so the screen doesn't paint over the bezel.
      padding: EdgeInsets.all(border),
      decoration: BoxDecoration(
        color: AppColors.boardDeep,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.slateDim, width: border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.dropShadow,
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - border),
        child: child,
      ),
    ),
  );
}
