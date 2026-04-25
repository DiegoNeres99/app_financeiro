import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../services/auth_service.dart';
import '../../config/app_theme.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _authService = AuthService();
  bool _sent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    if (!_formKey.currentState!.validate()) return;

    EasyLoading.show(status: 'Enviando...');
    try {
      await _authService.forgotPassword(_emailCtrl.text.trim());
      EasyLoading.dismiss();
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) setState(() => _sent = true); // por segurança não revelamos se existe
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.lock_reset_outlined, size: 72, color: AppColors.primary),
          const SizedBox(height: 24),
          const Text(
            'Informe seu e-mail cadastrado para receber as instruções de recuperação de senha.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', height: 1.5),
          ),
          const SizedBox(height: 32),
          AppTextField(
            controller: _emailCtrl,
            label: 'E-mail',
            hint: 'seu@email.com',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: Validators.email,
          ),
          const SizedBox(height: 24),
          AppButton(label: 'Enviar instruções', onPressed: _sendRequest),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_outline, size: 80, color: AppColors.income),
        const SizedBox(height: 24),
        const Text(
          'Instruções enviadas!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 12),
        const Text(
          'Se o e-mail estiver cadastrado, você receberá as instruções para redefinir sua senha.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins', height: 1.5),
        ),
        const SizedBox(height: 32),
        AppButton(
          label: 'Inserir token de recuperação',
          onPressed: () => Navigator.pushReplacementNamed(context, '/reset-password'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Voltar ao login'),
        ),
      ],
    );
  }
}
