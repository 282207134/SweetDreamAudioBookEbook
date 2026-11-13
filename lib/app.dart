import 'dart:async';

import 'package:flutter/material.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'data/books.dart';
import 'screens/catalog.dart';
import 'screens/profile.dart';
import 'screens/player.dart';
import 'screens/checkout.dart';
import 'screens/auth.dart';
import 'screens/filter.dart';
import 'widgets/common.dart';

class SweetDreamApp extends StatelessWidget {
  const SweetDreamApp({super.key, required this.state, this.initialView});
  final AppState state;
  final String? initialView;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: state,
    builder: (context, _) => MaterialApp(
      title: 'SweetDream',
      debugShowCheckedModeBanner: false,
      theme: dreamTheme(false),
      darkTheme: dreamTheme(true),
      themeMode: state.dark ? ThemeMode.dark : ThemeMode.light,
      home: DreamShell(state: state, initialView: initialView),
    ),
  );
}

class DreamShell extends StatefulWidget {
  const DreamShell({super.key, required this.state, this.initialView});
  final AppState state;
  final String? initialView;
  @override
  State<DreamShell> createState() => _DreamShellState();
}

class _DreamShellState extends State<DreamShell> with WidgetsBindingObserver {
  late String view;
  int tab = 0;
  AppState get state => widget.state;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    view = widget.initialView ?? (state.welcomed ? 'home' : 'welcome');
    tab = ['home', 'search', 'library', 'profile'].indexOf(view).clamp(0, 3);
    if (view == 'profile-expanded') tab = 3;
    if (['register', 'login', 'reset', 'password'].contains(view)) {
      final mode = view;
      view = 'home';
      WidgetsBinding.instance.addPostFrameCallback((_) => auth(mode));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState status) {
    if (status == AppLifecycleState.paused &&
        state.settings['Play in Background'] == false) {
      unawaited(state.player.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void go(String target) => setState(() => view = target);
  void switchTab(int index) => setState(() {
    tab = index;
    view = ['home', 'search', 'library', 'profile'][index];
  });

  Future<void> auth(String mode) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AuthSheet(state: state, initialMode: mode),
  );

  void openBook(Book book) {
    unawaited(state.select(book, play: false));
    go(state.library.contains(book.id) ? 'player' : 'checkout');
  }

  void account(String mode) {
    if (mode == 'register' || mode == 'login') {
      go('$mode-full');
    } else {
      unawaited(auth(mode));
    }
  }

  void bookAction(Book book) {
    if (state.library.contains(book.id) || book.price == 0) {
      state.update(() => state.library.add(book.id));
      unawaited(state.select(book));
      go('player');
    } else {
      openBook(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (view == 'welcome') {
      return WelcomeScreen(
        onStart: () {
          state.update(() => state.welcomed = true);
          go('home');
        },
      );
    }
    final hasNav = ![
      'filter',
      'checkout',
      'about',
      'reader',
      'register-full',
      'login-full',
    ].contains(view);
    final body = switch (view) {
      'search' => CatalogScreen(
        state: state,
        mode: 'search',
        onOpen: openBook,
        onAction: bookAction,
        onFilter: () => go('filter'),
      ),
      'library' => CatalogScreen(
        state: state,
        mode: 'library',
        onOpen: openBook,
        onAction: bookAction,
        onFilter: () => go('search'),
      ),
      'profile' => ProfileScreen(
        state: state,
        onAuth: account,
        initialExpanded: widget.initialView == 'profile-expanded',
        onCheckout: () => go('checkout'),
      ),
      'profile-expanded' => ProfileScreen(
        state: state,
        onAuth: account,
        initialExpanded: true,
        onCheckout: () => go('checkout'),
      ),
      'filter' => FilterScreen(
        filter: state.filter,
        onBack: () => go('search'),
        onApply: () => go('search'),
      ),
      'player' => PlayerScreen(
        state: state,
        onBack: () => switchTab(tab),
        onRead: () => go('reader'),
      ),
      'reader' => ReaderScreen(book: state.current, onBack: () => go('player')),
      'register-full' || 'login-full' => AuthSheet(
        state: state,
        initialMode: view == 'register-full' ? 'register' : 'login',
        fullScreen: true,
        onClose: () => switchTab(tab),
      ),
      'checkout' || 'about' => CheckoutScreen(
        state: state,
        initialAbout: view == 'about',
        onBack: () => switchTab(tab),
        onPurchased: () {
          switchTab(2);
          message(context, 'Demo purchase complete. Added to My books.');
        },
      ),
      _ => CatalogScreen(
        state: state,
        mode: 'home',
        onOpen: openBook,
        onAction: bookAction,
        onFilter: () => go('search'),
        onProfile: () => switchTab(3),
        onRegister: () => auth('register'),
      ),
    };
    final canLeave = [
      'home',
      'search',
      'library',
      'profile',
      'profile-expanded',
    ].contains(view);
    return PopScope(
      canPop: canLeave,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (view == 'filter') {
          go('search');
        } else if (view == 'reader') {
          go('player');
        } else {
          switchTab(tab);
        }
      },
      child: Scaffold(
        backgroundColor: view == 'player'
            ? Theme.of(context).colorScheme.surface
            : null,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(child: body),
              if (hasNav && state.playing && view != 'player') _miniPlayer(),
            ],
          ),
        ),
        bottomNavigationBar: hasNav ? _navigation() : null,
      ),
    );
  }

  Widget _miniPlayer() => Material(
    color: Theme.of(context).colorScheme.surface,
    child: ListTile(
      key: const Key('mini-player'),
      onTap: () => go('player'),
      leading: BookCover(state.current, width: 38, height: 44),
      title: Text(
        state.current.title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${clockText(state.position)} · Sample narration',
        style: const TextStyle(fontSize: 11),
      ),
      trailing: IconButton(
        tooltip: 'Pause',
        onPressed: state.togglePlayback,
        icon: const Icon(Icons.pause_rounded, color: orange),
      ),
    ),
  );

  Widget _navigation() => Container(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 80,
        child: Row(
          children: List.generate(4, (i) {
            const labels = ['Home', 'Search', 'My books', 'Profile'];
            const icons = [
              Icons.home_outlined,
              Icons.search,
              Icons.menu_book_outlined,
              Icons.person_outline,
            ];
            final active = tab == i;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 10,
                ),
                child: Material(
                  color: active
                      ? blue.withValues(alpha: .045)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    key: Key('nav-$i'),
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => switchTab(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icons[i],
                          color: active ? blue : const Color(0xff809abd),
                          size: 24,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 10,
                            color: active ? blue : const Color(0xff809abd),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: blue,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 50),
            const Text(
              'SweetDream',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Share with your friends and\nget discount',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.4,
                color: Color(0xffd2eaff),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 34),
                child: Image.asset(
                  'assets/images/astronaut-blue.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            GestureDetector(
              onHorizontalDragEnd: (_) => onStart(),
              child: DreamButton(
                'Swipe to access',
                key: const Key('get-started'),
                onTap: onStart,
                arrow: true,
                white: true,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
  );
}
