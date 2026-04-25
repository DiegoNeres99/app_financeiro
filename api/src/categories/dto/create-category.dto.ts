import {
  IsNotEmpty,
  IsString,
  IsOptional,
  IsIn,
  MaxLength,
  Matches,
} from 'class-validator';

export class CreateCategoryDto {
  @IsNotEmpty({ message: 'Nome é obrigatório' })
  @IsString()
  @MaxLength(100)
  name: string;

  @IsNotEmpty({ message: 'Tipo é obrigatório' })
  @IsIn(['income', 'expense'], { message: 'Tipo deve ser income ou expense' })
  type: string;

  @IsOptional()
  @IsString()
  @Matches(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/, {
    message: 'Cor deve ser um hexadecimal válido (ex: #FF5733)',
  })
  color?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  icon?: string;
}
