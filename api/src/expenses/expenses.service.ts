import {
  Injectable,
  Inject,
  NotFoundException,
} from '@nestjs/common';
import { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from '../config/database.module';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';
import { FilterExpenseDto } from './dto/filter-expense.dto';

@Injectable()
export class ExpensesService {
  constructor(@Inject(DATABASE_CONNECTION) private readonly db: Pool) {}

  async findAll(userId: number, filter: FilterExpenseDto) {
    let query = `
      SELECT e.*,
             c.name as category_name, c.color as category_color, c.icon as category_icon,
             pm.name as payment_method_name, pm.type as payment_method_type
      FROM expenses e
      LEFT JOIN categories c ON e.category_id = c.id
      LEFT JOIN payment_methods pm ON e.payment_method_id = pm.id
      WHERE e.user_id = ?`;
    const params: any[] = [userId];

    if (filter.month && filter.year) {
      query += ' AND MONTH(e.due_date) = ? AND YEAR(e.due_date) = ?';
      params.push(filter.month, filter.year);
    } else if (filter.year) {
      query += ' AND YEAR(e.due_date) = ?';
      params.push(filter.year);
    }

    if (filter.status) {
      query += ' AND e.status = ?';
      params.push(filter.status);
    }

    if (filter.category_id) {
      query += ' AND e.category_id = ?';
      params.push(filter.category_id);
    }

    if (filter.payment_method_id) {
      query += ' AND e.payment_method_id = ?';
      params.push(filter.payment_method_id);
    }

    if (filter.search) {
      query += ' AND e.description LIKE ?';
      params.push(`%${filter.search}%`);
    }

    if (filter.is_recurring !== undefined) {
      query += ' AND e.is_recurring = ?';
      params.push(filter.is_recurring ? 1 : 0);
    }

    query += ' ORDER BY e.due_date ASC';

    const [rows] = await this.db.execute<any[]>(query, params);
    return rows;
  }

  async findOne(id: number, userId: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT e.*, c.name as category_name, pm.name as payment_method_name
       FROM expenses e
       LEFT JOIN categories c ON e.category_id = c.id
       LEFT JOIN payment_methods pm ON e.payment_method_id = pm.id
       WHERE e.id = ? AND e.user_id = ?`,
      [id, userId],
    );
    if (rows.length === 0) throw new NotFoundException('Despesa não encontrada');
    return rows[0];
  }

  async create(userId: number, dto: CreateExpenseDto) {
    const [result] = await this.db.execute<any>(
      `INSERT INTO expenses (user_id, description, amount, due_date, payment_date, category_id,
        status, payment_method_id, is_recurring, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        userId,
        dto.description,
        dto.amount,
        dto.due_date,
        dto.payment_date || null,
        dto.category_id || null,
        dto.status || 'pending',
        dto.payment_method_id || null,
        dto.is_recurring ? 1 : 0,
      ],
    );
    return this.findOne(result.insertId, userId);
  }

  async update(id: number, userId: number, dto: UpdateExpenseDto) {
    await this.findOne(id, userId);

    const fields: string[] = [];
    const values: any[] = [];

    if (dto.description !== undefined) { fields.push('description = ?'); values.push(dto.description); }
    if (dto.amount !== undefined) { fields.push('amount = ?'); values.push(dto.amount); }
    if (dto.due_date !== undefined) { fields.push('due_date = ?'); values.push(dto.due_date); }
    if (dto.payment_date !== undefined) { fields.push('payment_date = ?'); values.push(dto.payment_date); }
    if (dto.category_id !== undefined) { fields.push('category_id = ?'); values.push(dto.category_id); }
    if (dto.status !== undefined) { fields.push('status = ?'); values.push(dto.status); }
    if (dto.payment_method_id !== undefined) { fields.push('payment_method_id = ?'); values.push(dto.payment_method_id); }
    if (dto.is_recurring !== undefined) { fields.push('is_recurring = ?'); values.push(dto.is_recurring ? 1 : 0); }

    if (fields.length > 0) {
      fields.push('updated_at = NOW()');
      values.push(id, userId);
      await this.db.execute(
        `UPDATE expenses SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
        values,
      );
    }

    return this.findOne(id, userId);
  }

  async markAsPaid(id: number, userId: number) {
    await this.findOne(id, userId);
    const today = new Date().toISOString().split('T')[0];
    await this.db.execute(
      `UPDATE expenses SET status = 'paid', payment_date = ?, updated_at = NOW()
       WHERE id = ? AND user_id = ?`,
      [today, id, userId],
    );
    return this.findOne(id, userId);
  }

  async remove(id: number, userId: number) {
    await this.findOne(id, userId);
    await this.db.execute('DELETE FROM expenses WHERE id = ? AND user_id = ?', [id, userId]);
    return { message: 'Despesa removida com sucesso' };
  }

  async getMonthlyTotal(userId: number, month: number, year: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT
         COALESCE(SUM(CASE WHEN status = 'paid' THEN amount ELSE 0 END), 0) as paid,
         COALESCE(SUM(CASE WHEN status = 'pending' THEN amount ELSE 0 END), 0) as pending,
         COALESCE(SUM(CASE WHEN status = 'overdue' THEN amount ELSE 0 END), 0) as overdue,
         COALESCE(SUM(amount), 0) as total
       FROM expenses
       WHERE user_id = ? AND MONTH(due_date) = ? AND YEAR(due_date) = ?`,
      [userId, month, year],
    );
    return rows[0];
  }

  async updateOverdueExpenses(userId: number) {
    const today = new Date().toISOString().split('T')[0];
    await this.db.execute(
      `UPDATE expenses SET status = 'overdue', updated_at = NOW()
       WHERE user_id = ? AND status = 'pending' AND due_date < ?`,
      [userId, today],
    );
  }
}
