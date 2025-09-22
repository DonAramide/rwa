import { MigrationInterface, QueryRunner, Table, Index, ForeignKey } from "typeorm";

export class VerificationRequestSystem1704067400000 implements MigrationInterface {

    public async up(queryRunner: QueryRunner): Promise<void> {
        // Create verification_requests table
        await queryRunner.createTable(new Table({
            name: "verification_requests",
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
                    enum: ["asset_inspection", "document_verification", "financial_audit", "compliance_check", "site_visit", "condition_assessment", "ownership_verification", "valuation_check"]
                },
                {
                    name: "status",
                    type: "enum",
                    enum: ["pending", "assigned", "in_progress", "submitted", "approved", "rejected", "cancelled", "disputed"],
                    default: "'pending'"
                },
                {
                    name: "urgency",
                    type: "enum",
                    enum: ["low", "medium", "high", "urgent"],
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
                    name: "requirements",
                    type: "json",
                    isNullable: true
                },
                {
                    name: "location",
                    type: "json",
                    isNullable: true
                },
                {
                    name: "budget",
                    type: "decimal",
                    precision: 10,
                    scale: 2
                },
                {
                    name: "currency",
                    type: "varchar",
                    length: "3",
                    default: "'USD'"
                },
                {
                    name: "deadline",
                    type: "timestamp",
                    isNullable: true
                },
                {
                    name: "deliverables",
                    type: "json",
                    isNullable: true
                },
                {
                    name: "notes",
                    type: "text",
                    isNullable: true
                },
                {
                    name: "asset_id",
                    type: "integer"
                },
                {
                    name: "requester_id",
                    type: "integer"
                },
                {
                    name: "assigned_verifier_id",
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

        // Create verification_proposals table
        await queryRunner.createTable(new Table({
            name: "verification_proposals",
            columns: [
                {
                    name: "id",
                    type: "integer",
                    isPrimary: true,
                    isGenerated: true,
                    generationStrategy: "increment"
                },
                {
                    name: "proposed_price",
                    type: "decimal",
                    precision: 10,
                    scale: 2
                },
                {
                    name: "currency",
                    type: "varchar",
                    length: "3",
                    default: "'USD'"
                },
                {
                    name: "proposal_message",
                    type: "text"
                },
                {
                    name: "estimated_completion",
                    type: "timestamp"
                },
                {
                    name: "methodology",
                    type: "json",
                    isNullable: true
                },
                {
                    name: "is_accepted",
                    type: "boolean",
                    default: false
                },
                {
                    name: "request_id",
                    type: "integer"
                },
                {
                    name: "verifier_id",
                    type: "integer"
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

        // Create verification_reports table
        await queryRunner.createTable(new Table({
            name: "verification_reports",
            columns: [
                {
                    name: "id",
                    type: "integer",
                    isPrimary: true,
                    isGenerated: true,
                    generationStrategy: "increment"
                },
                {
                    name: "title",
                    type: "varchar",
                    length: "255"
                },
                {
                    name: "summary",
                    type: "text"
                },
                {
                    name: "findings",
                    type: "json"
                },
                {
                    name: "photos",
                    type: "json",
                    isNullable: true
                },
                {
                    name: "documents",
                    type: "json",
                    isNullable: true
                },
                {
                    name: "gps_data",
                    type: "json",
                    isNullable: true
                },
                {
                    name: "is_approved",
                    type: "boolean",
                    default: false
                },
                {
                    name: "reviewer_notes",
                    type: "text",
                    isNullable: true
                },
                {
                    name: "reviewed_at",
                    type: "timestamp",
                    isNullable: true
                },
                {
                    name: "request_id",
                    type: "integer"
                },
                {
                    name: "verifier_id",
                    type: "integer"
                },
                {
                    name: "reviewer_id",
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

        // Create indexes
        await queryRunner.createIndex("verification_requests", new Index("IDX_verification_requests_asset_id", ["asset_id"]));
        await queryRunner.createIndex("verification_requests", new Index("IDX_verification_requests_requester_id", ["requester_id"]));
        await queryRunner.createIndex("verification_requests", new Index("IDX_verification_requests_assigned_verifier_id", ["assigned_verifier_id"]));
        await queryRunner.createIndex("verification_requests", new Index("IDX_verification_requests_status", ["status"]));
        await queryRunner.createIndex("verification_requests", new Index("IDX_verification_requests_type", ["type"]));
        await queryRunner.createIndex("verification_requests", new Index("IDX_verification_requests_urgency", ["urgency"]));
        await queryRunner.createIndex("verification_requests", new Index("IDX_verification_requests_created_at", ["created_at"]));

        await queryRunner.createIndex("verification_proposals", new Index("IDX_verification_proposals_request_id", ["request_id"]));
        await queryRunner.createIndex("verification_proposals", new Index("IDX_verification_proposals_verifier_id", ["verifier_id"]));
        await queryRunner.createIndex("verification_proposals", new Index("IDX_verification_proposals_unique", ["request_id", "verifier_id"], { isUnique: true }));

        await queryRunner.createIndex("verification_reports", new Index("IDX_verification_reports_request_id", ["request_id"]));
        await queryRunner.createIndex("verification_reports", new Index("IDX_verification_reports_verifier_id", ["verifier_id"]));

        // Create foreign keys
        await queryRunner.createForeignKey("verification_requests", new ForeignKey({
            columnNames: ["asset_id"],
            referencedTableName: "assets",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));

        await queryRunner.createForeignKey("verification_requests", new ForeignKey({
            columnNames: ["requester_id"],
            referencedTableName: "users",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));

        await queryRunner.createForeignKey("verification_requests", new ForeignKey({
            columnNames: ["assigned_verifier_id"],
            referencedTableName: "users",
            referencedColumnNames: ["id"],
            onDelete: "SET NULL"
        }));

        await queryRunner.createForeignKey("verification_proposals", new ForeignKey({
            columnNames: ["request_id"],
            referencedTableName: "verification_requests",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));

        await queryRunner.createForeignKey("verification_proposals", new ForeignKey({
            columnNames: ["verifier_id"],
            referencedTableName: "users",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));

        await queryRunner.createForeignKey("verification_reports", new ForeignKey({
            columnNames: ["request_id"],
            referencedTableName: "verification_requests",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));

        await queryRunner.createForeignKey("verification_reports", new ForeignKey({
            columnNames: ["verifier_id"],
            referencedTableName: "users",
            referencedColumnNames: ["id"],
            onDelete: "CASCADE"
        }));

        await queryRunner.createForeignKey("verification_reports", new ForeignKey({
            columnNames: ["reviewer_id"],
            referencedTableName: "users",
            referencedColumnNames: ["id"],
            onDelete: "SET NULL"
        }));
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable("verification_reports");
        await queryRunner.dropTable("verification_proposals");
        await queryRunner.dropTable("verification_requests");
    }
}