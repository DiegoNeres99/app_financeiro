-- ============================================================
-- Migration 005: Rendas (Incomes)
-- ============================================================

USE app_financeiro;

CREATE TABLE IF NOT EXISTS incomes (
  id            INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  user_id       INT UNSIGNED    NOT NULL,
  description   VARCHAR(255)    NOT NULL,
  amount        DECIMAL(15,2)   NOT NULL,
  receipt_date  DATE            NOT NULL,
  income_type   ENUM('salary','freelance','investment','sale','other') NOT NULL DEFAULT 'other',
  category_id   INT UNSIGNED    NULL,
  is_recurring  TINYINT(1)      NOT NULL DEFAULT 0,
  created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_incomes_user_id (user_id),
  INDEX idx_incomes_receipt_date (receipt_date),
  INDEX idx_incomes_income_type (income_type),
  CONSTRAINT fk_incomes_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_incomes_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
