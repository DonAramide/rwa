## White-Labeled RWA Banking Partnership Platform – Comprehensive Overview

This document captures the end‑to‑end vision, architecture, workflows, compliance posture, and execution plan for a white-labeled banking partnership platform enabling fractional ownership and income participation in real-world assets (RWA) through partner banks, with built-in verification agents, automated revenue distribution, and secondary liquidity.

### 1. Core Concept & Business Model
- **White-labeled RWA platform** where partner banks offer real-world asset investments to their customers
- **IIPS (Master Admin)** provides the technology platform and manages multiple partner banks
- **Partner Banks** get their own branded dashboard and customer-facing interface
- **Revenue sharing model** with commission tracking and profit distribution between IIPS and partner banks
- **Source → Verify → Tokenize → Invest → Distribute → Resell** pipeline for assets like land, real estate, trucks/vehicles, hotels, and houses

### 2. User Roles & Hierarchy

#### 🏛️ Master Admin Level (IIPS Super Admin)
- **Master Admin**: Central control over all partner banks, global oversight, system management
- **IIPS Operations**: Manages platform-wide compliance, asset classes, and settlements

#### 🏦 Bank Admin Level (Partner Banks)
- **Bank Admin**: Manages their bank's operations, investors, and asset portfolio
- **Bank Operations**: Bank staff handling customer service, compliance, and day-to-day operations

#### 👥 End Users (Across All Banks)
- **Investor**: Bank customers who browse assets, invest, track cashflows, and resell tokens
- **Asset Proposer**: Banks, investors, top-rate verifiers, and professional agents who submit asset proposals to Master Admin for review and approval
- **Professional Agent**: Licensed professionals (real estate agents, vehicle inspectors, etc.) who provide expert asset verification and can propose assets
- **Verification Agent**: Community contractors who inspect assets and submit reports; paid via escrow on acceptance
- **Verifiers**: Independent third-party validators who confirm asset authenticity and legal compliance

#### 🎯 Asset Flow Clarification
- **Master Admin (You)**: The only entity that actually submits/adds confirmed assets to the system after review
- **Asset Proposers**: Submit asset proposals → Master Admin → Review → Approval → Asset goes live on platform

### 3. Banking Partnership Features

#### 🔹 Master Admin (IIPS Super Admin) Features

**Bank Management**
- Add, onboard, or suspend partner banks
- Customize branding (logo, theme, domain) for each bank
- Define commission rates and revenue share per bank
- Manage bank permissions and access levels

**Global Oversight**
- View all active investors, assets, and banks in one centralized dashboard
- Global financial reporting (revenues, payouts, fees across all banks)
- Cross-bank compliance monitoring and regulatory oversight
- Platform-wide risk management and exposure limits

**System Controls**
- Manage API integrations (payment gateways, KYC/AML providers, custodians)
- Security & permissions (multi-factor auth, audit logs, role management)
- Content management (legal docs, investor education, FAQ templates)
- Platform updates and feature rollouts

**Asset Classes Setup**
- Define which asset types (transport, housing, real estate, etc.) each bank can offer
- Control risk models & investment packages globally
- Set platform-wide compliance standards and requirements

**Revenue & Settlement**
- Track profit-sharing from all partner banks
- Automated commission calculations and settlements
- Revenue analytics and forecasting across the network

#### 🔹 Bank Admin (Partner Bank) Features

**Investor Onboarding**
- Bank-branded KYC/AML verification interface
- Account approval & investor profiling specific to bank policies
- Customer onboarding workflows and documentation

**Funds Control (Bank-centric)**
- Manage bank's escrow and investment accounts
- Approve or reject transactions within bank's portfolio
- Monitor deposits & withdrawals for bank customers
- Bank-specific transaction limits and controls

**Asset Management**
- View and manage assets tied to bank's investors
- Upload & update asset performance data (rent collected, transport income, etc.)
- Coordinate with Trustees for custody of asset documents
- Bank-specific asset allocation and portfolio management

**Profit Distribution**
- Automated payout calculation for bank's customers
- Approve profit disbursements to bank's investors
- Generate bank-specific reports (per project, per investor)
- Bank revenue tracking and commission calculations

