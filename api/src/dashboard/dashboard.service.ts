import { Injectable, Inject } from '@nestjs/common';
import { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from '../config/database.module';

@Injectable()
export class DashboardService {
  constructor(@Inject(DATABASE_CONNECTION) private readonly db: Pool) {}

  // ─── Dashboard Principal ─────────────────────────────────────────────────────
  async getSummary(userId: number, month: number, year: number) {
    // Atualizar despesas atrasadas automaticamente
    const today = new Date().toISOString().split('T')[0];
    await this.db.execute(
      `UPDATE expenses SET status = 'overdue', updated_at = NOW()
       WHERE user_id = ? AND status = 'pending' AND due_date < ?`,
      [userId, today],
    );

    // Totais do mês
    const [incomeRows] = await this.db.execute<any[]>(
      `SELECT COALESCE(SUM(amount), 0) as total
       FROM incomes WHERE user_id = ? AND MONTH(receipt_date) = ? AND YEAR(receipt_date) = ?`,
      [userId, month, year],
    );

    const [expenseRows] = await this.db.execute<any[]>(
      `SELECT
         COALESCE(SUM(amount), 0) as total,
         COALESCE(SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END), 0) as paid,
         COALESCE(SUM(CASE WHEN status = 'pending' THEN amount ELSE 0 END), 0) as pending,
         COALESCE(SUM(CASE WHEN status = 'overdue' THEN amount ELSE 0 END), 0) as overdue,
         COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
         COUNT(CASE WHEN status = 'overdue' THEN 1 END) as overdue_count
       FROM expenses WHERE user_id = ? AND MONTH(due_date) = ? AND YEAR(due_date) = ?`,
      [userId, month, year],
    );

    // Cartões
    const [cardRows] = await this.db.execute<any[]>(
      `SELECT COALESCE(SUM(used_limit), 0) as total_used, COALESCE(SUM(total_limit), 0) as total_limit
       FROM cards WHERE user_id = ? AND is_active = 1`,
      [userId],
    );

    // Criptomoedas
    const [cryptoRows] = await this.db.execute<any[]>(
      `SELECT
         COALESCE(SUM(quantity * purchase_value), 0) as total_invested,
         COALESCE(SUM(quantity * current_value), 0) as total_current_value
       FROM cryptocurrencies WHERE user_id = ?`,
      [userId],
    );

    const totalIncome = parseFloat(incomeRows[0].total);
    const totalExpenses = parseFloat(expenseRows[0].total);
    const balance = totalIncome - totalExpenses;

    return {
      month,
      year,
      income: {
        total: totalIncome,
      },
      expenses: {
        total: totalExpenses,
        paid: parseFloat(expenseRows[0].paid),
        pending: parseFloat(expenseRows[0].pending),
        overdue: parseFloat(expenseRows[0].overdue),
        pending_count: parseInt(expenseRows[0].pending_count),
        overdue_count: parseInt(expenseRows[0].overdue_count),
      },
      balance,
      cards: {
        total_used: parseFloat(cardRows[0].total_used),
        total_limit: parseFloat(cardRows[0].total_limit),
        available: parseFloat(cardRows[0].total_limit) - parseFloat(cardRows[0].total_used),
        usage_percentage: cardRows[0].total_limit > 0
          ? Math.round((cardRows[0].total_used / cardRows[0].total_limit) * 100)
          : 0,
      },
      cryptocurrencies: {
        total_invested: parseFloat(cryptoRows[0].total_invested),
        total_current_value: parseFloat(cryptoRows[0].total_current_value),
        profit_loss: parseFloat(cryptoRows[0].total_current_value) - parseFloat(cryptoRows[0].total_invested),
      },
    };
  }

  // ─── Despesas por Categoria ──────────────────────────────────────────────────
  async getExpensesByCategory(userId: number, month: number, year: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT
         c.id, c.name, c.color, c.icon,
         COALESCE(SUM(e.amount), 0) as total,
         COUNT(e.id) as count
       FROM categories c
       LEFT JOIN expenses e ON e.category_id = c.id
         AND e.user_id = ?
         AND MONTH(e.due_date) = ?
         AND YEAR(e.due_date) = ?
       WHERE c.user_id = ? AND c.type = 'expense'
       GROUP BY c.id, c.name, c.color, c.icon
       HAVING total > 0
       ORDER BY total DESC`,
      [userId, month, year, userId],
    );
    return rows;
  }

  // ─── Evolução dos últimos 6 meses ────────────────────────────────────────────
  async getLast6Months(userId: number) {
    const months: any[] = [];

    for (let i = 5; i >= 0; i--) {
      const date = new Date();
      date.setMonth(date.getMonth() - i);
      const m = date.getMonth() + 1;
      const y = date.getFullYear();

      const [incomes] = await this.db.execute<any[]>(
        `SELECT COALESCE(SUM(amount), 0) as total
         FROM incomes WHERE user_id = ? AND MONTH(receipt_date) = ? AND YEAR(receipt_date) = ?`,
        [userId, m, y],
      );

      const [expenses] = await this.db.execute<any[]>(
        `SELECT COALESCE(SUM(amount), 0) as total
         FROM expenses WHERE user_id = ? AND MONTH(due_date) = ? AND YEAR(due_date) = ?`,
        [userId, m, y],
      );

      months.push({
        month: m,
        year: y,
        label: new Date(y, m - 1, 1).toLocaleString('pt-BR', { month: 'short', year: 'numeric' }),
        income: parseFloat(incomes[0].total),
        expenses: parseFloat(expenses[0].total),
        balance: parseFloat(incomes[0].total) - parseFloat(expenses[0].total),
      });
    }

    return months;
  }

  // ─── Despesas próximas do vencimento ─────────────────────────────────────────
  async getUpcomingExpenses(userId: number, days: number = 7) {
    const today = new Date().toISOString().split('T')[0];
    const future = new Date();
    future.setDate(future.getDate() + days);
    const futureDate = future.toISOString().split('T')[0];

    const [rows] = await this.db.execute<any[]>(
      `SELECT e.*, c.name as category_name, c.color as category_color
       FROM expenses e
       LEFT JOIN categories c ON e.category_id = c.id
       WHERE e.user_id = ? AND e.status = 'pending'
         AND e.due_date BETWEEN ? AND ?
       ORDER BY e.due_date ASC`,
      [userId, today, futureDate],
    );

    return rows;
  }

  // ─── Resumo mensal completo ───────────────────────────────────────────────────
  async getMonthlySummary(userId: number, month: number, year: number) {
    const summary = await this.getSummary(userId, month, year);
    const expensesByCategory = await this.getExpensesByCategory(userId, month, year);

    return {
      ...summary,
      expenses_by_category: expensesByCategory,
    };
  }

  // ─── Histórico de movimentações ───────────────────────────────────────────────
  async getMovementHistory(userId: number, month: number, year: number) {
    // Renda do mês
    const [incomes] = await this.db.execute<any[]>(
      `SELECT 'income' as type, id, description, amount, receipt_date as date, income_type as subtype
       FROM incomes
       WHERE user_id = ? AND MONTH(receipt_date) = ? AND YEAR(receipt_date) = ?`,
      [userId, month, year],
    );

    // Despesas do mês
    const [expenses] = await this.db.execute<any[]>(
      `SELECT 'expense' as type, id, description, amount, due_date as date, status as subtype
       FROM expenses
       WHERE user_id = ? AND MONTH(due_date) = ? AND YEAR(due_date) = ?`,
      [userId, month, year],
    );

    const history = [...incomes, ...expenses].sort(
      (a, b) => new Date(b.date).getTime() - new Date(a.date).getTime(),
    );

    return history;
  }
}
