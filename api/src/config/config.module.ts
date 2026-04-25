import { Module, Global } from '@nestjs/common';
import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({ path: path.resolve(process.cwd(), '.env') });

@Global()
@Module({
  providers: [],
  exports: [],
})
export class ConfigModule {}
