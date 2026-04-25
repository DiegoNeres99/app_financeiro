-- ============================================================
-- Migration 007: Cartões de crédito/débito
-- ============================================================

USE app_financeiro;

CREATE TABLE IF NOT EXISTS cards (
  id                  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  user_id             INT UNSIGNED    NOT NULL,
  card_name           VARCHAR(100)    NOT NULL,
  flag                VARCHAR(50)     NULL COMMENT 'Visa, Mastercard, Elo, etc.',
  total_limit         DECIMAL(15,2)   NOT NULL DEFAULT 0.00,
  used_limit          DECIMAL(15,2)   NOT NULL DEFAULT 0.00,
  best_purchase_day   TINYINT         NULL COMMENT 'Melhor dia para compra (1-31)',
  closing_day         TINYINT         NULL COMMENT 'Dia de fechamento da fatura (1-31)',
  due_day             TINYINT         NULL COMMENT 'Dia de vencimento da fatura (1-31)',
  is_active           TINYINT(1)      NOT NULL DEFAULT 1,
  created_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_cards_user_id (user_id),
  INDEX idx_cards_is_active (is_active),
  CONSTRAINT fk_cards_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
