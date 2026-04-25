import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../services/auth_service.dart';
import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    EasyLoading.show(status: 'Cadastrando...');
    try {
      await _authService.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        confirmPassword: _confirmCtrl.text,
      );
      if (!mounted) return;
      EasyLoading.dismiss();
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameCtrl,
                label: 'Nome completo',
                hint: 'Seu nome',
                prefixIcon: Icons.person_outline,
                validator: (v) => Validators.required(v, 'Nome'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailCtrl,
                label: 'E-mail',
                hint: 'seu@email.com',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneCtrl,
                label: 'Telefone',
                hint: '(11) 99999-9999',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                inputFormatters: [_phoneMask],
                validator: Validators.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordCtrl,
                label: 'Senha',
                hint: 'Mínimo 6 caracteres',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: Validators.password,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _confirmCtrl,
                label: 'Confirmar senha',
                hint: 'Repita a senha',
                obscureText: _obscureConfirm,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text),
              ),
              const SizedBox(height: 32),
              AppButton(label: 'Criar conta', onPressed: _register),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Já tem conta? ', style: TextStyle(fontFamily: 'Poppins')),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Entrar', style: TextStyle(color: AppColors.primary, fontFamily: 'Poppins', fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
