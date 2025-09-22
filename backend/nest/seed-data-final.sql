-- Seed data for RWA Investment Platform (final version)

-- Insert sample assets
INSERT INTO assets (type, title, spv_id, status, nav, verification_required, created_at) VALUES
('land', 'Downtown Commercial Land - Austin, TX', 'SPV-001', 'active', 2500000.00, true, NOW() - INTERVAL '30 days'),
('truck', 'Fleet Truck #001 - Freightliner', 'SPV-002', 'active', 85000.00, true, NOW() - INTERVAL '25 days'),
('hotel', 'Boutique Hotel - Miami Beach', 'SPV-003', 'active', 12000000.00, true, NOW() - INTERVAL '20 days'),
('house', 'Luxury Villa - Malibu, CA', 'SPV-004', 'active', 3500000.00, true, NOW() - INTERVAL '15 days'),
('land', 'Agricultural Land - Iowa', 'SPV-005', 'active', 1800000.00, true, NOW() - INTERVAL '10 days'),
('truck', 'Fleet Truck #002 - Volvo', 'SPV-006', 'pending', 95000.00, true, NOW() - INTERVAL '5 days'),
('hotel', 'Extended Stay Hotel - Dallas, TX', 'SPV-007', 'active', 8500000.00, true, NOW() - INTERVAL '3 days'),
('house', 'Historic Brownstone - Brooklyn, NY', 'SPV-008', 'suspended', 2200000.00, true, NOW() - INTERVAL '1 day');

-- Insert sample users (investors)
INSERT INTO users (email, phone, password_hash, kyc_status, created_at) VALUES
('john.doe@example.com', '+1-555-0101', '$2b$10$example_hash_1', 'approved', NOW() - INTERVAL '60 days'),
('jane.smith@example.com', '+1-555-0102', '$2b$10$example_hash_2', 'approved', NOW() - INTERVAL '45 days'),
('mike.wilson@example.com', '+1-555-0103', '$2b$10$example_hash_3', 'pending', NOW() - INTERVAL '30 days'),
('sarah.johnson@example.com', '+1-555-0104', '$2b$10$example_hash_4', 'approved', NOW() - INTERVAL '20 days'),
('david.brown@example.com', '+1-555-0105', '$2b$10$example_hash_5', 'approved', NOW() - INTERVAL '10 days');

-- Insert sample wallets
INSERT INTO wallets (user_id, type, address, chain_id, verified, created_at) VALUES
(1, 'self', '0x742d35Cc6634C0532925a3b8D0C4C4C4C4C4C4C4', 1, true, NOW() - INTERVAL '60 days'),
(2, 'self', '0x8ba1f109551bD432803012645Hac136c4C4C4C4C4', 1, true, NOW() - INTERVAL '45 days'),
(3, 'self', '0x9cA4315cC6634C0532925a3b8D0C4C4C4C4C4C4C4', 1, false, NOW() - INTERVAL '30 days'),
(4, 'self', '0x1dF6f109551bD432803012645Hac136c4C4C4C4C4', 1, true, NOW() - INTERVAL '20 days'),
(5, 'self', '0x2eA4315cC6634C0532925a3b8D0C4C4C4C4C4C4C4', 1, true, NOW() - INTERVAL '10 days');

-- Insert sample holdings
INSERT INTO holdings (user_id, asset_id, balance, locked_balance, updated_at) VALUES
(1, 1, 150.0, 0.0, NOW() - INTERVAL '25 days'),
(1, 2, 25.0, 0.0, NOW() - INTERVAL '20 days'),
(2, 3, 100.0, 0.0, NOW() - INTERVAL '15 days'),
(2, 4, 75.0, 0.0, NOW() - INTERVAL '10 days'),
(4, 5, 200.0, 0.0, NOW() - INTERVAL '5 days'),
(5, 1, 50.0, 0.0, NOW() - INTERVAL '3 days');