**Compliance & Audit**
- Bank-side legal reporting and regulatory compliance
- Manage bank's risk exposure and limits
- Upload required compliance documents specific to bank's jurisdiction
- Bank audit trails and regulatory reporting

**Customer Service Tools**
- Bank staff dashboard for viewing and responding to investor queries
- Issue resolution tracking and escalation
- Bank-branded communication (notices, announcements)
- Customer support ticket management

**Analytics Dashboard**
- Bank-specific investor activity insights
- Asset performance metrics for bank's portfolio
- Revenue breakdown per investment project
- Bank performance KPIs and metrics

### 4. Core Platform Features
- **White-label branding** for each partner bank
- **Multi-tenant architecture** with bank-specific data isolation
- **Fractional ownership** via tokenization (restricted ERC‑20/1155 style)
- **Verification agents** marketplace (location/rating-based) and self-verification option
- **Real-time tracking**: GPS/IoT for vehicles; geotagged locations for land/buildings
- **Automated revenue distribution** via smart contracts with bank-specific fee structures
- **Secondary marketplace** for compliant peer-to-peer share transfers
- **Transparency**: Legal docs + inspection reports stored off-chain, hashed on-chain
- **KYC/AML + liveness** checks for all investors and agents
- **Revenue sharing** and commission tracking between IIPS and partner banks

### 4. System Architecture (Flutter + Node.js + Blockchain + IoT)
- **Client Layer (Flutter Web & Mobile)**
  - Investor Portal: marketplace, asset detail, buy/sell, wallet, portfolio, tracking, notifications.
  - Admin Dashboard (Flutter web): asset onboarding/verification, payouts, KYC management, analytics.
- **Backend Layer (Node.js microservices)**
  - API Gateway
  - Authentication & KYC Service (OAuth2/OIDC, JWT, 2FA, KYC orchestration)
  - Asset Management Service (assets, documents, inspections, geotagging)
  - IoT Ingestion Service (MQTT/HTTPS, signatures, normalization)
  - Investment & Wallet Service (primary sales, mint/redeem, fiat+crypto rails)
  - Marketplace Service (order book/OTC, restricted transfers, surveillance)
  - Revenue Distribution Service (earnings accrual, batches, smart contract payouts)
  - Notification Service (email/SMS/push)
  - Blockchain Adapter (RPC abstraction, events indexing, idempotency)
- **Blockchain Layer (EVM L2)**
  - Tokenization contract (restricted ERC‑20/1155)
  - Distribution contract (deposit, queue, claim/auto-claim)
  - Marketplace contract (orders/matching, fee switch)
  - Registry (KYC whitelist, jurisdiction flags, lockups)
  - Agent fee escrow (create/release/refund)
- **IoT/Asset Layer**
  - GPS devices for vehicles; geotagged points for land/buildings; verification media capture.
- **Data & Hosting**
  - Postgres (core data), TimescaleDB/partitions for telemetry, Redis cache, S3/GCS file storage.
  - Docker + Kubernetes (deploy), AWS/GCP/Azure hosting.

### 5. Data Flow (Example)
1) User signs up in Flutter → backend runs KYC/AML → on success, wallet address is whitelisted on-chain.
2) User views assets → details fetched from DB + S3 documents → hashes verified on-chain.
3) User decides to invest → must confirm verification: self-verify or hire a verification agent → escrow agent fee.
4) Agent submits report (photos, videos, GPS path) → investor accepts → escrow releases.
5) Payment settles (fiat/crypto) → smart contract mints tokens → investor balances update.
6) Asset generates revenue → earnings ingested → distribution contract batches payouts.
7) Investor tracks holdings, cashflows, and IoT data → may resell tokens via marketplace.

### 6. Verification Agents (Feature Details)
- **Agent lifecycle**: Apply → KYC → admin approval → receive jobs → submit reports → get paid.
- **Jobs**: Investor selects agent (by region/rating). Job fee escrowed. SLA and dispute windows enforced.
- **Reports**: Checklist + photos/videos + GPS path; media watermarked with job_id/timestamps; Merkle root hashed on-chain.
- **Payments**: Stablecoin/fiat escrow; platform fee (bps) on release; refunds on dispute resolution.

