-- RWA Platform Database Initialization
-- This script sets up the initial database structure for local development

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "timescaledb";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) DEFAULT 'user' CHECK (role IN ('admin', 'investor', 'investor_agent', 'professional_agent', 'verifier', 'asset_owner', 'user', 'agent', 'issuer')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'inactive')),
    kyc_status VARCHAR(20) DEFAULT 'pending' CHECK (kyc_status IN ('pending', 'submitted', 'approved', 'rejected')),
    kyc_notes TEXT,
    residency VARCHAR(10),
    risk_flags JSONB DEFAULT '{}',
    two_factor_enabled BOOLEAN DEFAULT FALSE,
    two_factor_secret VARCHAR(255),
    last_login_at TIMESTAMP,
    last_login_ip INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Wallets table
CREATE TABLE IF NOT EXISTS wallets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('custodial', 'self')),
    address VARCHAR(255) NOT NULL,
    chain_id INTEGER NOT NULL,
    verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(address, chain_id)
);

-- Assets table
CREATE TABLE IF NOT EXISTS assets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(50) NOT NULL,
    spv_id VARCHAR(100),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    coords JSONB,
    status VARCHAR(20) DEFAULT 'pending',
    nav DECIMAL(20,8),
    documents JSONB DEFAULT '[]',
    verification_required BOOLEAN DEFAULT FALSE,
    last_verified_at TIMESTAMP,
    last_report_id UUID,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Asset tokens table
CREATE TABLE IF NOT EXISTS asset_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    symbol VARCHAR(20) NOT NULL,
    decimals INTEGER NOT NULL,
    contract_address VARCHAR(255) NOT NULL,
    restrictions JSONB DEFAULT '{}',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    side VARCHAR(10) NOT NULL CHECK (side IN ('buy', 'sell')),
    qty DECIMAL(20,8) NOT NULL,
    price DECIMAL(20,8) NOT NULL,
    status VARCHAR(20) DEFAULT 'open',
    filled_qty DECIMAL(20,8) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Trades table
CREATE TABLE IF NOT EXISTS trades (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    buy_order_id UUID REFERENCES orders(id),
    sell_order_id UUID REFERENCES orders(id),
    qty DECIMAL(20,8) NOT NULL,
    price DECIMAL(20,8) NOT NULL,
    tx_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Payments table
CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    method VARCHAR(20) NOT NULL,
    type VARCHAR(20) NOT NULL,
    amount DECIMAL(20,8) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    status VARCHAR(20) DEFAULT 'pending',
    escrow_status VARCHAR(20),
    provider_ref VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Distributions table
CREATE TABLE IF NOT EXISTS distributions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    period VARCHAR(50) NOT NULL,
    gross DECIMAL(20,8) NOT NULL,
    mgmt_fee_bps INTEGER NOT NULL,
    carry_bps INTEGER NOT NULL,
    net DECIMAL(20,8) NOT NULL,
    tx_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Holdings view (materialized)
CREATE TABLE IF NOT EXISTS holdings (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    balance DECIMAL(20,8) DEFAULT 0,
    locked_balance DECIMAL(20,8) DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, asset_id)
);

-- IoT devices table
CREATE TABLE IF NOT EXISTS iot_devices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    public_key VARCHAR(255) NOT NULL,
    last_seen TIMESTAMP,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Telemetry table (TimescaleDB hypertable)
CREATE TABLE IF NOT EXISTS telemetry (
    asset_id UUID NOT NULL,
    ts TIMESTAMP NOT NULL,
    lat DECIMAL(10,8),
    lon DECIMAL(11,8),
    speed DECIMAL(8,2),
    meta JSONB DEFAULT '{}'
);

-- Convert telemetry to hypertable
SELECT create_hypertable('telemetry', 'ts', if_not_exists => TRUE);

-- Agents table
CREATE TABLE IF NOT EXISTS agents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'pending',
    regions JSONB DEFAULT '[]',
    skills JSONB DEFAULT '[]',
    bio TEXT,
    kyc_level VARCHAR(20) DEFAULT 'basic',
    rating_avg DECIMAL(3,2) DEFAULT 0,
    rating_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verification jobs table
