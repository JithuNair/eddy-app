import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/sound_option.dart';

class SoundState {
  final SoundOption selected;
  final double volume;
  final bool isPlaying;
  final bool isLoading;
  final String customStreamUrl;
  final String? error;

  const SoundState({
    required this.selected,
    required this.volume,
    required this.isPlaying,
    required this.isLoading,
    required this.customStreamUrl,
    this.error,
  });

  SoundState copyWith({
    SoundOption? selected,
    double? volume,
    bool? isPlaying,
    bool? isLoading,
    String? customStreamUrl,
    String? error,
    bool clearError = false,
  }) {
    return SoundState(
      selected: selected ?? this.selected,
      volume: volume ?? this.volume,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      customStreamUrl: customStreamUrl ?? this.customStreamUrl,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class SoundNotifier extends StateNotifier<SoundState> {
  final AudioPlayer _player = AudioPlayer();

  SoundNotifier()
      : super(SoundState(
          selected: kBundledSounds[0],
          volume: 0.65,
          isPlaying: false,
          isLoading: false,
          customStreamUrl: kDefaultStreamUrl,
        )) {
    _player.onPlayerComplete.listen((_) {
      state = state.copyWith(isPlaying: false);
    });
  }

  Future<void> select(SoundOption sound) async {
    if (sound.id == state.selected.id) return;
    final wasPlaying = state.isPlaying;
    await _player.stop();
    state = state.copyWith(selected: sound, isPlaying: false, clearError: true);
    if (wasPlaying && sound.source != SoundSource.none) {
      await play();
    }
  }

  Future<void> play() async {
    final sound = state.selected;
    if (sound.source == SoundSource.none) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _player.setVolume(state.volume);

      if (sound.source == SoundSource.asset) {
        await _player.setReleaseMode(ReleaseMode.loop);
        await _player.play(AssetSource(sound.assetPath!.replaceFirst('assets/', '')));
      } else {
        final url = sound.streamUrl ?? state.customStreamUrl;
        await _player.setReleaseMode(ReleaseMode.release);
        await _player.play(UrlSource(url));
      }

      state = state.copyWith(isPlaying: true, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isPlaying: false,
        isLoading: false,
        error: 'Could not load audio. Check the URL or your connection.',
      );
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> setVolume(double v) async {
    await _player.setVolume(v);
    state = state.copyWith(volume: v);
  }

  Future<void> setCustomStreamUrl(String url) async {
    final updated = streamSoundOption(url);
    await _player.stop();
    state = state.copyWith(
      customStreamUrl: url,
      selected: updated,
      isPlaying: false,
      clearError: true,
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final soundProvider =
    StateNotifierProvider<SoundNotifier, SoundState>((ref) => SoundNotifier());
