-- ============================================================
-- Kila Darbar — Admin User Setup
-- Run this in pgAdmin 4 Query Tool
-- Connection: localhost:5434 / kiladarbar / kiladarbar / kiladarbar123
-- ============================================================

-- Step 1: Check existing roles
SELECT id, name FROM roles;

-- Step 2: Check if admin user already exists
SELECT id, email, name, password_hash FROM users WHERE email = 'admin@kiladarbar.com';

-- Step 3: Create the admin user
-- Default password: Admin@123
-- Change the password after first login via your own mechanism
INSERT INTO users (
    id,
    email,
    name,
    password_hash,
    is_verified,
    is_active,
    is_guest,
    role_id,
    created_at,
    updated_at
)
VALUES (
    gen_random_uuid(),
    'admin@kiladarbar.com',
    'Admin',
    '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewKyNEt6dQkRTWi2',
    true,
    true,
    false,
    (SELECT id FROM roles WHERE name = 'SUPER_ADMIN'),
    now(),
    now()
)
ON CONFLICT (email) DO NOTHING;

-- Step 4: Verify it was created
SELECT id, email, name, is_verified, is_active FROM users WHERE email = 'admin@kiladarbar.com';
