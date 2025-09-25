enum UserRole {
  investorAgent,
  professionalAgent,
  verifier,
  admin,
  superAdmin,
  merchantWhiteLabel,
  merchantAdmin,
  merchantOperations,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.investorAgent:
        return 'Investor-Agent';
      case UserRole.professionalAgent:
        return 'Professional Agent';
      case UserRole.verifier:
        return 'Verifier';
      case UserRole.admin:
        return 'Admin';
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.merchantWhiteLabel:
        return 'Merchant Partner';
      case UserRole.merchantAdmin:
        return 'Merchant Admin';
      case UserRole.merchantOperations:
        return 'Merchant Operations';
    }
  }

  String get description {
    switch (this) {
      case UserRole.investorAgent:
        return 'Invest in projects and monitor automatically';
      case UserRole.professionalAgent:
        return 'Expert verification and professional oversight';
      case UserRole.verifier:
        return 'On-demand site visits and verification tasks';
      case UserRole.admin:
        return 'Platform oversight and compliance management';
      case UserRole.superAdmin:
        return 'Full platform administration and white-label management';
      case UserRole.merchantWhiteLabel:
        return 'White-label merchant partner with custom branding';
      case UserRole.merchantAdmin:
        return 'Merchant administration and customer management';
      case UserRole.merchantOperations:
        return 'Merchant operations and transaction processing';
    }
  }
}