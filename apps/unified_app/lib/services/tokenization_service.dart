import 'package:flutter/foundation.dart';
import '../models/asset_upload_models.dart';
import '../core/api_client.dart';

/// Service for handling asset tokenization and smart contract deployment
class TokenizationService {
  /// Deploy smart contract for asset tokenization
  static Future<TokenizationResult> deployTokenContract({
    required TokenizationConfig config,
    String? network,
  }) async {
    try {
      debugPrint('Deploying token contract for asset: ${config.assetUploadId}');

      // In a real implementation, this would:
      // 1. Connect to blockchain network (Ethereum/Polygon)
      // 2. Deploy ERC-20 or ERC-1400 contract
      // 3. Set metadata and ownership rules
      // 4. Configure dividend distribution

      final deploymentData = {
        'assetUploadId': config.assetUploadId,
        'tokenName': config.tokenName,
        'tokenSymbol': config.tokenSymbol,
        'totalSupply': config.totalSupply,
        'decimals': config.decimals,
        'pricePerToken': config.pricePerToken,
        'network': network ?? 'polygon', // Default to Polygon for lower fees
        'contractType': 'ERC1400', // Security token standard
        'features': [
          'transferRestrictions',
          'dividendDistribution',
          'votingRights',
          'compliance',
        ],
      };

      final result = await ApiClient.deployTokenContract(deploymentData);

      if (result['success'] == true) {
        final contractAddress = result['contractAddress'] as String;
        final txHash = result['transactionHash'] as String;

        // Update configuration with deployment details
        final updatedConfig = TokenizationConfig(
          assetUploadId: config.assetUploadId,
          contractAddress: contractAddress,
          tokenName: config.tokenName,
          tokenSymbol: config.tokenSymbol,
          totalSupply: config.totalSupply,
          decimals: config.decimals,
          pricePerToken: config.pricePerToken,
          deploymentDate: DateTime.now(),
          isDeployed: true,
          deploymentTxHash: txHash,
          contractMetadata: {
            'network': network ?? 'polygon',
            'blockNumber': result['blockNumber'],
            'gasUsed': result['gasUsed'],
            'deployerAddress': result['deployerAddress'],
          },
        );

        // Store tokenization config
        await _storeTokenizationConfig(updatedConfig);

        return TokenizationResult(
          success: true,
          config: updatedConfig,
          transactionHash: txHash,
        );
      } else {
        return TokenizationResult(
          success: false,
          error: result['error'] as String? ?? 'Deployment failed',
        );
      }
    } catch (e) {
      debugPrint('Tokenization deployment error: $e');
      return TokenizationResult(
        success: false,
        error: 'Deployment failed: ${e.toString()}',
      );
    }
  }

  /// Mint initial tokens to asset owner
  static Future<bool> mintInitialTokens({
    required String contractAddress,
    required String ownerAddress,
    required int amount,
  }) async {
    try {
      final result = await ApiClient.mintTokens({
        'contractAddress': contractAddress,
        'to': ownerAddress,
        'amount': amount,
        'reason': 'Initial asset tokenization',
      });

      return result['success'] == true;
    } catch (e) {
      debugPrint('Token minting error: $e');
      return false;
    }
  }

  /// Configure compliance rules for security tokens
  static Future<bool> setComplianceRules({
    required String contractAddress,
    required List<ComplianceRule> rules,
  }) async {
    try {
      final rulesData = rules.map((rule) => rule.toJson()).toList();

      final result = await ApiClient.setComplianceRules({
        'contractAddress': contractAddress,
        'rules': rulesData,
      });

      return result['success'] == true;
    } catch (e) {
      debugPrint('Compliance rules error: $e');
      return false;
    }
  }

  /// Set up dividend distribution configuration
  static Future<bool> configureDividendDistribution({
    required String contractAddress,
    required DividendConfig dividendConfig,
  }) async {
    try {
      final result = await ApiClient.configureDividends({
        'contractAddress': contractAddress,
        'config': dividendConfig.toJson(),
      });

      return result['success'] == true;
    } catch (e) {
      debugPrint('Dividend configuration error: $e');
      return false;
    }
  }

