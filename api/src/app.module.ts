import { Module } from '@nestjs/common';
import { ThrottlerModule } from '@nestjs/throttler';
import { ConfigModule } from './config/config.module';
import { DatabaseModule } from './config/database.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { IncomesModule } from './incomes/incomes.module';
import { ExpensesModule } from './expenses/expenses.module';
import { PaymentMethodsModule } from './payment-methods/payment-methods.module';
import { CardsModule } from './cards/cards.module';
import { CryptocurrenciesModule } from './cryptocurrencies/cryptocurrencies.module';
import { CategoriesModule } from './categories/categories.module';
import { DashboardModule } from './dashboard/dashboard.module';

@Module({
  imports: [
    ConfigModule,
    DatabaseModule,
    ThrottlerModule.forRoot([
      {
        ttl: parseInt(process.env.THROTTLE_TTL || '60') * 1000,
        limit: parseInt(process.env.THROTTLE_LIMIT || '100'),
      },
    ]),
    AuthModule,
    UsersModule,
    IncomesModule,
    ExpensesModule,
    PaymentMethodsModule,
    CardsModule,
    CryptocurrenciesModule,
    CategoriesModule,
    DashboardModule,
  ],
})
export class AppModule {}
