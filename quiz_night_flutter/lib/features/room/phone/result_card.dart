import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../core/platform/share_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/brand/chalk_background.dart';
import '../../../widgets/brand/crest.dart';
import '../../../widgets/qn/standings_row.dart';
import '../final/result_summary.dart';
import '../standings_logic.dart';

/// Hands a PNG to the share sheet; [shareImage] in the app, a fake in tests.
typedef ImageSharer =
    Future<ShareOutcome> Function(
      Uint8List png, {
      required String fileName,
      required String text,
    });

/// A player's result as a 4:5 card, the shape Instagram and WhatsApp show
/// whole. Drawn at a fixed design size so the image always looks the same.
class ResultCard extends StatelessWidget {
  final ResultSummary result;

  /// The site's host name, printed at the bottom.
  final String site;

  const ResultCard({super.key, required this.result, required this.site});

  static const size = Size(360, 450);

  @override
  Widget build(BuildContext context) {
    final r = result;
    final accent = r.champion ? AppColors.gold : AppColors.chalk;
    return SizedBox.fromSize(
      size: size,
      // Square corners: transparent ones turn white or black in chat apps.
      child: ChalkBackground(
        spacing: 7,
        color: r.champion ? AppColors.green : AppColors.board,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Crest(width: 30),
                  const SizedBox(width: 10),
                  Text(
                    'QUIZ NIGHT',
                    style: AppTextStyles.headline.copyWith(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Shrinks to fit the fixed card when everything is long.
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      width: size.width - 56,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.nickname.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.chalkSoft,
                              letterSpacing: 1.4,
                            ),
                          ),
                          // Shrinks rather than overflows for "20th of 20".
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  ordinal(r.place),
                                  key: const Key('card.place'),
                                  style: AppTextStyles.displayXl.copyWith(
                                    fontSize: 92,
                                    height: 1,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'of ${r.playerCount}',
                                  style: AppTextStyles.headline.copyWith(
                                    fontSize: 24,
                                    color: AppColors.chalkSoft,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            r.title.toUpperCase(),
                            key: const Key('card.title'),
                            maxLines: 2,
                            style: AppTextStyles.headline.copyWith(
                              fontSize: 26,
                              color: r.champion
                                  ? AppColors.gold
                                  : AppColors.chalk,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Stat(
                                r.roundsSurvived == 1
                                    ? 'Survived 1 round'
                                    : 'Survived ${r.roundsSurvived} rounds',
                              ),
                              _Stat('${formatScore(r.points)} pts'),
                              if (r.finalPoints case final f?)
                                _Stat(
                                  '★ Final: ${formatScore(f)} pts',
                                  good: true,
                                ),
                              if (r.backedWinner case final backed?)
                                _Stat(
                                  backed
                                      ? '✓ Backed the winner'
                                      : '✕ Backed the wrong one',
                                  good: backed,
                                ),
                            ],
                          ),
                          if (r.hostLine case final line?) ...[
                            const SizedBox(height: 16),
                            Text(
                              '“$line”',
                              key: const Key('card.hostLine'),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(
                                fontSize: 15,
                                height: 1.35,
                                fontStyle: FontStyle.italic,
                                color: AppColors.goldPale,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: AppColors.line),
              const SizedBox(height: 12),
              Text(
                'Survive the round, or go home.',
                style: AppTextStyles.caption.copyWith(fontSize: 12),
              ),
              Text(
                site,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 12,
                  color: AppColors.gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String text;
  final bool? good;

  const _Stat(this.text, {this.good});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(
        color: switch (good) {
          true => AppColors.mint,
          false => AppColors.maroon,
          null => AppColors.line,
        },
      ),
    ),
    child: Text(
      text,
      style: AppTextStyles.chip.copyWith(fontSize: 13),
    ),
  );
}

/// The card's preview with Share; opened from the final placement.
class ResultCardSheet extends StatefulWidget {
  final ResultSummary result;
  final Uri site;
  final ImageSharer share;

  const ResultCardSheet({
    super.key,
    required this.result,
    required this.site,
    this.share = shareImage,
  });

  /// Opens the sheet over the placement screen.
  static Future<void> show(
    BuildContext context, {
    required ResultSummary result,
    required Uri site,
    ImageSharer share = shareImage,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.boardDeep,
    builder: (_) => ResultCardSheet(result: result, site: site, share: share),
  );

  @override
  State<ResultCardSheet> createState() => _ResultCardSheetState();
}

class _ResultCardSheetState extends State<ResultCardSheet> {
  final _card = GlobalKey();
  bool _busy = false;

  /// What happened to the last share, and whether it was a failure.
  (String, bool)? _status;

  /// The card as a 1080×1350 PNG.
  Future<Uint8List> _png() async {
    final boundary =
        _card.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(
      pixelRatio: 1080 / ResultCard.size.width,
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return bytes!.buffer.asUint8List();
  }

  Future<void> _share() async {
    setState(() {
      _busy = true;
      _status = null;
    });
    ShareOutcome outcome;
    try {
      outcome = await widget.share(
        await _png(),
        fileName: 'quiz-night-result.png',
        text: shareTextFor(widget.result, widget.site),
      );
    } catch (_) {
      outcome = ShareOutcome.failed;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      // In the sheet, not a toast: a toast would sit behind it.
      _status = switch (outcome) {
        ShareOutcome.shared || ShareOutcome.cancelled => null,
        ShareOutcome.downloaded => (
          'Saved to your downloads. Post it anywhere.',
          false,
        ),
        ShareOutcome.failed => (
          "Couldn't share the card. A screenshot works too.",
          true,
        ),
      };
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'YOUR RESULT',
            textAlign: TextAlign.center,
            style: AppTextStyles.eyebrow.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          // Shrinks to fit short phones; the image is always full size.
          Flexible(
            child: FittedBox(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: RepaintBoundary(
                  key: _card,
                  child: ResultCard(
                    result: widget.result,
                    site: widget.site.host,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: FilledButton(
              key: const Key('card.share'),
              onPressed: _busy ? null : _share,
              child: Text(_busy ? 'Preparing…' : 'Share my result'),
            ),
          ),
          if (_status case (final text, final failed)) ...[
            const SizedBox(height: 10),
            Text(
              text,
              key: const Key('card.status'),
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: failed ? AppColors.errorText : AppColors.mint,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
