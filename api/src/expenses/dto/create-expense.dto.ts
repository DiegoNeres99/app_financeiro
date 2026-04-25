import {
  IsNotEmpty,
  IsString,
  IsNumber,
  IsDateString,
  IsOptional,
  IsBoolean,
  IsIn,
  MaxLength,
  Min,
} from 'class-validator';
import { Transform } from 'class-transformer';

export class CreateExpenseDto {
  @IsNotEmpty({ message: 'Descrição é obrigatória' })
  @IsString()
  @MaxLength(255)
  description: string;

  @IsNotEmpty({ message: 'Valor é obrigatório' })
  @IsNumber({}, { message: 'Valor deve ser um número' })
  @Min(0.01, { message: 'Valor deve ser maior que zero' })
  @Transform(({ value }) => parseFloat(value))
  amount: number;

  @IsNotEmpty({ message: 'Data de vencimento é obrigatória' })
  @IsDateString({}, { message: 'Data de vencimento inválida' })
  due_date: string;

  @IsOptional()
  @IsDateString({}, { message: 'Data de pagamento inválida' })
  payment_date?: string;

  @IsOptional()
  @IsNumber()
  @Transform(({ value }) => value ? parseInt(value) : null)
  category_id?: number;

  @IsOptional()
  @IsIn(['pending', 'paid', 'overdue'], { message: 'Status inválido' })
  status?: string;

  @IsOptional()
  @IsNumber()
  @Transform(({ value }) => value ? parseInt(value) : null)
  payment_method_id?: number;

  @IsOptional()
  @IsBoolean()
  @Transform(({ value }) => value === true || value === 'true' || value === 1)
  is_recurring?: boolean;
}