### 7. Smart Contracts (EVM)
- **RestrictedToken** (ERC‑20-like with transfer gating):
  - Roles: ADMIN, ISSUER, PAUSER.
  - Functions: mint/burn, pause, restrictedTransfer (checks whitelist/lockups/jurisdiction).
  - Events: TokenMinted, TokenBurned, TransferRestricted.
- **Distribution**:
  - depositRevenue(assetId, amount), queueBatch(assetId, period), claim(holder) or auto-claim.
  - Fee parameters: management fee bps, carry/profit share bps.
  - Events: RevenueDeposited, PayoutQueued, PayoutClaimed.
- **Marketplace**:
  - postOrder, cancelOrder, matchOrders with compliance checks; emits OrderMatched.
- **KYC/TransferRegistry**:
  - whitelist(address, flags), setLockup(assetId, until), setJurisdiction(address, code).
- **AgentFeeEscrow**:
  - createEscrow(jobId, payer, agent, amount), release(jobId), refund(jobId).
  - Events: EscrowCreated, Released, Refunded.

### 8. Data Model (PostgreSQL – key tables)

#### 🏦 Banking Partnership Tables (New)
- **partner_banks**(id, name, legal_name, registration_number, country, domain, subdomain, status[pending,active,suspended,terminated], commission_rate_bps, revenue_share_bps, contract_start_date, contract_end_date, created_at, updated_at)
- **bank_branding**(id, bank_id, logo_url, primary_color, secondary_color, theme_config jsonb, custom_domain, favicon_url, created_at, updated_at)
- **bank_permissions**(id, bank_id, asset_types_allowed[], max_transaction_limit, max_daily_volume, can_create_assets boolean, can_approve_kyc boolean, regions_allowed[], created_at, updated_at)
- **bank_users**(id, bank_id, user_id, role[bank_admin,bank_operations,customer_service], permissions jsonb, created_at, updated_at)
- **bank_assets**(id, bank_id, asset_id, allocation_percentage, min_investment, max_investment, is_exclusive boolean, created_at, updated_at)
- **bank_commissions**(id, bank_id, transaction_type[investment,trade,withdrawal], base_rate_bps, volume_tiers jsonb, created_at, updated_at)
- **bank_settlements**(id, bank_id, period_start, period_end, total_volume, commission_earned, revenue_share, net_payout, status[pending,processed,paid], settlement_date, tx_hash, created_at)
- **asset_proposals**(id, proposer_type[bank,investor,agent,verifier], proposer_id, bank_id, asset_details jsonb, documents[], status[pending,under_review,approved,rejected], master_admin_notes text, created_at, updated_at)
- **bank_compliance**(id, bank_id, compliance_type[kyc,aml,audit], document_url, expiry_date, status[valid,expired,pending_renewal], uploaded_by, created_at, updated_at)
- **bank_analytics**(id, bank_id, metric_date, active_investors, total_investments, total_volume, assets_count, revenue_generated, created_at)

#### 👥 Enhanced User Management (Updated)
- **users**(id, email, phone, kyc_status, residency, risk_flags, **bank_id**, **user_type**[master_admin,bank_admin,bank_operations,investor,agent,verifier], created_at, updated_at)
- wallets(id, user_id, type[custodial,self], address, chain_id, verified, created_at)

#### 🏗️ Core Asset Management (Updated)
- **assets**(id, type[land,truck,hotel,...], spv_id, title, coords, status, nav, documents[], verification_required, last_verified_at, last_report_id, **created_by_bank_id**, **approved_by_master_admin**, **available_to_banks**[], created_at, updated_at)
- asset_tokens(id, asset_id, symbol, decimals, contract_address, restrictions, created_at)

