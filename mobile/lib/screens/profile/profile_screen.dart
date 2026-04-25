import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/financial_service.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/app_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _financialService = FinancialService();
  final _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _financialService.getProfile();
      setState(() { _user = user; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sair', style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.logout();
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  void _editProfile() {
    if (_user == null) return;
    final nameCtrl = TextEditingController(text: _user!.name);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Editar Perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nome', prefixIcon: Icon(Icons.person_outline)),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                EasyLoading.show();
                try {
                  await _financialService.updateProfile({'name': nameCtrl.text.trim()});
                  EasyLoading.dismiss();
                  _loadProfile();
                } catch (e) {
                  EasyLoading.dismiss();
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Salvar', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    nameCtrl.dispose();
  }

  void _changePassword() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          bool obscCurrent = true, obscNew = true, obscConfirm = true;
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Alterar Senha', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                const SizedBox(height: 16),
                TextField(controller: currentCtrl, obscureText: obscCurrent, decoration: InputDecoration(labelText: 'Senha atual', suffixIcon: IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () => setSheetState(() => obscCurrent = !obscCurrent)))),
                const SizedBox(height: 12),
                TextField(controller: newCtrl, obscureText: obscNew, decoration: InputDecoration(labelText: 'Nova senha', suffixIcon: IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () => setSheetState(() => obscNew = !obscNew)))),
                const SizedBox(height: 12),
                TextField(controller: confirmCtrl, obscureText: obscConfirm, decoration: InputDecoration(labelText: 'Confirmar nova senha', suffixIcon: IconButton(icon: const Icon(Icons.visibility_outlined, size: 18), onPressed: () => setSheetState(() => obscConfirm = !obscConfirm)))),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (newCtrl.text != confirmCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('As senhas não conferem'), backgroundColor: AppColors.expense));
                      return;
                    }
                    Navigator.pop(ctx);
                    EasyLoading.show();
                    try {
                      await _financialService.changePassword({'current_password': currentCtrl.text, 'new_password': newCtrl.text, 'confirm_new_password': confirmCtrl.text});
                      EasyLoading.dismiss();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Senha alterada com sucesso!'), backgroundColor: AppColors.income));
                    } catch (e) {
                      EasyLoading.dismiss();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Alterar senha', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Text(
                      _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Poppins'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_user?.name ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                  Text(_user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')),
                  const SizedBox(height: 32),
                  // Options
                  _buildOption(Icons.person_outline, 'Editar Perfil', _editProfile),
                  _buildOption(Icons.lock_outline, 'Alterar Senha', _changePassword),
                  _buildOption(Icons.payment_outlined, 'Métodos de Pagamento', () => Navigator.pushNamed(context, AppRoutes.paymentMethods)),
                  const Divider(height: 32),
                  _buildOption(Icons.logout, 'Sair', _logout, color: AppColors.expense),
                ],
              ),
            ),
    );
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap, {Color? color}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.primary),
      title: Text(label, style: TextStyle(fontFamily: 'Poppins', color: color)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
