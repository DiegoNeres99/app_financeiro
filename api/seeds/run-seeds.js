#!/usr/bin/env node
/**
 * Script para rodar seeds SQL
 * Uso: node run-seeds.js
 */

const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

async function runSeeds() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USERNAME || 'root',
    password: process.env.DB_PASSWORD || 'root',
    database: process.env.DB_DATABASE || 'app_financeiro',
    multipleStatements: true,
  });

  console.log('🌱 Rodando seeds...\n');

  const seedsDir = path.join(__dirname, '../seeds');
  const files = fs
    .readdirSync(seedsDir)
    .filter((f) => f.endsWith('.sql'))
    .sort();

  for (const file of files) {
    const filePath = path.join(seedsDir, file);
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
  console.log('\n✅ Seeds executados com sucesso!');
  console.log('👤 Usuário admin: admin@sistema.com / admin123');
}

runSeeds().catch((err) => {
  console.error('❌ Erro ao conectar:', err.message);
  process.exit(1);
});
