import {
  IsNotEmpty,
  IsString,
  MinLength,
  MaxLength,
} from 'class-validator';

export class ResetPasswordDto {
  @IsNotEmpty({ message: 'Token é obrigatório' })
  @IsString({ message: 'Token deve ser uma string' })
  token: string;

  @IsNotEmpty({ message: 'Nova senha é obrigatória' })
  @IsString({ message: 'Nova senha deve ser uma string' })
  @MinLength(6, { message: 'Nova senha deve ter no mínimo 6 caracteres' })
  @MaxLength(100, { message: 'Nova senha deve ter no máximo 100 caracteres' })
  newPassword: string;

  @IsNotEmpty({ message: 'Confirmação de nova senha é obrigatória' })
  @IsString({ message: 'Confirmação deve ser uma string' })
  confirmNewPassword: string;
}
