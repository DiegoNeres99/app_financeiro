-- ============================================================
-- Migration 004: Métodos de pagamento
-- ============================================================

USE app_financeiro;

CREATE TABLE IF NOT EXISTS payment_methods (
  id          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  user_id     INT UNSIGNED    NOT NULL,
  name        VARCHAR(100)    NOT NULL,
  type        ENUM('card','cash','check','pix','transfer','cryptocurrency','boleto','debit','credit','other')
              NOT NULL DEFAULT 'other',
  is_active   TINYINT(1)      NOT NULL DEFAULT 1,
  created_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_pm_user_id (user_id),
  INDEX idx_pm_type (type),
  CONSTRAINT fk_pm_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
