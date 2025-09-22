import 'package:flutter/material.dart';

enum AssetCategory {
  realEstate,
  transportation,
  precious,
  financial,
  sustainable,
}

enum AssetSubCategory {
  // Real Estate
  residentialHouses,
  apartments,
  commercialBuildings,
  hotels,
  warehouses,
  farmlands,
  vacantPlots,

  // Transportation & Mobility
  cars,
  buses,
  trucks,
  motorbikes,
  boats,
  aircraft,

  // Precious & Tangible
  gold,
  silver,
  diamonds,
  luxuryWatches,
  industrialMetals,

  // Financial & Business
  companyShares,
  bonds,
  businesses,
  franchiseRights,

  // Sustainable & Alternative
  renewableEnergy,
  agricultural,
  carbonCredits,
}

extension AssetCategoryExtension on AssetCategory {
  String get displayName {
    switch (this) {
      case AssetCategory.realEstate:
        return 'Real Estate';
      case AssetCategory.transportation:
        return 'Transportation & Mobility';
      case AssetCategory.precious:
        return 'Precious & Tangible';
      case AssetCategory.financial:
        return 'Financial & Business';
      case AssetCategory.sustainable:
        return 'Sustainable & Alternative';
    }
  }

  String get description {
    switch (this) {
      case AssetCategory.realEstate:
        return 'Property investments including residential, commercial, and land assets';
      case AssetCategory.transportation:
        return 'Vehicles and transportation assets for logistics and mobility services';
      case AssetCategory.precious:
        return 'Precious metals, gems, collectibles, and industrial commodities';
      case AssetCategory.financial:
        return 'Equity investments, business ownership, and revenue-generating assets';
      case AssetCategory.sustainable:
        return 'Green investments in renewable energy, agriculture, and environmental projects';
    }
  }

  IconData get icon {
    switch (this) {
      case AssetCategory.realEstate:
        return Icons.home;
      case AssetCategory.transportation:
        return Icons.directions_car;
      case AssetCategory.precious:
        return Icons.diamond;
      case AssetCategory.financial:
        return Icons.trending_up;
      case AssetCategory.sustainable:
        return Icons.eco;
    }
  }

  Color get color {
    switch (this) {
      case AssetCategory.realEstate:
        return Colors.blue;
      case AssetCategory.transportation:
        return Colors.orange;
      case AssetCategory.precious:
        return Colors.amber;
      case AssetCategory.financial:
        return Colors.green;
      case AssetCategory.sustainable:
        return Colors.teal;
    }
  }

  List<AssetSubCategory> get subCategories {
    switch (this) {
      case AssetCategory.realEstate:
        return [
          AssetSubCategory.residentialHouses,
          AssetSubCategory.apartments,
          AssetSubCategory.commercialBuildings,
          AssetSubCategory.hotels,
          AssetSubCategory.warehouses,
          AssetSubCategory.farmlands,
          AssetSubCategory.vacantPlots,
        ];
      case AssetCategory.transportation:
        return [
          AssetSubCategory.cars,
          AssetSubCategory.buses,
          AssetSubCategory.trucks,
          AssetSubCategory.motorbikes,
          AssetSubCategory.boats,
          AssetSubCategory.aircraft,
        ];
      case AssetCategory.precious:
        return [
          AssetSubCategory.gold,
          AssetSubCategory.silver,
          AssetSubCategory.diamonds,
          AssetSubCategory.luxuryWatches,
          AssetSubCategory.industrialMetals,
        ];
      case AssetCategory.financial:
        return [
          AssetSubCategory.companyShares,
          AssetSubCategory.bonds,
          AssetSubCategory.businesses,
          AssetSubCategory.franchiseRights,
        ];
      case AssetCategory.sustainable:
        return [
          AssetSubCategory.renewableEnergy,
          AssetSubCategory.agricultural,
          AssetSubCategory.carbonCredits,
        ];
    }
  }
}

extension AssetSubCategoryExtension on AssetSubCategory {
  String get displayName {
    switch (this) {
      // Real Estate
      case AssetSubCategory.residentialHouses:
        return 'Residential Houses';
      case AssetSubCategory.apartments:
        return 'Apartments / Flats';
      case AssetSubCategory.commercialBuildings:
        return 'Commercial Buildings';
      case AssetSubCategory.hotels:
        return 'Hotels & Resorts';
      case AssetSubCategory.warehouses:
        return 'Warehouses & Storage';
      case AssetSubCategory.farmlands:
        return 'Farmlands';
      case AssetSubCategory.vacantPlots:
        return 'Vacant Plots / Land';

      // Transportation
      case AssetSubCategory.cars:
        return 'Cars & Fleets';
      case AssetSubCategory.buses:
        return 'Buses & Coaches';
      case AssetSubCategory.trucks:
        return 'Trucks & Trailers';
      case AssetSubCategory.motorbikes:
        return 'Motorbikes';
      case AssetSubCategory.boats:
        return 'Boats & Ferries';
      case AssetSubCategory.aircraft:
        return 'Aircraft';

      // Precious
      case AssetSubCategory.gold:
        return 'Gold';
      case AssetSubCategory.silver:
        return 'Silver';
      case AssetSubCategory.diamonds:
        return 'Diamonds & Gemstones';
      case AssetSubCategory.luxuryWatches:
        return 'Luxury Watches & Collectibles';
      case AssetSubCategory.industrialMetals:
        return 'Industrial Metals';

      // Financial
      case AssetSubCategory.companyShares:
        return 'Company Shares';
      case AssetSubCategory.bonds:
        return 'Bonds';
      case AssetSubCategory.businesses:
        return 'Revenue-Generating Businesses';
      case AssetSubCategory.franchiseRights:
        return 'Franchise Rights & Licenses';

      // Sustainable
      case AssetSubCategory.renewableEnergy:
        return 'Renewable Energy Projects';
      case AssetSubCategory.agricultural:
        return 'Agricultural Projects';
      case AssetSubCategory.carbonCredits:
        return 'Carbon Credits';
    }
  }

