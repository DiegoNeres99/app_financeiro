import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'config/app_theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AppFinanceiro(),
    ),
  );
}

class AppFinanceiro extends StatelessWidget {
  const AppFinanceiro({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Financeiro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      builder: EasyLoading.init(),
    );
  }
}
