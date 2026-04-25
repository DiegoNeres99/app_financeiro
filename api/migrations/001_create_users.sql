-- ============================================================
-- Migration 001: Criar banco de dados e tabela de usuários
-- ============================================================

CREATE DATABASE IF NOT EXISTS app_financeiro
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE app_financeiro;

-- Tabela de usuários
CREATE TABLE IF NOT EXISTS users (
  id           INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  name         VARCHAR(100)    NOT NULL,
  email        VARCHAR(150)    NOT NULL UNIQUE,
  phone        VARCHAR(20)     NOT NULL UNIQUE,
  password     VARCHAR(255)    NOT NULL,
  is_active    TINYINT(1)      NOT NULL DEFAULT 1,
  created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_users_email (email),
  INDEX idx_users_phone (phone),
  INDEX idx_users_is_active (is_active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
