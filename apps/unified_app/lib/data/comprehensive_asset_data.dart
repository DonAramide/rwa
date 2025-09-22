import '../models/asset.dart';
import '../models/asset_categories.dart';

class ComprehensiveAssetData {
  static List<Map<String, dynamic>> getAllAssets() {
    return [
      // Real Estate Assets
      ...getRealEstateAssets(),
      // Transportation Assets
      ...getTransportationAssets(),
      // Precious & Tangible Assets
      ...getPreciousAssets(),
      // Financial & Business Assets
      ...getFinancialAssets(),
      // Sustainable & Alternative Assets
      ...getSustainableAssets(),
    ];
  }

  static List<Map<String, dynamic>> getRealEstateAssets() {
    return [
      // Residential Houses
      {
        'id': 1001,
        'type': 'house',
        'title': 'Luxury Villa in Beverly Hills',
        'spv_id': 'RE-VH-001',
        'status': 'active',
        'nav': '2500000.00',
        'verification_required': true,
        'createdAt': '2024-01-15T08:00:00Z',
        'description': 'Stunning 5-bedroom luxury villa with pool and panoramic city views',
        'location': {
          'latitude': 34.0736,
          'longitude': -118.4004,
          'address': '1234 Sunset Blvd',
          'city': 'Beverly Hills',
          'state': 'CA',
          'country': 'USA'
        }
      },
      {
        'id': 1002,
        'type': 'house',
        'title': 'Modern Family Home',
        'spv_id': 'RE-FH-002',
        'status': 'active',
        'nav': '850000.00',
        'verification_required': true,
        'createdAt': '2024-02-10T10:30:00Z',
        'description': '4-bedroom contemporary home with smart home features',
      },

      // Apartments
      {
        'id': 1003,
        'type': 'apartment',
        'title': 'Manhattan Penthouse',
        'spv_id': 'RE-PH-003',
        'status': 'active',
        'nav': '4200000.00',
        'verification_required': true,
        'createdAt': '2024-01-20T14:15:00Z',
        'description': 'Exclusive penthouse with 360-degree Manhattan views',
        'location': {
          'latitude': 40.7589,
          'longitude': -73.9851,
          'address': '432 Park Avenue',
          'city': 'New York',
          'state': 'NY',
          'country': 'USA'
        }
      },
      {
        'id': 1004,
        'type': 'apartment',
        'title': 'Downtown Loft Complex',
        'spv_id': 'RE-LC-004',
        'status': 'active',
        'nav': '1200000.00',
        'verification_required': true,
        'createdAt': '2024-02-05T09:45:00Z',
        'description': '12-unit loft building in trendy downtown district',
      },

      // Commercial Buildings
      {
        'id': 1005,
        'type': 'commercial',
        'title': 'Tech Hub Office Complex',
        'spv_id': 'RE-TH-005',
        'status': 'active',
        'nav': '15500000.00',
        'verification_required': true,
        'createdAt': '2024-01-25T11:00:00Z',
        'description': 'Modern office complex in Silicon Valley tech corridor',
        'location': {
          'latitude': 37.4419,
          'longitude': -122.1430,
          'address': '1000 Innovation Drive',
          'city': 'Palo Alto',
          'state': 'CA',
          'country': 'USA'
        }
      },
      {
        'id': 1006,
        'type': 'retail',
        'title': 'Premium Shopping Plaza',
        'spv_id': 'RE-SP-006',
        'status': 'active',
        'nav': '8750000.00',
        'verification_required': true,
        'createdAt': '2024-02-12T16:20:00Z',
        'description': 'High-end retail plaza with anchor tenants',
      },

      // Hotels
      {
        'id': 1007,
        'type': 'hotel',
        'title': 'Oceanfront Resort',
        'spv_id': 'RE-OR-007',
        'status': 'active',
        'nav': '25000000.00',
        'verification_required': true,
        'createdAt': '2024-01-30T13:45:00Z',
        'description': '150-room luxury resort with private beach access',
        'location': {
          'latitude': 25.7617,
          'longitude': -80.1918,
          'address': '789 Ocean Drive',
          'city': 'Miami Beach',
          'state': 'FL',
          'country': 'USA'
        }
      },

      // Warehouses
      {
        'id': 1008,
        'type': 'warehouse',
        'title': 'Logistics Distribution Center',
        'spv_id': 'RE-DC-008',
        'status': 'active',
        'nav': '3200000.00',
        'verification_required': true,
        'createdAt': '2024-02-08T12:00:00Z',
        'description': '500,000 sq ft distribution facility near major highways',
      },

      // Farmlands
      {
        'id': 1009,
        'type': 'farmland',
        'title': 'Organic Crop Farm',
        'spv_id': 'RE-OF-009',
        'status': 'active',
        'nav': '1850000.00',
        'verification_required': true,
        'createdAt': '2024-01-18T07:30:00Z',
        'description': '2,000 acres of certified organic farmland',
        'location': {
          'latitude': 40.4173,
          'longitude': -86.8677,
          'address': '5678 Rural Route 12',
          'city': 'Lafayette',
          'state': 'IN',
          'country': 'USA'
        }
      },

      // Vacant Plots
      {
        'id': 1010,
        'type': 'land',
        'title': 'Development Land Parcel',
        'spv_id': 'RE-DL-010',
        'status': 'active',
        'nav': '950000.00',
        'verification_required': true,
        'createdAt': '2024-02-14T15:10:00Z',
        'description': '50-acre development-ready land with utilities',
      },
    ];
  }

