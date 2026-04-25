import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsOptional,
  IsDateString,
  MaxLength,
  Min,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateCryptocurrencyDto {
  @IsNotEmpty({ message: 'Nome é obrigatório' })
  @IsString()
  @MaxLength(100)
  name: string;

  @IsNotEmpty({ message: 'Símbolo é obrigatório' })
  @IsString()
  @MaxLength(20)
  symbol: string;

  @IsNotEmpty({ message: 'Quantidade é obrigatória' })
  @IsNumber({}, { message: 'Quantidade deve ser um número' })
  @Min(0)
  @Transform(({ value }) => parseFloat(value))
  quantity: number;

  @IsNotEmpty({ message: 'Valor de compra é obrigatório' })
  @IsNumber({}, { message: 'Valor de compra deve ser um número' })
  @Min(0)
  @Transform(({ value }) => parseFloat(value))
  purchase_value: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Transform(({ value }) => value !== undefined ? parseFloat(value) : undefined)
  current_value?: number;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  exchange?: string;

  @IsOptional()
  @IsDateString()
  purchase_date?: string;
}
