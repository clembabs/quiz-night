import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../app/app_paths.dart';
import '../../core/platform/screen_wake_lock.dart';
import '../../core/platform/site_url.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/qn/host_stage.dart';
import '../../widgets/qn/loaders.dart';
import '../../widgets/qn/notices.dart';
import '../../widgets/qn/phone_frame.dart';
import '../../widgets/qn/session_clock.dart';
import 'final/final_logic.dart';
import 'host/host_cut.dart';
import 'host/host_final.dart';
import 'host/host_lobby.dart';
import 'host/host_podium.dart';
import 'host/host_question.dart';
import 'host/host_reveal.dart';
import 'host/host_standings.dart';
import 'phone/phone_cut.dart';
import 'phone/phone_final.dart';
import 'phone/phone_placement.dart';
import 'phone/phone_question.dart';
import 'phone/phone_result.dart';
import 'phone/phone_waiting.dart';
import 'room_cubit.dart';

/// The in-room screen for both roles. Picks a view from the live status.
class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

/// Stateful only to observe the app lifecycle.
class _RoomScreenState extends State<RoomScreen> with WidgetsBindingObserver {
  late final ScreenWakeLock _wakeLock = context.read<ScreenWakeLock>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wakeLock.keepOn();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _wakeLock.release();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Phone browsers freeze background tabs; get a fresh snapshot on return.
    if (state == AppLifecycleState.resumed) {
      context.read<RoomCubit>().reconnect();
      // Browsers drop the wake lock whenever the tab is hidden.
      _wakeLock.keepOn();
    }
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final cubit = context.read<RoomCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          cubit.state.seat.isHost ? 'STOP HOSTING?' : 'LEAVE THE GAME?',
        ),
        content: const Text('You will lose your seat in this room.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.maroon,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (ok == true) await cubit.leave();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<RoomCubit, RoomViewState>(
          listenWhen: (a, b) => a.errorSeq != b.errorSeq,
          listener: (context, state) =>
              showToast(context, state.actionError ?? ''),
        ),
        BlocListener<RoomCubit, RoomViewState>(
          listenWhen: (a, b) => !a.left && b.left,
          listener: (context, _) => context.go(AppPaths.home),
        ),
      ],
      child: BlocBuilder<RoomCubit, RoomViewState>(
        builder: (context, state) => Scaffold(
          body: state.seat.isHost
              ? _host(context, state)
              : _phone(context, state),
        ),
      ),
    );
  }

  /// Time left in the game's 30 minutes, once it has started.
  Widget? _clock(RoomState? room, RoomViewState state, {bool large = false}) {
    final endsAt = room?.sessionEndsAt;
    if (endsAt == null) return null;
    return SessionClock(
      endsAt: endsAt,
      clockOffset: state.clockOffset,
      large: large,
    );
  }

  bool _reconnecting(RoomViewState s) =>
      s.connection == ConnectionStatus.reconnecting && !s.roomGone;

  // ---- host (projector canvas)

  Widget _host(BuildContext context, RoomViewState state) {
    final room = state.room;
    return HostStage(
      topLabel: room == null ? 'Connecting' : hostTopLabel(room, state),
      code: state.seat.code,
      reconnecting: _reconnecting(state),
      clock: _clock(room, state, large: true),
      actions: [
        HostTextButton(label: 'Leave', onPressed: () => _confirmLeave(context)),
      ],
      child: _hostBody(room, state),
    );
  }

  Widget _hostBody(RoomState? room, RoomViewState state) {
    if (state.roomGone) return const _Gone(large: true);
    if (room == null) return const LoadingView();
    final q = room.question;
    final inFinal = q != null && q.isFinal;
    return switch (room.status) {
      RoomStatus.lobby => HostLobby(room: room, appUrl: siteRoot()),
      RoomStatus.question when q != null && !inFinal => HostQuestion(
        room: room,
        clockOffset: state.clockOffset,
      ),
      RoomStatus.reveal when q != null && !inFinal =>
        state.showingStandings
            ? HostStandings(room: room, rankMoves: state.rankMoves)
            : HostReveal(room: room),
      RoomStatus.elimination => HostCut(room: room),
      RoomStatus.buzzerFinal || RoomStatus.reveal when inFinal => HostFinal(
        room: room,
        clockOffset: state.clockOffset,
      ),
      RoomStatus.finished when closedBeforeStart(room) => const _Closed(
        large: true,
      ),
      RoomStatus.finished => HostPodium(room: room),
      _ => const _Waiting(),
    };
  }

  // ---- phone

  Widget _phone(BuildContext context, RoomViewState state) {
    final room = state.room;
    final cut = room?.status == RoomStatus.elimination;
    return PhoneFrame(
      // The cut paints its own full-bleed screens without the header.
      code: room == null || cut ? null : state.seat.code,
      phase: room == null ? null : phoneHeaderLabel(room, state.me),
      reconnecting: _reconnecting(state),
      onLeave: () => _confirmLeave(context),
      clock: _clock(room, state),
      child: _phoneBody(room, state),
    );
  }

  Widget _phoneBody(RoomState? room, RoomViewState state) {
    if (state.roomGone) return const _Gone();
    if (room == null) return const LoadingView();
    if (state.removedByHost) return const _Removed();
    final q = room.question;
    final me = state.me;
    final inFinal = q != null && q.isFinal;
    return switch (room.status) {
      RoomStatus.lobby => PhoneWaiting(room: room, me: me),
      RoomStatus.question when q != null && !inFinal => PhoneQuestion(
        room: room,
        me: me,
        myChoice: state.myChoice,
        clockOffset: state.clockOffset,
      ),
      RoomStatus.reveal when q != null && !inFinal => PhoneResult(
        key: ValueKey('result-${q.id}'),
        room: room,
        me: me,
        myChoice: state.myChoice,
        move: me == null ? null : state.rankMoves[me.id],
      ),
      RoomStatus.elimination => PhoneCut(
        room: room,
        me: me,
        myBackedId: state.myBackedId,
        keepWatching: state.keepWatching,
      ),
      RoomStatus.buzzerFinal || RoomStatus.reveal when inFinal =>
        me?.status == PlayerStatus.finalist
            ? PhoneBuzzer(
                room: room,
                me: me,
                myChoice: state.myChoice,
                buzzing: state.buzzing,
              )
            : PhoneWatching(room: room, me: me, myBackedId: state.myBackedId),
      RoomStatus.finished when closedBeforeStart(room) => const _Closed(),
      RoomStatus.finished => PhonePlacement(room: room, me: me),
      _ => const _Waiting(),
    };
  }
}

