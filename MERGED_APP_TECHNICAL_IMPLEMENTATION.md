# RWA Platform: Merged Investor-Agent App Technical Implementation

## 🎯 Technical Architecture Overview

The merged app creates a unified platform where users can seamlessly switch between investor and agent roles while maintaining strict compliance and conflict-of-interest protections.

## 📱 App Structure Redesign

### New App Architecture
```
RWA Platform App (Unified)
├── apps/
│   ├── unified_app/           # New merged application
│   └── admin_app/             # Remains separate for platform management
├── backend/
│   ├── compliance-service/     # New compliance engine
│   ├── role-management/       # Role switching logic
│   └── existing services...
└── p2p-network/               # P2P infrastructure
```

### Flutter App Structure
```dart
// lib/main.dart
class RWAPlatformApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'RWA Platform',
      routerConfig: AppRouter.router,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
    );
  }
}

// Core navigation structure
class AppRouter {
  static final router = GoRouter(
    routes: [
      // Onboarding & Auth
      GoRoute(path: '/onboarding', builder: (_, __) => OnboardingFlow()),
      GoRoute(path: '/role-selection', builder: (_, __) => RoleSelectionScreen()),
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
      
      // Unified Dashboard
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // Investor Features
          GoRoute(path: '/marketplace', builder: (_, __) => MarketplaceScreen()),
          GoRoute(path: '/portfolio', builder: (_, __) => PortfolioScreen()),
          GoRoute(path: '/assets/:id', builder: (_, state) => 
            AssetDetailScreen(assetId: state.pathParameters['id']!)),
          
          // Agent Features  
          GoRoute(path: '/verification-jobs', builder: (_, __) => JobsScreen()),
          GoRoute(path: '/field-inspection/:jobId', builder: (_, state) => 
            InspectionScreen(jobId: state.pathParameters['jobId']!)),
          GoRoute(path: '/agent-profile', builder: (_, __) => AgentProfileScreen()),
          
          // Shared Features
          GoRoute(path: '/profile', builder: (_, __) => UserProfileScreen()),
          GoRoute(path: '/compliance', builder: (_, __) => ComplianceScreen()),
          GoRoute(path: '/governance', builder: (_, __) => GovernanceScreen()),
        ],
      ),
    ],
  );
}
```

## 🔄 Role Management System

### User Role State Management
```dart
// lib/providers/user_role_provider.dart
@riverpod
class UserRoleManager extends _$UserRoleManager {
  @override
  UserRoleState build() => const UserRoleState.loading();

  Future<void> updateUserRoles(Set<UserRole> newRoles) async {
    state = const UserRoleState.loading();
    
    try {
      // Validate role compatibility and compliance
      final validation = await _validateRoleChange(newRoles);
      if (!validation.isValid) {
        state = UserRoleState.error(validation.error);
        return;
      }
      
      // Update backend
      await ref.read(authServiceProvider).updateUserRoles(newRoles);
      
      // Update local state
      final user = await ref.read(authServiceProvider).getCurrentUser();
      state = UserRoleState.success(user);
      
      // Trigger role-specific initializations
      await _initializeRoleSpecificServices(newRoles);
      
    } catch (e) {
      state = UserRoleState.error(e.toString());
    }
  }
  
  Future<ValidationResult> _validateRoleChange(Set<UserRole> newRoles) async {
    // Check jurisdiction compatibility
    final jurisdictionCheck = await ref.read(complianceServiceProvider)
        .validateRolesForJurisdiction(newRoles);
    
    // Check investment limits
    final investmentCheck = await ref.read(complianceServiceProvider)
        .validateInvestmentLimits(newRoles);
    
    // Check agent certification requirements
    final certificationCheck = await ref.read(agentServiceProvider)
        .validateCertificationRequirements(newRoles);
    
    return ValidationResult.combine([
      jurisdictionCheck,
      investmentCheck, 
      certificationCheck
    ]);
  }
}

// User role state model
@freezed
class UserRoleState with _$UserRoleState {
  const factory UserRoleState.loading() = _Loading;
  const factory UserRoleState.success(User user) = _Success;
  const factory UserRoleState.error(String message) = _Error;
}

enum UserRole {
  investor,
  agent,
  governance;
  
  bool get requiresCertification => this == UserRole.agent;
  bool get requiresEnhancedKYC => this == UserRole.agent;
}
```

