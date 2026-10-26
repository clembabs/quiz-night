import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sounds_stub.dart'
    if (dart.library.js_interop) 'sounds_web.dart'
    as impl;

/// The cut's sound cues, synthesised in the browser: no download.
enum SoundCue {
  /// Under "Who's going home?": a snare roll that builds.
  drumroll,

  /// A name stamped OUT: a low thud.
  stamp,

  /// "13 SURVIVE": a rising chime.
  survive,

  /// "Meet your finalists": a short fanfare.
  fanfare,
}

/// Plays [SoundCue]s on the projector. The host can mute them.
abstract interface class Sounds {
  bool get enabled;
  set enabled(bool value);

  /// Browsers allow audio only after a tap; call on every pointer down.
  void unlock();

  /// Plays [cue] if enabled and supported. Never throws.
  void play(SoundCue cue);

  /// Stops whatever is playing (a skipped reveal).
  void stop();

  /// The app's [Sounds], or silence when none is provided (tests).
  static Sounds of(BuildContext context) {
    try {
      return context.read<Sounds>();
    } catch (_) {
      return SilentSounds();
    }
  }
}

/// Web Audio in the browser; silent elsewhere.
Sounds createSounds() => impl.createSounds();

/// Sounds that never play: off the web, and in tests.
class SilentSounds implements Sounds {
  @override
  bool enabled = true;

  @override
  void unlock() {}

  @override
  void play(SoundCue cue) {}

  @override
  void stop() {}
}