-- Insert sample distributions
INSERT INTO distributions (asset_id, period, gross, mgmt_fee_bps, carry_bps, net, tx_hash, created_at) VALUES
(1, '[2024-01-01,2024-01-31]', 15000.00, 200, 100, 14550.00, '0xabc123...', NOW() - INTERVAL '5 days'),
(2, '[2024-01-01,2024-01-31]', 8500.00, 200, 100, 8245.00, '0xdef456...', NOW() - INTERVAL '5 days'),
(3, '[2024-01-01,2024-01-31]', 45000.00, 200, 100, 43650.00, '0xghi789...', NOW() - INTERVAL '5 days'),
(4, '[2024-01-01,2024-01-31]', 12000.00, 200, 100, 11640.00, '0xjkl012...', NOW() - INTERVAL '5 days'),
(5, '[2024-01-01,2024-01-31]', 18000.00, 200, 100, 17460.00, '0xmno345...', NOW() - INTERVAL '5 days');

-- Insert sample verification agents
INSERT INTO agents (user_id, status, regions, skills, bio, rating_avg, rating_count, created_at) VALUES
(1, 'approved', '{"TX", "CA", "NY"}', '{"real_estate", "commercial"}', 'Licensed real estate inspector with 10+ years experience in commercial properties.', 4.8, 45, NOW() - INTERVAL '60 days'),
(2, 'approved', '{"FL", "GA", "NC"}', '{"hospitality", "tourism"}', 'Hotel and hospitality industry expert with extensive experience in property evaluation.', 4.6, 32, NOW() - INTERVAL '45 days'),
(3, 'pending', '{"IA", "IL", "IN"}', '{"agriculture", "land"}', 'Agricultural land specialist with deep knowledge of farming operations and land valuation.', 0.0, 0, NOW() - INTERVAL '30 days'),
(4, 'approved', '{"CA", "NV", "AZ"}', '{"vehicles", "logistics"}', 'Commercial vehicle inspector with expertise in fleet management and maintenance.', 4.7, 28, NOW() - INTERVAL '20 days'),
(5, 'approved', '{"NY", "NJ", "CT"}', '{"residential", "historic"}', 'Residential property specialist with focus on historic and luxury properties.', 4.9, 38, NOW() - INTERVAL '10 days');

-- Insert sample verification jobs
INSERT INTO verification_jobs (asset_id, investor_id, agent_id, status, price, currency, sla_due_at, created_at) VALUES
(1, 1, 1, 'accepted', 500.00, 'USD', NOW() - INTERVAL '25 days', NOW() - INTERVAL '30 days'),
(2, 2, 4, 'accepted', 300.00, 'USD', NOW() - INTERVAL '20 days', NOW() - INTERVAL '25 days'),
(3, 1, 2, 'accepted', 750.00, 'USD', NOW() - INTERVAL '15 days', NOW() - INTERVAL '20 days'),
(4, 2, 5, 'accepted', 400.00, 'USD', NOW() - INTERVAL '10 days', NOW() - INTERVAL '15 days'),
(5, 4, 3, 'submitted', 600.00, 'USD', NOW() + INTERVAL '2 days', NOW() - INTERVAL '5 days');

