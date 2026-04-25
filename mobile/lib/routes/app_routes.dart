import 'package:flutter/material.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/expenses/expenses_screen.dart';
import '../screens/expenses/expense_form_screen.dart';
import '../screens/incomes/incomes_screen.dart';
import '../screens/incomes/income_form_screen.dart';
import '../screens/cards/cards_screen.dart';
import '../screens/cards/card_form_screen.dart';
import '../screens/cryptocurrencies/cryptocurrencies_screen.dart';
import '../screens/cryptocurrencies/cryptocurrency_form_screen.dart';
import '../screens/payment_methods/payment_methods_screen.dart';
import '../screens/profile/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String dashboard = '/dashboard';
  static const String expenses = '/expenses';
  static const String expenseForm = '/expenses/form';
  static const String incomes = '/incomes';
  static const String incomeForm = '/incomes/form';
  static const String cards = '/cards';
  static const String cardForm = '/cards/form';
  static const String cryptocurrencies = '/cryptocurrencies';
  static const String cryptocurrencyForm = '/cryptocurrencies/form';
  static const String paymentMethods = '/payment-methods';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _build(const SplashScreen(), settings);
      case login:
        return _build(const LoginScreen(), settings);
      case register:
        return _build(const RegisterScreen(), settings);
      case forgotPassword:
        return _build(const ForgotPasswordScreen(), settings);
      case resetPassword:
        return _build(const ResetPasswordScreen(), settings);
      case dashboard:
        return _build(const DashboardScreen(), settings);
      case expenses:
        return _build(const ExpensesScreen(), settings);
      case expenseForm:
        return _build(ExpenseFormScreen(expense: settings.arguments as dynamic), settings);
      case incomes:
        return _build(const IncomesScreen(), settings);
      case incomeForm:
        return _build(IncomeFormScreen(income: settings.arguments as dynamic), settings);
      case cards:
        return _build(const CardsScreen(), settings);
      case cardForm:
        return _build(CardFormScreen(card: settings.arguments as dynamic), settings);
      case cryptocurrencies:
        return _build(const CryptocurrenciesScreen(), settings);
      case cryptocurrencyForm:
        return _build(CryptocurrencyFormScreen(crypto: settings.arguments as dynamic), settings);
      case paymentMethods:
        return _build(const PaymentMethodsScreen(), settings);
      case profile:
        return _build(const ProfileScreen(), settings);
      default:
        return _build(const LoginScreen(), settings);
    }
  }

  static MaterialPageRoute _build(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
