import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from '../config/database.module';
import { CreatePaymentMethodDto } from './dto/create-payment-method.dto';
import { UpdatePaymentMethodDto } from './dto/update-payment-method.dto';

@Injectable()
export class PaymentMethodsService {
  constructor(@Inject(DATABASE_CONNECTION) private readonly db: Pool) {}

  async findAll(userId: number) {
    const [rows] = await this.db.execute<any[]>(
      'SELECT * FROM payment_methods WHERE user_id = ? ORDER BY name ASC',
      [userId],
    );
    return rows;
  }

  async findOne(id: number, userId: number) {
    const [rows] = await this.db.execute<any[]>(
      'SELECT * FROM payment_methods WHERE id = ? AND user_id = ?',
      [id, userId],
    );
    if (rows.length === 0) throw new NotFoundException('Método de pagamento não encontrado');
    return rows[0];
  }

  async create(userId: number, dto: CreatePaymentMethodDto) {
    const [result] = await this.db.execute<any>(
      `INSERT INTO payment_methods (user_id, name, type, is_active, created_at)
       VALUES (?, ?, ?, ?, NOW())`,
      [userId, dto.name, dto.type, dto.is_active !== false ? 1 : 0],
    );
    return this.findOne(result.insertId, userId);
  }

  async update(id: number, userId: number, dto: UpdatePaymentMethodDto) {
    await this.findOne(id, userId);

    const fields: string[] = [];
    const values: any[] = [];

    if (dto.name !== undefined) { fields.push('name = ?'); values.push(dto.name); }
    if (dto.type !== undefined) { fields.push('type = ?'); values.push(dto.type); }
    if (dto.is_active !== undefined) { fields.push('is_active = ?'); values.push(dto.is_active ? 1 : 0); }

    if (fields.length > 0) {
      values.push(id, userId);
      await this.db.execute(
        `UPDATE payment_methods SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
        values,
      );
    }

    return this.findOne(id, userId);
  }

  async remove(id: number, userId: number) {
    await this.findOne(id, userId);
    await this.db.execute(
      'DELETE FROM payment_methods WHERE id = ? AND user_id = ?',
      [id, userId],
    );
    return { message: 'Método de pagamento removido com sucesso' };
  }
}
