import 'asset_categories.dart';

class AssetLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String state;
  final String country;

  AssetLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
  });

  factory AssetLocation.fromJson(Map<String, dynamic> json) {
    return AssetLocation(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
    );
  }

  String get fullAddress => '$address, $city, $state, $country';
  String get shortAddress => '$city, $state';
}

class Asset {
  final int id;
  final String type;
  final String title;
  final String spvId;
  final String status;
  final String nav;
  final bool verificationRequired;
  final DateTime createdAt;
  final List<String> images;
  final AssetLocation? location;
  final String? description;
  final AssetCategory? category;
  final AssetSubCategory? subCategory;

  Asset({
    required this.id,
    required this.type,
    required this.title,
    required this.spvId,
    required this.status,
    required this.nav,
    required this.verificationRequired,
    required this.createdAt,
    this.images = const [],
    this.location,
    this.description,
    this.category,
    this.subCategory,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    final subCat = _getSubCategoryFromType(json['type']);
    return Asset(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      spvId: json['spv_id'],
      status: json['status'],
      nav: json['nav'],
      verificationRequired: json['verification_required'],
      createdAt: DateTime.parse(json['createdAt']),
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : _getDefaultImages(json['type']),
      location: json['location'] != null
          ? AssetLocation.fromJson(json['location'])
          : _getDefaultLocation(json['type']),
      description: json['description'],
      subCategory: subCat,
      category: subCat?.category,
    );
  }

  static AssetSubCategory? _getSubCategoryFromType(String type) {
    switch (type.toLowerCase()) {
      // Real Estate
      case 'house':
      case 'residential':
        return AssetSubCategory.residentialHouses;
      case 'apartment':
      case 'flat':
        return AssetSubCategory.apartments;
      case 'commercial':
      case 'office':
      case 'retail':
        return AssetSubCategory.commercialBuildings;
      case 'hotel':
      case 'resort':
        return AssetSubCategory.hotels;
      case 'warehouse':
      case 'storage':
        return AssetSubCategory.warehouses;
      case 'farmland':
      case 'agricultural':
        return AssetSubCategory.farmlands;
      case 'land':
      case 'plot':
        return AssetSubCategory.vacantPlots;

      // Transportation
      case 'car':
      case 'vehicle':
      case 'fleet':
        return AssetSubCategory.cars;
      case 'bus':
      case 'coach':
        return AssetSubCategory.buses;
      case 'truck':
      case 'trailer':
        return AssetSubCategory.trucks;
      case 'motorbike':
      case 'motorcycle':
        return AssetSubCategory.motorbikes;
      case 'boat':
      case 'ferry':
        return AssetSubCategory.boats;
      case 'aircraft':
      case 'plane':
        return AssetSubCategory.aircraft;

      // Precious
      case 'gold':
        return AssetSubCategory.gold;
      case 'silver':
        return AssetSubCategory.silver;
      case 'diamond':
      case 'gemstone':
        return AssetSubCategory.diamonds;
      case 'watch':
      case 'collectible':
        return AssetSubCategory.luxuryWatches;
      case 'metal':
      case 'copper':
      case 'lithium':
        return AssetSubCategory.industrialMetals;

      // Financial
      case 'shares':
      case 'equity':
        return AssetSubCategory.companyShares;
      case 'bond':
        return AssetSubCategory.bonds;
      case 'business':
      case 'enterprise':
        return AssetSubCategory.businesses;
      case 'franchise':
        return AssetSubCategory.franchiseRights;

      // Sustainable
      case 'solar':
      case 'wind':
      case 'renewable':
        return AssetSubCategory.renewableEnergy;
      case 'agriculture':
      case 'farming':
        return AssetSubCategory.agricultural;
      case 'carbon':
      case 'environmental':
        return AssetSubCategory.carbonCredits;

      default:
        return null;
    }
  }

  static List<String> _getDefaultImages(String type) {
    switch (type.toLowerCase()) {
      // Real Estate
      case 'house':
      case 'residential':
        return [
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
          'https://images.unsplash.com/photo-1523217582562-09d0def993a6?w=800',
        ];
      case 'apartment':
      case 'flat':
        return [
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800',
        ];
      case 'commercial':
      case 'office':
      case 'retail':
        return [
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        ];
      case 'hotel':
      case 'resort':
        return [
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
        ];
      case 'warehouse':
      case 'storage':
        return [
          'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=800',
          'https://images.unsplash.com/photo-1565883011550-66b8aacdae0a?w=800',
        ];
      case 'farmland':
      case 'agricultural':
        return [
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
          'https://images.unsplash.com/photo-1574263867128-a4bd8d1c6b2e?w=800',
        ];
      case 'land':
      case 'plot':
        return [
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
          'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800',
        ];

      // Transportation
      case 'car':
      case 'vehicle':
      case 'fleet':
        return [
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800',
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800',
        ];
      case 'bus':
      case 'coach':
        return [
          'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=800',
          'https://images.unsplash.com/photo-1558618667-fcd25c85cd64?w=800',
        ];
      case 'truck':
      case 'trailer':
        return [
          'https://images.unsplash.com/photo-1601584115197-04ecc0da31d7?w=800',
          'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800',
        ];
      case 'motorbike':
      case 'motorcycle':
        return [
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
          'https://images.unsplash.com/photo-1449426468159-d96dbf08f19f?w=800',
        ];
      case 'boat':
      case 'ferry':
        return [
          'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800',
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
        ];
      case 'aircraft':
      case 'plane':
        return [
          'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
          'https://images.unsplash.com/photo-1569629142374-fcc1fbda4912?w=800',
        ];

      // Precious
      case 'gold':
        return [
          'https://images.unsplash.com/photo-1610375461246-83df859d849d?w=800',
          'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?w=800',
        ];
      case 'silver':
        return [
          'https://images.unsplash.com/photo-1609177982263-77a63ac0c5e9?w=800',
          'https://images.unsplash.com/photo-1594736797933-d0401ba2fe65?w=800',
        ];
      case 'diamond':
      case 'gemstone':
        return [
          'https://images.unsplash.com/photo-1584555613497-9ecf9dd06f68?w=800',
          'https://images.unsplash.com/photo-1596944924616-7b38e7cfac36?w=800',
        ];
      case 'watch':
      case 'collectible':
        return [
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314?w=800',
          'https://images.unsplash.com/photo-1609081219090-a6d81d3085bf?w=800',
        ];
      case 'metal':
      case 'copper':
      case 'lithium':
        return [
          'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=800',
          'https://images.unsplash.com/photo-1581094794329-c8112a89af12?w=800',
        ];

      // Financial
      case 'shares':
      case 'equity':
        return [
          'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=800',
          'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800',
        ];
      case 'bond':
        return [
          'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=800',
          'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=800',
        ];
      case 'business':
      case 'enterprise':
        return [
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
          'https://images.unsplash.com/photo-1556155092-8707de31f9c4?w=800',
        ];
      case 'franchise':
        return [
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
          'https://images.unsplash.com/photo-1600880292203-757bb62b4baf?w=800',
        ];

      // Sustainable
      case 'solar':
      case 'wind':
      case 'renewable':
        return [
          'https://images.unsplash.com/photo-1466611653911-95081537e5b7?w=800',
          'https://images.unsplash.com/photo-1509391366360-2e959784a276?w=800',
        ];
      case 'agriculture':
      case 'farming':
        return [
          'https://images.unsplash.com/photo-1574263867128-a4bd8d1c6b2e?w=800',
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=800',
        ];
      case 'carbon':
      case 'environmental':
        return [
          'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=800',
          'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=800',
        ];

      default:
        return [
          'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=800',
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
        ];
    }
  }

  static AssetLocation _getDefaultLocation(String type) {
    switch (type.toLowerCase()) {
      // Real Estate
      case 'house':
      case 'residential':
        return AssetLocation(
          latitude: 40.7128,
          longitude: -74.0060,
          address: '123 Residential Ave',
          city: 'New York',
          state: 'NY',
          country: 'USA',
        );
      case 'apartment':
      case 'flat':
        return AssetLocation(
          latitude: 40.7831,
          longitude: -73.9712,
          address: '456 Urban Plaza',
          city: 'New York',
          state: 'NY',
          country: 'USA',
        );
      case 'commercial':
      case 'office':
      case 'retail':
        return AssetLocation(
          latitude: 37.7749,
          longitude: -122.4194,
          address: '555 Business Center',
          city: 'San Francisco',
          state: 'CA',
          country: 'USA',
        );
      case 'hotel':
      case 'resort':
        return AssetLocation(
          latitude: 34.0522,
          longitude: -118.2437,
          address: '456 Hospitality Blvd',
          city: 'Los Angeles',
          state: 'CA',
          country: 'USA',
        );
      case 'warehouse':
      case 'storage':
        return AssetLocation(
          latitude: 41.8781,
          longitude: -87.6298,
          address: '789 Industrial Way',
          city: 'Chicago',
          state: 'IL',
          country: 'USA',
        );
      case 'farmland':
      case 'agricultural':
        return AssetLocation(
          latitude: 30.2672,
          longitude: -97.7431,
          address: '321 Rural Road',
          city: 'Austin',
          state: 'TX',
          country: 'USA',
        );
      case 'land':
      case 'plot':
        return AssetLocation(
          latitude: 39.7392,
          longitude: -104.9903,
          address: '654 Development Drive',
          city: 'Denver',
          state: 'CO',
          country: 'USA',
        );

      // Transportation
      case 'car':
      case 'vehicle':
      case 'fleet':
        return AssetLocation(
          latitude: 42.3601,
          longitude: -71.0589,
          address: '123 Auto Plaza',
          city: 'Boston',
          state: 'MA',
          country: 'USA',
        );
      case 'bus':
      case 'coach':
        return AssetLocation(
          latitude: 39.2904,
          longitude: -76.6122,
          address: '456 Transit Hub',
          city: 'Baltimore',
          state: 'MD',
          country: 'USA',
        );
      case 'truck':
      case 'trailer':
        return AssetLocation(
          latitude: 41.8781,
          longitude: -87.6298,
          address: '789 Transport St',
          city: 'Chicago',
          state: 'IL',
          country: 'USA',
        );
      case 'motorbike':
      case 'motorcycle':
        return AssetLocation(
          latitude: 25.7617,
          longitude: -80.1918,
          address: '321 Bike Boulevard',
          city: 'Miami',
          state: 'FL',
          country: 'USA',
        );
      case 'boat':
      case 'ferry':
        return AssetLocation(
          latitude: 47.6062,
          longitude: -122.3321,
          address: '654 Marina Drive',
          city: 'Seattle',
          state: 'WA',
          country: 'USA',
        );
      case 'aircraft':
      case 'plane':
        return AssetLocation(
          latitude: 33.9425,
          longitude: -118.4081,
          address: '987 Aviation Way',
          city: 'Los Angeles',
          state: 'CA',
          country: 'USA',
        );

      // Precious (Financial centers)
      case 'gold':
      case 'silver':
      case 'diamond':
      case 'gemstone':
      case 'watch':
      case 'collectible':
      case 'metal':
      case 'copper':
      case 'lithium':
        return AssetLocation(
          latitude: 40.7614,
          longitude: -73.9776,
          address: '47 Precious Metals Exchange',
          city: 'New York',
          state: 'NY',
          country: 'USA',
        );

      // Financial
      case 'shares':
      case 'equity':
      case 'bond':
      case 'business':
      case 'enterprise':
      case 'franchise':
        return AssetLocation(
          latitude: 40.7589,
          longitude: -73.9851,
          address: '200 Financial District',
          city: 'New York',
          state: 'NY',
          country: 'USA',
        );

      // Sustainable
      case 'solar':
      case 'wind':
      case 'renewable':
        return AssetLocation(
          latitude: 36.1699,
          longitude: -115.1398,
          address: '789 Solar Farm Road',
          city: 'Las Vegas',
          state: 'NV',
          country: 'USA',
        );
      case 'agriculture':
      case 'farming':
        return AssetLocation(
          latitude: 30.2672,
          longitude: -97.7431,
          address: '123 Organic Farm Lane',
          city: 'Austin',
          state: 'TX',
          country: 'USA',
        );
      case 'carbon':
      case 'environmental':
        return AssetLocation(
          latitude: 45.5152,
          longitude: -122.6784,
          address: '456 Green Initiative Way',
          city: 'Portland',
          state: 'OR',
          country: 'USA',
        );

      default:
        return AssetLocation(
          latitude: 37.7749,
          longitude: -122.4194,
          address: '555 Business Center',
          city: 'San Francisco',
          state: 'CA',
          country: 'USA',
        );
    }
  }

  String get formattedNav {
    final value = double.parse(nav);
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${value.toStringAsFixed(0)}';
    }
  }

  String get statusColor {
    switch (status) {
      case 'active':
        return 'success';
      case 'pending':
        return 'warning';
      case 'suspended':
        return 'error';
      default:
        return 'secondary';
    }
  }

  String get typeIcon {
    switch (type) {
      case 'house':
        return 'home';
      case 'hotel':
        return 'hotel';
      case 'truck':
        return 'local_shipping';
      case 'land':
        return 'landscape';
      default:
        return 'business';
    }
  }
}

class AssetResponse {
  final List<Asset> items;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  AssetResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory AssetResponse.fromJson(Map<String, dynamic> json) {
    return AssetResponse(
      items: (json['items'] as List)
          .map((item) => Asset.fromJson(item))
          .toList(),
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
      hasMore: json['hasMore'],
    );
  }
}