  static List<Map<String, dynamic>> getTransportationAssets() {
    return [
      // Cars & Fleets
      {
        'id': 2001,
        'type': 'car',
        'title': 'Uber Fleet Portfolio',
        'spv_id': 'TR-UF-001',
        'status': 'active',
        'nav': '2400000.00',
        'verification_required': true,
        'createdAt': '2024-01-22T09:15:00Z',
        'description': '50-vehicle ride-hailing fleet with maintenance contracts',
        'location': {
          'latitude': 37.7749,
          'longitude': -122.4194,
          'address': '1550 Mission Street',
          'city': 'San Francisco',
          'state': 'CA',
          'country': 'USA'
        }
      },
      {
        'id': 2002,
        'type': 'vehicle',
        'title': 'Luxury Car Rental Fleet',
        'spv_id': 'TR-LR-002',
        'status': 'active',
        'nav': '1850000.00',
        'verification_required': true,
        'createdAt': '2024-02-03T11:30:00Z',
        'description': 'Premium vehicle rental portfolio in major cities',
      },

      // Buses
      {
        'id': 2003,
        'type': 'bus',
        'title': 'City Transit Contract',
        'spv_id': 'TR-CT-003',
        'status': 'active',
        'nav': '3200000.00',
        'verification_required': true,
        'createdAt': '2024-01-28T14:20:00Z',
        'description': '25-bus fleet with 10-year municipal contract',
        'location': {
          'latitude': 32.7767,
          'longitude': -96.7970,
          'address': '200 Transit Way',
          'city': 'Dallas',
          'state': 'TX',
          'country': 'USA'
        }
      },

      // Trucks
      {
        'id': 2004,
        'type': 'truck',
        'title': 'Long-Haul Freight Fleet',
        'spv_id': 'TR-LH-004',
        'status': 'active',
        'nav': '4500000.00',
        'verification_required': true,
        'createdAt': '2024-02-01T08:45:00Z',
        'description': '40-truck interstate freight operation',
        'location': {
          'latitude': 41.8781,
          'longitude': -87.6298,
          'address': '1200 Trucking Plaza',
          'city': 'Chicago',
          'state': 'IL',
          'country': 'USA'
        }
      },

      // Motorbikes
      {
        'id': 2005,
        'type': 'motorbike',
        'title': 'Food Delivery Fleet',
        'spv_id': 'TR-FD-005',
        'status': 'active',
        'nav': '180000.00',
        'verification_required': false,
        'createdAt': '2024-02-06T16:00:00Z',
        'description': '100-bike delivery network for food apps',
      },

      // Boats
      {
        'id': 2006,
        'type': 'boat',
        'title': 'Tourist Ferry Service',
        'spv_id': 'TR-TF-006',
        'status': 'active',
        'nav': '850000.00',
        'verification_required': true,
        'createdAt': '2024-01-26T10:15:00Z',
        'description': 'Harbor tour and transportation service',
        'location': {
          'latitude': 47.6062,
          'longitude': -122.3321,
          'address': 'Pier 55',
          'city': 'Seattle',
          'state': 'WA',
          'country': 'USA'
        }
      },

      // Aircraft
      {
        'id': 2007,
        'type': 'aircraft',
        'title': 'Charter Flight Service',
        'spv_id': 'TR-CF-007',
        'status': 'active',
        'nav': '12500000.00',
        'verification_required': true,
        'createdAt': '2024-02-09T13:30:00Z',
        'description': '5-aircraft charter service for business travel',
      },
    ];
  }

