import 'package:dio/dio.dart';
import 'api_service.dart';
import '../models/user_model.dart';
import '../models/financial_models.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';
import '../models/card_model.dart';
import '../models/cryptocurrency_model.dart';

class FinancialService {
  final _api = ApiService();

  String _handleError(DioException e) {
    if (e.response?.data is Map) {
      return e.response!.data['message'] ?? 'Erro desconhecido';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Tempo de conexão esgotado';
    }
    return 'Erro de conexão com o servidor';
  }

  // ─── Dashboard ───────────────────────────────────────────────────────────────
  Future<DashboardSummary> getDashboard({int? month, int? year}) async {
    try {
      final response = await _api.dio.get('/dashboard', queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      });
      final data = response.data['data'] ?? response.data;
      return DashboardSummary.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getLast6Months() async {
    try {
      final response = await _api.dio.get('/dashboard/last-6-months');
      final data = response.data['data'] ?? response.data;
      return List<Map<String, dynamic>>.from(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getExpensesByCategory({int? month, int? year}) async {
    try {
      final response = await _api.dio.get('/dashboard/expenses-by-category', queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      });
      final data = response.data['data'] ?? response.data;
      return List<Map<String, dynamic>>.from(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUpcomingExpenses({int days = 7}) async {
    try {
      final response = await _api.dio.get('/dashboard/upcoming-expenses', queryParameters: {'days': days});
      final data = response.data['data'] ?? response.data;
      return List<Map<String, dynamic>>.from(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Rendas ──────────────────────────────────────────────────────────────────
  Future<List<IncomeModel>> getIncomes({int? month, int? year, String? search}) async {
    try {
      final response = await _api.dio.get('/incomes', queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      final data = response.data['data'] ?? response.data;
      return (data as List).map((e) => IncomeModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<IncomeModel> createIncome(Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.post('/incomes', data: data);
      final d = response.data['data'] ?? response.data;
      return IncomeModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<IncomeModel> updateIncome(int id, Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.put('/incomes/$id', data: data);
      final d = response.data['data'] ?? response.data;
      return IncomeModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteIncome(int id) async {
    try {
      await _api.dio.delete('/incomes/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Despesas ─────────────────────────────────────────────────────────────────
  Future<List<ExpenseModel>> getExpenses({int? month, int? year, String? status, String? search}) async {
    try {
      final response = await _api.dio.get('/expenses', queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
        if (status != null) 'status': status,
        if (search != null && search.isNotEmpty) 'search': search,
      });
      final data = response.data['data'] ?? response.data;
      return (data as List).map((e) => ExpenseModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExpenseModel> createExpense(Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.post('/expenses', data: data);
      final d = response.data['data'] ?? response.data;
      return ExpenseModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExpenseModel> updateExpense(int id, Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.put('/expenses/$id', data: data);
      final d = response.data['data'] ?? response.data;
      return ExpenseModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ExpenseModel> markExpenseAsPaid(int id) async {
    try {
      final response = await _api.dio.patch('/expenses/$id/pay');
      final d = response.data['data'] ?? response.data;
      return ExpenseModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _api.dio.delete('/expenses/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Cartões ──────────────────────────────────────────────────────────────────
  Future<List<CardModel>> getCards() async {
    try {
      final response = await _api.dio.get('/cards');
      final data = response.data['data'] ?? response.data;
      return (data as List).map((e) => CardModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CardModel> createCard(Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.post('/cards', data: data);
      final d = response.data['data'] ?? response.data;
      return CardModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CardModel> updateCard(int id, Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.put('/cards/$id', data: data);
      final d = response.data['data'] ?? response.data;
      return CardModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCard(int id) async {
    try {
      await _api.dio.delete('/cards/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Criptomoedas ─────────────────────────────────────────────────────────────
  Future<List<CryptocurrencyModel>> getCryptocurrencies() async {
    try {
      final response = await _api.dio.get('/cryptocurrencies');
      final data = response.data['data'] ?? response.data;
      return (data as List).map((e) => CryptocurrencyModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CryptocurrencyModel> createCryptocurrency(Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.post('/cryptocurrencies', data: data);
      final d = response.data['data'] ?? response.data;
      return CryptocurrencyModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CryptocurrencyModel> updateCryptocurrency(int id, Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.put('/cryptocurrencies/$id', data: data);
      final d = response.data['data'] ?? response.data;
      return CryptocurrencyModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCryptocurrency(int id) async {
    try {
      await _api.dio.delete('/cryptocurrencies/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCryptoPortfolio() async {
    try {
      final response = await _api.dio.get('/cryptocurrencies/portfolio/summary');
      return (response.data['data'] ?? response.data) as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Categorias ───────────────────────────────────────────────────────────────
  Future<List<CategoryModel>> getCategories({String? type}) async {
    try {
      final response = await _api.dio.get('/categories', queryParameters: {
        if (type != null) 'type': type,
      });
      final data = response.data['data'] ?? response.data;
      return (data as List).map((e) => CategoryModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Métodos de Pagamento ─────────────────────────────────────────────────────
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    try {
      final response = await _api.dio.get('/payment-methods');
      final data = response.data['data'] ?? response.data;
      return (data as List).map((e) => PaymentMethodModel.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<PaymentMethodModel> createPaymentMethod(Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.post('/payment-methods', data: data);
      final d = response.data['data'] ?? response.data;
      return PaymentMethodModel.fromJson(d);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePaymentMethod(int id) async {
    try {
      await _api.dio.delete('/payment-methods/$id');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── Perfil ───────────────────────────────────────────────────────────────────
  Future<UserModel> getProfile() async {
    try {
      final response = await _api.dio.get('/users/me');
      final data = response.data['data'] ?? response.data;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.dio.patch('/users/me', data: data);
      return response.data['data'] ?? response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> changePassword(Map<String, dynamic> data) async {
    try {
      await _api.dio.patch('/users/me/change-password', data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
