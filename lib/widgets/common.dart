import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/books.dart';

class DreamButton extends StatelessWidget {
  const DreamButton(
    this.label, {
    super.key,
    required this.onTap,
    this.arrow = false,
    this.white = false,
  });
  final String label;
  final VoidCallback? onTap;
  final bool arrow, white;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 60,
    width: double.infinity,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: white ? Colors.white : blue,
        foregroundColor: white ? blue : Colors.white,
        shape: const StadiumBorder(),
        elevation: 0,
        shadowColor: white ? const Color(0xffd5e1f1) : blue,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (arrow) const Spacer(),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          if (arrow) ...[const Spacer(), const Icon(Icons.chevron_right)],
        ],
      ),
    ),
  );
}

class DreamHeader extends StatelessWidget {
  const DreamHeader(this.title, {super.key, this.leading, this.trailing});
  final String title;
  final Widget? leading, trailing;
  @override
  Widget build(BuildContext context) => Container(
    height: 72,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        SizedBox(width: 44, child: leading),
        Expanded(child: Text(title, textAlign: TextAlign.center)),
        SizedBox(width: 44, child: trailing),
      ],
    ),
  );
}

class BookCover extends StatelessWidget {
  const BookCover(
    this.book, {
    super.key,
    this.width = 90,
    this.height = 110,
    this.square = false,
  });
  final Book book;
  final double width, height;
  final bool square;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(square ? 14 : 7),
    child: Image.asset(
      square && book.id == 'prince'
          ? 'assets/images/prince-player.png'
          : book.cover,
      width: width,
      height: height,
      fit: BoxFit.cover,
    ),
  );
}

class BookCard extends StatelessWidget {
  const BookCard(
    this.book, {
    super.key,
    required this.onOpen,
    required this.onAction,
    this.owned = false,
    this.purchased = false,
  });
  final Book book;
  final VoidCallback onOpen, onAction;
  final bool owned;
  final bool purchased;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(
                    book,
                    width: owned ? 70 : 90,
                    height: owned ? 85 : 110,
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            right: book.price > 0 && !owned && !purchased
                                ? 25
                                : 0,
                          ),
                          child: Text(
                            book.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 12,
                              color: muted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              book.time,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 20),
                            const Icon(
                              Icons.cake_outlined,
                              size: 12,
                              color: muted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${book.age} age +',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          book.description,
                          maxLines: owned ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, height: 1.3),
                        ),
                        const SizedBox(height: 7),
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            height: 28,
                            width: 110,
                            child: FilledButton(
                              onPressed: onAction,
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                owned || purchased
                                    ? 'Listen now'
                                    : book.price == 0
                                    ? 'Listen for free'
                                    : 'Buy book',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (book.price > 0 && !owned && !purchased)
          Positioned(
            right: 15,
            top: -5,
            child: Container(
              width: 32,
              height: 43,
              decoration: const BoxDecoration(
                color: orange,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(4),
                  bottom: Radius.circular(2),
                ),
              ),
              child: Center(
                child: Text(
                  '${book.price}\nUSD',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    height: 1.1,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

void message(BuildContext context, String text) => ScaffoldMessenger.of(context)
  ..hideCurrentSnackBar()
  ..showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );

String clockText(Duration time) =>
    '${time.inMinutes.toString().padLeft(2, '0')}:${(time.inSeconds % 60).toString().padLeft(2, '0')}';
