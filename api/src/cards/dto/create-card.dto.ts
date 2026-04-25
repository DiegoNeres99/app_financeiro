import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsOptional,
  IsBoolean,
  IsInt,
  Min,
  Max,
  MaxLength,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateCardDto {
  @IsNotEmpty({ message: 'Nome do cartão é obrigatório' })
  @IsString()
  @MaxLength(100)
  card_name: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  flag?: string;

  @IsNotEmpty({ message: 'Limite total é obrigatório' })
  @IsNumber({}, { message: 'Limite total deve ser um número' })
  @Min(0, { message: 'Limite total deve ser maior ou igual a zero' })
  @Transform(({ value }) => parseFloat(value))
  total_limit: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Transform(({ value }) => value !== undefined ? parseFloat(value) : 0)
  used_limit?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(31)
  @Transform(({ value }) => value ? parseInt(value) : null)
  best_purchase_day?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(31)
  @Transform(({ value }) => value ? parseInt(value) : null)
  closing_day?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(31)
  @Transform(({ value }) => value ? parseInt(value) : null)
  due_day?: number;

  @IsOptional()
  @IsBoolean()
  @Transform(({ value }) => value === true || value === 'true' || value === 1)
  is_active?: boolean;
}