### Dynamic UI Based on Roles
```dart
// lib/screens/main_shell.dart
class MainShell extends ConsumerWidget {
  final Widget child;
  
  const MainShell({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRoles = ref.watch(userRoleManagerProvider);
    final currentRoute = GoRouterState.of(context).location;
    
    return userRoles.when(
      loading: () => const LoadingScreen(),
      error: (error) => ErrorScreen(error: error),
      success: (user) => Scaffold(
        appBar: _buildAppBar(user, currentRoute),
        body: child,
        bottomNavigationBar: _buildBottomNav(user, currentRoute),
        drawer: _buildDrawer(user),
      ),
    );
  }
  
  PreferredSizeWidget _buildAppBar(User user, String currentRoute) {
    return AppBar(
      title: _getScreenTitle(currentRoute),
      actions: [
        // Role indicator
        RoleIndicatorChip(roles: user.roles),
        
        // Compliance status
        ComplianceStatusIndicator(),
        
        // Notifications
        NotificationIconButton(),
        
        // Profile menu
        ProfileMenuButton(),
      ],
    );
  }
  
  Widget _buildBottomNav(User user, String currentRoute) {
    final availableTabs = _getAvailableTabs(user.roles);
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _getCurrentTabIndex(currentRoute, availableTabs),
      onTap: (index) => _navigateToTab(availableTabs[index]),
      items: availableTabs.map((tab) => BottomNavigationBarItem(
        icon: Icon(tab.icon),
        label: tab.label,
        backgroundColor: tab.isRestricted ? Colors.grey : null,
      )).toList(),
    );
  }
  
  List<NavigationTab> _getAvailableTabs(Set<UserRole> roles) {
    final tabs = <NavigationTab>[];
    
    // Always available
    tabs.add(NavigationTab.dashboard());
    
    // Investor features
    if (roles.contains(UserRole.investor)) {
      tabs.addAll([
        NavigationTab.marketplace(),
        NavigationTab.portfolio(),
      ]);
    }
    
    // Agent features
    if (roles.contains(UserRole.agent)) {
      tabs.addAll([
        NavigationTab.verificationJobs(),
        NavigationTab.fieldInspection(),
      ]);
    }
    
    // Governance (available to all but with different access levels)
    tabs.add(NavigationTab.governance(roles));
    
    return tabs;
  }
}
```

## 🛡️ Conflict of Interest Prevention