-- Insert sample verification reports
INSERT INTO verification_reports (job_id, summary, checklist, photos, videos, gps_path, doc_hashes, submitted_at) VALUES
(1, 'Property verified as described. All documents authentic. Location confirmed via GPS.', '{"title_verified": true, "location_confirmed": true, "condition_assessed": true}', '{"photo1.jpg", "photo2.jpg", "photo3.jpg"}', '{"video1.mp4"}', '{"type": "Point", "coordinates": [-97.7431, 30.2672]}', '{"hash1", "hash2", "hash3"}', NOW() - INTERVAL '25 days'),
(2, 'Vehicle in excellent condition. All maintenance records verified. Current location confirmed.', '{"vehicle_condition": true, "maintenance_verified": true, "location_confirmed": true}', '{"truck1.jpg", "truck2.jpg", "engine.jpg"}', '{"walkaround.mp4"}', '{"type": "Point", "coordinates": [-96.7970, 32.7767]}', '{"hash4", "hash5", "hash6"}', NOW() - INTERVAL '20 days'),
(3, 'Hotel property verified. Occupancy rates confirmed. Financial records reviewed.', '{"property_verified": true, "occupancy_confirmed": true, "financials_reviewed": true}', '{"hotel1.jpg", "hotel2.jpg", "lobby.jpg"}', '{"property_tour.mp4"}', '{"type": "Point", "coordinates": [-80.1918, 25.7617]}', '{"hash7", "hash8", "hash9"}', NOW() - INTERVAL '15 days'),
(4, 'Historic property verified. Renovation quality excellent. Rental potential confirmed.', '{"property_verified": true, "renovation_quality": true, "rental_potential": true}', '{"house1.jpg", "house2.jpg", "interior.jpg"}', '{"property_tour.mp4"}', '{"type": "Point", "coordinates": [-73.9857, 40.6782]}', '{"hash10", "hash11", "hash12"}', NOW() - INTERVAL '10 days');

-- Insert sample orders
INSERT INTO orders (user_id, asset_id, side, qty, price, status, filled_qty, created_at) VALUES
(1, 1, 'buy', 100.0, 25000.00, 'filled', 100.0, NOW() - INTERVAL '25 days'),
(2, 2, 'buy', 50.0, 1700.00, 'filled', 50.0, NOW() - INTERVAL '20 days'),
(1, 3, 'buy', 200.0, 60000.00, 'filled', 200.0, NOW() - INTERVAL '15 days'),
(2, 4, 'buy', 75.0, 26250.00, 'filled', 75.0, NOW() - INTERVAL '10 days'),
(4, 5, 'buy', 150.0, 13500.00, 'filled', 150.0, NOW() - INTERVAL '5 days'),
(5, 1, 'buy', 25.0, 6250.00, 'filled', 25.0, NOW() - INTERVAL '3 days'),
(1, 1, 'sell', 50.0, 26000.00, 'open', 0.0, NOW() - INTERVAL '1 day'),
(2, 2, 'sell', 25.0, 1800.00, 'open', 0.0, NOW() - INTERVAL '12 hours');

-- Insert sample IoT devices
INSERT INTO iot_devices (asset_id, type, public_key, last_seen, status, created_at) VALUES
(2, 'vehicle_gps', 'pubkey_truck_001', NOW() - INTERVAL '1 hour', 'active', NOW() - INTERVAL '25 days'),
(6, 'vehicle_gps', 'pubkey_truck_002', NOW() - INTERVAL '2 hours', 'active', NOW() - INTERVAL '5 days'),
(1, 'land_sensor', 'pubkey_land_001', NOW() - INTERVAL '30 minutes', 'active', NOW() - INTERVAL '30 days'),
(5, 'land_sensor', 'pubkey_land_002', NOW() - INTERVAL '1 hour', 'active', NOW() - INTERVAL '10 days');

-- Insert sample telemetry data
INSERT INTO telemetry (asset_id, ts, lat, lon, speed, meta) VALUES
(2, NOW() - INTERVAL '1 hour', 32.7767, -96.7970, 65.5, '{"engine_temp": 185, "fuel_level": 0.75}'),
(2, NOW() - INTERVAL '2 hours', 32.7849, -96.8084, 0.0, '{"engine_temp": 180, "fuel_level": 0.78}'),
(6, NOW() - INTERVAL '1 hour', 33.4484, -112.0740, 45.2, '{"engine_temp": 190, "fuel_level": 0.65}'),
(1, NOW() - INTERVAL '30 minutes', 30.2672, -97.7431, 0.0, '{"temperature": 75, "humidity": 0.45}'),
(5, NOW() - INTERVAL '1 hour', 41.8781, -93.0977, 0.0, '{"soil_moisture": 0.68, "temperature": 72}');


