import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.state,
    required this.onBack,
    required this.onPurchased,
    this.initialAbout = false,
  });
  final AppState state;
  final VoidCallback onBack, onPurchased;
  final bool initialAbout;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final form = GlobalKey<FormState>();
  late bool about = widget.initialAbout;
  bool save = true;
  final number = TextEditingController(text: '4718 6518 4182 2083');
  final expiry = TextEditingController(text: '12/29');
  final cvv = TextEditingController(text: '142');
  @override
  void dispose() {
    number.dispose();
    expiry.dispose();
    cvv.dispose();
    super.dispose();
  }

  Widget field(
    String label,
    TextEditingController controller,
    String? Function(String?) validator, {
    int? maxLength,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        key: Key('card-$label'),
        keyboardType: TextInputType.number,
        maxLength: maxLength,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9 /-]')),
        ],
        obscureText: label == 'CVV',
        validator: validator,
        decoration: InputDecoration(
          counterText: '',
          suffixIcon: label == 'CVV'
              ? null
              : const Icon(
                  Icons.credit_card,
                  color: Color(0xffbbc4ce),
                  size: 22,
                ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final book = widget.state.current;
    return Container(
      color: const Color(0xff203843),
      child: Column(
        children: [
          SizedBox(
            height: 315,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  book.cover,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
                Container(
                  color: const Color(0xff152b35).withValues(alpha: .85),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 62,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            tooltip: 'Back',
                            onPressed: widget.onBack,
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Book information',
                            onPressed: () => setState(() => about = true),
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          BookCover(book, width: 86, height: 105),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  book.author,
                                  style: const TextStyle(
                                    color: Color(0xffaab7c0),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '◷ ${book.time}     ♧ ${book.age} age +',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        book.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const SizedBox(width: 22),
                        _tab(
                          'Checkout',
                          !about,
                          () => setState(() => about = false),
                        ),
                        _tab(
                          'About',
                          about,
                          () => setState(() => about = true),
                        ),
                        const Spacer(),
                        Container(
                          color: orange,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(right: 40),
                          child: Text(
                            '${book.price}\nUSD',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 28),
                child: about
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${book.description}\n\nDiscover a world of imagination, friendship, and courage. Add this title to your collection and enjoy a quiet moment with SweetDream.\n\nThis prototype includes an original sample ebook and a short offline narration. Full book content and licensed recordings are not included.',
                            style: const TextStyle(fontSize: 15, height: 1.7),
                          ),
                          const SizedBox(height: 24),
                          DreamButton(
                            'Back to checkout',
                            onTap: () => setState(() => about = false),
                          ),
                        ],
                      )
                    : Form(
                        key: form,
                        child: Column(
                          children: [
                            field(
                              'Card number',
                              number,
                              (v) =>
                                  (v ?? '')
                                          .replaceAll(RegExp(r'\D'), '')
                                          .length ==
                                      16
                                  ? null
                                  : 'Enter a 16-digit demo card',
                              maxLength: 23,
                            ),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: field('Expiration date', expiry, (v) {
                                    final match = RegExp(
                                      r'^(0[1-9]|1[0-2])/([0-9]{2})$',
                                    ).firstMatch(v ?? '');
                                    if (match == null) return 'Use MM/YY';
                                    final expires = DateTime(
                                      2000 + int.parse(match[2]!),
                                      int.parse(match[1]!) + 1,
                                    );
                                    return expires.isAfter(DateTime.now())
                                        ? null
                                        : 'Card has expired';
                                  }, maxLength: 5),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: field(
                                    'CVV',
                                    cvv,
                                    (v) =>
                                        RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                                        ? null
                                        : '3–4 digits',
                                    maxLength: 4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Save card data for future payments',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                                Switch(
                                  key: const Key('save-card'),
                                  value: save,
                                  onChanged: (v) => setState(() => save = v),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            DreamButton(
                              'Proceed to Confirm',
                              key: const Key('confirm-purchase'),
                              arrow: true,
                              onTap: () async {
                                if (!form.currentState!.validate()) return;
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (c) => AlertDialog(
                                    title: const Text('Confirm demo purchase'),
                                    content: Text(
                                      'Add ${book.title} to your library for ${book.price} USD?\n\nNo payment is processed. No card data is stored.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(c, false),
                                        child: const Text('Cancel'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.pop(c, true),
                                        child: const Text('Add to library'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmed == true && mounted) {
                                  widget.state.update(
                                    () => widget.state.library.add(book.id),
                                  );
                                  widget.onPurchased();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Demo checkout · Use sample values only.\nNo charge or card storage.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, color: muted),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String title, bool selected, VoidCallback tap) => InkWell(
    onTap: tap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? orange : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xffaab7c0),
          fontWeight: selected ? FontWeight.w800 : FontWeight.w400,
        ),
      ),
    ),
  );
}
