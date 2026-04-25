import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../models/financial_models.dart';
import '../../services/financial_service.dart';
import '../../services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../utils/formatters.dart';
import '../../widgets/dashboard/balance_card.dart';
import '../../widgets/dashboard/summary_card.dart';
import '../../widgets/dashboard/chart_expenses_category.dart';
import '../../widgets/dashboard/upcoming_expenses_card.dart';
import '../../widgets/common/month_year_selector.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _financialService = FinancialService();
  final _authService = AuthService();

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  int _currentIndex = 0;

  DashboardSummary? _summary;
  List<Map<String, dynamic>> _categoryData = [];
  List<Map<String, dynamic>> _upcomingExpenses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _financialService.getDashboard(month: _selectedMonth, year: _selectedYear),
        _financialService.getExpensesByCategory(month: _selectedMonth, year: _selectedYear),
        _financialService.getUpcomingExpenses(days: 7),
      ]);
      setState(() {
        _summary = results[0] as DashboardSummary;
        _categoryData = results[1] as List<Map<String, dynamic>>;
        _upcomingExpenses = results[2] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair da sua conta?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.logout();
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 1: return _buildPlaceholder('Despesas', AppRoutes.expenses);
      case 2: return _buildPlaceholder('Rendas', AppRoutes.incomes);
      case 3: return _buildPlaceholder('Cartões', AppRoutes.cards);
      case 4: return _buildPlaceholder('Perfil', AppRoutes.profile);
      default: return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return NestedScrollView(
      headerSliverBuilder: (_, __) => [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('App Financeiro', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                MonthYearSelector(
                  month: _selectedMonth,
                  year: _selectedYear,
                  onChanged: (m, y) {
                    setState(() { _selectedMonth = m; _selectedYear = y; });
                    _loadData();
                  },
                ),
              ],
            ),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadData),
            IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: _logout),
          ],
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_summary != null) ...[
                          BalanceCard(summary: _summary!),
                          const SizedBox(height: 16),
                          _buildSummaryGrid(),
                          const SizedBox(height: 20),
                          if (_categoryData.isNotEmpty) ...[
                            const Text('Despesas por Categoria', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                            const SizedBox(height: 12),
                            ChartExpensesCategory(data: _categoryData),
                            const SizedBox(height: 20),
                          ],
                          if (_upcomingExpenses.isNotEmpty) ...[
                            const Text('Próximas a Vencer (7 dias)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
                            const SizedBox(height: 12),
                            UpcomingExpensesCard(expenses: _upcomingExpenses),
                            const SizedBox(height: 20),
                          ],
                          _buildQuickActions(),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSummaryGrid() {
    final s = _summary!;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        SummaryCard(
          title: 'Renda',
          value: s.incomeTotal,
          icon: Icons.trending_up,
          color: AppColors.income,
        ),
        SummaryCard(
          title: 'Despesas',
          value: s.expensesTotal,
          icon: Icons.trending_down,
          color: AppColors.expense,
        ),
        SummaryCard(
          title: 'Pendentes',
          value: s.expensesPending,
          icon: Icons.schedule,
          color: AppColors.pending,
          subtitle: '${s.pendingCount} conta(s)',
        ),
        SummaryCard(
          title: 'Atrasadas',
          value: s.expensesOverdue,
          icon: Icons.warning_amber_rounded,
          color: AppColors.overdue,
          subtitle: '${s.overdueCount} conta(s)',
        ),
        SummaryCard(
          title: 'Cartões',
          value: s.cardsUsed,
          icon: Icons.credit_card,
          color: AppColors.info,
          subtitle: '${s.cardUsagePercentage.toStringAsFixed(0)}% usado',
        ),
        SummaryCard(
          title: 'Cripto',
          value: s.cryptoCurrentValue,
          icon: Icons.currency_bitcoin,
          color: s.cryptoProfitLoss >= 0 ? AppColors.income : AppColors.expense,
          subtitle: s.cryptoProfitLoss >= 0 ? '+${AppFormatters.currency(s.cryptoProfitLoss)}' : AppFormatters.currency(s.cryptoProfitLoss),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ações Rápidas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
        const SizedBox(height: 12),
        Row(
          children: [
            _quickAction(Icons.add_circle_outline, 'Nova\nDespesa', AppColors.expense, () => Navigator.pushNamed(context, AppRoutes.expenseForm)),
            const SizedBox(width: 12),
            _quickAction(Icons.add_circle_outline, 'Nova\nRenda', AppColors.income, () => Navigator.pushNamed(context, AppRoutes.incomeForm)),
            const SizedBox(width: 12),
            _quickAction(Icons.credit_card, 'Cartões', AppColors.info, () => Navigator.pushNamed(context, AppRoutes.cards)),
            const SizedBox(width: 12),
            _quickAction(Icons.currency_bitcoin, 'Cripto', Colors.orange, () => Navigator.pushNamed(context, AppRoutes.cryptocurrencies)),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _quickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(color: color, fontSize: 11, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.expense),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Tentar novamente')),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, route);
      setState(() => _currentIndex = 0);
    });
    return const SizedBox.shrink();
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Despesas'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Rendas'),
        BottomNavigationBarItem(icon: Icon(Icons.credit_card_outlined), activeIcon: Icon(Icons.credit_card), label: 'Cartões'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
