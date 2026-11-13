import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../data/books.dart';
import '../widgets/common.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    required this.state,
    required this.mode,
    required this.onOpen,
    required this.onAction,
    required this.onFilter,
    this.onProfile,
    this.onRegister,
  });
  final AppState state;
  final String mode;
  final ValueChanged<Book> onOpen, onAction;
  final VoidCallback onFilter;
  final VoidCallback? onProfile, onRegister;
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String query = '', category = 'All books';
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHome = widget.mode == 'home', isLibrary = widget.mode == 'library';
    final filtered = books
        .where(
          (b) =>
              (!isLibrary || widget.state.library.contains(b.id)) &&
              (isHome || b.title.toLowerCase().contains(query.toLowerCase())) &&
              (isHome || category == 'All books' || b.category == category) &&
              (isHome || isLibrary || widget.state.filter.matches(b)),
        )
        .toList();
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
          child: Column(
            children: [
              SizedBox(
                height: 46,
                child: Row(
                  children: [
                    if (isHome) ...[
                      GestureDetector(
                        onTap: widget.onProfile,
                        child: Image.asset(
                          'assets/images/avatar.png',
                          width: 46,
                          height: 46,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        isHome
                            ? 'Hi, ${widget.state.name}!'
                            : isLibrary
                            ? 'My books'
                            : 'Discover books',
                        style: TextStyle(
                          fontSize: isHome ? 15 : 16,
                          fontWeight: isHome
                              ? FontWeight.w400
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: isHome ? 'Notifications' : 'Filter books',
                      onPressed: isHome
                          ? () => showDialog<void>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Your story awaits'),
                                content: const Text(
                                  'Welcome to SweetDream. Your saved books and a quiet moment are waiting for you.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Got it'),
                                  ),
                                ],
                              ),
                            )
                          : widget.onFilter,
                      icon: Icon(
                        isHome ? Icons.notifications_none_outlined : Icons.tune,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isHome) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: TextField(
                    key: const Key('search-field'),
                    controller: search,
                    onChanged: (v) => setState(() => query = v),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                search.clear();
                                setState(() => query = '');
                              },
                              icon: const Icon(Icons.close, size: 18),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      const categories = [
                        'All books',
                        'Tales',
                        'Poems',
                        'History books',
                      ];
                      return ChoiceChip(
                        label: Text(categories[i]),
                        selected: category == categories[i],
                        showCheckmark: false,
                        selectedColor: orange,
                        labelStyle: TextStyle(
                          color: category == categories[i]
                              ? Colors.white
                              : muted,
                        ),
                        onSelected: (_) =>
                            setState(() => category = categories[i]),
                        shape: const StadiumBorder(),
                        side: BorderSide.none,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: ListView(
            key: Key('${widget.mode}-list'),
            padding: const EdgeInsets.all(16),
            children: [
              if (isHome) ...[
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: widget.onRegister,
                  child: SizedBox(
                    height: 190,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 36,
                          left: 0,
                          right: 0,
                          height: 140,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.only(left: 24, top: 29),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Share with your friends\nand get discount',
                                  style: TextStyle(
                                    color: Color(0xff1f9fff),
                                    height: 1.3,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  '50% off',
                                  style: TextStyle(
                                    color: Color(0xff1f9fff),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 13,
                          top: 0,
                          child: Image.asset(
                            'assets/images/astronaut.png',
                            height: 160,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                const Text('New books'),
                const SizedBox(height: 12),
              ],
              if (!isHome && widget.state.filter.active && !isLibrary)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Text(
                        '${filtered.length} results · Filters applied',
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => setState(widget.state.filter.reset),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ),
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 65),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.auto_stories_outlined,
                        size: 54,
                        color: blue,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'No books found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try another title or adjust your filters.',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          search.clear();
                          setState(() {
                            query = '';
                            category = 'All books';
                            widget.state.filter.reset();
                          });
                        },
                        child: const Text('Show all books'),
                      ),
                    ],
                  ),
                ),
              ...filtered.map(
                (book) => BookCard(
                  book,
                  key: Key('book-${book.id}'),
                  owned: isLibrary,
                  purchased: widget.state.library.contains(book.id),
                  onOpen: () => widget.onOpen(book),
                  onAction: () => widget.onAction(book),
                ),
              ),
              if (isLibrary)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Your collection is saved on this device.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