  /// Transfer tokens between addresses
  static Future<TokenTransferResult> transferTokens({
    required String contractAddress,
    required String fromAddress,
    required String toAddress,
    required int amount,
    String? reason,
  }) async {
    try {
      final result = await ApiClient.transferTokens({
        'contractAddress': contractAddress,
        'from': fromAddress,
        'to': toAddress,
        'amount': amount,
        'reason': reason ?? 'Token transfer',
      });

      if (result['success'] == true) {
        return TokenTransferResult(
          success: true,
          transactionHash: result['transactionHash'] as String,
          blockNumber: result['blockNumber'] as int?,
        );
      } else {
        return TokenTransferResult(
          success: false,
          error: result['error'] as String? ?? 'Transfer failed',
        );
      }
    } catch (e) {
      debugPrint('Token transfer error: $e');
      return TokenTransferResult(
        success: false,
        error: 'Transfer failed: ${e.toString()}',
      );
    }
  }

  /// Get token balance for an address
  static Future<TokenBalance?> getTokenBalance({
    required String contractAddress,
    required String holderAddress,
  }) async {
    try {
      final result = await ApiClient.getTokenBalance({
        'contractAddress': contractAddress,
        'address': holderAddress,
      });

      if (result['success'] == true) {
        return TokenBalance.fromJson(result['balance']);
      }
      return null;
    } catch (e) {
      debugPrint('Token balance error: $e');
      return null;
    }
  }

  /// Get all token holders for a contract
  static Future<List<TokenHolder>> getTokenHolders(String contractAddress) async {
    try {
      final result = await ApiClient.getTokenHolders({'contractAddress': contractAddress});

      if (result['success'] == true) {
        final holders = (result['holders'] as List)
            .map((h) => TokenHolder.fromJson(h))
            .toList();
        return holders;
      }
      return [];
    } catch (e) {
      debugPrint('Token holders error: $e');
      return [];
    }
  }

  /// Distribute dividends to token holders
  static Future<DividendDistributionResult> distributeDividends({
    required String contractAddress,
    required double totalAmount,
    required String currency,
    String? reason,
  }) async {
    try {
      final result = await ApiClient.distributeDividends({
        'contractAddress': contractAddress,
        'totalAmount': totalAmount,
        'currency': currency,
        'reason': reason ?? 'Dividend distribution',
      });

      if (result['success'] == true) {
        return DividendDistributionResult(
          success: true,
          distributionId: result['distributionId'] as String,
          transactionHashes: List<String>.from(result['transactionHashes'] ?? []),
          totalRecipients: result['totalRecipients'] as int? ?? 0,
          totalDistributed: result['totalDistributed'] as double? ?? 0,
        );
      } else {
        return DividendDistributionResult(
          success: false,
          error: result['error'] as String? ?? 'Distribution failed',
        );
      }
    } catch (e) {
      debugPrint('Dividend distribution error: $e');
      return DividendDistributionResult(
        success: false,
        error: 'Distribution failed: ${e.toString()}',
      );
    }
  }

  /// Get tokenization status and metrics
  static Future<TokenizationMetrics?> getTokenizationMetrics(String contractAddress) async {
    try {
      final result = await ApiClient.getTokenizationMetrics({'contractAddress': contractAddress});

      if (result['success'] == true) {
        return TokenizationMetrics.fromJson(result['metrics']);
      }
      return null;
    } catch (e) {
      debugPrint('Tokenization metrics error: $e');
      return null;
    }
  }

  /// Validate token transaction before execution
  static Future<TokenValidationResult> validateTransaction({
    required String contractAddress,
    required String fromAddress,
    required String toAddress,
    required int amount,
  }) async {
    try {
      final result = await ApiClient.validateTokenTransaction({
        'contractAddress': contractAddress,
        'from': fromAddress,
        'to': toAddress,
        'amount': amount,
      });

      return TokenValidationResult.fromJson(result);
    } catch (e) {
      debugPrint('Transaction validation error: $e');
      return TokenValidationResult(
        isValid: false,
        errors: ['Validation failed: ${e.toString()}'],
      );
    }
  }

  // Private helper methods
  static Future<void> _storeTokenizationConfig(TokenizationConfig config) async {
    await ApiClient.storeTokenizationConfig(config.toJson());
  }
}

/// Tokenization result model
class TokenizationResult {
  final bool success;
  final TokenizationConfig? config;
  final String? transactionHash;
  final String? error;

  const TokenizationResult({
    required this.success,
    this.config,
    this.transactionHash,
    this.error,
  });
}

