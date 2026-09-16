import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../state/auth_notifier.dart';
import '../validation/validators.dart';
import '../widgets/api_error_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();
  final _username = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  bool _saving = false;
  bool _passwordTouched = false;

  @override
  void initState() {
    super.initState();
    _password.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {
      if (_password.text.isNotEmpty) _passwordTouched = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _passwordFieldKey.currentState?.validate();
    });
  }

  @override
  void dispose() {
    _password.removeListener(_onPasswordChanged);
    _username.dispose();
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _passwordTouched = true);
    if (!_formKey.currentState!.validate()) return;
    if (!Validators.passwordStrong(_password.text)) return;

    setState(() => _saving = true);
    try {
      await context.read<AuthNotifier>().register(
        username: _username.text,
        password: _password.text,
        displayName: _name.text,
      );
    } on ApiException catch (e) {
      if (mounted) await showApiError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _rule(String label, bool ok) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.cancel_outlined,
            size: 20,
            color: ok ? Colors.green.shade700 : scheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ok ? Colors.green.shade800 : scheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = _password.text;
    final longEnough = Validators.passwordHasMinLength(password);
    final hasDigit = Validators.passwordHasDigit(password);
    final hasSpecial = Validators.passwordHasSpecial(password);
    final allOk = Validators.passwordStrong(password);

    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _username,
                        decoration: const InputDecoration(labelText: 'Логин'),
                        validator: (v) =>
                            Validators.requiredField(v, label: 'логин'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Имя'),
                        validator: (v) =>
                            Validators.personName(v, label: 'Имя'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: _passwordFieldKey,
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Пароль',
                          helperText: 'От 8 символов, цифра и спецсимвол',
                        ),
                        autovalidateMode: _passwordTouched
                            ? AutovalidateMode.always
                            : AutovalidateMode.disabled,
                        validator: Validators.passwordLive,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Проверка по мере ввода:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _rule('Длина не меньше 8 символов', longEnough),
                      _rule('Есть хотя бы одна цифра', hasDigit),
                      _rule('Есть спецсимвол (! @ # \$ % и т.п.)', hasSpecial),
                      if (allOk) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Пароль подходит',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _saving || !allOk ? null : _submit,
                        child: const Text('Создать аккаунт'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: const Text('Уже есть вход'),
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
}
