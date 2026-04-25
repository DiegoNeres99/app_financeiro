-- ============================================================
-- Seed 001: Usuário administrador padrão
-- Senha: admin123 (hash bcrypt rounds=12)
-- ============================================================

USE app_financeiro;

-- Inserir usuário admin (se não existir)
INSERT INTO users (name, email, phone, password, is_active, created_at, updated_at)
SELECT 'Administrador', 'admin@sistema.com', '(11) 99999-0000',
  '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/RK.s5uhom', -- admin123
  1, NOW(), NOW()
WHERE NOT EXISTS (
  SELECT 1 FROM users WHERE email = 'admin@sistema.com'
);

-- Categorias padrão para o admin
SET @admin_id = (SELECT id FROM users WHERE email = 'admin@sistema.com' LIMIT 1);

-- Categorias de despesa
INSERT INTO categories (user_id, name, type, color, icon) VALUES
(@admin_id, 'Alimentação',       'expense', '#ef4444', 'restaurant'),
(@admin_id, 'Transporte',        'expense', '#f97316', 'directions_car'),
(@admin_id, 'Moradia',           'expense', '#eab308', 'home'),
(@admin_id, 'Saúde',             'expense', '#22c55e', 'local_hospital'),
(@admin_id, 'Educação',          'expense', '#3b82f6', 'school'),
(@admin_id, 'Lazer',             'expense', '#8b5cf6', 'sports_esports'),
(@admin_id, 'Vestuário',         'expense', '#ec4899', 'checkroom'),
(@admin_id, 'Tecnologia',        'expense', '#06b6d4', 'devices'),
(@admin_id, 'Assinaturas',       'expense', '#6366f1', 'subscriptions'),
(@admin_id, 'Outros',            'expense', '#6b7280', 'more_horiz');

-- Categorias de renda
INSERT INTO categories (user_id, name, type, color, icon) VALUES
(@admin_id, 'Salário',           'income',  '#22c55e', 'attach_money'),
(@admin_id, 'Freelance',         'income',  '#3b82f6', 'work'),
(@admin_id, 'Investimentos',     'income',  '#8b5cf6', 'trending_up'),
(@admin_id, 'Vendas',            'income',  '#f97316', 'sell'),
(@admin_id, 'Renda Extra',       'income',  '#06b6d4', 'add_circle');

-- Método de pagamento padrão
INSERT INTO payment_methods (user_id, name, type, is_active) VALUES
(@admin_id, 'Dinheiro',          'cash',     1),
(@admin_id, 'PIX',               'pix',      1),
(@admin_id, 'Transferência',     'transfer', 1);