/// Token transfer result
class TokenTransferResult {
  final bool success;
  final String? transactionHash;
  final int? blockNumber;
  final String? error;

  const TokenTransferResult({
    required this.success,
    this.transactionHash,
    this.blockNumber,
    this.error,
  });
}

/// Token balance model
class TokenBalance {
  final String address;
  final int balance;
  final double percentage;
  final DateTime lastUpdated;

  const TokenBalance({
    required this.address,
    required this.balance,
    required this.percentage,
    required this.lastUpdated,
  });

  factory TokenBalance.fromJson(Map<String, dynamic> json) {
    return TokenBalance(
      address: json['address'] as String,
      balance: json['balance'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }
}

/// Token holder model
class TokenHolder {
  final String address;
  final String? name;
  final int balance;
  final double percentage;
  final DateTime firstPurchase;
  final DateTime lastTransaction;
  final bool isVerified;

  const TokenHolder({
    required this.address,
    this.name,
    required this.balance,
    required this.percentage,
    required this.firstPurchase,
    required this.lastTransaction,
    this.isVerified = false,
  });

  factory TokenHolder.fromJson(Map<String, dynamic> json) {
    return TokenHolder(
      address: json['address'] as String,
      name: json['name'] as String?,
      balance: json['balance'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      firstPurchase: DateTime.parse(json['firstPurchase'] as String),
      lastTransaction: DateTime.parse(json['lastTransaction'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}

/// Compliance rule model
class ComplianceRule {
  final String name;
  final String type;
  final Map<String, dynamic> parameters;
  final bool isActive;

  const ComplianceRule({
    required this.name,
    required this.type,
    required this.parameters,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'parameters': parameters,
      'isActive': isActive,
    };
  }
}

/// Dividend configuration model
class DividendConfig {
  final String distributionMethod; // automatic, manual
  final String frequency; // monthly, quarterly, annually
  final double minimumDistribution;
  final bool autoReinvest;
  final List<String> eligibleHolders;

  const DividendConfig({
    required this.distributionMethod,
    required this.frequency,
    required this.minimumDistribution,
    this.autoReinvest = false,
    this.eligibleHolders = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'distributionMethod': distributionMethod,
      'frequency': frequency,
      'minimumDistribution': minimumDistribution,
      'autoReinvest': autoReinvest,
      'eligibleHolders': eligibleHolders,
    };
  }
}

/// Dividend distribution result
class DividendDistributionResult {
  final bool success;
  final String? distributionId;
  final List<String> transactionHashes;
  final int totalRecipients;
  final double totalDistributed;
  final String? error;

  const DividendDistributionResult({
    required this.success,
    this.distributionId,
    this.transactionHashes = const [],
    this.totalRecipients = 0,
    this.totalDistributed = 0,
    this.error,
  });
}

/// Tokenization metrics model
class TokenizationMetrics {
  final String contractAddress;
  final int totalSupply;
  final int circulatingSupply;
  final int uniqueHolders;
  final double marketCap;
  final double totalDividendsDistributed;
  final int totalTransactions;
  final DateTime lastActivity;

  const TokenizationMetrics({
    required this.contractAddress,
    required this.totalSupply,
    required this.circulatingSupply,
    required this.uniqueHolders,
    required this.marketCap,
    required this.totalDividendsDistributed,
    required this.totalTransactions,
    required this.lastActivity,
  });

  factory TokenizationMetrics.fromJson(Map<String, dynamic> json) {
    return TokenizationMetrics(
      contractAddress: json['contractAddress'] as String,
      totalSupply: json['totalSupply'] as int,
      circulatingSupply: json['circulatingSupply'] as int,
      uniqueHolders: json['uniqueHolders'] as int,
      marketCap: (json['marketCap'] as num).toDouble(),
      totalDividendsDistributed: (json['totalDividendsDistributed'] as num).toDouble(),
      totalTransactions: json['totalTransactions'] as int,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
    );
  }
}

/// Token validation result
class TokenValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  const TokenValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    this.metadata = const {},
  });

  factory TokenValidationResult.fromJson(Map<String, dynamic> json) {
    return TokenValidationResult(
      isValid: json['isValid'] as bool,
      errors: List<String>.from(json['errors'] ?? []),
      warnings: List<String>.from(json['warnings'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}