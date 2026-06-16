enum SoundSource { none, asset, stream }

class SoundOption {
  final String id;
  final String label;
  final String emoji;
  final SoundSource source;
  final String? assetPath;
  final String? streamUrl;
  final String? iconAsset;

  const SoundOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.source,
    this.assetPath,
    this.streamUrl,
    this.iconAsset,
  });
}

const List<SoundOption> kBundledSounds = [
  SoundOption(
    id: 'none',
    label: 'None',
    emoji: '○',
    source: SoundSource.none,
    iconAsset: 'assets/icons/focus_sounds/none.png',
  ),
  SoundOption(
    id: 'brown_noise',
    label: 'Brown Noise',
    emoji: '◎',
    source: SoundSource.asset,
    assetPath: 'assets/audio/brown_noise.mp3',
    iconAsset: 'assets/icons/focus_sounds/brown_noise.png',
  ),
  SoundOption(
    id: 'rain',
    label: 'Rain',
    emoji: '≋',
    source: SoundSource.asset,
    assetPath: 'assets/audio/rain.mp3',
    iconAsset: 'assets/icons/focus_sounds/rain.png',
  ),
  SoundOption(
    id: 'cafe',
    label: 'Café',
    emoji: '⌂',
    source: SoundSource.asset,
    assetPath: 'assets/audio/cafe.mp3',
    iconAsset: 'assets/icons/focus_sounds/cafe.png',
  ),
  SoundOption(
    id: 'vinyl',
    label: 'Film Projector',
    emoji: '◉',
    source: SoundSource.asset,
    assetPath: 'assets/audio/vinyl_70s.mp3',
    iconAsset: 'assets/icons/focus_sounds/vinyl.png',
  ),
];

// Lofi Girl radio — free, reliable, CORS-friendly
const String kDefaultStreamUrl =
    'https://lofi.stream.laut.fm/lofi';

SoundOption streamSoundOption(String url) => SoundOption(
      id: 'stream',
      label: 'Music Stream',
      emoji: '⊕',
      source: SoundSource.stream,
      streamUrl: url,
      iconAsset: 'assets/icons/focus_sounds/music_stream.png',
    );