### Algorithmic Conflict Detection
```dart
// lib/services/conflict_detection_service.dart
@riverpod
class ConflictDetectionService extends _$ConflictDetectionService {
  @override
  FutureOr<void> build() {}

  Future<ConflictCheckResult> checkPotentialConflicts({
    required String userId,
    required String assetId,
    required ConflictType checkType,
  }) async {
    final conflicts = <ConflictIssue>[];
    
    switch (checkType) {
      case ConflictType.verificationAssignment:
        conflicts.addAll(await _checkVerificationConflicts(userId, assetId));
        break;
      case ConflictType.investment:
        conflicts.addAll(await _checkInvestmentConflicts(userId, assetId));
        break;
      case ConflictType.governance:
        conflicts.addAll(await _checkGovernanceConflicts(userId, assetId));
        break;
    }
    
    return ConflictCheckResult(
      hasConflicts: conflicts.isNotEmpty,
      conflicts: conflicts,
      recommendedActions: _generateRecommendations(conflicts),
    );
  }
  
  Future<List<ConflictIssue>> _checkVerificationConflicts(
    String userId, 
    String assetId
  ) async {
    final conflicts = <ConflictIssue>[];
    
    // Check direct investment in asset
    final hasInvestment = await ref.read(portfolioServiceProvider)
        .hasInvestmentInAsset(userId, assetId);
    if (hasInvestment) {
      conflicts.add(ConflictIssue(
        type: ConflictType.directInvestment,
        severity: ConflictSeverity.high,
        description: 'User has direct investment in this asset',
        action: ConflictAction.prohibit,
      ));
    }
    
    // Check geographic proximity (prevent local verification farming)
    final assetLocation = await ref.read(assetServiceProvider)
        .getAssetLocation(assetId);
    final userLocation = await ref.read(userServiceProvider)
        .getUserLocation(userId);
    
    final distance = _calculateDistance(assetLocation, userLocation);
    if (distance < 100) { // 100km minimum distance
      conflicts.add(ConflictIssue(
        type: ConflictType.geographicProximity,
        severity: ConflictSeverity.medium,
        description: 'User location too close to asset ($distance km)',
        action: ConflictAction.requireApproval,
      ));
    }
    
    // Check recent verification history for same asset type
    final recentVerifications = await ref.read(verificationServiceProvider)
        .getRecentVerificationsByUser(userId, days: 30);
    
    final sameTypeCount = recentVerifications
        .where((v) => v.assetType == assetLocation.type)
        .length;
    
    if (sameTypeCount > 10) { // Max 10 verifications of same type per month
      conflicts.add(ConflictIssue(
        type: ConflictType.overSpecialization,
        severity: ConflictSeverity.low,
        description: 'User has verified many similar assets recently',
        action: ConflictAction.requireDisclosure,
      ));
    }
    
    return conflicts;
  }
  
  Future<List<ConflictIssue>> _checkInvestmentConflicts(
    String userId,
    String assetId
  ) async {
    final conflicts = <ConflictIssue>[];
    
    // Check if user has previously verified this asset
    final hasVerified = await ref.read(verificationServiceProvider)
        .hasUserVerifiedAsset(userId, assetId);
    
    if (hasVerified) {
      conflicts.add(ConflictIssue(
        type: ConflictType.priorVerification,
        severity: ConflictSeverity.medium,
        description: 'User previously verified this asset',
        action: ConflictAction.requireDisclosure,
      ));
    }
    
    // Check family/business relationships with asset owner
    final relationshipCheck = await ref.read(kycServiceProvider)
        .checkRelationshipWithAssetOwner(userId, assetId);
    
    if (relationshipCheck.hasRelationship) {
      conflicts.add(ConflictIssue(
        type: ConflictType.personalRelationship,
        severity: ConflictSeverity.high,
        description: relationshipCheck.relationshipType,
        action: ConflictAction.prohibit,
      ));
    }
    
    return conflicts;
  }
}

// Conflict resolution UI
class ConflictResolutionDialog extends ConsumerWidget {
  final ConflictCheckResult conflictResult;
  final VoidCallback onResolve;
  
  const ConflictResolutionDialog({
    required this.conflictResult,
    required this.onResolve,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Potential Conflicts Detected'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...conflictResult.conflicts.map((conflict) => 
            ConflictIssueCard(conflict: conflict)),
          
          const SizedBox(height: 16),
          
          if (conflictResult.canProceedWithDisclosure)
            const Text('You may proceed by acknowledging these conflicts:'),
          
          if (!conflictResult.canProceed)
            const Text(
              'This action is prohibited due to conflict of interest.',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        
        if (conflictResult.canProceedWithDisclosure)
          ElevatedButton(
            onPressed: () {
              _showDisclosureDialog(context);
            },
            child: const Text('Proceed with Disclosure'),
          ),
      ],
    );
  }
  
  void _showDisclosureDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ConflictDisclosureDialog(
        conflicts: conflictResult.conflicts,
        onConfirm: () {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          onResolve();
        },
      ),
    );
  }
}
```

