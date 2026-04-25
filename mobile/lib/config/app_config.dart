class AppConfig {
  // Para rodar no Chrome (web) na mesma máquina da API
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // Para emulador Android (localhost da máquina)
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1';

  // Para dispositivo físico na mesma rede WiFi
  // Execute: hostname -I | awk '{print $1}'
  // static const String baseUrl = 'http://SEU_IP_LOCAL:3000/api/v1';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  static const String appName = 'App Financeiro';
  static const String appVersion = '1.0.0';
}
