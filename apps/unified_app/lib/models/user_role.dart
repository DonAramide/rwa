enum UserRole {
  investorAgent,
  professionalAgent,
  verifier,
  admin,
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
    }
  }
}