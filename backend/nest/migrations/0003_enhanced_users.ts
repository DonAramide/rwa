import { MigrationInterface, QueryRunner } from "typeorm";

export class EnhancedUsers1703000000000 implements MigrationInterface {
    name = 'EnhancedUsers1703000000000'

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create user roles and statuses enums
        await queryRunner.query(`
            CREATE TYPE "user_role_enum" AS ENUM('admin', 'user', 'agent', 'issuer')
        `);
        
        await queryRunner.query(`
            CREATE TYPE "user_status_enum" AS ENUM('active', 'suspended', 'inactive')
        `);

        // Add new columns to users table
        await queryRunner.query(`
            ALTER TABLE "users" 
            ADD COLUMN "first_name" character varying,
            ADD COLUMN "last_name" character varying,
            ADD COLUMN "role" "user_role_enum" NOT NULL DEFAULT 'user',
            ADD COLUMN "status" "user_status_enum" NOT NULL DEFAULT 'active',
            ADD COLUMN "residency" character varying,
            ADD COLUMN "kyc_notes" text,
            ADD COLUMN "risk_flags" jsonb,
            ADD COLUMN "last_login_at" TIMESTAMP,
            ADD COLUMN "last_login_ip" inet,
            ADD COLUMN "two_factor_enabled" boolean NOT NULL DEFAULT false,
            ADD COLUMN "two_factor_secret" text
        `);

        // Make password_hash required (remove nullable)
        await queryRunner.query(`
            ALTER TABLE "users" ALTER COLUMN "password_hash" SET NOT NULL
        `);

        // Create indexes for performance
        await queryRunner.query(`
            CREATE INDEX "IDX_users_role_status" ON "users" ("role", "status")
        `);

        // Insert default admin user if it doesn't exist
        await queryRunner.query(`
            INSERT INTO "users" (
                email, 
                first_name, 
                last_name, 
                password_hash, 
                role, 
                status, 
                kyc_status
            ) 
            SELECT 
                'admin@rwa-platform.com',
                'Admin',
                'User',
                '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LeKwNFYjWzkHOzjeK', -- hashed 'admin123'
                'admin',
                'active',
                'approved'
            WHERE NOT EXISTS (
                SELECT 1 FROM "users" WHERE email = 'admin@rwa-platform.com'
            )
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Drop indexes
        await queryRunner.query(`DROP INDEX "IDX_users_role_status"`);

        // Remove added columns
        await queryRunner.query(`
            ALTER TABLE "users" 
            DROP COLUMN "first_name",
            DROP COLUMN "last_name", 
            DROP COLUMN "role",
            DROP COLUMN "status",
            DROP COLUMN "residency",
            DROP COLUMN "kyc_notes",
            DROP COLUMN "risk_flags",
            DROP COLUMN "last_login_at",
            DROP COLUMN "last_login_ip",
            DROP COLUMN "two_factor_enabled",
            DROP COLUMN "two_factor_secret"
        `);

        // Make password_hash nullable again
        await queryRunner.query(`
            ALTER TABLE "users" ALTER COLUMN "password_hash" DROP NOT NULL
        `);

        // Drop enums
        await queryRunner.query(`DROP TYPE "user_status_enum"`);
        await queryRunner.query(`DROP TYPE "user_role_enum"`);
    }
}