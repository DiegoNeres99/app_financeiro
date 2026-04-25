import {
  Injectable,
  Inject,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from '../config/database.module';
import { UpdateUserDto } from './dto/update-user.dto';
import { ChangePasswordDto } from './dto/change-password.dto';

@Injectable()
export class UsersService {
  constructor(@Inject(DATABASE_CONNECTION) private readonly db: Pool) {}

  async findById(id: number) {
    const [rows] = await this.db.execute<any[]>(
      'SELECT id, name, email, phone, is_active, created_at, updated_at FROM users WHERE id = ?',
      [id],
    );
    if (rows.length === 0) throw new NotFoundException('Usuário não encontrado');
    return rows[0];
  }

  async update(userId: number, dto: UpdateUserDto) {
    // Verificar e-mail duplicado
    if (dto.email) {
      const [existing] = await this.db.execute<any[]>(
        'SELECT id FROM users WHERE email = ? AND id != ?',
        [dto.email, userId],
      );
      if (existing.length > 0) throw new ConflictException('E-mail já está em uso');
    }

    // Verificar telefone duplicado
    if (dto.phone) {
      const [existing] = await this.db.execute<any[]>(
        'SELECT id FROM users WHERE phone = ? AND id != ?',
        [dto.phone, userId],
      );
      if (existing.length > 0) throw new ConflictException('Telefone já está em uso');
    }

    const fields: string[] = [];
    const values: any[] = [];

    if (dto.name) { fields.push('name = ?'); values.push(dto.name); }
    if (dto.email) { fields.push('email = ?'); values.push(dto.email); }
    if (dto.phone) { fields.push('phone = ?'); values.push(dto.phone); }

    if (fields.length === 0) return this.findById(userId);

    fields.push('updated_at = NOW()');
    values.push(userId);

    await this.db.execute(
      `UPDATE users SET ${fields.join(', ')} WHERE id = ?`,
      values,
    );

    return this.findById(userId);
  }

  async changePassword(userId: number, dto: ChangePasswordDto) {
    if (dto.newPassword !== dto.confirmNewPassword) {
      throw new BadRequestException('As senhas não conferem');
    }

    const [rows] = await this.db.execute<any[]>(
      'SELECT password FROM users WHERE id = ?',
      [userId],
    );

    if (rows.length === 0) throw new NotFoundException('Usuário não encontrado');

    const isValid = await bcrypt.compare(dto.currentPassword, rows[0].password);
    if (!isValid) throw new BadRequestException('Senha atual incorreta');

    const hashed = await bcrypt.hash(dto.newPassword, 12);
    await this.db.execute(
      'UPDATE users SET password = ?, updated_at = NOW() WHERE id = ?',
      [hashed, userId],
    );

    return { message: 'Senha alterada com sucesso' };
  }
}
