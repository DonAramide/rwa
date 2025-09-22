import { MigrationInterface, QueryRunner } from "typeorm";

export class Init00011700000000000 implements MigrationInterface {
  name = 'Init00011700000000000'

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'kyc_status') THEN
        CREATE TYPE kyc_status AS ENUM ('pending','submitted','approved','rejected');
      END IF;
    END $$;`);
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'asset_type') THEN
        CREATE TYPE asset_type AS ENUM ('land','truck','hotel','house','other');
      END IF;
    END $$;`);
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_side') THEN
        CREATE TYPE order_side AS ENUM ('buy','sell');
      END IF;
    END $$;`);
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status') THEN
        CREATE TYPE order_status AS ENUM ('open','partially_filled','filled','cancelled');
      END IF;
    END $$;`);
    await queryRunner.query(`DO $$ BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'agent_status') THEN
        CREATE TYPE agent_status AS ENUM ('pending','approved','suspended');
      END IF;
    END $$;`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS users (
      id BIGSERIAL PRIMARY KEY,
      email TEXT UNIQUE NOT NULL,
      phone TEXT,
      password_hash TEXT,
      kyc_status kyc_status NOT NULL DEFAULT 'pending',
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS assets (
      id BIGSERIAL PRIMARY KEY,
      type asset_type NOT NULL,
      title TEXT NOT NULL,
      spv_id TEXT,
      status TEXT,
      nav NUMERIC(18,2),
      verification_required BOOLEAN NOT NULL DEFAULT true,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS orders (
      id BIGSERIAL PRIMARY KEY,
      user_id BIGINT NOT NULL,
      asset_id BIGINT NOT NULL,
      side order_side NOT NULL,
      qty NUMERIC(38,18) NOT NULL,
      price NUMERIC(18,6) NOT NULL,
      status order_status NOT NULL DEFAULT 'open',
      filled_qty NUMERIC(38,18) NOT NULL DEFAULT 0,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS ix_orders_asset_status ON orders(asset_id, status)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS agents (
      id BIGSERIAL PRIMARY KEY,
      user_id BIGINT NOT NULL,
      status agent_status NOT NULL DEFAULT 'pending',
      regions TEXT[],
      skills TEXT[],
      bio TEXT,
      rating_avg DOUBLE PRECISION DEFAULT 0,
      rating_count INT DEFAULT 0,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE UNIQUE INDEX IF NOT EXISTS ux_agents_user ON agents(user_id)`);

    await queryRunner.query(`CREATE TABLE IF NOT EXISTS distributions (
      id BIGSERIAL PRIMARY KEY,
      asset_id BIGINT NOT NULL,
      period tstzrange NOT NULL,
      gross NUMERIC(18,2) NOT NULL,
      mgmt_fee_bps INT NOT NULL DEFAULT 0,
      carry_bps INT NOT NULL DEFAULT 0,
      net NUMERIC(18,2) NOT NULL,
      tx_hash TEXT,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await queryRunner.query(`CREATE INDEX IF NOT EXISTS ix_distributions_asset_period ON distributions(asset_id, period)`);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS ix_distributions_asset_period`);
    await queryRunner.query(`DROP TABLE IF EXISTS distributions`);
    await queryRunner.query(`DROP INDEX IF EXISTS ux_agents_user`);
    await queryRunner.query(`DROP TABLE IF EXISTS agents`);
    await queryRunner.query(`DROP INDEX IF EXISTS ix_orders_asset_status`);
    await queryRunner.query(`DROP TABLE IF EXISTS orders`);
    await queryRunner.query(`DROP TABLE IF EXISTS assets`);
    await queryRunner.query(`DROP TABLE IF EXISTS users`);
    await queryRunner.query(`DROP TYPE IF EXISTS agent_status`);
    await queryRunner.query(`DROP TYPE IF EXISTS order_status`);
    await queryRunner.query(`DROP TYPE IF EXISTS order_side`);
    await queryRunner.query(`DROP TYPE IF EXISTS asset_type`);
    await queryRunner.query(`DROP TYPE IF EXISTS kyc_status`);
  }
}




