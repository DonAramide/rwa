import { MigrationInterface, QueryRunner } from "typeorm";

export class VerificationEntities00021700000000001 implements MigrationInterface {
  name = 'VerificationEntities00021700000000001'

  public async up(queryRunner: QueryRunner): Promise<void> {
    // PostGIS is optional in local dev; omit extension to avoid install requirement
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'job_status') THEN
        CREATE TYPE job_status AS ENUM ('open','assigned','submitted','accepted','rejected','disputed','refunded','paid');
      END IF;
    END $$;`);
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_method') THEN
        CREATE TYPE payment_method AS ENUM ('fiat','stable');
      END IF;
    END $$;`);
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_type') THEN
        CREATE TYPE payment_type AS ENUM ('investment','agent_fee','refund');
      END IF;
    END $$;`);
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_status') THEN
        CREATE TYPE payment_status AS ENUM ('pending','succeeded','failed');
      END IF;
    END $$;`);
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'escrow_status') THEN
        CREATE TYPE escrow_status AS ENUM ('none','held','released','refunded');
      END IF;
    END $$;`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS verification_jobs (
      id BIGSERIAL PRIMARY KEY,
      asset_id BIGINT NOT NULL,
      investor_id BIGINT NOT NULL,
      agent_id BIGINT,
      status job_status NOT NULL DEFAULT 'open',
      price NUMERIC(18,2) NOT NULL,
      currency TEXT NOT NULL,
      escrow_payment_id BIGINT,
      sla_due_at timestamptz,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS ix_verification_jobs_asset_status ON verification_jobs(asset_id, status)`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS ix_verification_jobs_agent_status ON verification_jobs(agent_id, status)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS verification_reports (
      id BIGSERIAL PRIMARY KEY,
      job_id BIGINT NOT NULL,
      summary TEXT,
      checklist JSONB,
      photos TEXT[],
      videos TEXT[],
      gps_path TEXT,
      doc_hashes TEXT[],
      submitted_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE UNIQUE INDEX IF NOT EXISTS ux_verification_reports_job ON verification_reports(job_id)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS agent_reviews (
      id BIGSERIAL PRIMARY KEY,
      job_id BIGINT NOT NULL,
      rater_user_id BIGINT NOT NULL,
      agent_id BIGINT NOT NULL,
      score INT NOT NULL CHECK (score BETWEEN 1 AND 5),
      comment TEXT,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS ix_agent_reviews_agent ON agent_reviews(agent_id, created_at DESC)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS agent_messages (
      id BIGSERIAL PRIMARY KEY,
      job_id BIGINT NOT NULL,
      from_user_id BIGINT NOT NULL,
      to_user_id BIGINT NOT NULL,
      body TEXT NOT NULL,
      attachments TEXT[],
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS ix_agent_messages_job_created ON agent_messages(job_id, created_at DESC)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS payments (
      id BIGSERIAL PRIMARY KEY,
      user_id BIGINT,
      method payment_method NOT NULL,
      type payment_type NOT NULL,
      amount NUMERIC(18,2) NOT NULL,
      currency TEXT NOT NULL,
      status payment_status NOT NULL DEFAULT 'pending',
      escrow_status escrow_status NOT NULL DEFAULT 'none',
      provider_ref TEXT,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS ix_payments_user_created ON payments(user_id, created_at DESC)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS wallets (
      id BIGSERIAL PRIMARY KEY,
      user_id BIGINT NOT NULL,
      type TEXT NOT NULL,
      address TEXT NOT NULL,
      chain_id BIGINT NOT NULL,
      verified BOOLEAN NOT NULL DEFAULT false,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE UNIQUE INDEX IF NOT EXISTS ux_wallet_address_chain ON wallets(address, chain_id)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS holdings (
      user_id BIGINT NOT NULL,
      asset_id BIGINT NOT NULL,
      balance NUMERIC(38,18) NOT NULL DEFAULT 0,
      locked_balance NUMERIC(38,18) NOT NULL DEFAULT 0,
      updated_at timestamptz NOT NULL DEFAULT now(),
      PRIMARY KEY (user_id, asset_id)
    )`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS iot_devices (
      id BIGSERIAL PRIMARY KEY,
      asset_id BIGINT,
      type TEXT NOT NULL DEFAULT 'vehicle_gps',
      public_key TEXT,
      last_seen timestamptz,
      status TEXT,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS ix_iot_devices_asset ON iot_devices(asset_id)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS telemetry (
      id BIGSERIAL PRIMARY KEY,
      asset_id BIGINT,
      ts timestamptz NOT NULL,
      lat DOUBLE PRECISION,
      lon DOUBLE PRECISION,
      speed DOUBLE PRECISION,
      meta JSONB
    )`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS ix_telemetry_asset_ts ON telemetry(asset_id, ts DESC)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS audit_logs (
      id BIGSERIAL PRIMARY KEY,
      ts timestamptz NOT NULL DEFAULT now(),
      actor TEXT NOT NULL,
      action TEXT NOT NULL,
      entity TEXT NOT NULL,
      details JSONB
    )`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP TABLE IF EXISTS audit_logs`);
    await queryRunner.query(`DROP INDEX IF EXISTS ix_telemetry_asset_ts`);
    await queryRunner.query(`DROP TABLE IF EXISTS telemetry`);
    await queryRunner.query(`DROP INDEX IF EXISTS ix_iot_devices_asset`);
    await queryRunner.query(`DROP TABLE IF EXISTS iot_devices`);
    await queryRunner.query(`DROP TABLE IF EXISTS holdings`);
    await queryRunner.query(`DROP INDEX IF EXISTS ux_wallet_address_chain`);
    await queryRunner.query(`DROP TABLE IF EXISTS wallets`);
    await queryRunner.query(`DROP INDEX IF EXISTS ix_payments_user_created`);
    await queryRunner.query(`DROP TABLE IF EXISTS payments`);
    await queryRunner.query(`DROP INDEX IF EXISTS ix_agent_messages_job_created`);
    await queryRunner.query(`DROP TABLE IF EXISTS agent_messages`);
    await queryRunner.query(`DROP INDEX IF EXISTS ix_agent_reviews_agent`);
    await queryRunner.query(`DROP TABLE IF EXISTS agent_reviews`);
    await queryRunner.query(`DROP INDEX IF EXISTS ux_verification_reports_job`);
    await queryRunner.query(`DROP TABLE IF EXISTS verification_reports`);
    await queryRunner.query(`DROP INDEX IF EXISTS ix_verification_jobs_agent_status`);
    await queryRunner.query(`DROP INDEX IF EXISTS ix_verification_jobs_asset_status`);
    await queryRunner.query(`DROP TABLE IF EXISTS verification_jobs`);
    await queryRunner.query(`DROP TYPE IF EXISTS escrow_status`);
    await queryRunner.query(`DROP TYPE IF EXISTS payment_status`);
    await queryRunner.query(`DROP TYPE IF EXISTS payment_type`);
    await queryRunner.query(`DROP TYPE IF EXISTS payment_method`);
    await queryRunner.query(`DROP TYPE IF EXISTS job_status`);
  }
}