  String get description {
    switch (this) {
      // Real Estate
      case AssetSubCategory.residentialHouses:
        return 'Single-family homes, villas, and residential properties for rental income';
      case AssetSubCategory.apartments:
        return 'Multi-unit residential buildings and condominium complexes';
      case AssetSubCategory.commercialBuildings:
        return 'Office buildings, retail shops, plazas, and commercial spaces';
      case AssetSubCategory.hotels:
        return 'Hotels, resorts, and hospitality properties';
      case AssetSubCategory.warehouses:
        return 'Industrial storage facilities and logistics centers';
      case AssetSubCategory.farmlands:
        return 'Agricultural land for crop production and farming operations';
      case AssetSubCategory.vacantPlots:
        return 'Undeveloped land plots for future development';

      // Transportation
      case AssetSubCategory.cars:
        return 'Vehicle fleets for ride-hailing, logistics, and rental services';
      case AssetSubCategory.buses:
        return 'Public transport buses and private coach services';
      case AssetSubCategory.trucks:
        return 'Commercial trucks and trailers for freight transport';
      case AssetSubCategory.motorbikes:
        return 'Motorcycles for delivery services and ride-hailing';
      case AssetSubCategory.boats:
        return 'Watercraft for transport, tourism, and fishing operations';
      case AssetSubCategory.aircraft:
        return 'Small aircraft for charter services and leasing partnerships';

      // Precious
      case AssetSubCategory.gold:
        return 'Physical gold investments and gold-backed securities';
      case AssetSubCategory.silver:
        return 'Silver bullion and silver-based investment products';
      case AssetSubCategory.diamonds:
        return 'Precious gemstones and diamond investment portfolios';
      case AssetSubCategory.luxuryWatches:
        return 'High-value collectibles and luxury timepieces';
      case AssetSubCategory.industrialMetals:
        return 'Copper, lithium, and other industrial commodity investments';

      // Financial
      case AssetSubCategory.companyShares:
        return 'Private equity investments and startup company shares';
      case AssetSubCategory.bonds:
        return 'Corporate and government bonds (when regulated)';
      case AssetSubCategory.businesses:
        return 'Operating businesses including shops, factories, and farms';
      case AssetSubCategory.franchiseRights:
        return 'Franchise ownership and licensing opportunities';

      // Sustainable
      case AssetSubCategory.renewableEnergy:
        return 'Solar farms, wind turbines, and clean energy infrastructure';
      case AssetSubCategory.agricultural:
        return 'Palm oil plantations, rice mills, fisheries, and agribusiness';
      case AssetSubCategory.carbonCredits:
        return 'Environmental projects and carbon offset investments';
    }
  }

  IconData get icon {
    switch (this) {
      // Real Estate
      case AssetSubCategory.residentialHouses:
        return Icons.house;
      case AssetSubCategory.apartments:
        return Icons.apartment;
      case AssetSubCategory.commercialBuildings:
        return Icons.business;
      case AssetSubCategory.hotels:
        return Icons.hotel;
      case AssetSubCategory.warehouses:
        return Icons.warehouse;
      case AssetSubCategory.farmlands:
        return Icons.agriculture;
      case AssetSubCategory.vacantPlots:
        return Icons.landscape;

      // Transportation
      case AssetSubCategory.cars:
        return Icons.directions_car;
      case AssetSubCategory.buses:
        return Icons.directions_bus;
      case AssetSubCategory.trucks:
        return Icons.local_shipping;
      case AssetSubCategory.motorbikes:
        return Icons.two_wheeler;
      case AssetSubCategory.boats:
        return Icons.directions_boat;
      case AssetSubCategory.aircraft:
        return Icons.flight;

      // Precious
      case AssetSubCategory.gold:
        return Icons.star;
      case AssetSubCategory.silver:
        return Icons.circle;
      case AssetSubCategory.diamonds:
        return Icons.diamond;
      case AssetSubCategory.luxuryWatches:
        return Icons.watch;
      case AssetSubCategory.industrialMetals:
        return Icons.construction;

      // Financial
      case AssetSubCategory.companyShares:
        return Icons.trending_up;
      case AssetSubCategory.bonds:
        return Icons.account_balance;
      case AssetSubCategory.businesses:
        return Icons.store;
      case AssetSubCategory.franchiseRights:
        return Icons.business_center;

      // Sustainable
      case AssetSubCategory.renewableEnergy:
        return Icons.solar_power;
      case AssetSubCategory.agricultural:
        return Icons.eco;
      case AssetSubCategory.carbonCredits:
        return Icons.nature;
    }
  }

