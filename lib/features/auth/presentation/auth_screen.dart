import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/basil_icon.dart';
import '../application/auth_controller.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registering = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    if (_registering) {
      await auth.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } else {
      await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Consumer<AuthController>(
              builder:
                  (context, auth, _) => Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CircleAvatar(
                          radius: 38,
                          backgroundColor: AppColors.primaryContainer,
                          child: BasilIcon(
                            'shopping-bag-solid',
                            size: 38,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _registering ? 'Create your account' : 'Welcome back',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _registering
                              ? 'Sign up to start ordering your favourite meals.'
                              : 'Sign in to continue chowing.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (_registering) ...[
                          TextFormField(
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                            validator:
                                (value) =>
                                    (value?.trim().length ?? 0) < 2
                                        ? 'Enter your name.'
                                        : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            return email.contains('@') && email.contains('.')
                                ? null
                                : 'Enter a valid email address.';
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Password',
                            helperText:
                                _registering
                                    ? 'At least 10 characters with a letter and number.'
                                    : null,
                            suffixIcon: IconButton(
                              tooltip:
                                  _obscurePassword
                                      ? 'Show password'
                                      : 'Hide password',
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                              icon: BasilIcon(
                                _obscurePassword
                                    ? 'eye-outline'
                                    : 'eye-closed-outline',
                              ),
                            ),
                          ),
                          validator: (value) {
                            if ((value?.length ?? 0) < 10) {
                              return 'Password must be at least 10 characters.';
                            }
                            if (_registering &&
                                (!RegExp('[A-Za-z]').hasMatch(value!) ||
                                    !RegExp('[0-9]').hasMatch(value))) {
                              return 'Include at least one letter and one number.';
                            }
                            return null;
                          },
                        ),
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            auth.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ],
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: auth.isSubmitting ? null : _submit,
                          child:
                              auth.isSubmitting
                                  ? const SizedBox.square(
                                    dimension: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    _registering ? 'Create account' : 'Sign in',
                                  ),
                        ),
                        TextButton(
                          onPressed:
                              auth.isSubmitting
                                  ? null
                                  : () => setState(() {
                                    _registering = !_registering;
                                    _formKey.currentState?.reset();
                                  }),
                          child: Text(
                            _registering
                                ? 'Already have an account? Sign in'
                                : 'New to NdiChow? Create an account',
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    ),
  );
}
