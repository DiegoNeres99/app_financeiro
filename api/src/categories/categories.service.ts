import { Injectable, Inject, NotFoundException } from '@nestjs/common';
import { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from '../config/database.module';
import { CreateCategoryDto } from './dto/create-category.dto';
import { UpdateCategoryDto } from './dto/update-category.dto';

@Injectable()
export class CategoriesService {
  constructor(@Inject(DATABASE_CONNECTION) private readonly db: Pool) {}

  async findAll(userId: number, type?: string) {
    let query = 'SELECT * FROM categories WHERE user_id = ?';
    const params: any[] = [userId];

    if (type) {
      query += ' AND type = ?';
      params.push(type);
    }

    query += ' ORDER BY name ASC';
    const [rows] = await this.db.execute<any[]>(query, params);
    return rows;
  }

  async findOne(id: number, userId: number) {
    const [rows] = await this.db.execute<any[]>(
      'SELECT * FROM categories WHERE id = ? AND user_id = ?',
      [id, userId],
    );
    if (rows.length === 0) throw new NotFoundException('Categoria não encontrada');
    return rows[0];
  }

  async create(userId: number, dto: CreateCategoryDto) {
    const [result] = await this.db.execute<any>(
      `INSERT INTO categories (user_id, name, type, color, icon, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, NOW(), NOW())`,
      [userId, dto.name, dto.type, dto.color || '#6366f1', dto.icon || 'category'],
    );
    return this.findOne(result.insertId, userId);
  }

  async update(id: number, userId: number, dto: UpdateCategoryDto) {
    await this.findOne(id, userId);

    const fields: string[] = [];
    const values: any[] = [];

    if (dto.name !== undefined) { fields.push('name = ?'); values.push(dto.name); }
    if (dto.type !== undefined) { fields.push('type = ?'); values.push(dto.type); }
    if (dto.color !== undefined) { fields.push('color = ?'); values.push(dto.color); }
    if (dto.icon !== undefined) { fields.push('icon = ?'); values.push(dto.icon); }

    if (fields.length > 0) {
      fields.push('updated_at = NOW()');
      values.push(id, userId);
      await this.db.execute(
        `UPDATE categories SET ${fields.join(', ')} WHERE id = ? AND user_id = ?`,
        values,
      );
    }

    return this.findOne(id, userId);
  }

  async remove(id: number, userId: number) {
    await this.findOne(id, userId);
    await this.db.execute('DELETE FROM categories WHERE id = ? AND user_id = ?', [id, userId]);
    return { message: 'Categoria removida com sucesso' };
  }
}
