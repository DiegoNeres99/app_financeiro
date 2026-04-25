import { IsEmail, IsOptional, IsString, Matches, MaxLength } from 'class-validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString({ message: 'Nome deve ser uma string' })
  @MaxLength(100, { message: 'Nome deve ter no máximo 100 caracteres' })
  name?: string;

  @IsOptional()
  @IsEmail({}, { message: 'E-mail inválido' })
  @MaxLength(150, { message: 'E-mail deve ter no máximo 150 caracteres' })
  email?: string;

  @IsOptional()
  @IsString({ message: 'Telefone deve ser uma string' })
  @Matches(/^(\+55)?[\s.-]?\(?[1-9]{2}\)?[\s.-]?[0-9]{4,5}[\s.-]?[0-9]{4}$/, {
    message: 'Telefone inválido. Use o formato: (11) 99999-9999',
  })
  phone?: string;
}
