import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/auth_legal_fine_print.dart';
import 'widgets/auth_split_layout.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  String _countryCode = '+234';
  bool _obscure = true;
  bool _loading = false;
  String? _error;
  final Map<String, String> _fieldErrors = {};

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      _fieldErrors.clear();
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final session = await ref.read(authRepositoryProvider).register(
            firstName: _firstName.text,
            lastName: _lastName.text,
            email: _email.text,
            phoneCountryCode: _countryCode,
            phoneNumber: _phone.text,
            password: _password.text,
          );
      await ref.read(authControllerProvider.notifier).applySession(session);
      if (mounted) context.go('/dashboard');
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        for (final err in e.errors) {
          if (err.field.isNotEmpty) {
            _fieldErrors[err.field] = err.message;
          }
        }
      });
      _formKey.currentState!.validate();
    } catch (_) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _fieldError(String field, String? Function() local) {
    return _fieldErrors[field] ?? local();
  }

  @override
  Widget build(BuildContext context) {
    return AuthSplitLayout(
      headline: 'Seamlessly Delivering to Over 300 Countries from Nigeria!',
      subtext:
          'Access global markets with our quick shipping from Nigeria! Fast delivery and easy customs to 300+ countries.',
      form: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create an account',
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
                        'Sign up for Myafrimall and gain unlimited access to shipping to over 300 countries from Nigeria. Do you already have an account? ',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: GestureDetector(
                      onTap: () => context.go('/sign-in'),
                      child: const Text(
                        'Login',
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
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 420;
                final first = AuthTextField(
                  label: 'First Name',
                  controller: _firstName,
                  hint: 'John',
                  enabled: !_loading,
                  validator: (v) => _fieldError('firstName', () {
                    if (v == null || v.trim().length < 2) {
                      return 'Enter at least 2 characters';
                    }
                    return null;
                  }),
                );
                final last = AuthTextField(
                  label: 'Last Name',
                  controller: _lastName,
                  hint: 'Doe',
                  enabled: !_loading,
                  validator: (v) => _fieldError('lastName', () {
                    if (v == null || v.trim().length < 2) {
                      return 'Enter at least 2 characters';
                    }
                    return null;
                  }),
                );
                if (stacked) {
                  return Column(
                    children: [
                      first,
                      const SizedBox(height: 16),
                      last,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: first),
                    const SizedBox(width: 16),
                    Expanded(child: last),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: 'Email',
              controller: _email,
              hint: 'user@example.com',
              keyboardType: TextInputType.emailAddress,
              enabled: !_loading,
              validator: (v) => _fieldError('email', () {
                final value = v?.trim() ?? '';
                if (value.isEmpty || !value.contains('@')) {
                  return 'Enter a valid email';
                }
                return null;
              }),
            ),
            const SizedBox(height: 16),
            Text(
              'Phone Number',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: DropdownButtonFormField<String>(
                    initialValue: _countryCode,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 14,
                      ),
                    ),
                    items: AppConstants.phoneCountryCodes
                        .map(
                          (code) => DropdownMenuItem(
                            value: code,
                            child: Text(code, style: const TextStyle(fontSize: 14)),
                          ),
                        )
                        .toList(),
                    onChanged: _loading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() => _countryCode = value);
                            }
                          },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _phone,
                    enabled: !_loading,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: '8012345678',
                    ),
                    validator: (v) => _fieldError('phoneNumber', () {
                      final digits = (v ?? '').replaceAll(RegExp(r'\s+'), '');
                      if (digits.length < 7 || digits.length > 15) {
                        return 'Enter 7–15 digits';
                      }
                      if (!RegExp(r'^\d+$').hasMatch(digits)) {
                        return 'Digits only';
                      }
                      return null;
                    }),
                  ),
                ),
              ],
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
              validator: (v) => _fieldError('password', () {
                final value = v ?? '';
                if (value.length < 8) {
                  return 'Min 8 characters';
                }
                if (!RegExp(r'[A-Za-z]').hasMatch(value) ||
                    !RegExp(r'\d').hasMatch(value)) {
                  return 'Include a letter and a number';
                }
                return null;
              }),
            ),
            const SizedBox(height: 20),
            if (_error != null) AuthErrorBanner(message: _error!),
            AuthPrimaryButton(
              label: 'Create account',
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
