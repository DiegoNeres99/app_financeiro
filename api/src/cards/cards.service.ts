import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from '../config/database.module';
import { CreateCardDto } from './dto/create-card.dto';
import { UpdateCardDto } from './dto/update-card.dto';

@Injectable()
export class CardsService {
  constructor(@Inject(DATABASE_CONNECTION) private readonly db: Pool) {}

  async findAll(userId: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT *,
              (total_limit - used_limit) as available_limit,
              ROUND((used_limit / total_limit) * 100, 2) as usage_percentage
       FROM cards WHERE user_id = ? ORDER BY card_name ASC`,
      [userId],
    );
    return rows;
  }

  async findOne(id: number, userId: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT *,
              (total_limit - used_limit) as available_limit,
              ROUND((used_limit / total_limit) * 100, 2) as usage_percentage
       FROM cards WHERE id = ? AND user_id = ?`,
      [id, userId],
    );
    if (rows.length === 0) throw new NotFoundException('Cartão não encontrado');
    return rows[0];
  }

  async create(userId: number, dto: CreateCardDto) {
    const [result] = await this.db.execute<any>(
      `INSERT INTO cards (user_id, card_name, flag, total_limit, used_limit, best_purchase_day,
        closing_day, due_day, is_active, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        userId,
        dto.card_name,
        dto.flag || null,
        dto.total_limit,
        dto.used_limit || 0,
        dto.best_purchase_day || null,
        dto.closing_day || null,
        dto.due_day || null,
        dto.is_active !== false ? 1 : 0,
      ],
    );
    return this.findOne(result.insertId, userId);
  }

  async update(id: number, userId: number, dto: UpdateCardDto) {
    await this.findOne(id, userId);

    const fields: string[] = [];
    const values: any[] = [];

    if (dto.card_name !== undefined) { fields.push('card_name = ?'); values.push(dto.card_name); }
    if (dto.flag !== undefined) { fields.push('flag = ?'); values.push(dto.flag); }
    if (dto.total_limit !== undefined) { fields.push('total_limit = ?'); values.push(dto.total_limit); }
    if (dto.used_limit !== undefined) { fields.push('used_limit = ?'); values.push(dto.used_limit); }
    if (dto.best_purchase_day !== undefined) { fields.push('best_purchase_day = ?'); values.push(dto.best_purchase_day); }
    if (dto.closing_day !== undefined) { fields.push('closing_day = ?'); values.push(dto.closing_day); }
    if (dto.due_day !== undefined) { fields.push('due_day = ?'); values.push(dto.due_day); }
    if (dto.is_active !== undefined) { fields.push('is_active = ?'); values.push(dto.is_active ? 1 : 0); }

    if (fields.length > 0) {
      fields.push('updated_at = NOW()');
      values.push(id, userId);
      await this.db.execute(
        `UPDATE cards SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
        values,
      );
    }

    return this.findOne(id, userId);
  }

  async remove(id: number, userId: number) {
    await this.findOne(id, userId);
    await this.db.execute('DELETE FROM cards WHERE id = ? AND user_id = ?', [id, userId]);
    return { message: 'Cartão removido com sucesso' };
  }

  async getTotalUsedLimit(userId: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT COALESCE(SUM(used_limit), 0) as total_used, COALESCE(SUM(total_limit), 0) as total_limit
       FROM cards WHERE user_id = ? AND is_active = 1`,
      [userId],
    );
    return rows[0];
  }
}
