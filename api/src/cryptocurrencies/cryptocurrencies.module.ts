import { Module } from '@nestjs/common';
import { CryptocurrenciesController } from './cryptocurrencies.controller';
import { CryptocurrenciesService } from './cryptocurrencies.service';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [AuthModule],
  controllers: [CryptocurrenciesController],
  providers: [CryptocurrenciesService],
  exports: [CryptocurrenciesService],
})
export class CryptocurrenciesModule {}
