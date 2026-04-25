import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../services/auth_service.dart';
import '../../config/app_theme.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _authService = AuthService();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    EasyLoading.show(status: 'Redefinindo senha...');
    try {
      await _authService.resetPassword(
        token: _tokenCtrl.text.trim(),
        newPassword: _passwordCtrl.text,
        confirmNewPassword: _confirmCtrl.text,
      );
      EasyLoading.dismiss();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Senha redefinida com sucesso!'),
            backgroundColor: AppColors.income,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Redefinir Senha')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.lock_reset_outlined, size: 72, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Insira o token recebido por e-mail e defina sua nova senha.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', height: 1.5),
              ),
              const SizedBox(height: 32),
              AppTextField(
                controller: _tokenCtrl,
                label: 'Token de recuperação',
                hint: 'Cole o token aqui',
                prefixIcon: Icons.vpn_key_outlined,
                validator: (v) => Validators.required(v, 'Token'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordCtrl,
                label: 'Nova senha',
                hint: 'Mínimo 6 caracteres',
                obscureText: _obscurePass,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                onSuffixTap: () => setState(() => _obscurePass = !_obscurePass),
                validator: Validators.password,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _confirmCtrl,
                label: 'Confirmar nova senha',
                hint: 'Repita a nova senha',
                obscureText: _obscureConfirm,
                prefixIcon: Icons.lock_outline,
                suffixIcon: _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                onSuffixTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) => Validators.confirmPassword(v, _passwordCtrl.text),
              ),
              const SizedBox(height: 32),
              AppButton(label: 'Redefinir senha', onPressed: _resetPassword),
            ],
          ),
        ),
      ),
    );
  }
}