/// The phone header's phase: Lobby, Round 2, Spectating, Final, Results.
String phoneHeaderLabel(RoomState room, PlayerView? me) {
  if (room.status == RoomStatus.finished) return 'Results';
  if (room.status == RoomStatus.lobby) return 'Lobby';
  if (me?.status == PlayerStatus.eliminated) return 'Spectating';
  if (room.question?.isFinal ?? false) return 'Final';
  return 'Round ${room.round}';
}

/// The projector header's label for the current moment.
String hostTopLabel(RoomState room, RoomViewState state) {
  final q = room.question;
  return switch (room.status) {
    RoomStatus.lobby => 'Lobby',
    RoomStatus.question when q != null && !q.isFinal =>
      'Round ${q.round} · Question ${q.indexInRound} of ${room.questionsPerRound}',
    RoomStatus.reveal when q != null && !q.isFinal =>
      state.showingStandings ? 'Leaderboard' : 'Reveal',
    RoomStatus.elimination => 'Round ${room.round} · elimination',
    RoomStatus.buzzerFinal || RoomStatus.reveal => 'Final',
    RoomStatus.finished => 'Results',
    _ => '',
  };
}

class _Gone extends StatelessWidget {
  final bool large;

  const _Gone({this.large = false});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'This room no longer exists.',
      style: large ? AppProjectorText.title : AppTextStyles.title,
    ),
  );
}

/// A lobby closed after 30 minutes with nobody doing anything: no results
/// to show, just why the room is gone.
class _Closed extends StatelessWidget {
  final bool large;

  const _Closed({this.large = false});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ROOM CLOSED',
            textAlign: TextAlign.center,
            style: large ? AppProjectorText.displayL : AppTextStyles.displayL,
          ),
          const SizedBox(height: 12),
          Text(
            'Nothing happened here for 30 minutes, so the room closed. '
            'Start a new one any time.',
            key: const Key('room.closed'),
            textAlign: TextAlign.center,
            style: large ? AppProjectorText.bodySoft : AppTextStyles.bodySoft,
          ),
        ],
      ),
    ),
  );
}

/// A player the host removed from the lobby: say so, and offer the way out.
class _Removed extends StatelessWidget {
  const _Removed();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'YOU WERE REMOVED',
            textAlign: TextAlign.center,
            style: AppTextStyles.displayL,
          ),
          const SizedBox(height: 12),
          Text(
            'The host removed you from this room. You can join again with '
            'the code on the big screen.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySoft,
          ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('removed.home'),
            onPressed: context.read<RoomCubit>().leave,
            child: const Text('Back home'),
          ),
        ],
      ),
    ),
  );
}

/// Only reachable in states the server does not use yet (tiebreak rounds).
class _Waiting extends StatelessWidget {
  const _Waiting();

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PulsingDots(size: 10),
        const SizedBox(height: 16),
        Text('Hang tight, the host is setting up…', style: AppTextStyles.body),
      ],
    ),
  );
}
