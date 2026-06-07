enum SoundSource { none, asset, stream }

class SoundOption {
  final String id;
  final String label;
  final String emoji;
  final SoundSource source;
  final String? assetPath;
  final String? streamUrl;

  const SoundOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.source,
    this.assetPath,
    this.streamUrl,
  });
}

const List<SoundOption> kBundledSounds = [
  SoundOption(id: 'none', label: 'None', emoji: '○', source: SoundSource.none),
  SoundOption(
    id: 'brown_noise',
    label: 'Brown Noise',
    emoji: '◎',
    source: SoundSource.asset,
    assetPath: 'assets/audio/brown_noise.mp3',
  ),
  SoundOption(
    id: 'rain',
    label: 'Rain',
    emoji: '≋',
    source: SoundSource.asset,
    assetPath: 'assets/audio/rain.mp3',
  ),
  SoundOption(
    id: 'cafe',
    label: 'Café',
    emoji: '⌂',
    source: SoundSource.asset,
    assetPath: 'assets/audio/cafe.mp3',
  ),
  SoundOption(
    id: 'vinyl',
    label: '70s Vinyl',
    emoji: '◉',
    source: SoundSource.asset,
    assetPath: 'assets/audio/vinyl_70s.mp3',
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
    );
