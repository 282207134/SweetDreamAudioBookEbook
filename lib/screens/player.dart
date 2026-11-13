import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../data/books.dart';
import '../widgets/common.dart';

class PlayerScreen extends StatelessWidget {
  const PlayerScreen({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRead,
  });
  final AppState state;
  final VoidCallback onBack, onRead;

  void options(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Make yourself comfortable',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            const Text('Playback speed'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [.75, 1.0, 1.25, 1.5]
                  .map(
                    (v) => ActionChip(
                      label: Text('${v}x'),
                      onPressed: () {
                        state.setSpeed(v);
                        Navigator.pop(sheet);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            const Text('Sleep timer'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [0, 5, 15, 30]
                  .map(
                    (v) => ActionChip(
                      label: Text(v == 0 ? 'Off' : '$v min'),
                      onPressed: () {
                        state.setSleep(v);
                        Navigator.pop(sheet);
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.menu_book, color: blue),
              title: const Text('Read the sample ebook'),
              onTap: () {
                Navigator.pop(sheet);
                onRead();
              },
            ),
            const Text(
              'Original sample narration. Full licensed recordings are not included.',
              style: TextStyle(fontSize: 12, color: muted),
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      DreamHeader(
        'Now playing',
        leading: IconButton(
          tooltip: 'Minimize player',
          onPressed: onBack,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        trailing: IconButton(
          key: const Key('player-options'),
          tooltip: 'Playback options',
          onPressed: () => options(context),
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Column(
              children: [
                BookCover(state.current, square: true, width: 241, height: 241),
                const SizedBox(height: 18),
                Text(
                  state.current.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  state.current.author,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: muted),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    state.current.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
                const SizedBox(height: 24),
                SliderTheme(
                  data: SliderTheme.of(context)
                      .copyWith(overlayShape: SliderComponentShape.noOverlay),
                  child: Slider(
                    key: const Key('audio-seek'),
                    value: state.position.inMilliseconds.toDouble().clamp(
                      0,
                      state.duration.inMilliseconds.toDouble(),
                    ),
                    max: state.duration.inMilliseconds > 0
                        ? state.duration.inMilliseconds.toDouble()
                        : 1,
                    onChanged: state.duration == Duration.zero
                        ? null
                        : (v) => state.seek(v / 1000),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      clockText(state.position),
                      style: const TextStyle(fontSize: 13),
                    ),
                    Text(
                      clockText(state.duration),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      tooltip: 'Previous book',
                      onPressed: () => state.next(-1),
                      icon: const Icon(Icons.fast_rewind),
                    ),
                    IconButton(
                      tooltip: 'Back 15 seconds',
                      onPressed: () =>
                          state.seek(state.position.inSeconds - 15),
                      icon: const _SkipIcon(forward: false),
                    ),
                    SizedBox(
                      width: 68,
                      height: 68,
                      child: FilledButton(
                        key: const Key('play-toggle'),
                        onPressed: state.togglePlayback,
                        style: FilledButton.styleFrom(
                          backgroundColor: orange,
                          padding: EdgeInsets.zero,
                          shape: const CircleBorder(),
                        ),
                        child: Icon(
                          state.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 40,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Forward 15 seconds',
                      onPressed: () =>
                          state.seek(state.position.inSeconds + 15),
                      icon: const _SkipIcon(forward: true),
                    ),
                    IconButton(
                      tooltip: 'Next book',
                      onPressed: () => state.next(1),
                      icon: const Icon(Icons.fast_forward),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Sample narration · ${state.speed}x${state.sleepUntil == null ? '' : ' · Sleep timer on'}',
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
                if (state.audioError != null)
                  Text(
                    state.audioError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                TextButton.icon(
                  key: const Key('read-ebook'),
                  onPressed: onRead,
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: const Text('Read ebook'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

class _SkipIcon extends StatelessWidget {
  const _SkipIcon({required this.forward});
  final bool forward;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28,
    height: 30,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Icon(forward ? Icons.rotate_right : Icons.rotate_left, size: 29),
        Positioned(
          top: 12,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: const Text(
              '15',
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key, required this.book, required this.onBack});
  final Book book;
  final VoidCallback onBack;
  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  double size = 18;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      DreamHeader(
        'Read & dream',
        leading: IconButton(
          tooltip: 'Back',
          onPressed: widget.onBack,
          icon: const Icon(Icons.chevron_left),
        ),
        trailing: IconButton(
          tooltip: 'Change text size',
          onPressed: () => setState(() => size = size == 22 ? 16 : size + 2),
          icon: const Icon(Icons.text_fields),
        ),
      ),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SWEETDREAM LIBRARY',
                style: TextStyle(color: orange, letterSpacing: 2, fontSize: 11),
              ),
              const SizedBox(height: 20),
              Text(sampleStory, style: TextStyle(fontSize: size, height: 1.85)),
              const SizedBox(height: 30),
              const Text('End of sample', style: TextStyle(color: muted)),
            ],
          ),
        ),
      ),
    ],
  );
}
