import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/books.dart';

class AppState extends ChangeNotifier {
  final prefs = SharedPreferencesAsync();
  final player = AudioPlayer();
  final filter = BookFilter();
  final Set<String> library = {'prince', 'coco', 'ferdinand'};
  final Map<String, bool> settings = {
    'Notifications': true,
    'Play in Background': true,
    'Autoplay': false,
  };
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  bool dark = false, welcomed = false, playing = false;
  String name = 'Little Prince', email = 'littleprince@gmail.com';
  String language = 'English', gender = 'Boy';
  DateTime birthday = DateTime(2013, 3, 12);
  Book current = books[1];
  Duration position = Duration.zero, duration = Duration.zero;
  String? audioError;
  bool _loaded = false;
  double speed = 1;
  Timer? _sleepTimer;
  DateTime? sleepUntil;

  AppState() {
    player.positionUpdater = TimerPositionUpdater(
      getPosition: player.getCurrentPosition,
      interval: const Duration(milliseconds: 250),
    );
    _subscriptions.add(
      player.onPositionChanged.listen((value) {
        position = value;
        notifyListeners();
      }),
    );
    _subscriptions.add(
      player.onDurationChanged.listen((value) {
        duration = value;
        notifyListeners();
      }),
    );
    _subscriptions.add(
      player.onPlayerStateChanged.listen((value) {
        playing = value == PlayerState.playing;
        notifyListeners();
      }),
    );
    _subscriptions.add(
      player.onPlayerComplete.listen((_) async {
        _loaded = false;
        position = Duration.zero;
        if (settings['Autoplay'] == true) await next(1);
        notifyListeners();
      }),
    );
  }

  Future<void> restore() async {
    dark = await prefs.getBool('dark') ?? false;
    welcomed = await prefs.getBool('welcomed') ?? false;
    name = await prefs.getString('name') ?? name;
    email = await prefs.getString('email') ?? email;
    language = await prefs.getString('language') ?? language;
    gender = await prefs.getString('gender') ?? gender;
    birthday =
        DateTime.tryParse(await prefs.getString('birthday') ?? '') ?? birthday;
    final saved = await prefs.getStringList('library');
    if (saved != null) {
      library
        ..clear()
        ..addAll(saved);
    }
    for (final key in settings.keys) {
      settings[key] = await prefs.getBool(key) ?? settings[key]!;
    }
  }

  Future<void> save() async {
    await prefs.setBool('dark', dark);
    await prefs.setBool('welcomed', welcomed);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('language', language);
    await prefs.setString('gender', gender);
    await prefs.setString('birthday', birthday.toIso8601String());
    await prefs.setStringList('library', library.toList());
    for (final entry in settings.entries) {
      await prefs.setBool(entry.key, entry.value);
    }
  }

  void update(VoidCallback action) {
    action();
    notifyListeners();
    unawaited(save());
  }

  Future<void> select(Book book, {bool play = true}) async {
    if (current.id != book.id) {
      await player.stop();
      current = book;
      position = Duration.zero;
      _loaded = false;
    }
    notifyListeners();
    if (play && !playing) await togglePlayback();
  }

  Future<void> togglePlayback() async {
    try {
      audioError = null;
      if (playing) {
        await player.pause();
      } else if (_loaded) {
        await player.resume();
      } else {
        await player.play(AssetSource('audio/starlight.mp3'));
        _loaded = true;
      }
    } catch (_) {
      audioError = 'Audio could not start. Please try again.';
    }
    notifyListeners();
  }

  Future<void> seek(double seconds) async {
    if (duration == Duration.zero) return;
    final end = duration.inSeconds;
    await player.seek(Duration(seconds: seconds.round().clamp(0, end)));
  }

  Future<void> next(int direction) async {
    final owned = books.where((b) => library.contains(b.id)).toList();
    final index = owned.indexWhere((b) => b.id == current.id);
    await select(owned[(index + direction) % owned.length]);
  }

  Future<void> setSpeed(double value) async {
    await player.setPlaybackRate(value);
    speed = value;
    notifyListeners();
  }

  void setSleep(int minutes) {
    _sleepTimer?.cancel();
    sleepUntil = minutes == 0
        ? null
        : DateTime.now().add(Duration(minutes: minutes));
    if (minutes > 0) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        unawaited(player.pause());
        sleepUntil = null;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    unawaited(player.dispose());
    super.dispose();
  }
}
