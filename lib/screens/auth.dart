import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class AuthSheet extends StatefulWidget {
  const AuthSheet({
    super.key,
    required this.state,
    required this.initialMode,
    this.fullScreen = false,
    this.onClose,
  });
  final AppState state;
  final String initialMode;
  final bool fullScreen;
  final VoidCallback? onClose;
  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  final form = GlobalKey<FormState>();
  late String mode = widget.initialMode;
  late final name = TextEditingController(text: widget.state.name);
  late final email = TextEditingController(text: widget.state.email);
  final password = TextEditingController(), confirm = TextEditingController();
  bool obscure = true;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void change(String next) => setState(() {
    mode = next;
    form.currentState?.reset();
  });

  Widget input(
    String label,
    TextEditingController controller, {
    bool secret = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        TextFormField(
          key: Key('auth-$label'),
          controller: controller,
          obscureText: secret && obscure,
          keyboardType: label == 'Your e-mail'
              ? TextInputType.emailAddress
              : TextInputType.text,
          autofillHints: secret
              ? null
              : [
                  label == 'Your e-mail'
                      ? AutofillHints.email
                      : AutofillHints.name,
                ],
          validator: (v) {
            if ((v ?? '').trim().isEmpty) {
              return 'Please enter ${label.toLowerCase()}';
            }
            if (label == 'Your e-mail' &&
                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v!)) {
              return 'Enter a valid email address';
            }
            if (secret && v!.length < 8) return 'Use at least 8 characters';
            if (label == 'Confirm Password' && v != password.text) {
              return 'Passwords do not match';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: secret ? 'At least 8 characters' : label,
            suffixIcon: secret
                ? IconButton(
                    tooltip: obscure ? 'Show password' : 'Hide password',
                    onPressed: () => setState(() => obscure = !obscure),
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: muted,
                    ),
                  )
                : null,
          ),
        ),
      ],
    ),
  );

  void submit() {
    if (!form.currentState!.validate()) return;
    if (mode == 'reset') {
      change('password');
      return;
    }
    if (mode == 'password') {
      change('login');
      message(
        context,
        'Demo password reset complete. No email or server account was changed.',
      );
      return;
    }
    widget.state.update(() {
      widget.state.name = name.text.trim();
      widget.state.email = email.text.trim();
    });
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.pop(context);
    }
    message(
      context,
      mode == 'register'
          ? 'Demo profile created on this device.'
          : 'Demo session opened on this device.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = switch (mode) {
      'login' => 'Login',
      'reset' => 'Reset Password',
      'password' => 'Create new password',
      _ => 'Registration',
    };
    final content = Container(
      constraints: widget.fullScreen
          ? const BoxConstraints()
          : BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .92),
      decoration: BoxDecoration(
        color: widget.fullScreen
            ? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 22),
        child: SafeArea(
          top: false,
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.fullScreen)
                  Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close account form',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.keyboard_arrow_down),
                      ),
                    ],
                  ),
                const SizedBox(height: 16),
                if (mode == 'register') input('Full name', name),
                if (mode != 'password') input('Your e-mail', email),
                if (mode != 'reset')
                  input(
                    mode == 'password' ? 'New Password' : 'Password',
                    password,
                    secret: true,
                  ),
                if (mode == 'password')
                  input('Confirm Password', confirm, secret: true),
                if (mode == 'login')
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => change('reset'),
                      child: const Text(
                        'Forgot password ?',
                        style: TextStyle(color: orange),
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                DreamButton(
                  switch (mode) {
                    'login' => 'Login',
                    'reset' => 'Submit',
                    'password' => 'Reset Password',
                    _ => 'Register now',
                  },
                  key: const Key('auth-submit'),
                  onTap: submit,
                  arrow: true,
                ),
                const SizedBox(height: 12),
                if (mode == 'register' || mode == 'login')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mode == 'register'
                            ? 'Already have an account?'
                            : 'Not a user?',
                        style: const TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () =>
                            change(mode == 'register' ? 'login' : 'register'),
                        child: Text(
                          mode == 'register' ? 'Login' : 'Register now',
                          style: const TextStyle(color: orange),
                        ),
                      ),
                    ],
                  )
                else
                  TextButton(
                    onPressed: () => change('login'),
                    child: const Text('Back to login'),
                  ),
                if (mode == 'register') ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Or register with',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => message(
                            context,
                            'Facebook sign-in requires a connected authentication service.',
                          ),
                          icon: const Text(
                            'f',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          label: const Text('Facebook'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => message(
                            context,
                            'Google sign-in requires a connected authentication service.',
                          ),
                          icon: const Text(
                            'G',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: blue,
                            ),
                          ),
                          label: const Text('Google'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                const Text(
                  'Local demo · No server authentication or email delivery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!widget.fullScreen) return content;
    return ColoredBox(
      color: blue,
      child: Column(
        children: [
          SizedBox(
            height: 70,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.chevron_left, color: ink),
                ),
                if (mode == 'register' || mode == 'login') ...[
                  for (final item in [
                    ('register', 'Registration'),
                    ('login', 'Login'),
                  ])
                    Expanded(
                      child: InkWell(
                        onTap: () => change(item.$1),
                        child: Container(
                          height: 70,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 4,
                                color: mode == item.$1
                                    ? orange
                                    : Colors.transparent,
                              ),
                            ),
                          ),
                          child: Text(
                            item.$2,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: mode == item.$1
                                  ? Colors.white
                                  : Colors.white54,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(width: 24),
                ] else
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
