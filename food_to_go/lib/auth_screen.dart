import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'account_type.dart';
import 'home_screen.dart';
import 'services/app_data.dart';

bool isUsjrEmail(String email) =>
    email.trim().toLowerCase().endsWith('@usjr.edu.ph');

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.supabaseConfigured,
    required this.appData,
  });

  final bool supabaseConfigured;
  final AppData appData;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  StreamSubscription<AuthState>? _authSubscription;

  bool _creatingAccount = false;
  bool _loading = false;
  bool _obscurePassword = true;

  AccountType _selectedType = AccountType.regular;
  User? _user;

  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();

    if (widget.supabaseConfigured) {
      final auth = Supabase.instance.client.auth;
      _user = auth.currentUser;

      _authSubscription = auth.onAuthStateChange.listen((state) {
        if (!mounted) return;
        setState(() => _user = state.session?.user);
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Enter your email address.';

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    if (_selectedType == AccountType.regular && !isUsjrEmail(email)) {
      return 'Regular accounts must use an @usjr.edu.ph email.';
    }

    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final auth = Supabase.instance.client.auth;
      final email = _emailController.text.trim();

      if (_creatingAccount) {
        final response = await auth.signUp(
          email: email,
          password: _passwordController.text,
          data: {
            'requested_account_type':
                _selectedType == AccountType.foodStall
                    ? 'foodstall'
                    : 'regular',
          },
        );

        if (!mounted) return;

        if (response.session != null) {
          setState(() => _user = response.session!.user);
        } else {
          setState(() {
            _success =
                'Account request submitted. Check your email to confirm your account. Food Stall accounts require administrator approval.';
          });
        }
      } else {
        final response = await auth.signInWithPassword(
          email: email,
          password: _passwordController.text,
        );

        if (!mounted) return;
        setState(() => _user = response.user);
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (error) {
      if (mounted) setState(() => _error = 'Unable to connect: $error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user != null) {
      return HomeScreen(
        email: _user!.email ?? '',
        accountType: AccountTypeInfo.fromUser(_user!),
        storefrontId: assignedStorefrontId(_user!),
        appData: widget.appData,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 58,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _creatingAccount ? 'Create your account' : 'Welcome back',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _creatingAccount
                          ? 'Sign up to use Food to Go.'
                          : 'Log in using your registered email address.',
                    ),
                    const SizedBox(height: 24),

                    if (_creatingAccount) ...[
                      SegmentedButton<AccountType>(
                        segments: const [
                          ButtonSegment(
                            value: AccountType.regular,
                            label: Text('Regular'),
                          ),
                          ButtonSegment(
                            value: AccountType.foodStall,
                            label: Text('Food Stall'),
                          ),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _selectedType = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedType == AccountType.regular
                            ? 'Regular accounts require a USJ-R email.'
                            : 'Food Stall accounts accept any valid email and require administrator approval.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password.';
                        }
                        if (_creatingAccount && value.length < 8) {
                          return 'Use at least 8 characters.';
                        }
                        return null;
                      },
                    ),

                    if (_creatingAccount) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmController,
                        obscureText: _obscurePassword,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          prefixIcon: Icon(Icons.lock_reset_outlined),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],

                    if (_success != null) ...[
                      const SizedBox(height: 16),
                      Text(_success!),
                    ],

                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : Text(_creatingAccount ? 'Create Account' : 'Log In'),
                    ),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              setState(() {
                                _creatingAccount = !_creatingAccount;
                                _selectedType = AccountType.regular;
                                _error = null;
                                _success = null;
                              });
                            },
                      child: Text(
                        _creatingAccount
                            ? 'Already have an account? Log in'
                            : 'New here? Create an account',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}