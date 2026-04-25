-- ============================================================
-- Migration 008: Criptomoedas
-- ============================================================

USE app_financeiro;

CREATE TABLE IF NOT EXISTS cryptocurrencies (
  id              INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  user_id         INT UNSIGNED    NOT NULL,
  name            VARCHAR(100)    NOT NULL,
  symbol          VARCHAR(20)     NOT NULL,
  quantity        DECIMAL(20,8)   NOT NULL DEFAULT 0,
  purchase_value  DECIMAL(15,2)   NOT NULL DEFAULT 0.00 COMMENT 'Preço de compra por unidade (USD/BRL)',
  current_value   DECIMAL(15,2)   NOT NULL DEFAULT 0.00 COMMENT 'Valor atual por unidade',
  exchange        VARCHAR(100)    NULL COMMENT 'Corretora / Exchange',
  purchase_date   DATE            NULL,
  created_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),
  INDEX idx_crypto_user_id (user_id),
  INDEX idx_crypto_symbol (symbol),
  CONSTRAINT fk_crypto_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
