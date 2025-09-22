import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> with TickerProviderStateMixin {
  late TabController _tabController;

  // Asset management state
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Status';
  String _selectedVerification = 'All';

  // Analytics chart view state
  bool _showPieChart = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this); // Added Insurance tab
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Asset data with visibility controls and live tracking
  List<Map<String, dynamic>> _getAllAssets() {
    return [
      {
        'id': 'RE-VH-001',
        'title': 'Luxury Villa in Beverly Hills',
        'category': 'Real Estate',
        'status': 'Active',
        'verification': 'Verified',
        'nav': '\$2.5M',
        'location': 'Beverly Hills, CA',
        'image': 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=400&h=300&fit=crop',
        'isVisible': true,
        'isPublic': true,
        'isMovable': false,
        'hasLiveTracking': false,
        'currentLocation': null,
        'lastMovement': null,
      },
      {
        'id': 'RE-FH-002',
        'title': 'Modern Family Home',
        'category': 'Real Estate',
        'status': 'Active',
        'verification': 'Verified',
        'nav': '\$850K',
        'location': 'New York, NY',
        'image': 'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?w=400&h=300&fit=crop',
        'isVisible': true,
        'isPublic': true,
        'isMovable': false,
        'hasLiveTracking': false,
        'currentLocation': null,
        'lastMovement': null,
      },
      {
        'id': 'RE-PH-003',
        'title': 'Manhattan Penthouse',
        'category': 'Real Estate',
        'status': 'Active',
        'verification': 'Verified',
        'nav': '\$4.2M',
        'location': 'New York, NY',
        'image': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=400&h=300&fit=crop',
        'isVisible': true,
        'isPublic': true,
        'isMovable': false,
        'hasLiveTracking': false,
        'currentLocation': null,
        'lastMovement': null,
      },
      {
        'id': 'RE-LC-004',
        'title': 'Downtown Loft Complex',
        'category': 'Real Estate',
        'status': 'Pending',
        'verification': 'Pending',
        'nav': '\$1.8M',
        'location': 'Chicago, IL',
        'image': 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400&h=300&fit=crop',
        'isVisible': false,
        'isPublic': false,
        'isMovable': false,
        'hasLiveTracking': false,
        'currentLocation': null,
        'lastMovement': null,
      },
      {
        'id': 'TR-SC-005',
        'title': 'Luxury Sports Car Collection',
        'category': 'Transportation',
        'status': 'Active',
        'verification': 'Verified',
        'nav': '\$3.5M',
        'location': 'Monaco',
        'image': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=400&h=300&fit=crop',
        'isVisible': true,
        'isPublic': true,
        'isMovable': true,
        'hasLiveTracking': true,
        'hasIOT': true,
        'fleetSize': 12,
        'currentLocation': {'lat': 43.7384, 'lng': 7.4246, 'address': 'Monaco Garage, Monaco'},
        'lastMovement': '2024-01-15T10:30:00Z',
        'iotSensors': {
          'gps': {'status': 'online', 'accuracy': '±2m', 'lastUpdate': '2024-01-21T15:30:00Z'},
          'engine': {'status': 'online', 'temperature': '89°C', 'rpm': '0', 'fuel': '85%'},
          'security': {'status': 'armed', 'alarmStatus': 'normal', 'doorLocks': 'secured'},
          'maintenance': {'status': 'optimal', 'mileage': '12,450 km', 'nextService': '2024-02-15'},
          'battery': {'status': 'good', 'voltage': '12.4V', 'charge': '95%'},
          'tire': {'pressure': 'optimal', 'frontLeft': '32 PSI', 'frontRight': '32 PSI', 'rearLeft': '30 PSI', 'rearRight': '30 PSI'}
        },
        'aiInsights': {
          'healthScore': 94,
          'predictedMaintenance': 'Low oil change needed in 2 weeks',
          'riskAssessment': 'Low risk - all systems optimal',
          'efficiencyScore': 87,
          'recommendations': ['Schedule tire rotation', 'Check air filter'],
          'anomalies': []
        },
        'fleetMetrics': {
          'totalMileage': '145,230 km',
          'averageUtilization': '68%',
          'maintenanceCost': '\$8,450/month',
          'fuelEfficiency': '8.2L/100km average'
        }
      },
      {
        'id': 'PM-GB-006',
        'title': 'Gold Bullion Reserve',
        'category': 'Precious Metals',
        'status': 'Locked',
        'verification': 'Verified',
        'nav': '\$2.1M',
        'location': 'Swiss Vault, Zurich',
        'image': 'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=400&h=300&fit=crop',
        'isVisible': true,
        'isPublic': false,
        'isMovable': true,
        'hasLiveTracking': true,
        'currentLocation': {'lat': 47.3769, 'lng': 8.5417, 'address': 'Secure Vault, Zurich, Switzerland'},
        'lastMovement': null,
      },
      {
        'id': 'TR-YT-007',
        'title': 'Private Yacht',
        'category': 'Transportation',
        'status': 'Active',
        'verification': 'Verified',
        'nav': '\$8.2M',
        'location': 'Mediterranean Sea',
        'image': 'https://images.unsplash.com/photo-1605281317010-fe5ffe798166?w=400&h=300&fit=crop',
        'isVisible': true,
        'isPublic': true,
        'isMovable': true,
        'hasLiveTracking': true,
        'hasIOT': true,
        'fleetSize': 1,
        'currentLocation': {'lat': 43.2804, 'lng': 5.3360, 'address': 'Mediterranean Sea, near Marseille'},
        'lastMovement': '2024-01-20T14:45:00Z',
        'iotSensors': {
          'gps': {'status': 'online', 'accuracy': '±1m', 'lastUpdate': '2024-01-21T16:15:00Z'},
          'marine': {'status': 'online', 'depth': '42m', 'speed': '0 knots', 'heading': '235°'},
          'engine': {'status': 'standby', 'temperature': '45°C', 'fuelLevel': '78%', 'hoursRun': '1,240h'},
          'weather': {'status': 'monitoring', 'windSpeed': '12 knots', 'waveHeight': '1.2m', 'visibility': '15km'},
          'safety': {'status': 'all clear', 'liferafts': 'ready', 'fireSystem': 'armed', 'communications': 'online'},
          'power': {'status': 'shore power', 'batteries': '100%', 'generator': 'standby', 'solar': '85% efficient'}
        },
        'aiInsights': {
          'healthScore': 91,
          'predictedMaintenance': 'Hull cleaning recommended in 3 weeks',
          'riskAssessment': 'Low risk - weather conditions favorable',
          'efficiencyScore': 89,
          'recommendations': ['Check anchor chain', 'Service water maker', 'Update charts'],
          'anomalies': []
        },
        'fleetMetrics': {
          'totalNauticalMiles': '28,450 NM',
          'averageUtilization': '45%',
          'maintenanceCost': '\$15,200/month',
          'fuelEfficiency': '45L/hour cruising'
        }
      },
      {
        'id': 'TR-TF-009',
        'title': 'Commercial Transport Fleet',
        'category': 'Transportation',
        'status': 'Active',
        'verification': 'Verified',
        'nav': '\$4.8M',
        'location': 'Europe-wide Operations',
        'image': 'https://images.unsplash.com/photo-1615634260167-c8cdede054de?w=400&h=300&fit=crop',
        'isVisible': true,
        'isPublic': true,
        'isMovable': true,
        'hasLiveTracking': true,
        'hasIOT': true,
        'fleetSize': 45,
        'currentLocation': {'lat': 52.5200, 'lng': 13.4050, 'address': 'Berlin Distribution Center, Germany'},
        'lastMovement': '2024-01-21T08:20:00Z',
        'iotSensors': {
          'gps': {'status': 'online', 'accuracy': '±3m', 'lastUpdate': '2024-01-21T17:00:00Z'},
          'fleet': {'status': 'operational', 'activeVehicles': 42, 'maintenanceQueue': 3, 'fuelStations': 8},
          'cargo': {'status': 'monitored', 'temperature': '4°C', 'humidity': '65%', 'loadCapacity': '85%'},
          'driver': {'status': 'compliant', 'hoursRemaining': '6.5h', 'alertness': 'good', 'breakScheduled': '14:30'},
          'route': {'status': 'optimized', 'trafficDelay': '12min', 'fuelOptimal': 'yes', 'etaAccuracy': '94%'},
          'vehicle': {'status': 'healthy', 'averageFuel': '7.8L/100km', 'tirePressure': 'optimal', 'emissions': 'compliant'}
        },
        'aiInsights': {
          'healthScore': 88,
          'predictedMaintenance': 'Fleet rotation needed - 3 vehicles require service',
          'riskAssessment': 'Medium risk - winter weather conditions',
          'efficiencyScore': 92,
          'recommendations': ['Optimize route planning', 'Schedule winter tire change', 'Update driver training'],
          'anomalies': ['Vehicle TF-023 showing unusual fuel consumption', 'Driver break compliance below 95%']
        },
        'fleetMetrics': {
          'totalKilometers': '2,450,000 km',
          'averageUtilization': '89%',
          'maintenanceCost': '\$28,500/month',
          'fuelEfficiency': '7.8L/100km fleet average',
          'deliverySuccess': '99.2%',
          'customerSatisfaction': '4.7/5'
        }
      },
      {
        'id': 'FN-BC-008',
        'title': 'Bitcoin Mining Facility',
        'category': 'Financial',
        'status': 'Active',
        'verification': 'Under Review',
        'nav': '\$5.7M',
        'location': 'Iceland',
        'image': 'https://images.unsplash.com/photo-1640823637355-ae4e36c585b1?w=400&h=300&fit=crop',
        'isVisible': true,
        'isPublic': true,
        'isMovable': false,
        'hasLiveTracking': false,
        'currentLocation': null,
        'lastMovement': null,
      },
    ];
  }

  List<Map<String, dynamic>> _getFilteredAssets() {
    List<Map<String, dynamic>> assets = _getAllAssets();

    return assets.where((asset) {
      bool categoryMatch = _selectedCategory == 'All Categories' ||
                          asset['category'] == _selectedCategory;
      bool statusMatch = _selectedStatus == 'All Status' ||
                        asset['status'] == _selectedStatus;
      bool verificationMatch = _selectedVerification == 'All' ||
                              asset['verification'] == _selectedVerification;

      return categoryMatch && statusMatch && verificationMatch;
    }).toList();
  }

  int _getFilteredAssetsCount() {
    return _getFilteredAssets().length;
  }

  int _getActiveAssetsCount() {
    return _getAllAssets().where((asset) => asset['status'] == 'Active').length;
  }

  // Insurance Document Management System
  List<Map<String, dynamic>> _getAllInsuranceDocuments() {
    return [
      {
        'id': 'INS-DOC-001',
        'assetId': 'RE-VH-001',
        'assetTitle': 'Luxury Villa in Beverly Hills',
        'documentType': 'Property Insurance',
        'policyNumber': 'POL-BH-2024-001',
        'provider': 'Lloyd\'s of London',
        'coverageAmount': '\$2.5M',
        'premium': '\$12,500/year',
        'status': 'Active',
        'issueDate': '2024-01-01',
        'expiryDate': '2024-12-31',
        'daysToExpiry': 45,
        'documentUrl': 'https://storage.example.com/insurance/INS-DOC-001.pdf',
        'lastReviewed': '2024-09-15',
        'renewalReminder': true,
        'claims': [
          {
            'claimId': 'CLM-001',
            'date': '2024-06-15',
            'amount': '\$5,000',
            'status': 'Settled',
            'description': 'Minor water damage repair'
          }
        ],
        'coverage': {
          'property': '\$2.5M',
          'liability': '\$1M',
          'contents': '\$500K',
          'businessInterruption': '\$250K'
        },
        'assetDocuments': [
          {
            'id': 'DOC-001',
            'name': 'Property Deed',
            'type': 'Legal Document',
            'url': 'https://storage.example.com/assets/RE-VH-001/property-deed.pdf',
            'uploadDate': '2024-01-01',
            'size': '2.4 MB',
            'status': 'Verified'
          },
          {
            'id': 'DOC-002',
            'name': 'Property Valuation Report',
            'type': 'Appraisal',
            'url': 'https://storage.example.com/assets/RE-VH-001/valuation-report.pdf',
            'uploadDate': '2024-01-05',
            'size': '1.8 MB',
            'status': 'Verified'
          },
          {
            'id': 'DOC-003',
            'name': 'Property Survey',
            'type': 'Survey Document',
            'url': 'https://storage.example.com/assets/RE-VH-001/property-survey.pdf',
            'uploadDate': '2024-01-03',
            'size': '3.2 MB',
            'status': 'Verified'
          },
          {
            'id': 'DOC-004',
            'name': 'Building Inspection Report',
            'type': 'Inspection',
            'url': 'https://storage.example.com/assets/RE-VH-001/inspection-report.pdf',
            'uploadDate': '2024-01-10',
            'size': '4.1 MB',
            'status': 'Verified'
          },
          {
            'id': 'DOC-005',
            'name': 'Property Tax Records',
            'type': 'Tax Document',
            'url': 'https://storage.example.com/assets/RE-VH-001/tax-records.pdf',
            'uploadDate': '2024-01-15',
            'size': '1.2 MB',
            'status': 'Verified'
          }
        ]
      },
      {
        'id': 'INS-DOC-002',
        'assetId': 'RE-FH-002',
        'assetTitle': 'Modern Family Home',
        'documentType': 'Homeowner\'s Insurance',
        'policyNumber': 'POL-NY-2024-002',
        'provider': 'State Farm',
        'coverageAmount': '\$850K',
        'premium': '\$8,500/year',
        'status': 'Active',
        'issueDate': '2024-02-01',
        'expiryDate': '2025-01-31',
        'daysToExpiry': 132,
        'documentUrl': 'https://storage.example.com/insurance/INS-DOC-002.pdf',
        'lastReviewed': '2024-08-20',
        'renewalReminder': true,
        'claims': [],
        'coverage': {
          'dwelling': '\$650K',
          'liability': '\$300K',
          'personal': '\$150K',
          'medical': '\$50K'
        }
      },
      {
        'id': 'INS-DOC-003',
        'assetId': 'TR-TF-009',
        'assetTitle': 'Commercial Transport Fleet',
        'documentType': 'Commercial Auto Insurance',
        'policyNumber': 'POL-EU-2024-003',
        'provider': 'Allianz Commercial',
        'coverageAmount': '\$4.8M',
        'premium': '\$45,000/year',
        'status': 'Active',
        'issueDate': '2024-03-01',
        'expiryDate': '2025-02-28',
        'daysToExpiry': 160,
        'documentUrl': 'https://storage.example.com/insurance/INS-DOC-003.pdf',
        'lastReviewed': '2024-09-10',
        'renewalReminder': true,
        'claims': [
          {
            'claimId': 'CLM-002',
            'date': '2024-07-20',
            'amount': '\$15,000',
            'status': 'Pending',
            'description': 'Vehicle collision repair'
          }
        ],
        'coverage': {
          'vehicle': '\$200K per vehicle',
          'cargo': '\$100K per shipment',
          'liability': '\$2M',
          'comprehensive': '\$150K per vehicle'
        }
      },
      {
        'id': 'INS-DOC-004',
        'assetId': 'FN-BC-008',
        'assetTitle': 'Bitcoin Mining Facility',
        'documentType': 'Technology E&O Insurance',
        'policyNumber': 'POL-IS-2024-004',
        'provider': 'Chubb Insurance',
        'coverageAmount': '\$5.7M',
        'premium': '\$85,000/year',
        'status': 'Under Review',
        'issueDate': '2024-01-15',
        'expiryDate': '2025-01-14',
        'daysToExpiry': 115,
        'documentUrl': 'https://storage.example.com/insurance/INS-DOC-004.pdf',
        'lastReviewed': '2024-09-01',
        'renewalReminder': true,
        'claims': [],
        'coverage': {
          'equipment': '\$3M',
          'cyberLiability': '\$2M',
          'businessInterruption': '\$500K',
          'dataLoss': '\$200K'
        }
      },
      {
        'id': 'INS-DOC-005',
        'assetId': 'RE-PH-003',
        'assetTitle': 'Manhattan Penthouse',
        'documentType': 'Luxury Property Insurance',
        'policyNumber': 'POL-MH-2024-005',
        'provider': 'AIG Private Client',
        'coverageAmount': '\$4.2M',
        'premium': '\$32,000/year',
        'status': 'Expired',
        'issueDate': '2023-12-01',
        'expiryDate': '2024-11-30',
        'daysToExpiry': -5,
        'documentUrl': 'https://storage.example.com/insurance/INS-DOC-005.pdf',
        'lastReviewed': '2024-07-15',
        'renewalReminder': true,
        'claims': [],
        'coverage': {
          'building': '\$3M',
          'contents': '\$800K',
          'liability': '\$300K',
          'artAndJewelry': '\$100K'
        }
      }
    ];
  }

  List<Map<String, dynamic>> _getFilteredInsuranceDocuments() {
    return _getAllInsuranceDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.business_center), text: 'Assets'),
            Tab(icon: Icon(Icons.sensors), text: 'IOT Fleet'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.history), text: 'Activity'),
            Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
            Tab(icon: Icon(Icons.security), text: 'Compliance'),
            Tab(icon: Icon(Icons.shield), text: 'Insurance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildUsersTab(),
          _buildAssetsTab(),
          _buildIOTFleetTab(),
          _buildCategoriesTab(),
          _buildActivityTab(),
          _buildAnalyticsTab(),
          _buildComplianceTab(),
          _buildInsuranceTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Platform Statistics',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Statistics Cards Row - Responsive Layout
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 800) {
                // Desktop: Single row
                return Row(
                  children: [
                    Expanded(child: _buildStatCard('156', 'Total Users', Icons.people, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('30', 'Total Assets', Icons.business_center, Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('30', 'Active Assets', Icons.verified, Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('\$134.1M', 'Total NAV', Icons.attach_money, Colors.purple)),
                  ],
                );
              } else {
                // Mobile: Two rows
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('156', 'Total Users', Icons.people, Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('30', 'Total Assets', Icons.business_center, Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildStatCard('30', 'Active Assets', Icons.verified, Colors.green)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildStatCard('\$134.1M', 'Total NAV', Icons.attach_money, Colors.purple)),
                      ],
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Asset Categories Overview
          Text(
            'Asset Categories Overview',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Categories - Responsive Layout
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1000) {
                // Wide Desktop: Single row
                return Row(
                  children: [
                    Expanded(child: _buildCategoryCard('9', 'Real Estate', Icons.home, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCategoryCard('6', 'Transportation & M...', Icons.directions_car, Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCategoryCard('5', 'Precious & Tangible', Icons.diamond, Colors.yellow[700]!)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCategoryCard('7', 'Financial & Business', Icons.trending_up, Colors.green)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCategoryCard('3', 'Sustainable & Alter...', Icons.eco, Colors.teal)),
                  ],
                );
              } else {
                // Smaller screens: Multiple rows
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildCategoryCard('9', 'Real Estate', Icons.home, Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCategoryCard('6', 'Transportation & M...', Icons.directions_car, Colors.orange)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCategoryCard('5', 'Precious & Tangible', Icons.diamond, Colors.yellow[700]!)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildCategoryCard('7', 'Financial & Business', Icons.trending_up, Colors.green)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCategoryCard('3', 'Sustainable & Alter...', Icons.eco, Colors.teal)),
                        const SizedBox(width: 12),
                        Expanded(child: Container()), // Empty space for alignment
                      ],
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Recent Activity
          Text(
            'Recent Activity',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          _buildActivityList(),

          // Add bottom padding to prevent overflow
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'User Management',
                style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddUserDialog,
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text('Add User', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // User Statistics
          Row(
            children: [
              Expanded(child: _buildUserStatCard('Total Users', '156', Icons.people, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildUserStatCard('Active Users', '142', Icons.person, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildUserStatCard('Pending Approval', '8', Icons.pending, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildUserStatCard('Suspended', '6', Icons.block, Colors.red)),
            ],
          ),
          const SizedBox(height: 24),

          // User List
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Name', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 2, child: Text('Email', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 1, child: Text('Role', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 1, child: Text('Status', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 1, child: Text('Actions', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                    ],
                  ),
                ),
                // User Rows
                ..._buildUserRows(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Management',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[700]!,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Assets',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      // Desktop: Single row
                      return Row(
                        children: [
                          Expanded(
                            child: _buildFilterDropdown('Category', _selectedCategory, [
                              'All Categories', 'Real Estate', 'Transportation', 'Precious Metals', 'Financial', 'Sustainable'
                            ], (value) => setState(() => _selectedCategory = value!)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFilterDropdown('Status', _selectedStatus, [
                              'All Status', 'Active', 'Pending', 'Locked', 'Under Review'
                            ], (value) => setState(() => _selectedStatus = value!)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildFilterDropdown('Verification', _selectedVerification, [
                              'All', 'Verified', 'Pending', 'Failed'
                            ], (value) => setState(() => _selectedVerification = value!)),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddAssetDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Asset'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      );
                    } else {
                      // Mobile: Multiple rows
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterDropdown('Category', _selectedCategory, [
                                  'All Categories', 'Real Estate', 'Transportation', 'Precious Metals', 'Financial', 'Sustainable'
                                ], (value) => setState(() => _selectedCategory = value!)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildFilterDropdown('Status', _selectedStatus, [
                                  'All Status', 'Active', 'Pending', 'Locked', 'Under Review'
                                ], (value) => setState(() => _selectedStatus = value!)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterDropdown('Verification', _selectedVerification, [
                                  'All', 'Verified', 'Pending', 'Failed'
                                ], (value) => setState(() => _selectedVerification = value!)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _showAddAssetDialog,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Asset'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: ${_getFilteredAssetsCount()} assets',
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Assets List
          _buildAssetsList(),
        ],
      ),
    );
  }

  Widget _buildAssetsList() {
    List<Map<String, dynamic>> filteredAssets = _getFilteredAssets();

    if (filteredAssets.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No assets found',
              style: AppTextStyles.heading3.copyWith(color: Colors.grey[400]),
            ),
            Text(
              'Try adjusting your filters',
              style: AppTextStyles.body2.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredAssets.length,
      itemBuilder: (context, index) {
        final asset = filteredAssets[index];
        return _buildAssetCard(asset, index);
      },
    );
  }

  Widget _buildAssetCard(Map<String, dynamic> asset, int index) {
    final isMovable = asset['isMovable'] ?? false;
    final hasLiveTracking = asset['hasLiveTracking'] ?? false;
    final lastMovement = asset['lastMovement'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMovable ? AppColors.warning.withOpacity(0.3) : Colors.grey[700]!,
          width: isMovable ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset Image
              Container(
                width: 80,
                height: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    asset['image'] as String,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Asset Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            asset['title'],
                            style: AppTextStyles.heading3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isMovable) ...[
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'MOVABLE',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          asset['id'],
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.grey[400],
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: asset['category'] == 'Real Estate' ? Colors.blue.withOpacity(0.2) :
                                   asset['category'] == 'Transportation' ? Colors.green.withOpacity(0.2) :
                                   asset['category'] == 'Precious Metals' ? Colors.orange.withOpacity(0.2) :
                                   Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            asset['category'],
                            style: AppTextStyles.caption.copyWith(
                              color: asset['category'] == 'Real Estate' ? Colors.blue :
                                     asset['category'] == 'Transportation' ? Colors.green :
                                     asset['category'] == 'Precious Metals' ? Colors.orange :
                                     Colors.purple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NAV: ${asset['nav']} • ${asset['location']}',
                      style: AppTextStyles.body2.copyWith(color: Colors.grey[300]),
                    ),
                    if (hasLiveTracking && asset['currentLocation'] != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.gps_fixed, size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Live: ${asset['currentLocation']['address']}',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (lastMovement != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 14, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            'Last moved: ${_formatDateTime(lastMovement)}',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Status and Controls
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(asset['status']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      asset['status'],
                      style: AppTextStyles.caption.copyWith(
                        color: _getStatusColor(asset['status']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getVerificationColor(asset['verification']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      asset['verification'],
                      style: AppTextStyles.caption.copyWith(
                        color: _getVerificationColor(asset['verification']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Colors.grey),
          const SizedBox(height: 8),

          // Visibility Controls and Actions
          Row(
            children: [
              // Visibility toggles
              Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('Visible:', style: AppTextStyles.caption.copyWith(color: Colors.grey[400])),
                  const SizedBox(width: 8),
                  Switch(
                    value: asset['isVisible'] ?? true,
                    onChanged: (value) => _toggleAssetVisibility(asset['id'], 'isVisible', value),
                    activeColor: AppColors.success,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Row(
                children: [
                  Icon(Icons.public, size: 16, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('Public:', style: AppTextStyles.caption.copyWith(color: Colors.grey[400])),
                  const SizedBox(width: 8),
                  Switch(
                    value: asset['isPublic'] ?? true,
                    onChanged: (value) => _toggleAssetVisibility(asset['id'], 'isPublic', value),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const Spacer(),

              // Action buttons
              if (hasLiveTracking)
                IconButton(
                  onPressed: () => _showLiveTracking(asset),
                  icon: Icon(Icons.track_changes, color: AppColors.success),
                  tooltip: 'View Live Tracking',
                ),
              IconButton(
                onPressed: () => _showAssetDetails(asset),
                icon: Icon(Icons.info_outline, color: Colors.grey[400]),
                tooltip: 'View Details',
              ),
              IconButton(
                onPressed: () => _showAssetActions(asset),
                icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                tooltip: 'More Actions',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'locked':
        return AppColors.error;
      case 'under review':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  Color _getVerificationColor(String verification) {
    switch (verification.toLowerCase()) {
      case 'verified':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'failed':
        return AppColors.error;
      case 'under review':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _toggleAssetVisibility(String assetId, String field, bool value) {
    setState(() {
      // Find and update the asset in the local data
      final assets = _getAllAssets();
      final assetIndex = assets.indexWhere((asset) => asset['id'] == assetId);
      if (assetIndex != -1) {
        assets[assetIndex][field] = value;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Asset $field updated to $value'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLiveTracking(Map<String, dynamic> asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Live Tracking: ${asset['title']}',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (asset['currentLocation'] != null) ...[
              Text('Current Location:', style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold)),
              Text('${asset['currentLocation']['address']}', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              Text('Coordinates:', style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold)),
              Text('${asset['currentLocation']['lat']}, ${asset['currentLocation']['lng']}', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.gps_fixed, color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Text('Live tracking active', style: TextStyle(color: AppColors.success)),
                  ],
                ),
              ),
            ] else ...[
              Text('No location data available', style: TextStyle(color: Colors.grey[400])),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
          if (asset['currentLocation'] != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Open map view
              },
              child: Text('View on Map'),
            ),
        ],
      ),
    );
  }

  void _showAssetDetails(Map<String, dynamic> asset) {
    // TODO: Navigate to detailed asset view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Asset details for ${asset['title']}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _showAssetActions(Map<String, dynamic> asset) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Asset Actions',
              style: AppTextStyles.heading3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.white),
              title: Text('Edit Asset', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open edit dialog
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: Colors.white),
              title: Text('View History', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show asset history
              },
            ),
            if (asset['isMovable'] == true) ...[
              ListTile(
                leading: Icon(Icons.notifications, color: AppColors.warning),
                title: Text('Movement Alerts', style: TextStyle(color: Colors.white)),
                subtitle: Text('Configure push notifications', style: TextStyle(color: Colors.grey[400])),
                onTap: () {
                  Navigator.pop(context);
                  _showMovementAlerts(asset);
                },
              ),
            ],
            ListTile(
              leading: Icon(Icons.delete, color: AppColors.error),
              title: Text('Delete Asset', style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show delete confirmation
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMovementAlerts(Map<String, dynamic> asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Movement Alerts: ${asset['title']}',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text('Real-time notifications', style: TextStyle(color: Colors.white)),
              subtitle: Text('Get notified when asset moves', style: TextStyle(color: Colors.grey[400])),
              value: true, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Update notification settings
              },
              activeColor: AppColors.success,
            ),
            SwitchListTile(
              title: Text('Geofence alerts', style: TextStyle(color: Colors.white)),
              subtitle: Text('Alert when leaving designated area', style: TextStyle(color: Colors.grey[400])),
              value: false, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Update geofence settings
              },
              activeColor: AppColors.warning,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Movement alerts updated for ${asset['title']}'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddAssetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Add New Asset',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Asset creation functionality coming soon...',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(Icons.info, color: AppColors.info, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    'New features will include:\n• Real estate tokenization\n• Vehicle asset tracking\n• Precious metals verification\n• Automatic compliance checks',
                    style: TextStyle(color: AppColors.info),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Asset Categories Management',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // Category Statistics
          Row(
            children: [
              Expanded(child: _buildStatCard('3', 'Total Categories', Icons.category, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('${_getFilteredAssets().length}', 'Total Assets', Icons.business_center, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('${_getActiveAssetsCount()}', 'Active Assets', Icons.verified, Colors.purple)),
            ],
          ),

          const SizedBox(height: 32),

          // Category Cards
          Text(
            'Categories',
            style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildClickableCategoryCard('Real Estate', Icons.home, Colors.blue, 4),
              _buildClickableCategoryCard('Transportation', Icons.directions_car, Colors.orange, 1),
              _buildClickableCategoryCard('Precious Metals', Icons.diamond, Colors.amber, 1),
            ],
          ),

          const SizedBox(height: 32),

          // Category Distribution Chart Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category Distribution',
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
              ),
              Row(
                children: [
                  Text('Bar Chart', style: TextStyle(color: Colors.grey[400])),
                  const SizedBox(width: 8),
                  Switch(
                    value: _showPieChart,
                    onChanged: (value) {
                      setState(() {
                        _showPieChart = value;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text('Pie Chart', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart Container
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: _showPieChart ? _buildCategoryPieChart() : _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Activity',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // Activity Statistics
          Row(
            children: [
              Expanded(child: _buildStatCard('1,247', 'Total Activities', Icons.timeline, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('89', 'Today', Icons.today, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('23', 'Critical Events', Icons.warning, Colors.red)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('156', 'Active Users', Icons.people, Colors.purple)),
            ],
          ),

          const SizedBox(height: 32),

          // Activity Filter
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown('Activity Type', 'All Types', [
                  'All Types', 'User Actions', 'Trading', 'Asset Management', 'System Events', 'Security'
                ], (value) {}),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFilterDropdown('Time Range', 'Last 24 Hours', [
                  'Last 24 Hours', 'Last 7 Days', 'Last 30 Days', 'Custom Range'
                ], (value) {}),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download),
                label: const Text('Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Enhanced Activity List
          _buildEnhancedActivityList(),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics Dashboard',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // Analytics Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Key Metrics',
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Text('Chart View: ', style: AppTextStyles.body2),
                  Switch(
                    value: _showPieChart,
                    onChanged: (value) => setState(() => _showPieChart = value),
                    activeColor: AppColors.primary,
                  ),
                  Text(_showPieChart ? 'Pie Chart' : 'Line Graph', style: AppTextStyles.body2),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Key Metrics Row
          Row(
            children: [
              Expanded(child: _buildAnalyticsCard('Total Revenue', '\$2.8M', '↗ 12.5%', Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildAnalyticsCard('Active Investments', '1,247', '↗ 8.2%', Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildAnalyticsCard('Platform Fees', '\$142K', '↗ 15.3%', Colors.purple)),
              const SizedBox(width: 16),
              Expanded(child: _buildAnalyticsCard('User Growth', '+89', '↗ 22.1%', Colors.orange)),
            ],
          ),

          const SizedBox(height: 32),

          // Charts Section - Dynamic based on toggle
          _showPieChart ?
            Row(
              children: [
                Expanded(
                  child: _buildPieChartCard('Revenue Distribution', 300),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPieChartCard('Asset Distribution', 300),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildChartCard('Asset Performance Over Time', 300),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildChartCard('Revenue Trends', 300),
                ),
              ],
            ),

          const SizedBox(height: 32),

          // Performance Metrics
          Row(
            children: [
              Expanded(
                child: _buildMetricsTable('Top Performing Assets'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricsTable('User Engagement'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compliance Dashboard',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // Compliance Status Overview - Clickable
          Row(
            children: [
              Expanded(child: _buildClickableComplianceCard('KYC Status', '142 / 156', '91%', Colors.green, () => _showKYCList())),
              const SizedBox(width: 16),
              Expanded(child: _buildClickableComplianceCard('AML Checks', '156 / 156', '100%', Colors.green, () => _showAMLList())),
              const SizedBox(width: 16),
              Expanded(child: _buildClickableComplianceCard('Doc Verification', '28 / 30', '93%', Colors.orange, () => _showDocVerificationList())),
              const SizedBox(width: 16),
              Expanded(child: _buildClickableComplianceCard('Risk Assessment', '30 / 30', '100%', Colors.green, () => _showRiskAssessmentList())),
            ],
          ),

          const SizedBox(height: 32),

          // Compliance Alerts & Flags
          Text(
            'Compliance Alerts & Flags',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildComplianceAlertsCard(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRiskLevelsCard(),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Regulatory Reports & Audit Trail
          Row(
            children: [
              Expanded(
                child: _buildRegulatoryReportsCard(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAuditTrailCard(),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Compliance Metrics
          _buildComplianceMetricsCard(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body2.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String count, String title, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            count,
            style: AppTextStyles.heading1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    final activities = [
      {
        'icon': Icons.person_add,
        'title': 'New user registered: investor2@example.com',
        'subtitle': 'System • 2 hours ago',
        'color': Colors.blue,
      },
      {
        'icon': Icons.business_center,
        'title': 'New asset added: Historic Brownstone - Brooklyn, NY',
        'subtitle': 'admin@rwa-platform.com • 4 hours ago',
        'color': Colors.green,
      },
      {
        'icon': Icons.verified,
        'title': 'Asset verification completed: SPV-007',
        'subtitle': 'verifier@example.com • 6 hours ago',
        'color': Colors.purple,
      },
      {
        'icon': Icons.attach_money,
        'title': 'Investment order placed: \$50,000 in SPV-003',
        'subtitle': 'investor@example.com • 8 hours ago',
        'color': Colors.orange,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey[700],
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: (activity['color'] as Color).withOpacity(0.1),
              child: Icon(
                activity['icon'] as IconData,
                color: activity['color'] as Color,
                size: 20,
              ),
            ),
            title: Text(
              activity['title'] as String,
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            subtitle: Text(
              activity['subtitle'] as String,
              style: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
            ),
          );
        },
      ),
    );
  }


  Widget _buildAnalyticsCard(String title, String value, String change, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: AppTextStyles.body2.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildLineChart(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(String title, double height) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildPieChart(title),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsTable(String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[700]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Metrics Table\nPlaceholder',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(String title, String value, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              percentage,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceAlertsCard() {
    final alerts = [
      {
        'type': 'KYC Incomplete',
        'user': 'john.doe@example.com',
        'severity': 'Medium',
        'time': '2 hours ago',
        'color': Colors.orange,
      },
      {
        'type': 'Document Expired',
        'user': 'jane.smith@example.com',
        'severity': 'High',
        'time': '4 hours ago',
        'color': Colors.red,
      },
      {
        'type': 'Suspicious Activity',
        'user': 'user123@example.com',
        'severity': 'Critical',
        'time': '6 hours ago',
        'color': Colors.red[800]!,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Text(
                'Recent Compliance Alerts',
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...alerts.map((alert) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (alert['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (alert['color'] as Color).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: alert['color'] as Color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        alert['severity'] as String,
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      alert['time'] as String,
                      style: AppTextStyles.body2.copyWith(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  alert['type'] as String,
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  alert['user'] as String,
                  style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRiskLevelsCard() {
    final riskData = [
      {'level': 'Low Risk', 'count': '120', 'color': Colors.green},
      {'level': 'Medium Risk', 'count': '28', 'color': Colors.orange},
      {'level': 'High Risk', 'count': '6', 'color': Colors.red},
      {'level': 'Critical', 'count': '2', 'color': Colors.red[800]!},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Risk Levels',
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...riskData.map((risk) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: risk['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    risk['level'] as String,
                    style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                Text(
                  risk['count'] as String,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: risk['color'] as Color,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRegulatoryReportsCard() {
    final reports = [
      {
        'title': 'Monthly Compliance Report',
        'status': 'Generated',
        'date': 'Sept 1, 2024',
        'icon': Icons.description,
      },
      {
        'title': 'AML Monitoring Report',
        'status': 'Pending',
        'date': 'Due Sept 15, 2024',
        'icon': Icons.security,
      },
      {
        'title': 'Risk Assessment Summary',
        'status': 'In Review',
        'date': 'Sept 10, 2024',
        'icon': Icons.assessment,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_open, color: Colors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                'Regulatory Reports',
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...reports.map((report) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  report['icon'] as IconData,
                  color: Colors.blue,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report['title'] as String,
                        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        report['date'] as String,
                        style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report['status'] as String).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report['status'] as String,
                    style: AppTextStyles.body2.copyWith(
                      color: _getStatusColor(report['status'] as String),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAuditTrailCard() {
    final auditItems = [
      {
        'action': 'User KYC Updated',
        'user': 'admin@platform.com',
        'time': '10:30 AM',
        'icon': Icons.person,
      },
      {
        'action': 'Document Verified',
        'user': 'verifier@platform.com',
        'time': '09:15 AM',
        'icon': Icons.verified,
      },
      {
        'action': 'Risk Score Modified',
        'user': 'admin@platform.com',
        'time': '08:45 AM',
        'icon': Icons.speed,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'Audit Trail',
                style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...auditItems.map((item) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.green,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['action'] as String,
                        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'by ${item['user']}',
                        style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Text(
                  item['time'] as String,
                  style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildComplianceMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compliance Metrics & Trends',
            style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.analytics, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Compliance Trends Chart'),
                  Text('(Implementation needed)', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // Missing methods for compilation
  Widget _buildFilterDropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: Colors.grey[800],
            style: AppTextStyles.body2.copyWith(color: Colors.white),
            underline: const SizedBox.shrink(),
            isExpanded: true,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildClickableCategoryCard(String category, IconData icon, Color color, int count) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _tabController.animateTo(2); // Switch to Assets tab
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[700]!),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              count.toString(),
              style: AppTextStyles.heading2.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart() {
    return const Center(
      child: Text(
        'Pie Chart\n(Chart implementation needed)',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBarChart() {
    return const Center(
      child: Text(
        'Bar Chart\n(Chart implementation needed)',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildClickableComplianceCard(String title, String value, String percentage, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: _buildComplianceCard(title, value, percentage, color),
    );
  }

  Widget _buildEnhancedActivityList() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: const Center(
        child: Text(
          'Enhanced Activity List\n(Implementation needed)',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return const Center(
      child: Text(
        'Line Chart\n(Chart implementation needed)',
        style: TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPieChart(String title) {
    return Center(
      child: Text(
        'Pie Chart: $title\n(Chart implementation needed)',
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildIOTFleetTab() {
    List<Map<String, dynamic>> iotAssets = _getAllAssets()
        .where((asset) => asset['hasIOT'] == true)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'IOT Fleet Monitoring',
            style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 24),

          // Fleet Overview Cards
          _buildFleetOverview(iotAssets),
          const SizedBox(height: 24),

          // Live Fleet Status
          Text(
            'Live Fleet Status',
            style: AppTextStyles.heading3.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),

          // IOT Assets List
          ...iotAssets.map((asset) => _buildIOTAssetCard(asset)),
        ],
      ),
    );
  }

  Widget _buildFleetOverview(List<Map<String, dynamic>> iotAssets) {
    int totalFleetSize = iotAssets.fold(0, (sum, asset) => sum + (asset['fleetSize'] as int? ?? 0));
    int activeAssets = iotAssets.where((asset) => asset['status'] == 'Active').length;

    return Row(
      children: [
        Expanded(
          child: _buildIOTStatCard(
            'Total IOT Assets',
            '${iotAssets.length}',
            Icons.sensors,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildIOTStatCard(
            'Fleet Vehicles',
            '$totalFleetSize',
            Icons.directions_car,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildIOTStatCard(
            'Active Assets',
            '$activeAssets',
            Icons.online_prediction,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildIOTStatCard(
            'Avg Health Score',
            '91%',
            Icons.health_and_safety,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildIOTStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LIVE',
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildIOTAssetCard(Map<String, dynamic> asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          // Asset Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    asset['image'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[700],
                        child: const Icon(Icons.image_not_supported, color: Colors.white54),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset['title'],
                        style: AppTextStyles.heading3.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            asset['location'],
                            style: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Fleet Size',
                      style: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
                    ),
                    Text(
                      '${asset['fleetSize']}',
                      style: AppTextStyles.heading3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // AI Insights
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'AI Insights',
                      style: AppTextStyles.body1.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getHealthScoreColor(asset['aiInsights']['healthScore']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Health: ${asset['aiInsights']['healthScore']}%',
                        style: AppTextStyles.caption.copyWith(
                          color: _getHealthScoreColor(asset['aiInsights']['healthScore']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  asset['aiInsights']['predictedMaintenance'],
                  style: AppTextStyles.body2.copyWith(color: Colors.grey[300]),
                ),
                const SizedBox(height: 8),
                Text(
                  asset['aiInsights']['riskAssessment'],
                  style: AppTextStyles.body2.copyWith(color: Colors.grey[300]),
                ),
                const SizedBox(height: 16),

                // Sensor Status Grid
                Text(
                  'Sensor Status',
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSensorGrid(asset['iotSensors']),

                const SizedBox(height: 16),

                // Fleet Metrics
                Text(
                  'Fleet Metrics',
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFleetMetrics(asset['fleetMetrics']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorGrid(Map<String, dynamic> sensors) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: sensors.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[600]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getSensorStatusColor(entry.value['status'] as String? ?? 'unknown'),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.key.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFleetMetrics(Map<String, dynamic> metrics) {
    return Column(
      children: metrics.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  entry.key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                  style: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
                ),
              ),
              Text(
                entry.value.toString(),
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.orange;
    return Colors.red;
  }

  Color _getSensorStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'good':
      case 'optimal':
      case 'operational':
      case 'healthy':
      case 'compliant':
      case 'monitored':
      case 'all clear':
        return Colors.green;
      case 'standby':
      case 'shore power':
      case 'monitoring':
      case 'armed':
      case 'ready':
        return Colors.blue;
      case 'warning':
      case 'maintenance':
        return Colors.orange;
      case 'offline':
      case 'error':
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Placeholder methods for compliance functionality
  void _showKYCList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('KYC List - Coming Soon')),
    );
  }

  void _showAMLList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AML List - Coming Soon')),
    );
  }

  void _showDocVerificationList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document Verification List - Coming Soon')),
    );
  }

  void _showRiskAssessmentList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Risk Assessment List - Coming Soon')),
    );
  }


  // User Management Methods
  Widget _buildUserStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUserRows() {
    final users = [
      {
        'name': 'Sarah Johnson',
        'email': 'sarah.johnson@email.com',
        'role': 'Investor Agent',
        'status': 'Active',
        'joinDate': '2024-01-15',
        'lastActive': '2 hours ago',
      },
      {
        'name': 'Michael Chen',
        'email': 'michael.chen@email.com',
        'role': 'Professional Agent',
        'status': 'Active',
        'joinDate': '2024-02-20',
        'lastActive': '5 minutes ago',
      },
      {
        'name': 'Emma Davis',
        'email': 'emma.davis@email.com',
        'role': 'Verifier',
        'status': 'Active',
        'joinDate': '2024-01-10',
        'lastActive': '1 day ago',
      },
      {
        'name': 'Robert Wilson',
        'email': 'robert.wilson@email.com',
        'role': 'Investor Agent',
        'status': 'Pending',
        'joinDate': '2024-09-20',
        'lastActive': 'Never',
      },
      {
        'name': 'Lisa Anderson',
        'email': 'lisa.anderson@email.com',
        'role': 'Professional Agent',
        'status': 'Suspended',
        'joinDate': '2024-03-05',
        'lastActive': '2 weeks ago',
      },
    ];

    return users.map((user) => _buildUserRow(user)).toList();
  }

  Widget _buildUserRow(Map<String, dynamic> user) {
    Color statusColor;
    switch (user['status']) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'Suspended':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[700]!, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Joined: ${user['joinDate']}',
                  style: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['email'],
                  style: AppTextStyles.body2.copyWith(color: Colors.white),
                ),
                Text(
                  'Last active: ${user['lastActive']}',
                  style: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user['role'],
                style: AppTextStyles.caption.copyWith(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user['status'],
                style: AppTextStyles.caption.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _editUser(user),
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 18),
                  tooltip: 'Edit User',
                ),
                IconButton(
                  onPressed: () => _deleteUser(user),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 18),
                  tooltip: 'Delete User',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add New User', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.grey[800],
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Role',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                items: ['Investor Agent', 'Professional Agent', 'Verifier', 'Admin']
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role, style: TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User would be added to the system'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: Text('Add User', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editUser(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit user: ${user['name']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete User', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete ${user['name']}? This action cannot be undone.',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('User ${user['name']} has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Statistics
          Row(
            children: [
              Text(
                'Insurance Document Management',
                style: AppTextStyles.heading2.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showAddInsuranceDocumentDialog,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Policy', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Insurance Statistics Cards
          Row(
            children: [
              Expanded(child: _buildInsuranceStatCard('Total Policies', '5', Icons.shield, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildInsuranceStatCard('Active Policies', '4', Icons.verified, Colors.green)),
              const SizedBox(width: 16),
              Expanded(child: _buildInsuranceStatCard('Expiring Soon', '1', Icons.warning, Colors.orange)),
              const SizedBox(width: 16),
              Expanded(child: _buildInsuranceStatCard('Total Coverage', '\$18.1M', Icons.monetization_on, Colors.purple)),
            ],
          ),
          const SizedBox(height: 24),

          // Insurance Documents Table
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!),
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 2, child: Text('Asset & Policy', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 2, child: Text('Provider & Coverage', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 1, child: Text('Status', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 1, child: Text('Expiry', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                      Expanded(flex: 1, child: Text('Actions', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: Colors.white))),
                    ],
                  ),
                ),
                // Insurance Document Rows
                ..._buildInsuranceDocumentRows(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInsuranceDocumentRows() {
    final documents = _getFilteredInsuranceDocuments();
    return documents.map((doc) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
      ),
      child: Row(
        children: [
          // Asset & Policy Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['assetTitle'],
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  doc['documentType'],
                  style: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
                ),
                const SizedBox(height: 2),
                Text(
                  doc['policyNumber'],
                  style: AppTextStyles.caption.copyWith(color: Colors.grey[500], fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          // Provider & Coverage
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['provider'],
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  doc['coverageAmount'],
                  style: AppTextStyles.body2.copyWith(color: Colors.green),
                ),
                const SizedBox(height: 2),
                Text(
                  doc['premium'],
                  style: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
                ),
              ],
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getInsuranceStatusColor(doc['status']).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                doc['status'],
                style: AppTextStyles.caption.copyWith(
                  color: _getInsuranceStatusColor(doc['status']),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Expiry Info
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['expiryDate'],
                  style: AppTextStyles.body2.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  '${doc['daysToExpiry']} days',
                  style: AppTextStyles.caption.copyWith(
                    color: doc['daysToExpiry'] < 30 ? Colors.red : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showInsuranceDocumentDetails(doc),
                  icon: const Icon(Icons.visibility, color: Colors.blue),
                  tooltip: 'View Details',
                ),
                IconButton(
                  onPressed: () => _editInsuranceDocument(doc),
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Edit',
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) => _handleInsuranceDocumentAction(value, doc),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'download', child: Text('Download PDF')),
                    const PopupMenuItem(value: 'renew', child: Text('Renew Policy')),
                    const PopupMenuItem(value: 'claim', child: Text('File Claim')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )).toList();
  }

  Color _getInsuranceStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Under Review':
        return Colors.orange;
      case 'Expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showAddInsuranceDocumentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Insurance Policy', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Asset ID',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Policy Type',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Provider',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Coverage Amount',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Insurance policy added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Add Policy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showInsuranceDocumentDetails(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Insurance Policy Details', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Policy Number', document['policyNumber']),
                _buildDetailRow('Asset', document['assetTitle']),
                _buildDetailRow('Document Type', document['documentType']),
                _buildDetailRow('Provider', document['provider']),
                _buildDetailRow('Coverage Amount', document['coverageAmount']),
                _buildDetailRow('Premium', document['premium']),
                _buildDetailRow('Status', document['status']),
                _buildDetailRow('Issue Date', document['issueDate']),
                _buildDetailRow('Expiry Date', document['expiryDate']),
                _buildDetailRow('Last Reviewed', document['lastReviewed']),
                const SizedBox(height: 16),
                Text('Coverage Details', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                ...(document['coverage'] as Map<String, dynamic>).entries.map(
                  (entry) => _buildDetailRow(entry.key, entry.value.toString()),
                ),
                if ((document['claims'] as List).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Claims History', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                  const SizedBox(height: 8),
                  ...(document['claims'] as List).map((claim) => Card(
                    color: Colors.grey[800],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Claim ID', claim['claimId']),
                          _buildDetailRow('Date', claim['date']),
                          _buildDetailRow('Amount', claim['amount']),
                          _buildDetailRow('Status', claim['status']),
                          _buildDetailRow('Description', claim['description']),
                        ],
                      ),
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.grey[400])),
          ),
        ],
      ),
    );
  }

  void _editInsuranceDocument(Map<String, dynamic> document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing policy ${document['policyNumber']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleInsuranceDocumentAction(String action, Map<String, dynamic> document) {
    switch (action) {
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloading ${document['policyNumber']}.pdf'),
            backgroundColor: Colors.green,
          ),
        );
        break;
      case 'renew':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Renewing policy ${document['policyNumber']}'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'claim':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filing claim for ${document['policyNumber']}'),
            backgroundColor: Colors.orange,
          ),
        );
        break;
      case 'delete':
        _showDeleteInsuranceDocumentDialog(document);
        break;
    }
  }

  void _showDeleteInsuranceDocumentDialog(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Delete Insurance Policy', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete policy ${document['policyNumber']}? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Policy ${document['policyNumber']} has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: AppTextStyles.body2.copyWith(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Missing method implementations
  void _shareAsset(Map<String, dynamic> asset) {
    // Placeholder implementation for sharing asset
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Share Asset', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        content: Text('Share functionality for ${asset['title']} will be implemented here.',
            style: AppTextStyles.body1.copyWith(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _handleAssetDetailAction(String action, Map<String, dynamic> asset) {
    // Placeholder implementation for handling asset detail actions
    switch (action) {
      case 'edit':
        // Edit asset functionality
        break;
      case 'delete':
        // Delete asset functionality
        break;
      case 'duplicate':
        // Duplicate asset functionality
        break;
      default:
        print('Unknown action: $action');
    }
  }

  Color _getAssetStatusColor(String status) {
    // Return color based on asset status
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'locked':
        return Colors.red;
      case 'under review':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  void _updateAssetNAV(Map<String, dynamic> asset) {
    // Placeholder implementation for updating asset NAV
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Update NAV', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update NAV for ${asset['title']}',
                style: AppTextStyles.body1.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'New NAV Value',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Update', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _addDividend(Map<String, dynamic> asset) {
    // Placeholder implementation for adding dividend
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Add Dividend', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add dividend for ${asset['title']}',
                style: AppTextStyles.body1.copyWith(color: Colors.white)),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Dividend Amount',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Add', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _bulkTransfer() {
    // Placeholder implementation for bulk transfer
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Bulk Transfer', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        content: Text('Bulk transfer functionality will be implemented here.',
            style: AppTextStyles.body1.copyWith(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _generateAssetReport() {
    // Placeholder implementation for generating asset report
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Generate Report', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        content: Text('Asset report generation will be implemented here.',
            style: AppTextStyles.body1.copyWith(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _scheduleValuation() {
    // Placeholder implementation for scheduling valuation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Schedule Valuation', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        content: Text('Valuation scheduling will be implemented here.',
            style: AppTextStyles.body1.copyWith(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _runComplianceCheck() {
    // Placeholder implementation for running compliance check
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('Compliance Check', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
        content: Text('Compliance check will be implemented here.',
            style: AppTextStyles.body1.copyWith(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: Colors.white),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Row(
        children: [
          Icon(
            activity['icon'] as IconData? ?? Icons.info,
            color: activity['color'] as Color? ?? Colors.blue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] ?? 'Unknown Activity',
                  style: AppTextStyles.body1.copyWith(color: Colors.white),
                ),
                if (activity['description'] != null)
                  Text(
                    activity['description'],
                    style: AppTextStyles.caption.copyWith(color: Colors.grey[400]),
                  ),
              ],
            ),
          ),
          Text(
            activity['time'] ?? '',
            style: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(color: Colors.grey[400]),
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              color: valueColor ?? Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}
