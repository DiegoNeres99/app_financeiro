import { IsOptional, IsNumberString, IsString, IsBoolean } from 'class-validator';
import { Transform } from 'class-transformer';

export class FilterIncomeDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  month?: number;

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  year?: number;

  @IsOptional()
  @IsString()
  income_type?: string;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  is_recurring?: boolean;
}
