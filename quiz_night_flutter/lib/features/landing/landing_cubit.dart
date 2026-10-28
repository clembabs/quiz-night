import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/room_code.dart';

/// Whose walkthrough the "How it works" section shows.
enum WalkthroughTab { players, hosts }

class LandingState extends Equatable {
  final WalkthroughTab tab;

  /// FAQ answers that are open, by "group-index" key.
  final Set<String> openFaq;

  /// The narrow-screen menu.
  final bool menuOpen;

  /// What is typed in the hero's room code box.
  final String code;

  const LandingState({
    this.tab = WalkthroughTab.players,
    this.openFaq = const {},
    this.menuOpen = false,
    this.code = '',
  });

  /// Long enough to try joining with (four letters and digits).
  bool get codeComplete => RoomCode.isComplete(code);

  LandingState copyWith({
    WalkthroughTab? tab,
    Set<String>? openFaq,
    bool? menuOpen,
    String? code,
  }) => LandingState(
    tab: tab ?? this.tab,
    openFaq: openFaq ?? this.openFaq,
    menuOpen: menuOpen ?? this.menuOpen,
    code: code ?? this.code,
  );

  @override
  List<Object?> get props => [tab, openFaq, menuOpen, code];
}

/// The landing page's own state: tabs, FAQ, menu and the code box.
class LandingCubit extends Cubit<LandingState> {
  LandingCubit() : super(const LandingState());

  void pickTab(WalkthroughTab tab) => emit(state.copyWith(tab: tab));

  void toggleFaq(String key) {
    final open = {...state.openFaq};
    if (!open.remove(key)) open.add(key);
    emit(state.copyWith(openFaq: open));
  }

  void toggleMenu() => emit(state.copyWith(menuOpen: !state.menuOpen));

  void closeMenu() {
    if (state.menuOpen) emit(state.copyWith(menuOpen: false));
  }

  /// Keeps letters and digits, in capitals.
  void setCode(String text) => emit(state.copyWith(code: RoomCode.clean(text)));
}
