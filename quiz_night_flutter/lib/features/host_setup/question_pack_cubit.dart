import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../data/app_failure.dart';
import '../../data/questions_repository.dart';
import 'host_setup_cubit.dart';

enum PackStatus {
  /// Asking the server whether AI questions are set up.
  checking,

  /// This server has no AI key: built-in questions only.
  unavailable,

  /// Waiting for a topic.
  idle,

  /// The AI is writing (about 10–20 seconds).
  generating,

  /// A pack is ready to preview and use.
  ready,
}

/// How many questions the host may ask the AI for (the server checks too).
abstract final class PackLimits {
  static const minCount = 10;
  static const maxCount = 40;
  static const step = 5;
  static const defaultCount = 20;
}

class QuestionPackState extends Equatable {
  final PackStatus status;
  final String topic;
  final QuestionDifficulty difficulty;

  /// Questions to write, rounds and final together.
  final int count;
  final PackDraft? pack;
  final String? error;

  const QuestionPackState({
    this.status = PackStatus.checking,
    this.topic = '',
    this.difficulty = QuestionDifficulty.mixed,
    this.count = PackLimits.defaultCount,
    this.pack,
    this.error,
  });

  /// Topics are 2–100 characters (the server checks again).
  bool get canGenerate =>
      status != PackStatus.generating &&
      status != PackStatus.unavailable &&
      topic.trim().length >= 2;

  int get roundCount => pack?.questions.where((q) => !q.isFinal).length ?? 0;
  int get finalCount => pack?.questions.where((q) => q.isFinal).length ?? 0;

  QuestionPackState copyWith({
    PackStatus? status,
    String? topic,
    QuestionDifficulty? difficulty,
    int? count,
    PackDraft? pack,
    bool clearPack = false,
    String? error,
    bool clearError = false,
  }) => QuestionPackState(
    status: status ?? this.status,
    topic: topic ?? this.topic,
    difficulty: difficulty ?? this.difficulty,
    count: count ?? this.count,
    pack: clearPack ? null : pack ?? this.pack,
    error: clearError ? null : error ?? this.error,
  );

  @override
  List<Object?> get props => [status, topic, difficulty, count, pack, error];
}

/// The setup screen's AI questions; game settings live in [HostSetupCubit].
class QuestionPackCubit extends Cubit<QuestionPackState> {
  final QuestionsRepository _questions;

  QuestionPackCubit(this._questions) : super(const QuestionPackState());

  /// Asks the server whether it can write questions.
  Future<void> start() async {
    final ok = await _questions.aiAvailable();
    if (isClosed) return;
    emit(state.copyWith(status: ok ? PackStatus.idle : PackStatus.unavailable));
  }

  void setTopic(String topic) =>
      emit(state.copyWith(topic: topic, clearError: true));

  void setDifficulty(QuestionDifficulty d) =>
      emit(state.copyWith(difficulty: d));

  /// Sets how many questions to write, kept within [PackLimits].
  void setCount(int count) => emit(
    state.copyWith(
      count: count.clamp(PackLimits.minCount, PackLimits.maxCount),
    ),
  );

  /// Writes [QuestionPackState.count] questions on the topic for [config].
  Future<void> generate(RoomConfig config) async {
    if (!state.canGenerate) return;
    final previous = state.pack;
    emit(state.copyWith(status: PackStatus.generating, clearError: true));
    try {
      final pack = await _questions.generatePack(
        state.topic.trim(),
        state.difficulty,
        state.count,
        config,
      );
      emit(state.copyWith(status: PackStatus.ready, pack: pack));
    } on AppFailure catch (f) {
      // Keep any earlier pack: a failed retry shouldn't lose it.
      emit(
        state.copyWith(
          status: previous == null ? PackStatus.idle : PackStatus.ready,
          error: f.message,
        ),
      );
    }
  }

  Future<void> remove(int questionId, RoomConfig config) async {
    final pack = state.pack;
    if (pack == null) return;
    try {
      final updated = await _questions.removeQuestion(pack, questionId, config);
      emit(state.copyWith(pack: updated, clearError: true));
    } on AppFailure catch (f) {
      emit(state.copyWith(error: f.message));
    }
  }

  /// Back to the built-in questions.
  void discard() => emit(
    state.copyWith(status: PackStatus.idle, clearPack: true, clearError: true),
  );

  /// The summary line for the questions the game will use.
  SummaryItem get summaryItem {
    final pack = state.pack;
    if (pack != null && state.status == PackStatus.ready) {
      final count = state.roundCount + state.finalCount;
      final short =
          state.roundCount < pack.roundQuestionsNeeded ||
          state.finalCount < pack.finalQuestionsNeeded;
      return SummaryItem(
        '$count AI questions on “${pack.topic}”',
        short
            ? 'Written for this game; the built-in questions fill in if they '
                  'run out.'
            : 'Written for this game: enough for every round and the final.',
      );
    }
    if (state.status == PackStatus.unavailable) {
      return const SummaryItem(
        'Built-in questions',
        'General knowledge from the question bank.',
      );
    }
    return const SummaryItem(
      'Built-in questions',
      'Or type a topic and let AI write questions for this game.',
    );
  }
}
