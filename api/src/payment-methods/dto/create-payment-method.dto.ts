import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsBoolean,
  IsIn,
  MaxLength,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class CreatePaymentMethodDto {
  @IsNotEmpty({ message: 'Nome é obrigatório' })
  @IsString()
  @MaxLength(100)
  name: string;

  @IsNotEmpty({ message: 'Tipo é obrigatório' })
  @IsIn(['card', 'cash', 'check', 'pix', 'transfer', 'cryptocurrency', 'boleto', 'debit', 'credit', 'other'], {
    message: 'Tipo inválido',
  })
  type: string;

  @IsOptional()
  @IsBoolean()
  @Transform(({ value }) => value === true || value === 'true' || value === 1)
  is_active?: boolean;
}
