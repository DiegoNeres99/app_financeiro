import 'package:intl/intl.dart';

class AppFormatters {
  // Formatação de moeda BRL
  static String currency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }

  // Formatação de data (dd/MM/yyyy)
  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formatação de data curta (dd/MM)
  static String dateShort(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  // Formatação de data e hora
  static String dateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Formato de mês/ano (Abril 2026)
  static String monthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'pt_BR').format(date);
  }

  // Formato curto mês/ano (abr/2026)
  static String monthYearShort(DateTime date) {
    return DateFormat('MMM/yyyy', 'pt_BR').format(date);
  }

  // Formatar percentual
  static String percentage(double value) {
    return '${value.toStringAsFixed(1)}%';
  }

  // Abreviar valor grande (10k, 1M)
  static String compactCurrency(double value) {
    if (value >= 1000000) {
      return 'R\$ ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'R\$ ${(value / 1000).toStringAsFixed(1)}k';
    }
    return currency(value);
  }

  // Converter string de data para DateTime (yyyy-MM-dd)
  static DateTime? parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  // Converter DateTime para string da API (yyyy-MM-dd)
  static String toApiDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Converter string no formato de exibição (dd/MM/yyyy) para yyyy-MM-dd
  static String toApiDateFromDisplay(String displayDate) {
    try {
      final dt = DateFormat('dd/MM/yyyy').parse(displayDate);
      return DateFormat('yyyy-MM-dd').format(dt);
    } catch (_) {
      return displayDate;
    }
  }

  // Formatar string de data da API (yyyy-MM-dd ou ISO) para dd/MM/yyyy
  static String dateFromStr(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    final dt = parseDate(dateStr);
    if (dt == null) return dateStr;
    return DateFormat('dd/MM/yyyy').format(dt);
  }
}
