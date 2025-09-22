import { MigrationInterface, QueryRunner, Table, Index, ForeignKey } from "typeorm";

export class MonitoringSystem1704067200000 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create flags table
        await queryRunner.createTable(new Table({
            name: "flags",
            columns: [
                {
                    name: "id",
                    type: "integer",
                    isPrimary: true,
                    isGenerated: true,
                    generationStrategy: "increment"
                },
                {
                    name: "type",
                    type: "enum",
                    enum: ["suspicious_activity", "document_discrepancy", "financial_irregularity", "milestone_delay", "communication_issue", "legal_concern", "other"]
                },
                {
                    name: "status",
                    type: "enum",
                    enum: ["pending", "under_review", "resolved", "dismissed", "escalated"],
                    default: "'pending'"
                },
                {
                    name: "severity",
                    type: "enum",
                    enum: ["low", "medium", "high", "critical"],
                    default: "'medium'"
                },
                {
                    name: "title",
                    type: "varchar",
                    length: "255"
                },
                {
                    name: "description",
                    type: "text"
                },
                {
                    name: "evidence",
                    type: "json",
                    isNullable: true
                },
                {
                    name: "admin_notes",
                    type: "text",
                    isNullable: true
                },
                {
                    name: "resolution_notes",
                    type: "text",
                    isNullable: true
                },
                {
                    name: "is_anonymous",
                    type: "boolean",
                    default: false
                },
                {
                    name: "upvotes",
                    type: "integer",
                    default: 0
                },
                {
                    name: "downvotes",
                    type: "integer",
                    default: 0
                },
                {
                    name: "asset_id",
                    type: "integer"
                },
                {
                    name: "flagger_id",
                    type: "integer"
                },
                {
                    name: "assigned_admin_id",
                    type: "integer",
                    isNullable: true
                },
                {
                    name: "created_at",
                    type: "timestamp",
                    default: "CURRENT_TIMESTAMP"
                },
                {
                    name: "updated_at",
                    type: "timestamp",
                    default: "CURRENT_TIMESTAMP",
                    onUpdate: "CURRENT_TIMESTAMP"
                }
            ]
        }), true);

        // Create flag_votes table
        await queryRunner.createTable(new Table({
            name: "flag_votes",
            columns: [
                {
                    name: "id",
                    type: "integer",
                    isPrimary: true,
                    isGenerated: true,
                    generationStrategy: "increment"
                },
                {
                    name: "vote_type",
                    type: "enum",
                    enum: ["upvote", "downvote"]
                },
                {
                    name: "flag_id",
                    type: "integer"
                },
                {
                    name: "voter_id",
                    type: "integer"
                },
                {
                    name: "created_at",
                    type: "timestamp",
                    default: "CURRENT_TIMESTAMP"
                }
            ]
        }), true);

        // Create indexes
        await queryRunner.createIndex("flags", new Index("IDX_flags_asset_id", ["asset_id"]));
        await queryRunner.createIndex("flags", new Index("IDX_flags_flagger_id", ["flagger_id"]));
        await queryRunner.createIndex("flags", new Index("IDX_flags_status", ["status"]));
        await queryRunner.createIndex("flags", new Index("IDX_flags_type", ["type"]));
        await queryRunner.createIndex("flags", new Index("IDX_flags_severity", ["severity"]));
        await queryRunner.createIndex("flags", new Index("IDX_flags_created_at", ["created_at"]));

        await queryRunner.createIndex("flag_votes", new Index("IDX_flag_votes_flag_id", ["flag_id"]));
        await queryRunner.createIndex("flag_votes", new Index("IDX_flag_votes_voter_id", ["voter_id"]));
        await queryRunner.createIndex("flag_votes", new Index("IDX_flag_votes_unique", ["flag_id", "voter_id"], { isUnique: true }));

        // Create foreign keys
        await queryRunner.createForeignKey("flags", new ForeignKey({
            columnNames: ["asset_id"],
            referencedTableName: "assets",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));

        await queryRunner.createForeignKey("flags", new ForeignKey({
            columnNames: ["flagger_id"],
            referencedTableName: "users",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));

        await queryRunner.createForeignKey("flags", new ForeignKey({
            columnNames: ["assigned_admin_id"],
            referencedTableName: "users",
            referencedColumnNames: ["id"],
            onDelete: "SET NULL"
        }));

        await queryRunner.createForeignKey("flag_votes", new ForeignKey({
            columnNames: ["flag_id"],
            referencedTableName: "flags",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));

        await queryRunner.createForeignKey("flag_votes", new ForeignKey({
            columnNames: ["voter_id"],
            referencedTableName: "users",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable("flag_votes");
        await queryRunner.dropTable("flags");
    }
}