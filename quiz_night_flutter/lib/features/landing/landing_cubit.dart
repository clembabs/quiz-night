import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  /// Room codes are four digits.
  bool get codeComplete => RegExp(r'^\d{4}$').hasMatch(code);

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

  /// Keeps digits only, at most four.
  void setCode(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    emit(
      state.copyWith(code: digits.length > 4 ? digits.substring(0, 4) : digits),
    );
  }

  /// Empties the code box, e.g. after coming back from a game.
  void clearCode() => emit(state.copyWith(code: ''));
}