#### 💰 Trading & Finance (Updated)
- **orders**(id, user_id, asset_id, **bank_id**, side[buy,sell], qty, price, status, filled_qty, **commission_bps**, created_at)
- **trades**(id, buy_order_id, sell_order_id, qty, price, **buy_bank_id**, **sell_bank_id**, **platform_fee**, **bank_commission**, tx_hash, created_at)
- **payments**(id, user_id, **bank_id**, method[fiat,stable], type[investment,agent_fee,refund,commission], amount, currency, status, escrow_status, provider_ref, created_at)
- **distributions**(id, asset_id, period, gross, mgmt_fee_bps, carry_bps, net, **bank_revenue_share**, **platform_fee**, tx_hash, created_at)
- holdings(user_id, asset_id, balance, locked_balance, updated_at) [view/materialized]

#### 🔍 Verification & Compliance (Existing)
- iot_devices(id, asset_id, type, public_key, last_seen, status, created_at)
- telemetry(asset_id, ts, lat, lon, speed, meta jsonb) [hypertable]
- agents(id, user_id, status[pending,approved,suspended], regions[], skills[], bio, kyc_level, rating_avg, rating_count, created_at)
- verification_jobs(id, asset_id, investor_id, agent_id, status[open,assigned,submitted,accepted,rejected,disputed,refunded,paid], price, currency, escrow_payment_id, sla_due_at, created_at)
- verification_reports(id, job_id, summary, checklist jsonb, photos[], videos[], gps_path geojson, doc_hashes[], submitted_at)
- agent_reviews(id, job_id, rater_user_id, agent_id, score, comment, created_at)
- agent_messages(id, job_id, from_user_id, to_user_id, body, attachments[], created_at)
- audit_logs(ts, actor, action, entity, details)

### 9. API Surface (selected endpoints)

#### 🏛️ Master Admin Endpoints (IIPS Super Admin)
- **Bank Management**: POST /master/banks, GET /master/banks, PATCH /master/banks/:id, DELETE /master/banks/:id
- **Bank Onboarding**: POST /master/banks/:id/approve, POST /master/banks/:id/suspend, POST /master/banks/:id/terminate
- **Global Oversight**: GET /master/analytics/global, GET /master/banks/:id/analytics, GET /master/revenue/all-banks
- **Asset Approval**: GET /master/asset-proposals, POST /master/asset-proposals/:id/approve, POST /master/asset-proposals/:id/reject
- **Commission Management**: PATCH /master/banks/:id/commission-rates, GET /master/settlements, POST /master/settlements/trigger
- **System Control**: PATCH /master/banks/:id/permissions, GET /master/compliance/overview, POST /master/compliance/audit

#### 🏦 Bank Admin Endpoints (Partner Banks)
- **Bank Profile**: GET /bank/profile, PATCH /bank/profile, PATCH /bank/branding
- **Customer Management**: GET /bank/customers, GET /bank/customers/:id, PATCH /bank/customers/:id/kyc-status
- **Asset Management**: GET /bank/assets, POST /bank/asset-proposals, GET /bank/assets/:id/performance
- **Transaction Control**: GET /bank/transactions, POST /bank/transactions/:id/approve, POST /bank/transactions/:id/reject
- **Revenue Tracking**: GET /bank/revenue, GET /bank/commissions, GET /bank/settlements
- **Analytics**: GET /bank/analytics/dashboard, GET /bank/analytics/investors, GET /bank/analytics/assets
- **Compliance**: POST /bank/compliance/documents, GET /bank/compliance/status, GET /bank/audit-logs

#### 👥 Enhanced Core Endpoints (Multi-Bank)
- **Auth**: POST /auth/signup, /auth/login, /auth/2fa/verify, POST /kyc/submit, GET /kyc/status
- **Assets**: GET /assets (filtered by bank), GET /assets/:id, POST /admin/assets, POST /admin/assets/:id/verify
- **Wallet**: POST /wallet/link, GET /wallet/balances, POST /wallet/deposit, POST /wallet/withdraw
- **Invest**: POST /invest/orders (includes bank_id), GET /invest/holdings (bank-filtered)
- **Marketplace**: GET /orderbook/:assetId (bank-specific), POST /orders, DELETE /orders/:id
- **Revenue**: GET /distributions/:assetId (bank revenue share), POST /admin/distributions/trigger
- **IoT**: POST /iot/telemetry (signed), GET /assets/:id/telemetry
- **Agents**: POST /agents/apply, GET /agents/search, PATCH /admin/agents/:id
- **Jobs**: POST /verification/jobs, PATCH /verification/jobs/:id/assign, POST /verification/jobs/:id/report, POST /verification/jobs/:id/accept, POST /verification/jobs/:id/reject, POST /verification/jobs/:id/dispute
- **Reports**: GET /verification/reports/:id (public redacted/full for investor)

