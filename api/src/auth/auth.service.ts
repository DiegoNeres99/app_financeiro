import {
  Injectable,
  Inject,
  ConflictException,
  UnauthorizedException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { Pool } from 'mysql2/promise';
import { DATABASE_CONNECTION } from '../config/database.module';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';

@Injectable()
export class AuthService {
  constructor(
    @Inject(DATABASE_CONNECTION) private readonly db: Pool,
    private readonly jwtService: JwtService,
  ) {}

  // ─── Cadastro ───────────────────────────────────────────────────────────────
  async register(dto: RegisterDto) {
    const [existingEmail] = await this.db.execute<any[]>(
      'SELECT id FROM users WHERE email = ?',
      [dto.email],
    );
    if (existingEmail.length > 0) {
      throw new ConflictException('Este e-mail já está em uso');
    }

    const [existingPhone] = await this.db.execute<any[]>(
      'SELECT id FROM users WHERE phone = ?',
      [dto.phone],
    );
    if (existingPhone.length > 0) {
      throw new ConflictException('Este telefone já está em uso');
    }

    if (dto.password !== dto.confirmPassword) {
      throw new BadRequestException('As senhas não conferem');
    }

    const hashedPassword = await bcrypt.hash(dto.password, 12);

    const [result] = await this.db.execute<any>(
      `INSERT INTO users (name, email, phone, password, created_at, updated_at)
       VALUES (?, ?, ?, ?, NOW(), NOW())`,
      [dto.name, dto.email, dto.phone, hashedPassword],
    );

    const userId = result.insertId;
    const token = this._generateToken(userId, dto.email, dto.name);

    return {
      message: 'Usuário cadastrado com sucesso',
      token,
      user: {
        id: userId,
        name: dto.name,
        email: dto.email,
        phone: dto.phone,
      },
    };
  }

  // ─── Login ───────────────────────────────────────────────────────────────────
  async login(dto: LoginDto) {
    const [rows] = await this.db.execute<any[]>(
      'SELECT id, name, email, phone, password, is_active FROM users WHERE email = ?',
      [dto.email],
    );

    if (rows.length === 0) {
      throw new UnauthorizedException('E-mail ou senha inválidos');
    }

    const user = rows[0];

    if (!user.is_active) {
      throw new UnauthorizedException('Conta inativa. Entre em contato com o suporte');
    }

    const passwordValid = await bcrypt.compare(dto.password, user.password);
    if (!passwordValid) {
      throw new UnauthorizedException('E-mail ou senha inválidos');
    }

    const token = this._generateToken(user.id, user.email, user.name);

    return {
      message: 'Login realizado com sucesso',
      token,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
      },
    };
  }

  // ─── Esqueci Minha Senha ─────────────────────────────────────────────────────
  async forgotPassword(dto: ForgotPasswordDto) {
    const [rows] = await this.db.execute<any[]>(
      'SELECT id, name, email FROM users WHERE email = ?',
      [dto.email],
    );

    // Por segurança, retorna mesma mensagem independente de encontrar ou não
    if (rows.length === 0) {
      return {
        message: 'Se o e-mail estiver cadastrado, você receberá as instruções',
      };
    }

    const user = rows[0];
    const token = uuidv4();
    const expiresAt = new Date();
    expiresAt.setHours(
      expiresAt.getHours() +
        parseInt(process.env.RESET_TOKEN_EXPIRATION_HOURS || '2'),
    );

    // Invalidar tokens anteriores
    await this.db.execute(
      'UPDATE password_reset_tokens SET used = 1 WHERE user_id = ? AND used = 0',
      [user.id],
    );

    // Inserir novo token
    await this.db.execute(
      `INSERT INTO password_reset_tokens (user_id, token, expires_at, created_at)
       VALUES (?, ?, ?, NOW())`,
      [user.id, token, expiresAt],
    );

    // Em produção, enviar e-mail com o token
    // Por ora, retornamos o token para fins de desenvolvimento
    return {
      message: 'Se o e-mail estiver cadastrado, você receberá as instruções',
      // REMOVER em produção:
      resetToken: token,
      note: 'Em produção, este token seria enviado por e-mail',
    };
  }

  // ─── Redefinir Senha ─────────────────────────────────────────────────────────
  async resetPassword(dto: ResetPasswordDto) {
    if (dto.newPassword !== dto.confirmNewPassword) {
      throw new BadRequestException('As senhas não conferem');
    }

    const [rows] = await this.db.execute<any[]>(
      `SELECT prt.id, prt.user_id, prt.expires_at, prt.used
       FROM password_reset_tokens prt
       WHERE prt.token = ? AND prt.used = 0`,
      [dto.token],
    );

    if (rows.length === 0) {
      throw new BadRequestException('Token inválido ou já utilizado');
    }

    const tokenData = rows[0];
    const now = new Date();

    if (new Date(tokenData.expires_at) < now) {
      throw new BadRequestException('Token expirado. Solicite uma nova recuperação de senha');
    }

    const hashedPassword = await bcrypt.hash(dto.newPassword, 12);

    await this.db.execute(
      'UPDATE users SET password = ?, updated_at = NOW() WHERE id = ?',
      [hashedPassword, tokenData.user_id],
    );

    await this.db.execute(
      'UPDATE password_reset_tokens SET used = 1 WHERE id = ?',
      [tokenData.id],
    );

    return { message: 'Senha redefinida com sucesso' };
  }

  // ─── Validar usuário pelo JWT ────────────────────────────────────────────────
  async validateUserById(userId: number) {
    const [rows] = await this.db.execute<any[]>(
      'SELECT id, name, email, phone, is_active FROM users WHERE id = ? AND is_active = 1',
      [userId],
    );
    return rows.length > 0 ? rows[0] : null;
  }

  // ─── Utilitários privados ────────────────────────────────────────────────────
  private _generateToken(userId: number, email: string, name: string): string {
    return this.jwtService.sign({
      sub: userId,
      email,
      name,
    });
  }
}
