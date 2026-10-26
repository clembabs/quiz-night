import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/layout/responsive_grid.dart';
import '../landing_content.dart';
import '../landing_cubit.dart';
import 'landing_parts.dart';

/// The headline, and the two ways in: "I'm playing" and "I'm hosting".
class HeroSection extends StatelessWidget {
  final ValueChanged<String> onJoin;
  final VoidCallback onHost;
  final VoidCallback onReadGuide;

  const HeroSection({
    super.key,
    required this.onJoin,
    required this.onHost,
    required this.onReadGuide,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gap = AppWebLayout.heroGap(width);
    return LandingSection(
      top: AppWebLayout.heroTop(width),
      child: LayoutBuilder(
        builder: (context, c) {
          final intro = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LandingContent.eyebrow.toUpperCase(),
                style: AppWebText.eyebrow,
              ),
              const SizedBox(height: 22),
              Text(
                LandingContent.headline.toUpperCase(),
                style: AppWebText.hero(width),
              ),
              const SizedBox(height: 22),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Text(
                  LandingContent.lead,
                  style: AppWebText.lead(width),
                ),
              ),
            ],
          );
          final cards = ResponsiveGrid(
            minItemWidth: 260,
            children: [
              _JoinCard(onJoin: onJoin),
              _HostCard(onHost: onHost, onReadGuide: onReadGuide),
            ],
          );
          // Side by side when both halves get 420; stacked below that.
          final twoColumns =
              ResponsiveGrid.columnsFor(c.maxWidth, 420, gap, 2) == 2;
          if (!twoColumns) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                intro,
                SizedBox(height: gap),
                cards,
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: intro),
              SizedBox(width: gap),
              Expanded(child: cards),
            ],
          );
        },
      ),
    );
  }
}

/// Room code box and JOIN GAME. Stateful only to own the text controller.
class _JoinCard extends StatefulWidget {
  final ValueChanged<String> onJoin;

  const _JoinCard({required this.onJoin});

  @override
  State<_JoinCard> createState() => _JoinCardState();
}

class _JoinCardState extends State<_JoinCard> {
  late final _code = TextEditingController(
    text: context.read<LandingCubit>().state.code,
  );

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LandingCubit>();
    final state = context.watch<LandingCubit>().state;
    final ready = state.codeComplete;
    void join() {
      if (ready) widget.onJoin(state.code);
    }

    return LandingCard(
      borderColor: AppColors.gold,
      borderWidth: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'I’M PLAYING',
            style: AppWebText.cardEyebrow.copyWith(
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(height: 14),
          Text('GOT A ROOM CODE?', style: AppWebText.cardTitle),
          const SizedBox(height: 14),
          Text(
            'Room code',
            style: AppWebText.small.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.chalkSoft,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            key: const Key('landing.code'),
            controller: _code,
            onChanged: cubit.setCode,
            onSubmitted: (_) => join(),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.go,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            style: AppTextStyles.codeInput.copyWith(fontSize: 32),
            decoration: InputDecoration(
              hintText: '0000',
              hintStyle: AppTextStyles.codeInput.copyWith(
                fontSize: 32,
                color: AppColors.faint,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: _border(ready ? AppColors.gold : AppColors.line),
              focusedBorder: _border(AppColors.gold),
            ),
          ),
          const SizedBox(height: 14),
          LandingButton(
            buttonKey: const Key('landing.join'),
            label: 'Join game',
            onPressed: ready ? join : null,
          ),
          const SizedBox(height: 14),
          Text(
            'The code is on the big screen. No account needed.',
            style: AppWebText.small,
          ),
        ],
      ),
    );
  }

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadii.md),
    borderSide: BorderSide(color: color, width: AppBorders.focus),
  );
}

class _HostCard extends StatelessWidget {
  final VoidCallback onHost;
  final VoidCallback onReadGuide;

  const _HostCard({required this.onHost, required this.onReadGuide});

  @override
  Widget build(BuildContext context) => LandingCard(
    borderColor: AppColors.line,
    // spaceBetween, not a Spacer: the card must also work at its own height
    // when the cards stack.
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'I’M HOSTING',
              style: AppWebText.cardEyebrow.copyWith(color: AppColors.mint),
            ),
            const SizedBox(height: 14),
            Text('RUN A QUIZ NIGHT', style: AppWebText.cardTitle),
            const SizedBox(height: 14),
            Text(
              'Type any topic and AI writes the questions. Set the rounds, '
              'and open the host screen on a laptop connected to a TV or '
              'projector.',
              style: AppWebText.body,
            ),
            const SizedBox(height: 14),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LandingButton(
              buttonKey: const Key('landing.host'),
              label: 'Start hosting',
              kind: LandingButtonKind.chalk,
              onPressed: onHost,
            ),
            const SizedBox(height: 6),
            Center(
              child: LandingLink(
                label: 'Read the hosting guide',
                onTap: onReadGuide,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