  static List<Map<String, dynamic>> getPreciousAssets() {
    return [
      // Gold
      {
        'id': 3001,
        'type': 'gold',
        'title': 'Gold Bullion Vault',
        'spv_id': 'PR-GB-001',
        'status': 'active',
        'nav': '5200000.00',
        'verification_required': true,
        'createdAt': '2024-01-21T10:00:00Z',
        'description': '100 oz of certified gold bullion in secure vault',
        'location': {
          'latitude': 40.7614,
          'longitude': -73.9776,
          'address': '47 Wall Street',
          'city': 'New York',
          'state': 'NY',
          'country': 'USA'
        }
      },

      // Silver
      {
        'id': 3002,
        'type': 'silver',
        'title': 'Industrial Silver Holdings',
        'spv_id': 'PR-IS-002',
        'status': 'active',
        'nav': '850000.00',
        'verification_required': true,
        'createdAt': '2024-02-04T12:15:00Z',
        'description': '10,000 oz silver bars for industrial demand',
      },

      // Diamonds
      {
        'id': 3003,
        'type': 'diamond',
        'title': 'Certified Diamond Portfolio',
        'spv_id': 'PR-CD-003',
        'status': 'active',
        'nav': '3200000.00',
        'verification_required': true,
        'createdAt': '2024-01-29T15:45:00Z',
        'description': 'Collection of GIA-certified investment-grade diamonds',
      },

      // Luxury Watches
      {
        'id': 3004,
        'type': 'watch',
        'title': 'Vintage Watch Collection',
        'spv_id': 'PR-VW-004',
        'status': 'active',
        'nav': '1200000.00',
        'verification_required': true,
        'createdAt': '2024-02-07T11:20:00Z',
        'description': 'Rare Rolex and Patek Philippe timepieces',
      },

      // Industrial Metals
      {
        'id': 3005,
        'type': 'copper',
        'title': 'Copper Commodity Holdings',
        'spv_id': 'PR-CC-005',
        'status': 'active',
        'nav': '950000.00',
        'verification_required': true,
        'createdAt': '2024-02-11T09:30:00Z',
        'description': 'Strategic copper reserves for infrastructure demand',
      },
    ];
  }

