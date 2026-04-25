-- ============================================================
-- Migration 006: Despesas (Expenses)
-- ============================================================

USE app_financeiro;

CREATE TABLE IF NOT EXISTS expenses (
  id                INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  user_id           INT UNSIGNED    NOT NULL,
  description       VARCHAR(255)    NOT NULL,
  amount            DECIMAL(15,2)   NOT NULL,
  due_date          DATE            NOT NULL,
  payment_date      DATE            NULL,
  category_id       INT UNSIGNED    NULL,
  status            ENUM('pending','paid','overdue') NOT NULL DEFAULT 'pending',
  payment_method_id INT UNSIGNED    NULL,
  is_recurring      TINYINT(1)      NOT NULL DEFAULT 0,
  created_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_expenses_user_id (user_id),
  INDEX idx_expenses_due_date (due_date),
  INDEX idx_expenses_status (status),
  INDEX idx_expenses_category_id (category_id),
  CONSTRAINT fk_expenses_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
  CONSTRAINT fk_expenses_category FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL,
  CONSTRAINT fk_expenses_payment_method FOREIGN KEY (payment_method_id) REFERENCES payment_methods (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
