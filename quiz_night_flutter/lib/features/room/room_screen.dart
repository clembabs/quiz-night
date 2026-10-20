import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_night_client/quiz_night_client.dart';

import '../../widgets/common.dart';
import 'host_lobby_view.dart';
import 'player_lobby_view.dart';
import 'room_cubit.dart';
import 'round/host_cut_view.dart';
import 'round/host_question_view.dart';
import 'round/player_cut_view.dart';
import 'round/player_question_view.dart';
import 'round/player_reveal_view.dart';

/// The in-room screen for both roles. Picks a view from the live status.
class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

/// Stateful only to observe the app lifecycle.
class _RoomScreenState extends State<RoomScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Phone browsers freeze background tabs; get a fresh snapshot on return.
    if (state == AppLifecycleState.resumed) {
      context.read<RoomCubit>().reconnect();
    }
  }

  Future<void> _confirmLeave(BuildContext context) async {
    final cubit = context.read<RoomCubit>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          cubit.state.seat.isHost ? 'Stop hosting?' : 'Leave the game?',
        ),
        content: const Text('You will lose your seat in this room.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
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
          listener: (context, state) => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.actionError ?? ''))),
        ),
        BlocListener<RoomCubit, RoomViewState>(
          listenWhen: (a, b) => !a.left && b.left,
          listener: (context, _) => Navigator.of(context).pop(),
        ),
      ],
      child: BlocBuilder<RoomCubit, RoomViewState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('Room ${state.seat.code}'),
            actions: [
              if (state.connection == ConnectionStatus.reconnecting &&
                  !state.roomGone)
                const _ReconnectingChip(),
              IconButton(
                tooltip: 'Leave',
                onPressed: () => _confirmLeave(context),
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          body: SafeArea(child: _body(state)),
        ),
      ),
    );
  }

  Widget _body(RoomViewState state) {
    if (state.roomGone) {
      return const MessageView(
        icon: Icons.search_off_rounded,
        text: 'This room no longer exists.',
      );
    }
    final room = state.room;
    if (room == null) return const Center(child: CircularProgressIndicator());
    return state.seat.isHost
        ? _hostStage(room, state)
        : _playerStage(room, state);
  }

  Widget _hostStage(RoomState room, RoomViewState state) {
    final q = room.question;
    return switch (room.status) {
      RoomStatus.lobby => HostLobbyView(room: room),
      RoomStatus.question || RoomStatus.reveal when q != null && !q.isFinal =>
        HostQuestionView(room: room, clockOffset: state.clockOffset),
      RoomStatus.elimination => HostCutView(room: room),
      _ => _comingSoon(room),
    };
  }

  Widget _playerStage(RoomState room, RoomViewState state) {
    final q = room.question;
    final me = state.me;
    return switch (room.status) {
      RoomStatus.lobby => PlayerLobbyView(room: room, me: me),
      RoomStatus.question when q != null && !q.isFinal => PlayerQuestionView(
        room: room,
        me: me,
        myChoice: state.myChoice,
        clockOffset: state.clockOffset,
      ),
      RoomStatus.reveal when q != null && !q.isFinal => PlayerRevealView(
        room: room,
        me: me,
        myChoice: state.myChoice,
      ),
      RoomStatus.elimination => PlayerCutView(room: room, me: me),
      _ => _comingSoon(room),
    };
  }

  // The buzzer final and podium arrive in Milestone 6.
  Widget _comingSoon(RoomState room) => MessageView(
    icon: Icons.construction_rounded,
    text:
        'Game in progress (${room.status.name}).\n'
        'This screen arrives in a later milestone.',
  );
}

class _ReconnectingChip extends StatelessWidget {
  const _ReconnectingChip();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(right: 8),
    child: Chip(
      avatar: SizedBox.square(
        dimension: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      label: Text('Reconnecting'),
    ),
  );
}
