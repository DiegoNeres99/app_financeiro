-- ============================================================
-- Migration 003: Categorias financeiras
-- ============================================================

USE app_financeiro;

CREATE TABLE IF NOT EXISTS categories (
  id          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  user_id     INT UNSIGNED    NOT NULL,
  name        VARCHAR(100)    NOT NULL,
  type        ENUM('income','expense') NOT NULL DEFAULT 'expense',
  color       VARCHAR(20)     NOT NULL DEFAULT '#6366f1',
  icon        VARCHAR(50)     NOT NULL DEFAULT 'category',
  created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_categories_user_id (user_id),
  INDEX idx_categories_type (type),
  CONSTRAINT fk_categories_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