## 📋 Compliance Integration

### Real-time Compliance Monitoring
```dart
// lib/services/compliance_service.dart
@riverpod
class ComplianceService extends _$ComplianceService {
  @override
  FutureOr<ComplianceStatus> build() async {
    return await _fetchComplianceStatus();
  }

  Future<ComplianceStatus> _fetchComplianceStatus() async {
    final user = await ref.read(authServiceProvider).getCurrentUser();
    if (user == null) return ComplianceStatus.notAuthenticated();
    
    // Fetch compliance status from backend
    final response = await ref.read(apiClientProvider)
        .get('/compliance/status/${user.id}');
    
    return ComplianceStatus.fromJson(response.data);
  }
  
  Future<void> triggerComplianceCheck() async {
    state = const AsyncValue.loading();
    
    try {
      final user = await ref.read(authServiceProvider).getCurrentUser();
      await ref.read(apiClientProvider)
          .post('/compliance/check/${user!.id}');
      
      // Refresh status
      state = AsyncValue.data(await _fetchComplianceStatus());
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
  
  Future<DocumentGenerationResult> generateRequiredDocuments({
    required Set<UserRole> roles,
    required String jurisdiction,
  }) async {
    final response = await ref.read(apiClientProvider).post(
      '/compliance/documents/generate',
      data: {
        'roles': roles.map((r) => r.name).toList(),
        'jurisdiction': jurisdiction,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    return DocumentGenerationResult.fromJson(response.data);
  }
}

// Compliance status widget
class ComplianceStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complianceStatus = ref.watch(complianceServiceProvider);
    
    return complianceStatus.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, _) => IconButton(
        icon: const Icon(Icons.error, color: Colors.red),
        onPressed: () => _showErrorDialog(context, error),
      ),
      data: (status) => PopupMenuButton<String>(
        icon: Icon(
          _getStatusIcon(status),
          color: _getStatusColor(status),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'view',
            child: ListTile(
              leading: Icon(_getStatusIcon(status)),
              title: Text('Compliance Status'),
              subtitle: Text(status.description),
            ),
          ),
          
          if (status.hasRequiredActions)
            PopupMenuItem(
              value: 'actions',
              child: ListTile(
                leading: const Icon(Icons.warning),
                title: const Text('Required Actions'),
                subtitle: Text('${status.requiredActions.length} items'),
              ),
            ),
          
          PopupMenuItem(
            value: 'refresh',
            child: const ListTile(
              leading: Icon(Icons.refresh),
              title: Text('Refresh Status'),
            ),
          ),
        ],
        onSelected: (value) => _handleMenuAction(context, ref, value, status),
      ),
    );
  }
  
  IconData _getStatusIcon(ComplianceStatus status) {
    switch (status.level) {
      case ComplianceLevel.compliant:
        return Icons.verified;
      case ComplianceLevel.warning:
        return Icons.warning;
      case ComplianceLevel.nonCompliant:
        return Icons.error;
      case ComplianceLevel.pending:
        return Icons.hourglass_empty;
    }
  }
  
  Color _getStatusColor(ComplianceStatus status) {
    switch (status.level) {
      case ComplianceLevel.compliant:
        return Colors.green;
      case ComplianceLevel.warning:
        return Colors.orange;
      case ComplianceLevel.nonCompliant:
        return Colors.red;
      case ComplianceLevel.pending:
        return Colors.blue;
    }
  }
}
```

## 🔄 Backend Service Updates

