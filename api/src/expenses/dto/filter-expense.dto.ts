import { IsOptional, IsString } from 'class-validator';
import { Transform } from 'class-transformer';

export class FilterExpenseDto {
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  month?: number;

  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  year?: number;

  @IsOptional()
  @IsString()
  status?: string;

  @IsOptional()
  @Transform(({ value }) => value ? parseInt(value) : undefined)
  category_id?: number;

  @IsOptional()
  @Transform(({ value }) => value ? parseInt(value) : undefined)
  payment_method_id?: number;

  @IsOptional()
  @IsString()
  search?: string;

  @IsOptional()
  @Transform(({ value }) => value === 'true' || value === true)
  is_recurring?: boolean;
}
