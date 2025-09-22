-- Seed data for RWA Investment Platform

-- Insert sample assets
INSERT INTO assets (id, type, title, description, nav, status, documents, verification_required, created_at) VALUES
('asset-001', 'land', 'Downtown Commercial Land - Austin, TX', 'Prime commercial land in downtown Austin, zoned for mixed-use development. Located near major tech companies and public transportation.', 2500000.00, 'active', '["deed.pdf", "survey.pdf", "zoning.pdf"]', true, NOW() - INTERVAL '30 days'),
('asset-002', 'truck', 'Fleet Truck #001 - Freightliner', '2022 Freightliner Cascadia with 150k miles. Currently leased to major logistics company with guaranteed monthly income.', 85000.00, 'active', '["title.pdf", "maintenance.pdf", "lease_agreement.pdf"]', true, NOW() - INTERVAL '25 days'),
('asset-003', 'hotel', 'Boutique Hotel - Miami Beach', '50-room boutique hotel in South Beach. Recently renovated with modern amenities and strong occupancy rates.', 12000000.00, 'active', '["property_deed.pdf", "financials.pdf", "occupancy_report.pdf"]', true, NOW() - INTERVAL '20 days'),
('asset-004', 'house', 'Luxury Villa - Malibu, CA', 'Oceanfront villa with 5 bedrooms, 3 bathrooms, and private beach access. Currently used as vacation rental.', 3500000.00, 'active', '["deed.pdf", "appraisal.pdf", "rental_history.pdf"]', true, NOW() - INTERVAL '15 days'),
('asset-005', 'land', 'Agricultural Land - Iowa', '500-acre corn and soybean farm with modern irrigation system. Multi-year lease agreement with local farmer.', 1800000.00, 'active', '["deed.pdf", "soil_report.pdf", "lease_agreement.pdf"]', true, NOW() - INTERVAL '10 days'),
('asset-006', 'truck', 'Fleet Truck #002 - Volvo', '2021 Volvo VNL with 120k miles. Equipped with advanced safety features and fuel-efficient engine.', 95000.00, 'pending', '["title.pdf", "inspection.pdf"]', true, NOW() - INTERVAL '5 days'),
('asset-007', 'hotel', 'Extended Stay Hotel - Dallas, TX', '120-room extended stay hotel near DFW airport. Consistent business traveler occupancy.', 8500000.00, 'active', '["deed.pdf", "financials.pdf", "market_analysis.pdf"]', true, NOW() - INTERVAL '3 days'),
('asset-008', 'house', 'Historic Brownstone - Brooklyn, NY', '4-story brownstone in Park Slope. Recently renovated with modern amenities while preserving historic character.', 2200000.00, 'suspended', '["deed.pdf", "renovation_permits.pdf", "appraisal.pdf"]', true, NOW() - INTERVAL '1 day');

-- Insert sample users (investors)
INSERT INTO users (id, email, first_name, last_name, phone, kyc_status, residency, created_at) VALUES
('user-001', 'john.doe@example.com', 'John', 'Doe', '+1-555-0101', 'approved', 'US', NOW() - INTERVAL '60 days'),
('user-002', 'jane.smith@example.com', 'Jane', 'Smith', '+1-555-0102', 'approved', 'US', NOW() - INTERVAL '45 days'),
('user-003', 'mike.wilson@example.com', 'Mike', 'Wilson', '+1-555-0103', 'pending', 'US', NOW() - INTERVAL '30 days'),
('user-004', 'sarah.johnson@example.com', 'Sarah', 'Johnson', '+1-555-0104', 'approved', 'CA', NOW() - INTERVAL '20 days'),
('user-005', 'david.brown@example.com', 'David', 'Brown', '+1-555-0105', 'approved', 'US', NOW() - INTERVAL '10 days');

-- Insert sample wallets
INSERT INTO wallets (id, user_id, type, address, chain_id, verified, created_at) VALUES
('wallet-001', 'user-001', 'self', '0x742d35Cc6634C0532925a3b8D0C4C4C4C4C4C4C4', 1, true, NOW() - INTERVAL '60 days'),
('wallet-002', 'user-002', 'self', '0x8ba1f109551bD432803012645Hac136c4C4C4C4C4', 1, true, NOW() - INTERVAL '45 days'),
('wallet-003', 'user-003', 'self', '0x9cA4315cC6634C0532925a3b8D0C4C4C4C4C4C4C4', 1, false, NOW() - INTERVAL '30 days'),
('wallet-004', 'user-004', 'self', '0x1dF6f109551bD432803012645Hac136c4C4C4C4C4', 1, true, NOW() - INTERVAL '20 days'),
('wallet-005', 'user-005', 'self', '0x2eA4315cC6634C0532925a3b8D0C4C4C4C4C4C4C4', 1, true, NOW() - INTERVAL '10 days');