### Role Management Service
```typescript
// backend/nest/src/role-management/role-management.service.ts
@Injectable()
export class RoleManagementService {
  constructor(
    @InjectRepository(UserEntity)
    private userRepository: Repository<UserEntity>,
    
    @InjectRepository(RoleAssignmentEntity)
    private roleAssignmentRepository: Repository<RoleAssignmentEntity>,
    
    private complianceService: ComplianceService,
    private conflictDetectionService: ConflictDetectionService,
  ) {}

  async updateUserRoles(
    userId: string, 
    newRoles: UserRole[]
  ): Promise<RoleUpdateResult> {
    
    // Validate role compatibility
    const validation = await this.validateRoleChange(userId, newRoles);
    if (!validation.isValid) {
      throw new BadRequestException(validation.errors);
    }
    
    // Check compliance requirements
    const complianceCheck = await this.complianceService
      .validateRoleCompliance(userId, newRoles);
    if (!complianceCheck.isCompliant) {
      throw new BadRequestException('Compliance requirements not met');
    }
    
    // Start transaction
    return await this.userRepository.manager.transaction(async (manager) => {
      // Deactivate current roles
      await manager.update(RoleAssignmentEntity, 
        { userId, isActive: true },
        { isActive: false, deactivatedAt: new Date() }
      );
      
      // Create new role assignments
      const roleAssignments = newRoles.map(role => 
        manager.create(RoleAssignmentEntity, {
          userId,
          role,
          isActive: true,
          assignedAt: new Date(),
          assignedBy: 'SYSTEM',
        })
      );
      
      await manager.save(roleAssignments);
      
      // Update user entity
      await manager.update(UserEntity, userId, {
        roles: newRoles,
        rolesUpdatedAt: new Date(),
      });
      
      // Trigger role-specific initializations
      await this.initializeRoleSpecificServices(userId, newRoles);
      
      return {
        success: true,
        roles: newRoles,
        effectiveDate: new Date(),
      };
    });
  }
  
  async validateRoleChange(
    userId: string, 
    newRoles: UserRole[]
  ): Promise<ValidationResult> {
    const errors: string[] = [];
    
    // Check jurisdiction compatibility
    const user = await this.userRepository.findOne({ 
      where: { id: userId },
      relations: ['kycData']
    });
    
    const jurisdictionRules = await this.getJurisdictionRules(
      user.kycData.jurisdiction
    );
    
    for (const role of newRoles) {
      if (!jurisdictionRules.allowedRoles.includes(role)) {
        errors.push(`Role ${role} not permitted in ${user.kycData.jurisdiction}`);
      }
    }
    
    // Check role combinations
    if (newRoles.includes(UserRole.AGENT) && 
        newRoles.includes(UserRole.INVESTOR)) {
      const conflictCheck = await this.conflictDetectionService
        .checkRoleCombinationConflicts(userId, newRoles);
      
      if (conflictCheck.hasHighSeverityConflicts) {
        errors.push('Role combination creates unresolvable conflicts');
      }
    }
    
    return {
      isValid: errors.length === 0,
      errors,
    };
  }
  
  async assignVerificationJob(
    jobId: string, 
    agentId: string
  ): Promise<JobAssignmentResult> {
    
    // Check conflicts of interest
    const job = await this.getVerificationJob(jobId);
    const conflictCheck = await this.conflictDetectionService
      .checkVerificationConflicts(agentId, job.assetId);
    
    if (conflictCheck.hasBlockingConflicts) {
      throw new BadRequestException('Assignment blocked due to conflicts');
    }
    
    // Assign job with conflict disclosure if needed
    return await this.createJobAssignment(jobId, agentId, conflictCheck);
  }
}
```

