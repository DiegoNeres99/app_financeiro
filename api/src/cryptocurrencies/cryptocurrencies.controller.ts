import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  ParseIntPipe,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { CryptocurrenciesService } from './cryptocurrencies.service';
import { CreateCryptocurrencyDto } from './dto/create-cryptocurrency.dto';
import { UpdateCryptocurrencyDto } from './dto/update-cryptocurrency.dto';

@UseGuards(JwtAuthGuard)
@Controller('cryptocurrencies')
export class CryptocurrenciesController {
  constructor(private readonly cryptoService: CryptocurrenciesService) {}

  @Get()
  findAll(@CurrentUser('id') userId: number) {
    return this.cryptoService.findAll(userId);
  }

  @Get('portfolio/summary')
  getPortfolioSummary(@CurrentUser('id') userId: number) {
    return this.cryptoService.getPortfolioSummary(userId);
  }

  @Get(':id')
  findOne(@Param('id', ParseIntPipe) id: number, @CurrentUser('id') userId: number) {
    return this.cryptoService.findOne(id, userId);
  }

  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(@CurrentUser('id') userId: number, @Body() dto: CreateCryptocurrencyDto) {
    return this.cryptoService.create(userId, dto);
  }

  @Put(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @CurrentUser('id') userId: number,
    @Body() dto: UpdateCryptocurrencyDto,
  ) {
    return this.cryptoService.update(id, userId, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  remove(@Param('id', ParseIntPipe) id: number, @CurrentUser('id') userId: number) {
    return this.cryptoService.remove(id, userId);
  }
}
