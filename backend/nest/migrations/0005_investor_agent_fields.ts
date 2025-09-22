import { MigrationInterface, QueryRunner } from "typeorm";

export class InvestorAgentFields1704067300000 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Add new user roles to enum
        await queryRunner.query(`
            ALTER TYPE "users_role_enum" ADD VALUE 'investor';
            ALTER TYPE "users_role_enum" ADD VALUE 'investor_agent';
            ALTER TYPE "users_role_enum" ADD VALUE 'professional_agent';
            ALTER TYPE "users_role_enum" ADD VALUE 'verifier';
            ALTER TYPE "users_role_enum" ADD VALUE 'asset_owner';
        `);

        // Add investor-agent fields to users table
        await queryRunner.query(`
            ALTER TABLE "users"
            ADD COLUMN "is_investor_agent" boolean DEFAULT false NOT NULL,
            ADD COLUMN "investor_agent_since" timestamp,
            ADD COLUMN "reputation_score" integer DEFAULT 0 NOT NULL,
            ADD COLUMN "total_flags_submitted" integer DEFAULT 0 NOT NULL,
            ADD COLUMN "total_flags_resolved" integer DEFAULT 0 NOT NULL;
        `);

        // Create indexes for new fields
        await queryRunner.query(`
            CREATE INDEX "IDX_users_is_investor_agent" ON "users" ("is_investor_agent");
            CREATE INDEX "IDX_users_reputation_score" ON "users" ("reputation_score");
        `);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Remove indexes
        await queryRunner.query(`DROP INDEX "IDX_users_reputation_score"`);
        await queryRunner.query(`DROP INDEX "IDX_users_is_investor_agent"`);

        // Remove columns
        await queryRunner.query(`
            ALTER TABLE "users"
            DROP COLUMN "total_flags_resolved",
            DROP COLUMN "total_flags_submitted",
            DROP COLUMN "reputation_score",
            DROP COLUMN "investor_agent_since",
            DROP COLUMN "is_investor_agent";
        `);

        // Note: Cannot remove enum values in PostgreSQL without recreating the enum
        // This would require more complex migration with data preservation
    }
}