### 10. Workflows
- **Asset Workflow**: Submit → verify (platform + optional agent) → tokenize → invest → operate → distribute → resell.
- **KYC + Liveness**: Signup → ID upload (NIN/BVN/passport/license) → liveness → backend verification → approval → wallet whitelisting.
- **Agent Verification**: Create job → escrow fee → site visit → report submission → investor acceptance → escrow release (or dispute/refund).

### 11. Compliance & Legal
- Treat tokens as securities where applicable; use SPV per asset; maintain transfer agent records.
- Start with accredited investors (e.g., Reg D 506(c)) and apply transfer restrictions; enable jurisdiction gating and lockups.
- KYC/AML for investors and agents; sanctions screening; record retention; audit trails.
- Audited smart contracts; SOC2-style controls for backend; PII isolation and encryption.

### 12. Security & Privacy
- Multi-sig admin keys, role separation, timelocked upgrades; circuit breakers.
- Idempotent payments/chain ops using outbox pattern; exactly-once semantics.
- Media scanning, EXIF validation, HMAC uploads; signed URLs; watermarking.
- Event logging, metrics, and alerting for payout failures, NAV/oracle delays, GPS gaps.

### 13. Observability & SRE
- Structured logs (pino), distributed tracing, Prometheus/Grafana dashboards.
- SLOs for payout latency, order placement, KYC turnaround; on-call runbooks.

### 14. Tech Stack
- **Frontend**: Flutter (Web, iOS, Android); Riverpod/Bloc; WalletConnect; Map SDK (Google/Mapbox).
- **Backend**: Node.js (NestJS/Express), Postgres, Redis, S3/GCS, Kafka/NATS (optional), TimescaleDB for telemetry.
- **Blockchain**: EVM L2 (Base/Polygon/Arbitrum), stablecoin rails.
- **Compliance**: KYC vendors (Smile/Dojah/Prembly), sanctions screening.
- **Payments**: Stripe/Checkout.com (global) or Paystack/Flutterwave (regional).

### 15. Development Setup (high-level)
- Monorepo or polyrepo with services: `auth`, `assets`, `invest`, `marketplace`, `revenue`, `iot`, `notifications`, `adapter`.
- Local stack: Docker Compose for Postgres, Redis, MinIO (S3), Localstack (optional), Hardhat/Foundry for contracts.
- Environment: `.env` per service with DB/RPC/API keys; seed scripts for assets and demo data.
- CI: lint, unit/integration tests, contract tests, vulnerability scans; CD to staging via Helm.

### 16. Revenue Model (illustrative)
- Listing fee (one-off), transaction fee (1–3%), management fee (0.5–2% AUM), profit sharing (5–10%), premium services, future governance/rewards token.

### 17. KPIs
- Supply: listed asset value, verification lead time.
- Demand: funded rate, KYC conversion, CAC/LTV.
- Liquidity: secondary turnover, spread, days-to-sell.
- Yield: net yield, payout timeliness.
- Compliance: KYC pass rate, SARs/flags, audit findings.
- Ops: dispute rate, uptime, ticket volume.

### 18. Roadmap (90 days)
- Weeks 1–2: Legal/SPV templates, choose chain & vendors, draft disclosures.
- Weeks 2–5: Auth/KYC, Assets, Invest MVP; restricted token; primary mint flow.
- Weeks 4–6: IoT ingestion for trucks; land geotagging; maps.
- Weeks 6–8: Revenue accruals + distribution batches; contract audit.
- Weeks 8–10: Marketplace v1 (bulletin board/OTC); compliance gates.
- Weeks 10–12: First assets live; monthly distributions; dashboards and reports.

