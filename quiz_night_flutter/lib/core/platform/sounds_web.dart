import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'sounds.dart';

Sounds createSounds() => _WebAudioSounds();

/// Cues built from Web Audio oscillators and noise: no files to download.
class _WebAudioSounds implements Sounds {
  @override
  bool enabled = true;

  web.AudioContext? _ctx;

  /// Everything plays through this, so [stop] can cut it all at once.
  web.GainNode? _master;
  web.AudioBuffer? _noise;

  web.AudioContext? get _context {
    try {
      return _ctx ??= web.AudioContext();
    } catch (_) {
      return null;
    }
  }

  @override
  void unlock() {
    try {
      final ctx = _context;
      if (ctx != null && ctx.state == 'suspended') ctx.resume();
    } catch (_) {}
  }

  @override
  void play(SoundCue cue) {
    if (!enabled) return;
    try {
      final ctx = _context;
      if (ctx == null || ctx.state != 'running') return;
      final out = _master ??= _newMaster(ctx);
      final t = ctx.currentTime;
      switch (cue) {
        case SoundCue.drumroll:
          _drumroll(ctx, out, t);
        case SoundCue.stamp:
          _stamp(ctx, out, t);
        case SoundCue.survive:
          _chord(ctx, out, t, const [523.25, 659.25, 783.99, 1046.5], 0.09);
        case SoundCue.fanfare:
          _chord(ctx, out, t, const [392.0, 523.25, 659.25, 783.99], 0.16);
          _chord(ctx, out, t + 0.7, const [523.25, 659.25, 783.99], 0);
      }
    } catch (_) {}
  }

  @override
  void stop() {
    try {
      _master?.disconnect();
    } catch (_) {}
    _master = null;
  }

  web.GainNode _newMaster(web.AudioContext ctx) {
    final g = ctx.createGain()..gain.value = 0.8;
    g.connect(ctx.destination);
    return g;
  }

  /// White noise, made once and reused by every hit.
  web.AudioBuffer _noiseBuffer(web.AudioContext ctx) {
    if (_noise case final n?) return n;
    final rate = ctx.sampleRate.round();
    final buffer = ctx.createBuffer(1, rate, rate);
    final rng = Random(7);
    final data = Float32List(rate);
    for (var i = 0; i < rate; i++) {
      data[i] = rng.nextDouble() * 2 - 1;
    }
    buffer.copyToChannel(data.toJS, 0);
    return _noise = buffer;
  }

  /// One filtered noise hit: a snare tap or the crack of a stamp.
  void _hit(
    web.AudioContext ctx,
    web.AudioNode out,
    double at, {
    required double level,
    required double length,
    double frequency = 1800,
  }) {
    final src = ctx.createBufferSource()..buffer = _noiseBuffer(ctx);
    final filter = ctx.createBiquadFilter()
      ..type = 'bandpass'
      ..frequency.value = frequency;
    final gain = ctx.createGain();
    gain.gain
      ..setValueAtTime(level, at)
      ..exponentialRampToValueAtTime(0.001, at + length);
    src.connect(filter);
    filter.connect(gain);
    gain.connect(out);
    src.start(at, Random().nextDouble() * 0.5, length + 0.05);
  }

  /// About 2.4 s of snare taps, faster and louder towards the end.
  void _drumroll(web.AudioContext ctx, web.AudioNode out, double t) {
    var at = t;
    const end = 2.4;
    while (at < t + end) {
      final p = (at - t) / end;
      _hit(ctx, out, at, level: 0.12 + 0.3 * p, length: 0.07);
      at += 0.085 - 0.045 * p;
    }
  }

  /// A low drop under a sharp crack.
  void _stamp(web.AudioContext ctx, web.AudioNode out, double t) {
    final osc = ctx.createOscillator()..type = 'sine';
    osc.frequency
      ..setValueAtTime(140, t)
      ..exponentialRampToValueAtTime(45, t + 0.35);
    final gain = ctx.createGain();
    gain.gain
      ..setValueAtTime(0.9, t)
      ..exponentialRampToValueAtTime(0.001, t + 0.45);
    osc.connect(gain);
    gain.connect(out);
    osc
      ..start(t)
      ..stop(t + 0.5);
    _hit(ctx, out, t, level: 0.5, length: 0.12, frequency: 2600);
  }

  /// Plays [notes] (Hz) [spread] s apart, each ringing: a chime, or a chord.
  void _chord(
    web.AudioContext ctx,
    web.AudioNode out,
    double t,
    List<double> notes,
    double spread,
  ) {
    for (var i = 0; i < notes.length; i++) {
      final at = t + i * spread;
      final osc = ctx.createOscillator()
        ..type = 'triangle'
        ..frequency.value = notes[i];
      final gain = ctx.createGain();
      gain.gain
        ..setValueAtTime(0.0001, at)
        ..exponentialRampToValueAtTime(0.22, at + 0.02)
        ..exponentialRampToValueAtTime(0.001, at + 1.2);
      osc.connect(gain);
      gain.connect(out);
      osc
        ..start(at)
        ..stop(at + 1.3);
    }
  }
}