-- Insert sample asset tokens
INSERT INTO asset_tokens (id, asset_id, symbol, decimals, contract_address, restrictions, created_at) VALUES
('token-001', 'asset-001', 'LAND001', 18, '0x1234567890123456789012345678901234567890', '{"transferRestricted": true, "kycRequired": true}', NOW() - INTERVAL '30 days'),
('token-002', 'asset-002', 'TRUCK001', 18, '0x2345678901234567890123456789012345678901', '{"transferRestricted": true, "kycRequired": true}', NOW() - INTERVAL '25 days'),
('token-003', 'asset-003', 'HOTEL001', 18, '0x3456789012345678901234567890123456789012', '{"transferRestricted": true, "kycRequired": true}', NOW() - INTERVAL '20 days'),
('token-004', 'asset-004', 'HOUSE001', 18, '0x4567890123456789012345678901234567890123', '{"transferRestricted": true, "kycRequired": true}', NOW() - INTERVAL '15 days'),
('token-005', 'asset-005', 'LAND002', 18, '0x5678901234567890123456789012345678901234', '{"transferRestricted": true, "kycRequired": true}', NOW() - INTERVAL '10 days');

-- Insert sample holdings
INSERT INTO holdings (user_id, asset_id, balance, locked_balance, updated_at) VALUES
('user-001', 'asset-001', 150.0, 0.0, NOW() - INTERVAL '25 days'),
('user-001', 'asset-002', 25.0, 0.0, NOW() - INTERVAL '20 days'),
('user-002', 'asset-003', 100.0, 0.0, NOW() - INTERVAL '15 days'),
('user-002', 'asset-004', 75.0, 0.0, NOW() - INTERVAL '10 days'),
('user-004', 'asset-005', 200.0, 0.0, NOW() - INTERVAL '5 days'),
('user-005', 'asset-001', 50.0, 0.0, NOW() - INTERVAL '3 days');

-- Insert sample distributions
INSERT INTO distributions (id, asset_id, period, gross, mgmt_fee_bps, carry_bps, net, tx_hash, created_at) VALUES
('dist-001', 'asset-001', '2024-01', 15000.00, 200, 100, 14550.00, '0xabc123...', NOW() - INTERVAL '5 days'),
('dist-002', 'asset-002', '2024-01', 8500.00, 200, 100, 8245.00, '0xdef456...', NOW() - INTERVAL '5 days'),
('dist-003', 'asset-003', '2024-01', 45000.00, 200, 100, 43650.00, '0xghi789...', NOW() - INTERVAL '5 days'),
('dist-004', 'asset-004', '2024-01', 12000.00, 200, 100, 11640.00, '0xjkl012...', NOW() - INTERVAL '5 days'),
('dist-005', 'asset-005', '2024-01', 18000.00, 200, 100, 17460.00, '0xmno345...', NOW() - INTERVAL '5 days');

-- Insert sample verification agents
INSERT INTO agents (id, user_id, status, regions, skills, bio, kyc_level, rating_avg, rating_count, created_at) VALUES
('agent-001', 'user-001', 'approved', '["TX", "CA", "NY"]', '["real_estate", "commercial"]', 'Licensed real estate inspector with 10+ years experience in commercial properties.', 'enhanced', 4.8, 45, NOW() - INTERVAL '60 days'),
('agent-002', 'user-002', 'approved', '["FL", "GA", "NC"]', '["hospitality", "tourism"]', 'Hotel and hospitality industry expert with extensive experience in property evaluation.', 'enhanced', 4.6, 32, NOW() - INTERVAL '45 days'),
('agent-003', 'user-003', 'pending', '["IA", "IL", "IN"]', '["agriculture", "land"]', 'Agricultural land specialist with deep knowledge of farming operations and land valuation.', 'basic', 0.0, 0, NOW() - INTERVAL '30 days'),
('agent-004', 'user-004', 'approved', '["CA", "NV", "AZ"]', '["vehicles", "logistics"]', 'Commercial vehicle inspector with expertise in fleet management and maintenance.', 'enhanced', 4.7, 28, NOW() - INTERVAL '20 days'),
('agent-005', 'user-005', 'approved', '["NY", "NJ", "CT"]', '["residential", "historic"]', 'Residential property specialist with focus on historic and luxury properties.', 'enhanced', 4.9, 38, NOW() - INTERVAL '10 days');

-- Insert sample verification jobs
INSERT INTO verification_jobs (id, asset_id, investor_id, agent_id, status, price, currency, sla_due_at, created_at) VALUES
('job-001', 'asset-001', 'user-001', 'agent-001', 'completed', 500.00, 'USD', NOW() - INTERVAL '25 days', NOW() - INTERVAL '30 days'),
('job-002', 'asset-002', 'user-002', 'agent-004', 'completed', 300.00, 'USD', NOW() - INTERVAL '20 days', NOW() - INTERVAL '25 days'),
('job-003', 'asset-003', 'user-001', 'agent-002', 'completed', 750.00, 'USD', NOW() - INTERVAL '15 days', NOW() - INTERVAL '20 days'),
('job-004', 'asset-004', 'user-002', 'agent-005', 'completed', 400.00, 'USD', NOW() - INTERVAL '10 days', NOW() - INTERVAL '15 days'),
('job-005', 'asset-005', 'user-004', 'agent-003', 'in_progress', 600.00, 'USD', NOW() + INTERVAL '2 days', NOW() - INTERVAL '5 days');