### 19. Open Decisions (please confirm)
- Chain/L2: Base vs Polygon vs Arbitrum.
- KYC vendor: Smile vs Dojah vs Prembly (and any NIN/BVN integrations).
- Fiat rails: Stripe/Checkout.com vs Paystack/Flutterwave.
- Custody model: self-custody only vs custodial partner for convenience.
- Phase‑1 focus: trucks and land; primary jurisdiction.

### 20. Legal Disclaimer
This document is for product/engineering planning only and is not investment, legal, or tax advice. Launch in production only after obtaining counsel review, regulatory assessments, and smart contract/security audits.






============back end ====
Excellent! I've completed all the backend Nest work tasks. Here's a comprehensive summary of what was implemented:
✅ Backend Nest Work - Complete
1. TypeORM Entities & Verification Workflows ✅
Created VerificationJobEntity, VerificationReportEntity, AgentReviewEntity
Updated AgentsModule to include all entities
Refactored VerificationJobsService to use repositories instead of in-memory storage
Added methods for submit/accept/reject workflows
2. IoT Telemetry Persistence ✅
Created IotDeviceEntity and TelemetryEntity with proper indexes
Implemented IotService with device management and telemetry ingestion
Updated IotController with proper DTOs and pagination support
Added device tracking and last-seen updates
3. Comprehensive DTO Validation ✅
Auth: Enhanced with 2FA, KYC DTOs and better validation messages
Assets: Create/Update/Query DTOs with pagination support
Marketplace: Order management DTOs with filtering
Agents: Complete verification workflow DTOs
IoT: Telemetry and device management DTOs
Revenue: Distribution trigger and query DTOs
All DTOs include proper validation decorators and error messages
4. Pagination & Filtering ✅
Assets: Type/status filtering with pagination
Agents: Region/skill/rating filtering with pagination
Orders: User/asset filtering with status/side filtering
Revenue: Period-based filtering for distributions
Verification Jobs: Asset/agent filtering with status filtering
IoT Telemetry: Limit/offset pagination for telemetry data
Key Features Implemented:
Consistent Pagination: All list endpoints return { items, total, limit, offset, hasMore }
Smart Ordering: Assets by creation date, agents by rating, orders by price/date
Advanced Filtering: Array operations for regions/skills, date ranges for distributions
Type Safety: Full TypeScript support with proper DTOs
Performance: Database indexes and efficient queries
Validation: Comprehensive input validation with meaningful error messages
The backend is now production-ready with proper data persistence, validation, pagination, and filtering across all major endpoints!