CREATE TABLE IF NOT EXISTS verification_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID REFERENCES assets(id) ON DELETE CASCADE,
    investor_id UUID REFERENCES users(id) ON DELETE CASCADE,
    agent_id UUID REFERENCES agents(id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'open',
    price DECIMAL(10,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,
    escrow_payment_id UUID,
    sla_due_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Verification reports table
CREATE TABLE IF NOT EXISTS verification_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES verification_jobs(id) ON DELETE CASCADE,
    summary TEXT NOT NULL,
    checklist JSONB DEFAULT '{}',
    photos JSONB DEFAULT '[]',
    videos JSONB DEFAULT '[]',
    gps_path JSONB,
    doc_hashes JSONB DEFAULT '[]',
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Agent reviews table
CREATE TABLE IF NOT EXISTS agent_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES verification_jobs(id) ON DELETE CASCADE,
    rater_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    agent_id UUID REFERENCES agents(id) ON DELETE CASCADE,
    score INTEGER NOT NULL CHECK (score >= 1 AND score <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Agent messages table
CREATE TABLE IF NOT EXISTS agent_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES verification_jobs(id) ON DELETE CASCADE,
    from_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    to_user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    body TEXT NOT NULL,
    attachments JSONB DEFAULT '[]',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Audit logs table
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    actor VARCHAR(255) NOT NULL,
    action VARCHAR(100) NOT NULL,
    entity VARCHAR(100) NOT NULL,
    details JSONB DEFAULT '{}'
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_kyc_status ON users(kyc_status);
CREATE INDEX IF NOT EXISTS idx_wallets_user_id ON wallets(user_id);
CREATE INDEX IF NOT EXISTS idx_wallets_address ON wallets(address);
CREATE INDEX IF NOT EXISTS idx_assets_status ON assets(status);
CREATE INDEX IF NOT EXISTS idx_assets_type ON assets(type);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_asset_id ON orders(asset_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_telemetry_asset_id_ts ON telemetry(asset_id, ts DESC);
CREATE INDEX IF NOT EXISTS idx_agents_status ON agents(status);
CREATE INDEX IF NOT EXISTS idx_verification_jobs_asset_id ON verification_jobs(asset_id);
CREATE INDEX IF NOT EXISTS idx_verification_jobs_agent_id ON verification_jobs(agent_id);
CREATE INDEX IF NOT EXISTS idx_verification_jobs_status ON verification_jobs(status);
CREATE INDEX IF NOT EXISTS idx_audit_logs_ts ON audit_logs(ts DESC);

-- Insert sample data for local testing
INSERT INTO users (id, email, password_hash, first_name, last_name, role, status, kyc_status) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'admin@rwa-platform.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4K9VzKQ9iW', 'Admin', 'User', 'admin', 'active', 'approved'),
('550e8400-e29b-41d4-a716-446655440001', 'investor@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4K9VzKQ9iW', 'Test', 'Investor', 'investor', 'active', 'approved'),
('550e8400-e29b-41d4-a716-446655440002', 'agent@example.com', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj4K9VzKQ9iW', 'Test', 'Agent', 'professional_agent', 'active', 'approved');

INSERT INTO assets (id, type, title, description, status, nav, verification_required) VALUES
('660e8400-e29b-41d4-a716-446655440000', 'real_estate', 'Downtown Office Building', 'Prime office space in downtown business district', 'active', 1000000.00, true),
('660e8400-e29b-41d4-a716-446655440001', 'vehicle', 'Fleet Truck #001', 'Commercial delivery truck with GPS tracking', 'active', 50000.00, true),
('660e8400-e29b-41d4-a716-446655440002', 'land', 'Agricultural Land - Iowa', '500 acres of prime agricultural land', 'active', 2500000.00, false);

INSERT INTO agents (id, user_id, status, regions, skills, bio, rating_avg, rating_count) VALUES
('770e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002', 'approved', '["US", "CA"]', '["real_estate", "vehicle"]', 'Professional verification agent with 5+ years experience in real estate and vehicle inspections.', 4.8, 25);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_assets_updated_at BEFORE UPDATE ON assets FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_agents_updated_at BEFORE UPDATE ON agents FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_verification_jobs_updated_at BEFORE UPDATE ON verification_jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();



