import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/cryptocurrency_model.dart';
import '../../services/financial_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/formatters.dart';

class CryptocurrenciesScreen extends StatefulWidget {
  const CryptocurrenciesScreen({super.key});

  @override
  State<CryptocurrenciesScreen> createState() => _CryptocurrenciesScreenState();
}

class _CryptocurrenciesScreenState extends State<CryptocurrenciesScreen> {
  final _service = FinancialService();
  List<CryptocurrencyModel> _cryptos = [];
  Map<String, dynamic>? _portfolio;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _service.getCryptocurrencies(),
        _service.getCryptoPortfolio(),
      ]);
      setState(() {
        _cryptos = results[0] as List<CryptocurrencyModel>;
        _portfolio = results[1] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(CryptocurrencyModel crypto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir criptomoeda'),
        content: Text('Deseja excluir "${crypto.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir', style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (confirm != true) return;
    EasyLoading.show();
    try {
      await _service.deleteCryptocurrency(crypto.id);
      EasyLoading.dismiss();
      _loadData();
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criptomoedas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_portfolio != null) _buildPortfolio(),
                  const SizedBox(height: 16),
                  if (_cryptos.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Nenhuma criptomoeda cadastrada', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins'))))
                  else
                    ..._cryptos.map((c) => _buildCryptoCard(c)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.cryptocurrencyForm);
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova Cripto'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildPortfolio() {
    final total = double.tryParse(_portfolio!['total_invested']?.toString() ?? '0') ?? 0;
    final current = double.tryParse(_portfolio!['total_current_value']?.toString() ?? '0') ?? 0;
    final pl = double.tryParse(_portfolio!['profit_loss']?.toString() ?? '0') ?? 0;
    final plPct = double.tryParse(_portfolio!['profit_loss_percentage']?.toString() ?? '0') ?? 0;
    final isProfit = pl >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade700, Colors.orange.shade400], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Portfólio Total', style: TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          Text(AppFormatters.currency(current), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          Row(
            children: [
              _portfolioStat('Investido', AppFormatters.currency(total)),
              const SizedBox(width: 24),
              _portfolioStat(
                'Lucro/Prejuízo',
                '${isProfit ? '+' : ''}${AppFormatters.currency(pl)} (${plPct.toStringAsFixed(2)}%)',
                color: isProfit ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _portfolioStat(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'Poppins')),
        Text(value, style: TextStyle(color: color ?? Colors.white, fontWeight: FontWeight.w600, fontFamily: 'Poppins', fontSize: 13)),
      ],
    );
  }

  Widget _buildCryptoCard(CryptocurrencyModel crypto) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.15),
          child: Text(crypto.symbol.substring(0, crypto.symbol.length.clamp(0, 3)).toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Poppins')),
        ),
        title: Text(crypto.name, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Poppins')),
        subtitle: Text(
          '${crypto.quantity} ${crypto.symbol.toUpperCase()} · Compra: ${AppFormatters.currency(crypto.purchaseValue)}',
          style: const TextStyle(fontSize: 12, fontFamily: 'Poppins', color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(AppFormatters.currency(crypto.currentValue), style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(crypto.isProfit ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: crypto.isProfit ? AppColors.income : AppColors.expense),
                Text(
                  '${crypto.isProfit ? '+' : ''}${AppFormatters.currency(crypto.totalCurrentValue - crypto.totalInvested)}',
                  style: TextStyle(fontSize: 11, color: crypto.isProfit ? AppColors.income : AppColors.expense, fontFamily: 'Poppins'),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          await Navigator.pushNamed(context, AppRoutes.cryptocurrencyForm, arguments: crypto);
          _loadData();
        },
        onLongPress: () => _delete(crypto),
      ),
    );
  }
}
