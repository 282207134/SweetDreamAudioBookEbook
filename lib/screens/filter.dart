import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/books.dart';
import '../widgets/common.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({
    super.key,
    required this.filter,
    required this.onBack,
    required this.onApply,
  });
  final BookFilter filter;
  final VoidCallback onBack, onApply;
  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late int age = widget.filter.age;
  late String language = widget.filter.language, price = widget.filter.price;
  late RangeValues duration = RangeValues(
    widget.filter.minDuration,
    widget.filter.maxDuration,
  );
  late RangeValues money = RangeValues(
    widget.filter.minPrice,
    widget.filter.maxPrice,
  );
  Widget options(
    List<String> values,
    String selected,
    ValueChanged<String> change,
  ) => Row(
    children: values
        .map(
          (v) => Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: () => setState(() => change(v)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selected == v
                        ? orange
                        : Theme.of(context).colorScheme.surface,
                    foregroundColor: selected == v
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(
                      color: selected == v ? orange : const Color(0xffd3dfef),
                    ),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(v),
                ),
              ),
            ),
          ),
        )
        .toList(),
  );

  Widget section(String title, Widget child, {String? value}) => Container(
    padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(title),
            const Spacer(),
            if (value != null)
              Text(
                value,
                style: const TextStyle(
                  color: orange,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
        const SizedBox(height: 18),
        child,
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      DreamHeader(
        'Filter',
        leading: IconButton(
          tooltip: 'Back',
          onPressed: widget.onBack,
          icon: const Icon(Icons.chevron_left),
        ),
        trailing: IconButton(
          key: const Key('reset-filter'),
          tooltip: 'Reset filters',
          onPressed: () => setState(() {
            age = 5;
            language = 'ENG';
            price = 'All';
            duration = const RangeValues(3, 90);
            money = const RangeValues(0, 17);
          }),
          icon: const Icon(Icons.refresh),
        ),
      ),
      Expanded(
        child: ListView(
          children: [
            section(
              'Age limit',
              options(
                ['5', '6', '7', '8', '9', '10+'],
                age == 10 ? '10+' : '$age',
                (v) => age = int.parse(v.replaceAll('+', '')),
              ),
            ),
            section(
              'Audio duration',
              Column(
                children: [
                  RangeSlider(
                    values: duration,
                    min: 3,
                    max: 90,
                    onChanged: (v) => setState(() => duration = v),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '3 min',
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                      Text(
                        '90 min',
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ),
                ],
              ),
              value: '${duration.start.round()} - ${duration.end.round()} min',
            ),
            section(
              'Language',
              SizedBox(
                width: 160,
                child: options(['ENG', 'RUS'], language, (v) => language = v),
              ),
            ),
            section(
              'Price',
              options(['All', 'Paid', 'Free'], price, (v) => price = v),
            ),
            section(
              'Price range',
              Column(
                children: [
                  RangeSlider(
                    values: money,
                    min: 0,
                    max: 17,
                    onChanged: (v) => setState(() {
                      money = v;
                      price = 'Paid';
                    }),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 USD',
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                      Text(
                        '17 USD',
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    ],
                  ),
                ],
              ),
              value: '${money.start.round()} - ${money.end.round()} USD',
            ),
          ],
        ),
      ),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: DreamButton(
            'Search book',
            key: const Key('apply-filter'),
            onTap: () {
              final f = widget.filter;
              f
                ..age = age
                ..language = language
                ..price = price
                ..minDuration = duration.start
                ..maxDuration = duration.end
                ..minPrice = money.start
                ..maxPrice = money.end
                ..active = true;
              widget.onApply();
            },
          ),
        ),
      ),
    ],
  );
}