### Compliance Engine Service
```typescript
// backend/nest/src/compliance/compliance.service.ts
@Injectable()
export class ComplianceService {
  constructor(
    @InjectRepository(ComplianceRecordEntity)
    private complianceRepository: Repository<ComplianceRecordEntity>,
    
    @InjectRepository(LegalDocumentEntity)
    private documentRepository: Repository<LegalDocumentEntity>,
    
    private ipfsService: IpfsService,
    private jurisdictionService: JurisdictionService,
  ) {}

  async generateRequiredDocuments(
    userId: string,
    roles: UserRole[],
    jurisdiction: string
  ): Promise<DocumentGenerationResult> {
    
    const documentRequirements = await this.jurisdictionService
      .getDocumentRequirements(jurisdiction, roles);
    
    const generatedDocs: GeneratedDocument[] = [];
    
    for (const requirement of documentRequirements) {
      // Generate document from template
      const document = await this.generateDocumentFromTemplate(
        requirement.templateId,
        {
          userId,
          roles,
          jurisdiction,
          timestamp: new Date().toISOString(),
          version: requirement.version,
        }
      );
      
      // Store on IPFS
      const ipfsHash = await this.ipfsService.store(document.content);
      
      // Save to database
      const docEntity = await this.documentRepository.save({
        userId,
        type: requirement.type,
        content: document.content,
        ipfsHash,
        jurisdiction,
        version: requirement.version,
        requiresSignature: requirement.requiresSignature,
        createdAt: new Date(),
      });
      
      generatedDocs.push({
        id: docEntity.id,
        type: requirement.type,
        ipfsHash,
        requiresSignature: requirement.requiresSignature,
        content: document.content,
      });
    }
    
    return {
      documents: generatedDocs,
      totalCount: generatedDocs.length,
      signaturesRequired: generatedDocs.filter(d => d.requiresSignature).length,
    };
  }
  
  async validateRoleCompliance(
    userId: string, 
    roles: UserRole[]
  ): Promise<ComplianceCheckResult> {
    
    const checks: ComplianceCheck[] = [];
    
    // KYC level validation
    const kycCheck = await this.validateKycLevel(userId, roles);
    checks.push(kycCheck);
    
    // Investment limit validation
    const investmentCheck = await this.validateInvestmentLimits(userId, roles);
    checks.push(investmentCheck);
    
    // Professional certification validation (for agents)
    if (roles.includes(UserRole.AGENT)) {
      const certificationCheck = await this.validateAgentCertification(userId);
      checks.push(certificationCheck);
    }
    
    // Insurance validation (for agents)
    if (roles.includes(UserRole.AGENT)) {
      const insuranceCheck = await this.validateInsurance(userId);
      checks.push(insuranceCheck);
    }
    
    const isCompliant = checks.every(check => check.passed);
    const failedChecks = checks.filter(check => !check.passed);
    
    return {
      isCompliant,
      checks,
      failedChecks,
      requiredActions: failedChecks.flatMap(check => check.requiredActions),
    };
  }
}
```

## 📱 Updated App Structure

### New Directory Structure
```
apps/
├── unified_app/                    # Merged investor-agent app
│   ├── lib/
│   │   ├── core/
│   │   │   ├── routing/
│   │   │   ├── theme/
│   │   │   └── constants/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   │   ├── role_selection/
│   │   │   │   └── onboarding/
│   │   │   ├── investor/
│   │   │   │   ├── marketplace/
│   │   │   │   ├── portfolio/
│   │   │   │   └── asset_detail/
│   │   │   ├── agent/
│   │   │   │   ├── verification_jobs/
│   │   │   │   ├── field_inspection/
│   │   │   │   └── agent_profile/
│   │   │   ├── compliance/
│   │   │   │   ├── status/
│   │   │   │   ├── documents/
│   │   │   │   └── conflict_resolution/
│   │   │   └── governance/
│   │   │       ├── voting/
│   │   │       ├── proposals/
│   │   │       └── dao_management/
│   │   ├── shared/
│   │   │   ├── widgets/
│   │   │   ├── services/
│   │   │   └── models/
│   │   └── providers/
│   └── pubspec.yaml
└── admin_app/                      # Remains separate
    └── ...
```

This technical implementation creates a seamless, compliant platform where users can safely operate in dual roles while maintaining regulatory compliance and preventing conflicts of interest through automated detection and resolution systems.