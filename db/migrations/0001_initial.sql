-- Crypto RWA Platform - Initial PostgreSQL Schema
-- Safe to run on a fresh database. Idempotency is partially handled via IF NOT EXISTS.

-- Extensions (optional but useful)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- ===============
-- Enum Types
-- ===============
DO $$ BEGIN
    CREATE TYPE kyc_status AS ENUM ('pending','submitted','approved','rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE wallet_type AS ENUM ('custodial','self');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE asset_type AS ENUM ('land','truck','hotel','house','other');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE order_side AS ENUM ('buy','sell');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM ('open','partially_filled','filled','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE payment_method AS ENUM ('fiat','stable');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE payment_type AS ENUM ('investment','agent_fee','refund');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE payment_status AS ENUM ('pending','succeeded','failed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE escrow_status AS ENUM ('none','held','released','refunded');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE device_type AS ENUM ('vehicle_gps','sensor','other');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE agent_status AS ENUM ('pending','approved','suspended');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE job_status AS ENUM ('open','assigned','submitted','accepted','rejected','disputed','refunded','paid');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ===============
-- Core Tables
-- ===============
CREATE TABLE IF NOT EXISTS users (
    id                 BIGSERIAL PRIMARY KEY,
    email              TEXT UNIQUE NOT NULL,
    phone              TEXT,
    password_hash      TEXT,
    kyc_status         kyc_status NOT NULL DEFAULT 'pending',
    residency          TEXT,
    risk_flags         TEXT[],
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS wallets (
    id                 BIGSERIAL PRIMARY KEY,
    user_id            BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type               wallet_type NOT NULL,
    address            TEXT NOT NULL,
    chain_id           BIGINT NOT NULL,
    verified           BOOLEAN NOT NULL DEFAULT false,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_wallet_address_chain ON wallets(address, chain_id);

CREATE TABLE IF NOT EXISTS assets (
    id                      BIGSERIAL PRIMARY KEY,
    type                    asset_type NOT NULL,
    spv_id                  TEXT,
    title                   TEXT NOT NULL,
    coords                  geometry(Point, 4326),
    status                  TEXT NOT NULL DEFAULT 'draft',
    nav                     NUMERIC(18,2),
    documents               TEXT[],
    verification_required   BOOLEAN NOT NULL DEFAULT true,
    last_verified_at        TIMESTAMPTZ,
    last_report_id          BIGINT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS asset_tokens (
    id                 BIGSERIAL PRIMARY KEY,
    asset_id           BIGINT NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    symbol             TEXT NOT NULL,
    decimals           INT NOT NULL DEFAULT 18,
    contract_address   TEXT NOT NULL,
    restrictions       JSONB,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_asset_token_contract ON asset_tokens(contract_address);

CREATE TABLE IF NOT EXISTS orders (
    id                 BIGSERIAL PRIMARY KEY,
    user_id            BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    asset_id           BIGINT NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    side               order_side NOT NULL,
    qty                NUMERIC(38, 18) NOT NULL,
    price              NUMERIC(18, 6) NOT NULL,
    status             order_status NOT NULL DEFAULT 'open',
    filled_qty         NUMERIC(38, 18) NOT NULL DEFAULT 0,
    verification_confirmation_id BIGINT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_orders_asset_status ON orders(asset_id, status);

CREATE TABLE IF NOT EXISTS trades (
    id                 BIGSERIAL PRIMARY KEY,
    buy_order_id       BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    sell_order_id      BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    qty                NUMERIC(38, 18) NOT NULL,
    price              NUMERIC(18, 6) NOT NULL,
    tx_hash            TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS payments (
    id                 BIGSERIAL PRIMARY KEY,
    user_id            BIGINT REFERENCES users(id) ON DELETE SET NULL,
    method             payment_method NOT NULL,
    type               payment_type NOT NULL,
    amount             NUMERIC(18, 2) NOT NULL,
    currency           TEXT NOT NULL,
    status             payment_status NOT NULL DEFAULT 'pending',
    escrow_status      escrow_status NOT NULL DEFAULT 'none',
    provider_ref       TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_payments_user_created ON payments(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS distributions (
    id                 BIGSERIAL PRIMARY KEY,
    asset_id           BIGINT NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    period             DATERANGE NOT NULL,
    gross              NUMERIC(18, 2) NOT NULL,
    mgmt_fee_bps       INT NOT NULL DEFAULT 0,
    carry_bps          INT NOT NULL DEFAULT 0,
    net                NUMERIC(18, 2) NOT NULL,
    tx_hash            TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_distributions_asset_period ON distributions(asset_id, period);

-- holdings can be a materialized view in production; start as a table for simplicity
CREATE TABLE IF NOT EXISTS holdings (
    user_id            BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    asset_id           BIGINT NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    balance            NUMERIC(38, 18) NOT NULL DEFAULT 0,
    locked_balance     NUMERIC(38, 18) NOT NULL DEFAULT 0,
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (user_id, asset_id)
);

CREATE TABLE IF NOT EXISTS iot_devices (
    id                 BIGSERIAL PRIMARY KEY,
    asset_id           BIGINT REFERENCES assets(id) ON DELETE SET NULL,
    type               device_type NOT NULL DEFAULT 'vehicle_gps',
    public_key         TEXT,
    last_seen          TIMESTAMPTZ,
    status             TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_iot_devices_asset ON iot_devices(asset_id);

CREATE TABLE IF NOT EXISTS telemetry (
    id                 BIGSERIAL PRIMARY KEY,
    asset_id           BIGINT REFERENCES assets(id) ON DELETE SET NULL,
    ts                 TIMESTAMPTZ NOT NULL,
    lat                DOUBLE PRECISION,
    lon                DOUBLE PRECISION,
    speed              DOUBLE PRECISION,
    meta               JSONB
);
CREATE INDEX IF NOT EXISTS ix_telemetry_asset_ts ON telemetry(asset_id, ts DESC);

-- ===============
-- Verification Agents Feature
-- ===============
CREATE TABLE IF NOT EXISTS agents (
    id                 BIGSERIAL PRIMARY KEY,
    user_id            BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status             agent_status NOT NULL DEFAULT 'pending',
    regions            TEXT[],
    skills             TEXT[],
    bio                TEXT,
    kyc_level          TEXT,
    rating_avg         DOUBLE PRECISION DEFAULT 0,
    rating_count       INT DEFAULT 0,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_agents_user ON agents(user_id);

CREATE TABLE IF NOT EXISTS verification_jobs (
    id                 BIGSERIAL PRIMARY KEY,
    asset_id           BIGINT NOT NULL REFERENCES assets(id) ON DELETE CASCADE,
    investor_id        BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    agent_id           BIGINT REFERENCES agents(id) ON DELETE SET NULL,
    status             job_status NOT NULL DEFAULT 'open',
    price              NUMERIC(18, 2) NOT NULL,
    currency           TEXT NOT NULL,
    escrow_payment_id  BIGINT REFERENCES payments(id) ON DELETE SET NULL,
    sla_due_at         TIMESTAMPTZ,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_verification_jobs_asset_status ON verification_jobs(asset_id, status);
CREATE INDEX IF NOT EXISTS ix_verification_jobs_agent_status ON verification_jobs(agent_id, status);

CREATE TABLE IF NOT EXISTS verification_reports (
    id                 BIGSERIAL PRIMARY KEY,
    job_id             BIGINT NOT NULL REFERENCES verification_jobs(id) ON DELETE CASCADE,
    summary            TEXT,
    checklist          JSONB,
    photos             TEXT[],
    videos             TEXT[],
    gps_path           geometry(LineString, 4326),
    doc_hashes         TEXT[],
    submitted_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_verification_reports_job ON verification_reports(job_id);

CREATE TABLE IF NOT EXISTS agent_reviews (
    id                 BIGSERIAL PRIMARY KEY,
    job_id             BIGINT NOT NULL REFERENCES verification_jobs(id) ON DELETE CASCADE,
    rater_user_id      BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    agent_id           BIGINT NOT NULL REFERENCES agents(id) ON DELETE CASCADE,
    score              INT NOT NULL CHECK (score BETWEEN 1 AND 5),
    comment            TEXT,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_agent_reviews_agent ON agent_reviews(agent_id, created_at DESC);

CREATE TABLE IF NOT EXISTS agent_messages (
    id                 BIGSERIAL PRIMARY KEY,
    job_id             BIGINT NOT NULL REFERENCES verification_jobs(id) ON DELETE CASCADE,
    from_user_id       BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    to_user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    body               TEXT NOT NULL,
    attachments        TEXT[],
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_agent_messages_job_created ON agent_messages(job_id, created_at DESC);

-- Link last_report_id after reports table exists
DO $$ BEGIN
    ALTER TABLE assets
    ADD CONSTRAINT fk_assets_last_report
    FOREIGN KEY (last_report_id) REFERENCES verification_reports(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ===============
-- Audit Logs
-- ===============
CREATE TABLE IF NOT EXISTS audit_logs (
    id                 BIGSERIAL PRIMARY KEY,
    ts                 TIMESTAMPTZ NOT NULL DEFAULT now(),
    actor              TEXT NOT NULL,
    action             TEXT NOT NULL,
    entity             TEXT NOT NULL,
    details            JSONB
);

-- Helpful views or materialized views can be added in subsequent migrations.


