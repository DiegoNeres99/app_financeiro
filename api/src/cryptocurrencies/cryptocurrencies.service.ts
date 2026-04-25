import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from '../config/database.module';
import { CreateCryptocurrencyDto } from './dto/create-cryptocurrency.dto';
import { UpdateCryptocurrencyDto } from './dto/update-cryptocurrency.dto';

@Injectable()
export class CryptocurrenciesService {
  constructor(@Inject(DATABASE_CONNECTION) private readonly db: Pool) {}

  async findAll(userId: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT *,
              (current_value - purchase_value) * quantity as profit_loss,
              CASE WHEN purchase_value > 0
                THEN ROUND(((current_value - purchase_value) / purchase_value) * 100, 2)
                ELSE 0
              END as profit_loss_percentage
       FROM cryptocurrencies WHERE user_id = ? ORDER BY name ASC`,
      [userId],
    );
    return rows;
  }

  async findOne(id: number, userId: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT *,
              (current_value - purchase_value) * quantity as profit_loss,
              CASE WHEN purchase_value > 0
                THEN ROUND(((current_value - purchase_value) / purchase_value) * 100, 2)
                ELSE 0
              END as profit_loss_percentage
       FROM cryptocurrencies WHERE id = ? AND user_id = ?`,
      [id, userId],
    );
    if (rows.length === 0) throw new NotFoundException('Criptomoeda não encontrada');
    return rows[0];
  }

  async create(userId: number, dto: CreateCryptocurrencyDto) {
    const [result] = await this.db.execute<any>(
      `INSERT INTO cryptocurrencies (user_id, name, symbol, quantity, purchase_value, current_value, exchange, purchase_date, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())`,
      [
        userId,
        dto.name,
        dto.symbol,
        dto.quantity,
        dto.purchase_value,
        dto.current_value || dto.purchase_value,
        dto.exchange || null,
        dto.purchase_date || null,
      ],
    );
    return this.findOne(result.insertId, userId);
  }

  async update(id: number, userId: number, dto: UpdateCryptocurrencyDto) {
    await this.findOne(id, userId);

    const fields: string[] = [];
    const values: any[] = [];

    if (dto.name !== undefined) { fields.push('name = ?'); values.push(dto.name); }
    if (dto.symbol !== undefined) { fields.push('symbol = ?'); values.push(dto.symbol); }
    if (dto.quantity !== undefined) { fields.push('quantity = ?'); values.push(dto.quantity); }
    if (dto.purchase_value !== undefined) { fields.push('purchase_value = ?'); values.push(dto.purchase_value); }
    if (dto.current_value !== undefined) { fields.push('current_value = ?'); values.push(dto.current_value); }
    if (dto.exchange !== undefined) { fields.push('exchange = ?'); values.push(dto.exchange); }
    if (dto.purchase_date !== undefined) { fields.push('purchase_date = ?'); values.push(dto.purchase_date); }

    if (fields.length > 0) {
      fields.push('updated_at = NOW()');
      values.push(id, userId);
      await this.db.execute(
        `UPDATE cryptocurrencies SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
        values,
      );
    }

    return this.findOne(id, userId);
  }

  async remove(id: number, userId: number) {
    await this.findOne(id, userId);
    await this.db.execute(
      'DELETE FROM cryptocurrencies WHERE id = ? AND user_id = ?',
      [id, userId],
    );
    return { message: 'Criptomoeda removida com sucesso' };
  }

  async getPortfolioSummary(userId: number) {
    const [rows] = await this.db.execute<any[]>(
      `SELECT
         COUNT(*) as total_coins,
         COALESCE(SUM(quantity * purchase_value), 0) as total_invested,
         COALESCE(SUM(quantity * current_value), 0) as total_current_value,
         COALESCE(SUM((current_value - purchase_value) * quantity), 0) as total_profit_loss
       FROM cryptocurrencies WHERE user_id = ?`,
      [userId],
    );
    return rows[0];
  }
}
