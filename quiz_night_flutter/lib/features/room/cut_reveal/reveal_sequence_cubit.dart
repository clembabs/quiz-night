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

  @override
  List<Object?> get props => [phase, revealed, total];
}

/// Drives the dramatic one-by-one elimination reveal.
///
/// Every screen runs its own copy from the same cut, so the projector and
/// phones stay roughly in step without extra server messages.
class RevealSequenceCubit extends Cubit<RevealSequenceState> {
  final Duration intro;
  final Duration step;
  Timer? _timer;

  static const defaultIntro = Duration(milliseconds: 2500);
  static const defaultStep = Duration(milliseconds: 1800);

  RevealSequenceCubit({
    required int total,
    this.intro = defaultIntro,
    this.step = defaultStep,
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
    emit(
      RevealSequenceState(
        phase: RevealPhase.revealing,
        revealed: s.revealed + 1,
        total: s.total,
      ),
    );
    // Hold on the last name a beat before showing who is safe.
    _timer = Timer(step, _next);
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
