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

  /// Players are not in one room (a call): their screens show everything.
  final bool remote;

  /// No new players once the host presses Start.
  final bool lockOnStart;
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
    this.remote = false,
    this.lockOnStart = false,
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
    bool? remote,
    bool? lockOnStart,
  }) => HostSetupState(
    rule: rule ?? this.rule,
    questionsPerRound: questionsPerRound ?? this.questionsPerRound,
    finalists: finalists ?? this.finalists,
    roundsBeforeFinal: roundsBeforeFinal ?? this.roundsBeforeFinal,
    secondsPerQuestion: secondsPerQuestion ?? this.secondsPerQuestion,
    showQuestionOnPhones: showQuestionOnPhones ?? this.showQuestionOnPhones,
    remote: remote ?? this.remote,
    lockOnStart: lockOnStart ?? this.lockOnStart,
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
    remote: remote,
    lockOnStart: lockOnStart,
    submitting: submitting,
    error: error,
    seat: seat,
  );

  RoomConfig toConfig({PackDraft? pack}) => RoomConfig(
    packId: pack?.packId,
    packToken: pack?.packToken,
    eliminationRule: rule,
    questionsPerRound: questionsPerRound,
    finalistTarget: finalists,
    roundsBeforeFinal: roundsBeforeFinal,
    timeLimitSeconds: secondsPerQuestion,
    showQuestionOnPhones: remote || showQuestionOnPhones,
    remote: remote,
    lockOnStart: lockOnStart,
  );

  @override
  List<Object?> get props => [
    rule,
    questionsPerRound,
    finalists,
    roundsBeforeFinal,
    secondsPerQuestion,
    showQuestionOnPhones,
    remote,
    lockOnStart,
    submitting,
    error,
    seat,
  ];
}

/// One setting in the summary: what was picked, and what it means.
class SummaryItem extends Equatable {
  final String title;
  final String detail;

  const SummaryItem(this.title, this.detail);

  @override
  List<Object?> get props => [title, detail];
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

  void setRemote(bool remote) => emit(state.copyWith(remote: remote));

  void setLockOnStart(bool lock) => emit(state.copyWith(lockOnStart: lock));

  /// What each choice means for the game, for the summary panel.
  List<SummaryItem> get summary {
    final s = state;
    final finalQuestions = s.toConfig().finalQuestionCount;
    return [
      s.remote
          ? const SummaryItem(
              'Remote game',
              'Players join from anywhere with the link. Every phone shows '
                  'the questions, the cut and the podium; sharing your '
                  'screen is optional.',
            )
          : const SummaryItem(
              'Everyone in the room',
              'Questions and the cut play on your big screen; phones answer.',
            ),
      switch (s.rule) {
        EliminationRule.bottomPercent => const SummaryItem(
          'Bottom 30%',
          'After each round the lowest 30% go home; ties go to the faster '
              'player.',
        ),
        EliminationRule.autoScaled => SummaryItem(
          'Auto-scaled',
          'Each cut is sized so any room reaches ${s.finalists} finalists in '
              '${s.roundsBeforeFinal} rounds, however many join.',
        ),
        EliminationRule.suddenDeath => const SummaryItem(
          'Sudden death',
          'A wrong or missed answer knocks you out on the spot. Two players '
              'always survive.',
        ),
      },
      SummaryItem(
        '${s.questionsPerRound} questions a round, ${s.secondsPerQuestion}s each',
        'Correct answers score 500 to 1000; faster scores more.',
      ),
      SummaryItem(
        'Top ${s.finalists} go to the buzzer final',
        '$finalQuestions questions. First to buzz answers; a wrong answer '
            'locks them out.',
      ),
      if (!s.remote)
        s.showQuestionOnPhones
            ? const SummaryItem(
                'Question on phones',
                'Phones show the question and the options too.',
              )
            : const SummaryItem(
                'Question on the big screen only',
                'Phones show just the answer buttons, so everyone looks up.',
              ),
      s.lockOnStart
          ? const SummaryItem(
              'Locked once it starts',
              'Nobody new can join after you press Start.',
            )
          : const SummaryItem(
              'Latecomers welcome',
              'They play until the first cut, then watch. Lock the room any '
                  'time.',
            ),
      const SummaryItem(
        'Knocked out? Keep playing',
        'They answer for a shadow score and back a finalist.',
      ),
    ];
  }

  /// Creates the room, playing [pack] (AI questions) when given.
  Future<void> create({PackDraft? pack}) async {
    if (state.submitting) return;
    emit(state.withStatus(submitting: true));
    try {
      final seat = await _lobby.createRoom(state.toConfig(pack: pack));
      await _seats.save(seat);
      emit(state.withStatus(seat: seat));
    } on AppFailure catch (f) {
      emit(state.withStatus(error: f.message));
    }
  }
}
