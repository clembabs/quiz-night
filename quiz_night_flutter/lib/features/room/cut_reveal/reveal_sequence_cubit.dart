import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum RevealPhase {
  /// "Who's going home?" before any name.
  intro,

  /// Names appearing one at a time.
  revealing,

  /// Everyone revealed; survivors and next steps can show.
  done,
}

class RevealSequenceState extends Equatable {
  final RevealPhase phase;

  /// How many eliminated names are showing.
  final int revealed;
  final int total;

  const RevealSequenceState({
    required this.phase,
    required this.revealed,
    required this.total,
  });

  bool get isDone => phase == RevealPhase.done;

  /// All names but the last are out: the bubble, the cruellest moment.
  bool get waitingForLast =>
      phase == RevealPhase.revealing && total > 1 && revealed == total - 1;

  @override
  List<Object?> get props => [phase, revealed, total];
}

/// Drives the one-by-one elimination reveal.
/// Each screen runs its own copy, so they stay in step without server messages.
class RevealSequenceCubit extends Cubit<RevealSequenceState> {
  final Duration intro;
  final Duration step;

  /// The longer pause before the last name.
  final Duration lastHold;
  Timer? _timer;

  static const defaultIntro = Duration(milliseconds: 2500);
  static const defaultStep = Duration(milliseconds: 1800);
  static const defaultLastHold = Duration(milliseconds: 3200);

  RevealSequenceCubit({
    required int total,
    this.intro = defaultIntro,
    this.step = defaultStep,
    this.lastHold = defaultLastHold,
  }) : super(
         RevealSequenceState(
           phase: RevealPhase.intro,
           revealed: 0,
           total: total,
         ),
       );

  void start() {
    _timer?.cancel();
    _timer = Timer(intro, _next);
  }

  void _next() {
    if (isClosed) return;
    final s = state;
    if (s.revealed >= s.total) {
      emit(
        RevealSequenceState(
          phase: RevealPhase.done,
          revealed: s.total,
          total: s.total,
        ),
      );
      return;
    }
    final next = RevealSequenceState(
      phase: RevealPhase.revealing,
      revealed: s.revealed + 1,
      total: s.total,
    );
    emit(next);
    // Wait longer before the last name, then hold before showing who's safe.
    _timer = Timer(next.waitingForLast ? lastHold : step, _next);
  }

  /// Jumps straight to the end.
  void skip() {
    _timer?.cancel();
    if (state.isDone) return;
    emit(
      RevealSequenceState(
        phase: RevealPhase.done,
        revealed: state.total,
        total: state.total,
      ),
    );
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