  static List<Map<String, dynamic>> getFinancialAssets() {
    return [
      // Company Shares
      {
        'id': 4001,
        'type': 'shares',
        'title': 'Tech Startup Portfolio',
        'spv_id': 'FN-TS-001',
        'status': 'active',
        'nav': '2800000.00',
        'verification_required': true,
        'createdAt': '2024-01-24T14:00:00Z',
        'description': 'Diversified early-stage technology company investments',
        'location': {
          'latitude': 37.4419,
          'longitude': -122.1430,
          'address': '3000 Sand Hill Road',
          'city': 'Menlo Park',
          'state': 'CA',
          'country': 'USA'
        }
      },

      // Bonds
      {
        'id': 4002,
        'type': 'bond',
        'title': 'Municipal Bond Portfolio',
        'spv_id': 'FN-MB-002',
        'status': 'active',
        'nav': '1650000.00',
        'verification_required': true,
        'createdAt': '2024-02-02T16:30:00Z',
        'description': 'Tax-free municipal bonds from AAA-rated cities',
      },

      // Businesses
      {
        'id': 4003,
        'type': 'business',
        'title': 'Coffee Shop Chain',
        'spv_id': 'FN-CS-003',
        'status': 'active',
        'nav': '3400000.00',
        'verification_required': true,
        'createdAt': '2024-01-27T08:20:00Z',
        'description': '12-location specialty coffee franchise',
        'location': {
          'latitude': 47.6062,
          'longitude': -122.3321,
          'address': '1912 Pike Place',
          'city': 'Seattle',
          'state': 'WA',
          'country': 'USA'
        }
      },

      // Franchise Rights
      {
        'id': 4004,
        'type': 'franchise',
        'title': 'Fast Food Franchise Rights',
        'spv_id': 'FN-FF-004',
        'status': 'active',
        'nav': '2200000.00',
        'verification_required': true,
        'createdAt': '2024-02-13T13:15:00Z',
        'description': 'Multi-unit franchise development rights',
      },
    ];
  }

  static List<Map<String, dynamic>> getSustainableAssets() {
    return [
      // Renewable Energy
      {
        'id': 5001,
        'type': 'solar',
        'title': 'Solar Farm Project',
        'spv_id': 'SU-SF-001',
        'status': 'active',
        'nav': '8500000.00',
        'verification_required': true,
        'createdAt': '2024-01-23T11:45:00Z',
        'description': '50MW solar installation with 25-year power purchase agreement',
        'location': {
          'latitude': 36.1699,
          'longitude': -115.1398,
          'address': '5000 Solar Farm Road',
          'city': 'Las Vegas',
          'state': 'NV',
          'country': 'USA'
        }
      },
      {
        'id': 5002,
        'type': 'wind',
        'title': 'Wind Energy Portfolio',
        'spv_id': 'SU-WE-002',
        'status': 'active',
        'nav': '12200000.00',
        'verification_required': true,
        'createdAt': '2024-02-15T09:00:00Z',
        'description': '25-turbine wind farm in high-wind corridor',
        'location': {
          'latitude': 39.0458,
          'longitude': -101.7619,
          'address': 'Wind Ridge Road',
          'city': 'Colby',
          'state': 'KS',
          'country': 'USA'
        }
      },

      // Agricultural
      {
        'id': 5003,
        'type': 'agriculture',
        'title': 'Sustainable Rice Mill',
        'spv_id': 'SU-RM-003',
        'status': 'active',
        'nav': '1850000.00',
        'verification_required': true,
        'createdAt': '2024-01-31T14:30:00Z',
        'description': 'Organic rice processing facility with export contracts',
        'location': {
          'latitude': 30.2672,
          'longitude': -97.7431,
          'address': '7890 Farm to Market Road',
          'city': 'Austin',
          'state': 'TX',
          'country': 'USA'
        }
      },

      // Carbon Credits
      {
        'id': 5004,
        'type': 'carbon',
        'title': 'Reforestation Carbon Project',
        'spv_id': 'SU-RC-004',
        'status': 'active',
        'nav': '650000.00',
        'verification_required': true,
        'createdAt': '2024-02-16T10:45:00Z',
        'description': '10,000-acre reforestation project generating carbon credits',
        'location': {
          'latitude': 45.5152,
          'longitude': -122.6784,
          'address': '456 Green Initiative Way',
          'city': 'Portland',
          'state': 'OR',
          'country': 'USA'
        }
      },
    ];
  }
}