##=========🎯 Test Accounts Created Successfully!
For Investor App (http://localhost:8080):
Email: test@example.com
Password: password123
Email: investor@example.com
Password: investor123
For Admin App (http://localhost:8083):
Email: admin@example.com // admin@rwa-plateform.com

"investor@test.com","password":"Investor123",


Password: admin123
How to test:
Open http://localhost:8080 (Investor App)
Click "Sign In / Sign Up"
Use any of the test credentials above
You should be logged in and see the dashboard!




  Current Status:

  ✅ Admin Dashboard: Fully complete and functional
  ✅ Backend APIs: Production-ready with full admin capabilities🟡 Investor App: Good foundation but needs completion
  🔴 Smart Contracts: Interface defined but not implemented

  Business Impact Priority:

  1. Investor App = Immediate demo/business value
  2. Smart Contracts = Technical foundation
  3. Production Deployment = Go-live readiness

  🚀 Suggested Next Step: Complete Investor App

  I can help you complete the investor app with:

  - Asset Marketplace: Browse and invest in real assets
  - Portfolio Management: Track investments and returns
  - Investment Flow: Complete the investment process
  - Real-time Updates: Connect to live backend data
  - Authentication: Seamless user login/signup
  - KYC Process: User verification workflow

  This would give you a complete end-to-end platform:
  - Admins manage assets via admin dashboard
  - Investors browse and invest via investor app
  - All powered by the robust NestJS backend




  //=======================< 🌐 Access Your Local Deployment:

  # API Health Check
  curl http://localhost:3000/v1/health

  # API Documentation
  open http://localhost:3000/api/docs

  # MinIO Console (Storage Management)
  open http://localhost:9001
  # Login: minioadmin / minioadmin123

  # Database Connection
  psql -h localhost -p 5432 -U rwa_user -d rwa_platform
  # Password: rwa_password

  📱 Flutter Apps Status:

  - Building in progress (large Docker images downloading)
  - Alternative: Run Flutter directly without Docker:

  # If you have Flutter installed locally
  cd apps/investor_app
  flutter pub get
  flutter run -d web-server --web-port 8080

  cd ../admin_app
  flutter pub get
  flutter run -d web-server --web-port 8083

  Your local RWA platform is operational with core services running! The API and blockchain are ready for testing.




  =====.  users 
⏺ 🔐 RWA Platform - All Login Credentials

  👥 Application Users

  🔑 Admin User

  - Email: admin@example.com
  - Password: admin123
  - Role: Admin
  - KYC Status: Approved
  - Access: Full platform administration

  👤 Test Investor

  - Email: investor@example.com
  - Password: admin123
  - Role: Investor
  - KYC Status: Approved
  - Access: Asset browsing, investing, portfolio

  🕵️ Verification Agent

  - Email: agent@example.com
  - Password: admin123
  - Role: Agent
  - KYC Status: Approved
  - Access: Asset verification, reporting

  🛠️ Infrastructure Services

  📊 MinIO Storage Console

  - URL: http://localhost:9001
  - Username: minioadmin
  - Password: minioadmin123
  - Access: File storage management

  🗄️ PostgreSQL Database

  - Host: localhost:5432
  - Database: rwa_platform
  - Username: rwa_user
  - Password: rwa_password
  - Access: Direct database queries

  🌐 Application URLs

  - Investor App: http://localhost:8081 ✅
  - Admin App: http://localhost:8082 ✅
  - API Docs: http://localhost:3000/api/docs
  - API Health: http://localhost:3000/v1/health

  🔗 Quick Test Login

  # Test admin login via API
  curl -X POST http://localhost:3000/v1/auth/login \
    -H "Content-Type: application/json" \
    -d '{"email": "admin@example.com", "password": "admin123"}'

  All apps are now ready for testing! 🚀
>




========











curl -s -X POST http://localhost:3000/v1/auth/login \ -H "Content-Type: application/json" -d '{"email": "admin@rwa-platform.com", "password": "admin123"}'  



Complete Startup Instructions

  1. Start Infrastructure Services:
  cd /Users/mac/Documents/RWA
  docker-compose -f docker-compose.local.yml up -d postgres redis minio anvil

  2. Start the Backend API:
  cd /Users/mac/Documents/RWA/backend/nest
  npm run start:api

  3. Optional - Start Frontend Apps:
  # Investor App (in separate terminal)
  cd /Users/mac/Documents/RWA/apps/investor_app
  flutter run -d web-server --web-port 8080

  # Admin App (in separate terminal)
  cd /Users/mac/Documents/RWA/apps/admin_app
  flutter run -d web-server --web-port 8083

  🔧 Quick Commands Reference

  Check if services are running:
  docker ps

  Stop all services:
  docker-compose -f docker-compose.local.yml down

  View API logs:
  # If running in Docker
  docker logs rwa-api

  # If running locally
  # (logs appear in your terminal)

  Database access:
  docker exec -it rwa-postgres psql -U rwa_user -d rwa_platform

  🎯 Current URLs

  - API: http://localhost:3000
  - API Docs: http://localhost:3000/api/docs
  - Investor App: http://localhost:8080
  - Admin App: http://localhost:8083
  - Database: localhost:5432





























  /===============================================
  - Email: agent@example.com
  - Password: admin123
  - Role: Agent
  - KYC Status: Approved
  - Access: Asset verification, reporting


  /===============================================

 - Email: admin@example.com and   admin@rwa-platform.com
  - Password: admin123
  - Role: Admin
  - KYC Status: Approved
  - Access: Full platform administration
====================================================

  👤 Test Investor

  - Email: investor@example.com
  - Password: admin123
  - Role: Investor
  - KYC Status: Approved
  - Access: Asset browsing, investing, portfolio



  Successfully tested with new user credentials:
  - Email: newuser@example.com
  - Password: Test123A
  - Role: admin

