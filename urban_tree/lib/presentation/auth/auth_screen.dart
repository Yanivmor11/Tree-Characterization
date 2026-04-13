import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSignup = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController auth) async {
    if (!_form.currentState!.validate()) return;
    if (_isSignup) {
      await auth.signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        displayName: _nameCtrl.text.trim(),
      );
    } else {
      await auth.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    }
    if (!mounted || auth.error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(auth.error!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'UrbanTree',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isSignup ? 'Create your account' : 'Welcome back',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 24),
                        if (_isSignup) ...[
                          TextFormField(
                            controller: _nameCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => (v == null || v.trim().length < 2)
                                ? 'Enter a valid username'
                                : null,
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                          ),
                          validator: (v) =>
                              (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Password must be at least 6 characters'
                              : null,
                          onFieldSubmitted: (_) {
                            if (!auth.loading) _submit(auth);
                          },
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: auth.loading ? null : () => _submit(auth),
                          child: Text(_isSignup ? 'Sign up' : 'Sign in'),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: auth.loading ? null : auth.signInWithGoogle,
                          icon: const Icon(Icons.g_mobiledata_rounded),
                          label: const Text('Continue with Google'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: auth.loading
                              ? null
                              : () => setState(() => _isSignup = !_isSignup),
                          child: Text(
                            _isSignup
                                ? 'Already have an account? Sign in'
                                : 'No account yet? Sign up',
                          ),
                        ),
                        if (auth.loading) ...[
                          const SizedBox(height: 12),
                          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
