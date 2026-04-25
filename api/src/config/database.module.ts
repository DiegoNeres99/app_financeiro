import { Module, Global } from '@nestjs/common';
import * as mysql from 'mysql2/promise';
import * as dotenv from 'dotenv';

dotenv.config();

export const DATABASE_CONNECTION = 'DATABASE_CONNECTION';

const databaseProvider = {
  provide: DATABASE_CONNECTION,
  useFactory: async () => {
    const pool = mysql.createPool({
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '3306'),
      user: process.env.DB_USERNAME || 'root',
      password: process.env.DB_PASSWORD || 'root',
      database: process.env.DB_DATABASE || 'app_financeiro',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      timezone: '-03:00',
      charset: 'utf8mb4',
    });

    // Testar conexão
    try {
      const conn = await pool.getConnection();
      console.log('✅ Banco de dados MySQL conectado com sucesso!');
      conn.release();
    } catch (err) {
      console.error('❌ Erro ao conectar no banco de dados:', err.message);
    }

    return pool;
  },
};

@Global()
@Module({
  providers: [databaseProvider],
  exports: [databaseProvider],
})
export class DatabaseModule {}
