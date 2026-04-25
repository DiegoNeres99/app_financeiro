import {
  Injectable,
  Inject,
  NotFoundException,
  ForbiddenException,
} from '@nestjs/common';
import { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from '../config/database.module';
import { CreateIncomeDto } from './dto/create-income.dto';
import { UpdateIncomeDto } from './dto/update-income.dto';
import { FilterIncomeDto } from './dto/filter-income.dto';

@Injectable()
export class IncomesService {
  constructor(@Inject(DATABASE_CONNECTION) private readonly db: Pool) {}

  async findAll(userId: number, filter: FilterIncomeDto) {
    let query = `SELECT i.*, c.name as category_name, c.color as category_color, c.icon as category_icon
                 FROM incomes i
                 LEFT JOIN categories c ON i.category_id = c.id
                 WHERE i.user_id = ?`;
    const params: any[] = [userId];

    if (filter.month && filter.year) {
      query += ' AND MONTH(i.receipt_date) = ? AND YEAR(i.receipt_date) = ?';
      params.push(filter.month, filter.year);
    } else if (filter.year) {
      query += ' AND YEAR(i.receipt_date) = ?';
      params.push(filter.year);
    }

    if (filter.income_type) {
      query += ' AND i.income_type = ?';
      params.push(filter.income_type);
    }

    if (filter.search) {
      query += ' AND i.description LIKE ?';
      params.push(`%${filter.search}%`);
    }

    if (filter.is_recurring !== undefined) {
      query += ' AND i.is_recurring = ?';
      params.push(filter.is_recurring ? 1 : 0);
    }

    query += ' ORDER BY i.receipt_date DESC';

    const [rows] = await this.db.execute<any[]>(query, params);
    return rows;
  }

  async findOne(id: number, userId: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT i.*, c.name as category_name
       FROM incomes i
       LEFT JOIN categories c ON i.category_id = c.id
       WHERE i.id = ? AND i.user_id = ?`,
      [id, userId],
    );
    if (rows.length === 0) throw new NotFoundException('Renda não encontrada');
    return rows[0];
  }

  async create(userId: number, dto: CreateIncomeDto) {
    const [result] = await this.db.execute<any>(
      `INSERT INTO incomes (user_id, description, amount, receipt_date, income_type, category_id, is_recurring, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        userId,
        dto.description,
        dto.amount,
        dto.receipt_date,
        dto.income_type || 'other',
        dto.category_id || null,
        dto.is_recurring ? 1 : 0,
      ],
    );
    return this.findOne(result.insertId, userId);
  }

  async update(id: number, userId: number, dto: UpdateIncomeDto) {
    await this.findOne(id, userId);

    const fields: string[] = [];
    const values: any[] = [];

    if (dto.description !== undefined) { fields.push('description = ?'); values.push(dto.description); }
    if (dto.amount !== undefined) { fields.push('amount = ?'); values.push(dto.amount); }
    if (dto.receipt_date !== undefined) { fields.push('receipt_date = ?'); values.push(dto.receipt_date); }
    if (dto.income_type !== undefined) { fields.push('income_type = ?'); values.push(dto.income_type); }
    if (dto.category_id !== undefined) { fields.push('category_id = ?'); values.push(dto.category_id); }
    if (dto.is_recurring !== undefined) { fields.push('is_recurring = ?'); values.push(dto.is_recurring ? 1 : 0); }

    if (fields.length > 0) {
      fields.push('updated_at = NOW()');
      values.push(id, userId);
      await this.db.execute(
        `UPDATE incomes SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
        values,
      );
    }

    return this.findOne(id, userId);
  }

  async remove(id: number, userId: number) {
    await this.findOne(id, userId);
    await this.db.execute('DELETE FROM incomes WHERE id = ? AND user_id = ?', [id, userId]);
    return { message: 'Renda removida com sucesso' };
  }

  async getMonthlyTotal(userId: number, month: number, year: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT COALESCE(SUM(amount), 0) as total
       FROM incomes
       WHERE user_id = ? AND MONTH(receipt_date) = ? AND YEAR(receipt_date) = ?`,
      [userId, month, year],
    );
    return rows[0].total;
  }
}
