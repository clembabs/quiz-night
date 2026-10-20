import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../data/app_failure.dart';
import '../../data/room_repositories.dart';
import '../../data/seat.dart';
import '../../data/seat_repository.dart';

/// Allowed ranges for the host's settings.
abstract final class HostSetupLimits {
  /// The quick-pick values shown on the create screen.
  static const questionsChoices = [3, 5, 8, 10];
  static const finalistChoices = [2, 3, 4];
  static const secondsChoices = [15, 20, 30];

  static const questionsPerRound = (min: 1, max: 10);
  static const finalists = (min: 2, max: 5);
  static const rounds = (min: 1, max: 6);
  static const seconds = (min: 10, max: 60, step: 5);
}

class HostSetupState extends Equatable {
  final EliminationRule rule;
  final int questionsPerRound;
  final int finalists;
  final int roundsBeforeFinal;
  final int secondsPerQuestion;

  /// Whether phones show the question text, or only the projector.
  final bool showQuestionOnPhones;
  final bool submitting;
  final String? error;

  /// Set once the room exists; the screen moves into it.
  final Seat? seat;

  const HostSetupState({
    this.rule = EliminationRule.bottomPercent,
    this.questionsPerRound = 5,
    this.finalists = 3,
    this.roundsBeforeFinal = 3,
    this.secondsPerQuestion = 20,
    this.showQuestionOnPhones = true,
    this.submitting = false,
    this.error,
    this.seat,
  });

  HostSetupState copyWith({
    EliminationRule? rule,
    int? questionsPerRound,
    int? finalists,
    int? roundsBeforeFinal,
    int? secondsPerQuestion,
    bool? showQuestionOnPhones,
  }) => HostSetupState(
    rule: rule ?? this.rule,
    questionsPerRound: questionsPerRound ?? this.questionsPerRound,
    finalists: finalists ?? this.finalists,
    roundsBeforeFinal: roundsBeforeFinal ?? this.roundsBeforeFinal,
    secondsPerQuestion: secondsPerQuestion ?? this.secondsPerQuestion,
    showQuestionOnPhones: showQuestionOnPhones ?? this.showQuestionOnPhones,
  );

  HostSetupState withStatus({
    bool submitting = false,
    String? error,
    Seat? seat,
  }) => HostSetupState(
    rule: rule,
    questionsPerRound: questionsPerRound,
    finalists: finalists,
    roundsBeforeFinal: roundsBeforeFinal,
    secondsPerQuestion: secondsPerQuestion,
    showQuestionOnPhones: showQuestionOnPhones,
    submitting: submitting,
    error: error,
    seat: seat,
  );

  RoomConfig toConfig() => RoomConfig(
    eliminationRule: rule,
    questionsPerRound: questionsPerRound,
    finalistTarget: finalists,
    roundsBeforeFinal: roundsBeforeFinal,
    timeLimitSeconds: secondsPerQuestion,
    showQuestionOnPhones: showQuestionOnPhones,
  );

  @override
  List<Object?> get props => [
    rule,
    questionsPerRound,
    finalists,
    roundsBeforeFinal,
    secondsPerQuestion,
    showQuestionOnPhones,
    submitting,
    error,
    seat,
  ];
}

class HostSetupCubit extends Cubit<HostSetupState> {
  final LobbyRepository _lobby;
  final SeatRepository _seats;

  HostSetupCubit(this._lobby, this._seats) : super(const HostSetupState());

  void setRule(EliminationRule rule) => emit(state.copyWith(rule: rule));

  void setQuestionsPerRound(int v) {
    final l = HostSetupLimits.questionsPerRound;
    emit(state.copyWith(questionsPerRound: v.clamp(l.min, l.max)));
  }

  void setFinalists(int v) {
    final l = HostSetupLimits.finalists;
    emit(state.copyWith(finalists: v.clamp(l.min, l.max)));
  }

  void setRoundsBeforeFinal(int v) {
    final l = HostSetupLimits.rounds;
    emit(state.copyWith(roundsBeforeFinal: v.clamp(l.min, l.max)));
  }

  void setSecondsPerQuestion(int v) {
    final l = HostSetupLimits.seconds;
    emit(state.copyWith(secondsPerQuestion: v.clamp(l.min, l.max)));
  }

  void setShowQuestionOnPhones(bool show) =>
      emit(state.copyWith(showQuestionOnPhones: show));

  /// One line describing the game, for the summary panel.
  String get summary {
    final s = state;
    final rule = switch (s.rule) {
      EliminationRule.bottomPercent => 'Bottom 30%',
      EliminationRule.autoScaled => 'Auto-scaled',
      EliminationRule.suddenDeath => 'Sudden death',
    };
    return '$rule elimination, ${s.questionsPerRound} questions per round, '
        '${s.finalists} finalists in a buzzer final. '
        '${s.secondsPerQuestion}s per question; questions '
        '${s.showQuestionOnPhones ? 'on phones and' : 'only on'} the big '
        'screen.';
  }

  Future<void> create() async {
    if (state.submitting) return;
    emit(state.withStatus(submitting: true));
    try {
      final seat = await _lobby.createRoom(state.toConfig());
      await _seats.save(seat);
      emit(state.withStatus(seat: seat));
    } on AppFailure catch (f) {
      emit(state.withStatus(error: f.message));
    }
  }
}
