import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/auth_legal_fine_print.dart';
import 'widgets/auth_split_layout.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final session = await ref.read(authRepositoryProvider).login(
            email: _email.text,
            password: _password.text,
          );
      await ref.read(authControllerProvider.notifier).applySession(session);
      if (mounted) context.go('/dashboard');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthSplitLayout(
      headline: 'Effortlessly Track Your Shipments from Nigeria!',
      subtext:
          'Monitor your shipments from Nigeria! Enjoy swift delivery and seamless customs processing',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sign in to your account',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 32,
                    color: AppColors.textPrimary,
                    height: 1.15,
                  ),
            ),
            const SizedBox(height: 12),
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                children: [
                  const TextSpan(
                    text:
                        'Log in to Myafrimall to enjoy seamless shipping to over 300 countries right from Nigeria. Don\'t have an account yet? ',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () => context.go('/sign-up'),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.linkBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            AuthTextField(
              label: 'Email',
              controller: _email,
              hint: 'user@example.com',
              keyboardType: TextInputType.emailAddress,
              enabled: !_loading,
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty || !value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Password',
              controller: _password,
              hint: 'Enter Password',
              obscureText: _obscure,
              enabled: !_loading,
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter your password';
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : () => context.go('/forgot-password'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Forgot Password?'),
            ),
            const SizedBox(height: 20),
            if (_error != null) AuthErrorBanner(message: _error!),
            AuthPrimaryButton(
              label: 'Login',
              loading: _loading,
              onPressed: _submit,
            ),
            const SizedBox(height: 20),
            const AuthLegalFinePrint(),
          ],
        ),
      ),
    );
  }
}
