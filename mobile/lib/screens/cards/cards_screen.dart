import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../config/app_theme.dart';
import '../../models/card_model.dart';
import '../../services/financial_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/formatters.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final _service = FinancialService();
  List<CardModel> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getCards();
      setState(() { _cards = data; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _delete(CardModel card) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cartão'),
        content: Text('Deseja excluir "${card.cardName}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Excluir', style: TextStyle(color: AppColors.expense))),
        ],
      ),
    );
    if (confirm != true) return;
    EasyLoading.show();
    try {
      await _service.deleteCard(card.id);
      EasyLoading.dismiss();
      _loadCards();
    } catch (e) {
      EasyLoading.dismiss();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.expense));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cartões de Crédito')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
              ? const Center(child: Text('Nenhum cartão cadastrado', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Poppins')))
              : RefreshIndicator(
                  onRefresh: _loadCards,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _cards.length,
                    itemBuilder: (_, i) => _buildCard(_cards[i]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.cardForm);
          _loadCards();
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Cartão'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Widget _buildCard(CardModel card) {
    final usagePct = card.usagePercentage;
    final usageColor = usagePct >= 90 ? AppColors.expense : usagePct >= 70 ? AppColors.pending : AppColors.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.credit_card, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Text(card.cardName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                if (card.flag != null)
                  Text(card.flag!, style: const TextStyle(color: Colors.white70, fontFamily: 'Poppins')),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (v) {
                    if (v == 'edit') { Navigator.pushNamed(context, AppRoutes.cardForm, arguments: card).then((_) => _loadCards()); }
                    if (v == 'delete') _delete(card);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Editar')),
                    PopupMenuItem(value: 'delete', child: Text('Excluir')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _cardInfo('Limite Total', AppFormatters.currency(card.totalLimit)),
                _cardInfo('Usado', AppFormatters.currency(card.usedLimit)),
                _cardInfo('Disponível', AppFormatters.currency(card.availableLimit)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usagePct / 100,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(usageColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${usagePct.toStringAsFixed(0)}% utilizado',
              style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins'),
            ),
            if (card.dueDay != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, color: Colors.white60, size: 14),
                    const SizedBox(width: 4),
                    Text('Vencimento: dia ${card.dueDay}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
                    if (card.closingDay != null) ...[
                      const SizedBox(width: 16),
                      Text('Fechamento: dia ${card.closingDay}', style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Poppins')),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _cardInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'Poppins')),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
      ],
    );
  }
}
