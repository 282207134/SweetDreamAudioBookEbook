import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.state,
    required this.onAuth,
    required this.onCheckout,
    this.initialExpanded = false,
  });
  final AppState state;
  final ValueChanged<String> onAuth;
  final VoidCallback onCheckout;
  final bool initialExpanded;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool expanded = widget.initialExpanded;
  AppState get state => widget.state;
  Widget box(List<Widget> children) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(16),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    ),
  );
  Widget label(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Text(text),
  );
  Widget row(
    IconData icon,
    String title, {
    String? subtitle,
    String? value,
    VoidCallback? tap,
    Widget? trailing,
  }) => ListTile(
    contentPadding: EdgeInsets.zero,
    minLeadingWidth: 18,
    leading: Icon(icon, color: blue, size: 22),
    title: Text(
      title,
      style: TextStyle(
        fontSize: subtitle == null ? 14 : 12,
        color: subtitle == null ? null : muted,
      ),
    ),
    subtitle: subtitle == null
        ? null
        : Text(subtitle, style: const TextStyle(fontSize: 14)),
    onTap: tap,
    trailing:
        trailing ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(value, style: const TextStyle(color: muted, fontSize: 14)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: muted),
          ],
        ),
  );

  Future<void> edit(
    String title,
    String original,
    ValueChanged<String> update,
  ) async {
    final controller = TextEditingController(text: original);
    String? error;
    final value = await showDialog<String>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setDialog) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(errorText: error),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isEmpty ||
                    (title == 'E-mail' &&
                        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch(text))) {
                  setDialog(() => error = 'Please enter a valid value');
                  return;
                }
                Navigator.pop(c, text);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    // The route exit animation still owns the field for a short time.
    Future<void>.delayed(const Duration(milliseconds: 300), controller.dispose);
    if (value != null) state.update(() => update(value));
  }

  void support(String title, String content) => showDialog<void>(
    context: context,
    builder: (c) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(content)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => ListView(
    key: const Key('profile-list'),
    padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
    children: [
      Center(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => support(
                'Profile picture',
                'This demo uses the avatar supplied in the Pixso design.',
              ),
              child: Container(
                width: 104,
                height: 104,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: blue, width: 3),
                ),
                child: Image.asset('assets/images/avatar.png'),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => support(
                'Profile picture',
                'The reference avatar is included locally. Photo uploads require a connected account service.',
              ),
              child: const Text(
                'Edit profile picture',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
      label('Account'),
      box([
        row(
          Icons.person_outline,
          'Full name',
          subtitle: state.name,
          tap: () => edit('Full name', state.name, (v) => state.name = v),
        ),
        if (expanded) ...[
          row(
            Icons.mail_outline,
            'E-mail',
            subtitle: state.email,
            tap: () => edit('E-mail', state.email, (v) => state.email = v),
          ),
          row(
            Icons.lock_outline,
            'Password',
            tap: () => widget.onAuth('password'),
          ),
          row(
            Icons.face_outlined,
            'Gender',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['Boy', 'Girl']
                  .map(
                    (v) => TextButton(
                      onPressed: () => state.update(() => state.gender = v),
                      child: Text(
                        v,
                        style: TextStyle(
                          color: state.gender == v ? orange : muted,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          row(
            Icons.cake_outlined,
            'Birthday',
            value:
                '${state.birthday.day}/${state.birthday.month}/${state.birthday.year}',
            tap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.birthday,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (date != null) state.update(() => state.birthday = date);
            },
          ),
          row(Icons.logout, 'Logout', tap: () => widget.onAuth('login')),
        ],
        ListTile(
          key: const Key('expand-profile'),
          contentPadding: EdgeInsets.zero,
          title: Text(
            expanded ? 'See Less' : 'See More',
            style: const TextStyle(fontSize: 14),
          ),
          trailing: Icon(
            expanded
                ? Icons.keyboard_double_arrow_up
                : Icons.keyboard_double_arrow_down,
            size: 20,
            color: muted,
          ),
          onTap: () => setState(() => expanded = !expanded),
        ),
      ]),
      label('App Settings'),
      box([
        row(
          Icons.language,
          'Language',
          value: state.language,
          tap: () => showDialog<void>(
            context: context,
            builder: (c) => SimpleDialog(
              title: const Text('Content language'),
              children: ['English', 'Russian']
                  .map(
                    (v) => SimpleDialogOption(
                      onPressed: () {
                        state.update(() => state.language = v);
                        Navigator.pop(c);
                      },
                      child: Text('$v${state.language == v ? ' ✓' : ''}'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        for (final item in [
          (Icons.notifications_none, 'Notifications'),
          (Icons.headset_mic_outlined, 'Play in Background'),
          (Icons.sync, 'Autoplay'),
        ])
          row(
            item.$1,
            item.$2,
            trailing: Switch(
              value: state.settings[item.$2]!,
              onChanged: (v) => state.update(() => state.settings[item.$2] = v),
            ),
          ),
        row(
          Icons.contrast,
          'Dark Theme',
          trailing: Switch(
            key: const Key('dark-theme'),
            value: state.dark,
            onChanged: (v) => state.update(() => state.dark = v),
          ),
        ),
      ]),
      label('Payment'),
      box([
        row(
          Icons.credit_card,
          'Demo card',
          value: '4724',
          tap: widget.onCheckout,
        ),
        row(Icons.add_circle_outline, 'Add New Card', tap: widget.onCheckout),
      ]),
      label('Support'),
      box([
        row(
          Icons.description_outlined,
          'Terms and Conditions',
          tap: () => support(
            'Terms and Conditions',
            'SweetDream is a local UI demonstration. Purchases and accounts are simulated. Reference artwork is included for design review; no distribution rights to the depicted books or films are granted.',
          ),
        ),
        row(
          Icons.shield_outlined,
          'Privacy Policy',
          tap: () => support(
            'Privacy Policy',
            'Your demo name, email, preferences, birthday, and library are saved on this device. Passwords and card details are never saved or transmitted. Uninstall the app to remove local data.',
          ),
        ),
        row(
          Icons.chat_bubble_outline,
          'Contact us',
          tap: () => support(
            'Contact us',
            'This is an offline prototype. A production support contact has not been configured. See the project README for implementation details.',
          ),
        ),
      ]),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'SweetDream 2026',
            style: TextStyle(fontSize: 11, color: muted),
          ),
          TextButton(
            key: const Key('open-register'),
            onPressed: () => widget.onAuth('register'),
            child: const Text(
              'Registration / Login',
              style: TextStyle(fontSize: 11),
            ),
          ),
          const Text('v1.0.0', style: TextStyle(fontSize: 11, color: muted)),
        ],
      ),
    ],
  );
}
