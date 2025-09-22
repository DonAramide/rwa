class BrandConfig {
  final String id;
  final String bankId;
  final String brandName;
  final BrandColors colors;
  final BrandAssets assets;
  final BrandTypography typography;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BrandConfig({
    required this.id,
    required this.bankId,
    required this.brandName,
    required this.colors,
    required this.assets,
    required this.typography,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrandConfig.fromJson(Map<String, dynamic> json) {
    return BrandConfig(
      id: json['id'],
      bankId: json['bankId'],
      brandName: json['brandName'],
      colors: BrandColors.fromJson(json['colors']),
      assets: BrandAssets.fromJson(json['assets']),
      typography: BrandTypography.fromJson(json['typography']),
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankId': bankId,
      'brandName': brandName,
      'colors': colors.toJson(),
      'assets': assets.toJson(),
      'typography': typography.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BrandConfig copyWith({
    String? id,
    String? bankId,
    String? brandName,
    BrandColors? colors,
    BrandAssets? assets,
    BrandTypography? typography,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BrandConfig(
      id: id ?? this.id,
      bankId: bankId ?? this.bankId,
      brandName: brandName ?? this.brandName,
      colors: colors ?? this.colors,
      assets: assets ?? this.assets,
      typography: typography ?? this.typography,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BrandColors {
  final String primary;
  final String secondary;
  final String accent;
  final String background;
  final String surface;
  final String error;
  final String onPrimary;
  final String onSecondary;
  final String onBackground;
  final String onSurface;
  final String onError;

  BrandColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.onError,
  });

  factory BrandColors.fromJson(Map<String, dynamic> json) {
    return BrandColors(
      primary: json['primary'] ?? '#2196F3',
      secondary: json['secondary'] ?? '#03DAC6',
      accent: json['accent'] ?? '#FFC107',
      background: json['background'] ?? '#FFFFFF',
      surface: json['surface'] ?? '#FFFFFF',
      error: json['error'] ?? '#B00020',
      onPrimary: json['onPrimary'] ?? '#FFFFFF',
      onSecondary: json['onSecondary'] ?? '#000000',
      onBackground: json['onBackground'] ?? '#000000',
      onSurface: json['onSurface'] ?? '#000000',
      onError: json['onError'] ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'accent': accent,
      'background': background,
      'surface': surface,
      'error': error,
      'onPrimary': onPrimary,
      'onSecondary': onSecondary,
      'onBackground': onBackground,
      'onSurface': onSurface,
      'onError': onError,
    };
  }

  factory BrandColors.defaultColors() {
    return BrandColors(
      primary: '#2196F3',
      secondary: '#03DAC6',
      accent: '#FFC107',
      background: '#FFFFFF',
      surface: '#FFFFFF',
      error: '#B00020',
      onPrimary: '#FFFFFF',
      onSecondary: '#000000',
      onBackground: '#000000',
      onSurface: '#000000',
      onError: '#FFFFFF',
    );
  }
}

class BrandAssets {
  final String? logoUrl;
  final String? logoLightUrl;
  final String? logoDarkUrl;
  final String? faviconUrl;
  final String? backgroundImageUrl;
  final String? watermarkUrl;

  BrandAssets({
    this.logoUrl,
    this.logoLightUrl,
    this.logoDarkUrl,
    this.faviconUrl,
    this.backgroundImageUrl,
    this.watermarkUrl,
  });

  factory BrandAssets.fromJson(Map<String, dynamic> json) {
    return BrandAssets(
      logoUrl: json['logoUrl'],
      logoLightUrl: json['logoLightUrl'],
      logoDarkUrl: json['logoDarkUrl'],
      faviconUrl: json['faviconUrl'],
      backgroundImageUrl: json['backgroundImageUrl'],
      watermarkUrl: json['watermarkUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logoUrl': logoUrl,
      'logoLightUrl': logoLightUrl,
      'logoDarkUrl': logoDarkUrl,
      'faviconUrl': faviconUrl,
      'backgroundImageUrl': backgroundImageUrl,
      'watermarkUrl': watermarkUrl,
    };
  }

  factory BrandAssets.defaultAssets() {
    return BrandAssets();
  }
}

class BrandTypography {
  final String fontFamily;
  final String headingFontFamily;
  final Map<String, double> fontSizes;
  final Map<String, String> fontWeights;

  BrandTypography({
    required this.fontFamily,
    required this.headingFontFamily,
    required this.fontSizes,
    required this.fontWeights,
  });

  factory BrandTypography.fromJson(Map<String, dynamic> json) {
    return BrandTypography(
      fontFamily: json['fontFamily'] ?? 'Roboto',
      headingFontFamily: json['headingFontFamily'] ?? 'Roboto',
      fontSizes: Map<String, double>.from(json['fontSizes'] ?? _defaultFontSizes),
      fontWeights: Map<String, String>.from(json['fontWeights'] ?? _defaultFontWeights),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontFamily': fontFamily,
      'headingFontFamily': headingFontFamily,
      'fontSizes': fontSizes,
      'fontWeights': fontWeights,
    };
  }

  static const Map<String, double> _defaultFontSizes = {
    'h1': 32.0,
    'h2': 28.0,
    'h3': 24.0,
    'h4': 20.0,
    'h5': 18.0,
    'h6': 16.0,
    'body1': 16.0,
    'body2': 14.0,
    'caption': 12.0,
  };

  static const Map<String, String> _defaultFontWeights = {
    'light': '300',
    'regular': '400',
    'medium': '500',
    'semiBold': '600',
    'bold': '700',
  };

  factory BrandTypography.defaultTypography() {
    return BrandTypography(
      fontFamily: 'Roboto',
      headingFontFamily: 'Roboto',
      fontSizes: _defaultFontSizes,
      fontWeights: _defaultFontWeights,
    );
  }
}