  AssetCategory get category {
    switch (this) {
      case AssetSubCategory.residentialHouses:
      case AssetSubCategory.apartments:
      case AssetSubCategory.commercialBuildings:
      case AssetSubCategory.hotels:
      case AssetSubCategory.warehouses:
      case AssetSubCategory.farmlands:
      case AssetSubCategory.vacantPlots:
        return AssetCategory.realEstate;

      case AssetSubCategory.cars:
      case AssetSubCategory.buses:
      case AssetSubCategory.trucks:
      case AssetSubCategory.motorbikes:
      case AssetSubCategory.boats:
      case AssetSubCategory.aircraft:
        return AssetCategory.transportation;

      case AssetSubCategory.gold:
      case AssetSubCategory.silver:
      case AssetSubCategory.diamonds:
      case AssetSubCategory.luxuryWatches:
      case AssetSubCategory.industrialMetals:
        return AssetCategory.precious;

      case AssetSubCategory.companyShares:
      case AssetSubCategory.bonds:
      case AssetSubCategory.businesses:
      case AssetSubCategory.franchiseRights:
        return AssetCategory.financial;

      case AssetSubCategory.renewableEnergy:
      case AssetSubCategory.agricultural:
      case AssetSubCategory.carbonCredits:
        return AssetCategory.sustainable;
    }
  }

  List<String> get typicalUseCases {
    switch (this) {
      case AssetSubCategory.residentialHouses:
        return ['Rental income', 'Capital appreciation', 'Family housing'];
      case AssetSubCategory.apartments:
        return ['Multi-tenant rental', 'Student housing', 'Urban investment'];
      case AssetSubCategory.commercialBuildings:
        return ['Office leasing', 'Retail spaces', 'Mixed-use development'];
      case AssetSubCategory.hotels:
        return ['Tourism revenue', 'Business travel', 'Event hosting'];
      case AssetSubCategory.warehouses:
        return ['E-commerce storage', 'Industrial leasing', 'Logistics hubs'];
      case AssetSubCategory.farmlands:
        return ['Crop production', 'Agricultural leasing', 'Food security'];
      case AssetSubCategory.vacantPlots:
        return ['Future development', 'Land appreciation', 'Subdivision'];

      case AssetSubCategory.cars:
        return ['Ride-hailing services', 'Car rental', 'Fleet management'];
      case AssetSubCategory.buses:
        return ['Public transport', 'Tourism', 'School services'];
      case AssetSubCategory.trucks:
        return ['Freight transport', 'Logistics', 'Delivery services'];
      case AssetSubCategory.motorbikes:
        return ['Food delivery', 'Urban mobility', 'Last-mile logistics'];
      case AssetSubCategory.boats:
        return ['Ferry services', 'Tourism', 'Fishing operations'];
      case AssetSubCategory.aircraft:
        return ['Charter flights', 'Cargo transport', 'Tourism'];

      case AssetSubCategory.gold:
        return ['Inflation hedge', 'Portfolio diversification', 'Store of value'];
      case AssetSubCategory.silver:
        return ['Industrial demand', 'Investment hedge', 'Jewelry'];
      case AssetSubCategory.diamonds:
        return ['Luxury investment', 'Store of value', 'Collectibles'];
      case AssetSubCategory.luxuryWatches:
        return ['Collectible investment', 'Luxury market', 'Heritage value'];
      case AssetSubCategory.industrialMetals:
        return ['Manufacturing demand', 'Technology sector', 'Infrastructure'];

      case AssetSubCategory.companyShares:
        return ['Startup investment', 'Business growth', 'Dividend income'];
      case AssetSubCategory.bonds:
        return ['Fixed income', 'Capital preservation', 'Portfolio stability'];
      case AssetSubCategory.businesses:
        return ['Operating income', 'Business ownership', 'Cash flow'];
      case AssetSubCategory.franchiseRights:
        return ['Brand licensing', 'Business model', 'Territorial rights'];

      case AssetSubCategory.renewableEnergy:
        return ['Clean energy production', 'Government incentives', 'ESG investing'];
      case AssetSubCategory.agricultural:
        return ['Food production', 'Export revenue', 'Sustainable farming'];
      case AssetSubCategory.carbonCredits:
        return ['Environmental impact', 'Carbon offsetting', 'Green investments'];
    }
  }
}