import 'package:flutter/material.dart';

const blue = Color(0xff328eff);
const orange = Color(0xffff8700);
const ink = Color(0xff1e3243);
const muted = Color(0xff7c8899);

ThemeData dreamTheme(bool dark) {
  final surface = dark ? const Color(0xff1e3445) : Colors.white;
  final text = dark ? const Color(0xfff4f6fa) : ink;
  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    fontFamily: 'Nunito',
    scaffoldBackgroundColor: dark
        ? const Color(0xff15232e)
        : const Color(0xfff8f8fb),
    colorScheme: ColorScheme.fromSeed(
      seedColor: blue,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: blue,
      secondary: orange,
      surface: surface,
      onSurface: text,
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: 15, color: text),
      bodySmall: const TextStyle(fontSize: 12, color: muted),
      titleLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: text,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: text,
      ),
    ),
    dividerColor: dark ? const Color(0xff30475b) : const Color(0xffe7edf6),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
      hintStyle: const TextStyle(color: Color(0xff9aa5b4), fontSize: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Color(0xffd3dfef)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: Color(0xffd3dfef)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: orange,
      thumbColor: orange,
      inactiveTrackColor: Color(0xffd4dfed),
      trackHeight: 3,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.selected) ? blue : const Color(0xffd3dfed),
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? blue.withValues(alpha: .1)
            : const Color(0xfff8f8fb),
      ),
    ),
  );
}
