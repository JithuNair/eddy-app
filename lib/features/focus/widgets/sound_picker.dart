import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/color_tokens.dart';
import '../models/sound_option.dart';
import '../providers/sound_provider.dart';

class SoundPicker extends ConsumerStatefulWidget {
  const SoundPicker({super.key});

  @override
  ConsumerState<SoundPicker> createState() => _SoundPickerState();
}

class _SoundPickerState extends ConsumerState<SoundPicker> {
  final _urlController = TextEditingController();
  bool _editingUrl = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = ref.read(soundProvider).customStreamUrl;
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sound = ref.watch(soundProvider);
    final notifier = ref.read(soundProvider.notifier);
    final isStream = sound.selected.source == SoundSource.stream;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BACKGROUND',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: c.textMuted,
                  letterSpacing: 2,
                )),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              ...[
                for (final option in kBundledSounds) ...[
                  _SoundChip(
                    option: option,
                    selected: sound.selected.id == option.id,
                    accentColor: c.focus,
                    colors: c,
                    onTap: () => notifier.select(option),
                  ),
                  const SizedBox(width: 8),
                ]
              ],
              _StreamChip(
                selected: isStream,
                accentColor: c.focus,
                colors: c,
                onTap: () async {
                  await notifier.select(streamSoundOption(sound.customStreamUrl));
                },
              ),
            ],
          ),
        ),
        if (isStream) ...[
          const SizedBox(height: 12),
          _StreamUrlRow(
            controller: _urlController,
            editing: _editingUrl,
            error: sound.error,
            accentColor: c.focus,
            colors: c,
            onEdit: () => setState(() => _editingUrl = true),
            onSave: () {
              setState(() => _editingUrl = false);
              final url = _urlController.text.trim();
              if (url.isNotEmpty) notifier.setCustomStreamUrl(url);
            },
            defaultLabel: 'Lofi stream',
            onUseDefault: () {
              _urlController.text = kDefaultStreamUrl;
              notifier.setCustomStreamUrl(kDefaultStreamUrl);
            },
          ),
        ],
        if (!isStream && sound.error != null) ...[
          const SizedBox(height: 8),
          Text(sound.error!,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.redAccent)),
        ],
      ],
    );
  }
}

class _SoundChip extends StatelessWidget {
  final SoundOption option;
  final bool selected;
  final Color accentColor;
  final ColorTokens colors;
  final VoidCallback onTap;

  const _SoundChip({
    required this.option,
    required this.selected,
    required this.accentColor,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? accentColor : c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accentColor : c.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(option.emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 6),
            Text(option.label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? Colors.white : c.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    )),
          ],
        ),
      ),
    );
  }
}

class _StreamChip extends StatelessWidget {
  final bool selected;
  final Color accentColor;
  final ColorTokens colors;
  final VoidCallback onTap;

  const _StreamChip({
    required this.selected,
    required this.accentColor,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? accentColor : c.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? accentColor : c.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('âŠ•',
                style: TextStyle(
                    fontSize: 13,
                    color: selected ? Colors.white : c.textSecondary)),
            const SizedBox(width: 6),
            Text('Music Stream',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? Colors.white : c.textSecondary,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    )),
          ],
        ),
      ),
    );
  }
}

class _StreamUrlRow extends StatelessWidget {
  final TextEditingController controller;
  final bool editing;
  final String? error;
  final Color accentColor;
  final ColorTokens colors;
  final VoidCallback onEdit;
  final VoidCallback onSave;
  final String defaultLabel;
  final VoidCallback onUseDefault;

  const _StreamUrlRow({
    required this.controller,
    required this.editing,
    required this.error,
    required this.accentColor,
    required this.colors,
    required this.onEdit,
    required this.onSave,
    required this.defaultLabel,
    required this.onUseDefault,
  });

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: error != null
              ? Colors.redAccent.withValues(alpha: 0.4)
              : c.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: editing
                    ? TextField(
                        controller: controller,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: c.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Paste stream URL...',
                          hintStyle: TextStyle(color: c.textMuted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        autofocus: true,
                        onSubmitted: (_) => onSave(),
                      )
                    : Text(
                        controller.text.isEmpty ? defaultLabel : controller.text,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: c.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: editing ? onSave : onEdit,
                child: Text(editing ? 'Save' : 'Edit',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        )),
              ),
            ],
          ),
          if (!editing) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: onUseDefault,
              child: Text('Use default: $defaultLabel',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: c.textMuted,
                        decoration: TextDecoration.underline,
                        decorationColor: c.textMuted,
                      )),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 6),
            Text(error!,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.redAccent)),
          ],
        ],
      ),
    );
  }
}