-- Insert sample verification reports
INSERT INTO verification_reports (id, job_id, summary, checklist, photos, videos, gps_path, doc_hashes, submitted_at) VALUES
('report-001', 'job-001', 'Property verified as described. All documents authentic. Location confirmed via GPS.', '{"title_verified": true, "location_confirmed": true, "condition_assessed": true}', '["photo1.jpg", "photo2.jpg", "photo3.jpg"]', '["video1.mp4"]', '{"type": "Point", "coordinates": [-97.7431, 30.2672]}', '["hash1", "hash2", "hash3"]', NOW() - INTERVAL '25 days'),
('report-002', 'job-002', 'Vehicle in excellent condition. All maintenance records verified. Current location confirmed.', '{"vehicle_condition": true, "maintenance_verified": true, "location_confirmed": true}', '["truck1.jpg", "truck2.jpg", "engine.jpg"]', '["walkaround.mp4"]', '{"type": "Point", "coordinates": [-96.7970, 32.7767]}', '["hash4", "hash5", "hash6"]', NOW() - INTERVAL '20 days'),
('report-003', 'job-003', 'Hotel property verified. Occupancy rates confirmed. Financial records reviewed.', '{"property_verified": true, "occupancy_confirmed": true, "financials_reviewed": true}', '["hotel1.jpg", "hotel2.jpg", "lobby.jpg"]', '["property_tour.mp4"]', '{"type": "Point", "coordinates": [-80.1918, 25.7617]}', '["hash7", "hash8", "hash9"]', NOW() - INTERVAL '15 days'),
('report-004', 'job-004', 'Historic property verified. Renovation quality excellent. Rental potential confirmed.', '{"property_verified": true, "renovation_quality": true, "rental_potential": true}', '["house1.jpg", "house2.jpg", "interior.jpg"]', '["property_tour.mp4"]', '{"type": "Point", "coordinates": [-73.9857, 40.6782]}', '["hash10", "hash11", "hash12"]', NOW() - INTERVAL '10 days');

-- Insert sample orders
INSERT INTO orders (id, user_id, asset_id, side, qty, price, status, filled_qty, created_at) VALUES
('order-001', 'user-001', 'asset-001', 'buy', 100.0, 25000.00, 'filled', 100.0, NOW() - INTERVAL '25 days'),
('order-002', 'user-002', 'asset-002', 'buy', 50.0, 1700.00, 'filled', 50.0, NOW() - INTERVAL '20 days'),
('order-003', 'user-001', 'asset-003', 'buy', 200.0, 60000.00, 'filled', 200.0, NOW() - INTERVAL '15 days'),
('order-004', 'user-002', 'asset-004', 'buy', 75.0, 26250.00, 'filled', 75.0, NOW() - INTERVAL '10 days'),
('order-005', 'user-004', 'asset-005', 'buy', 150.0, 13500.00, 'filled', 150.0, NOW() - INTERVAL '5 days'),
('order-006', 'user-005', 'asset-001', 'buy', 25.0, 6250.00, 'filled', 25.0, NOW() - INTERVAL '3 days'),
('order-007', 'user-001', 'asset-001', 'sell', 50.0, 26000.00, 'open', 0.0, NOW() - INTERVAL '1 day'),
('order-008', 'user-002', 'asset-002', 'sell', 25.0, 1800.00, 'open', 0.0, NOW() - INTERVAL '12 hours');

-- Insert sample trades
INSERT INTO trades (id, buy_order_id, sell_order_id, qty, price, tx_hash, created_at) VALUES
('trade-001', 'order-001', NULL, 100.0, 25000.00, '0xtrade001...', NOW() - INTERVAL '25 days'),
('trade-002', 'order-002', NULL, 50.0, 1700.00, '0xtrade002...', NOW() - INTERVAL '20 days'),
('trade-003', 'order-003', NULL, 200.0, 60000.00, '0xtrade003...', NOW() - INTERVAL '15 days'),
('trade-004', 'order-004', NULL, 75.0, 26250.00, '0xtrade004...', NOW() - INTERVAL '10 days'),
('trade-005', 'order-005', NULL, 150.0, 13500.00, '0xtrade005...', NOW() - INTERVAL '5 days'),
('trade-006', 'order-006', NULL, 25.0, 6250.00, '0xtrade006...', NOW() - INTERVAL '3 days');








