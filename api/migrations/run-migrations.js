#!/usr/bin/env node
/**
 * Script para rodar todas as migrations SQL na ordem correta
 * Uso: node run-migrations.js
 */

const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

async function runMigrations() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USERNAME || 'root',
    password: process.env.DB_PASSWORD || 'root',
    multipleStatements: true,
  });

  console.log('🔄 Conectado ao MySQL. Rodando migrations...\n');

  const migrationsDir = path.join(__dirname, '../migrations');
  const files = fs
    .readdirSync(migrationsDir)
    .filter((f) => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    const filePath = path.join(migrationsDir, file);
    const sql = fs.readFileSync(filePath, 'utf8');

    try {
      await connection.query(sql);
      console.log(`✅ ${file}`);
    } catch (err) {
      console.error(`❌ Erro em ${file}: ${err.message}`);
      process.exit(1);
    }
  }

  await connection.end();
  console.log('\n✅ Todas as migrations executadas com sucesso!');
}

runMigrations().catch((err) => {
  console.error('❌ Erro ao conectar:', err.message);
  process.exit(1);
});
