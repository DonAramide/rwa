import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/verification_models.dart';
import '../core/api_client.dart';

class VerificationState {
  final InvestorVerification? verification;
  final bool isLoading;
  final String? error;

  const VerificationState({
    this.verification,
    this.isLoading = false,
    this.error,
  });

  VerificationState copyWith({
    InvestorVerification? verification,
    bool? isLoading,
    String? error,
  }) {
    return VerificationState(
      verification: verification ?? this.verification,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isVerified => verification?.canInvest ?? false;
  bool get hasVerification => verification != null;
  bool get needsVerification => !hasVerification || !isVerified;
}

class VerificationNotifier extends StateNotifier<VerificationState> {
  VerificationNotifier() : super(const VerificationState());

  Future<void> loadVerificationStatus() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Try to load from API
      final response = await ApiClient.getVerificationStatus();
      final verification = InvestorVerification.fromJson(response['verification']);

      state = state.copyWith(
        verification: verification,
        isLoading: false,
      );
    } catch (e) {
      // For demo purposes, create mock verification status
      state = state.copyWith(
        verification: _createMockVerification(),
        isLoading: false,
      );
    }
  }

  Future<bool> submitVerification({
    required String firstName,
    required String lastName,
    required String email,
    required List<VerificationDocument> documents,
    VerificationType type = VerificationType.selfSubmitted,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final verification = InvestorVerification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id',
        email: email,
        firstName: firstName,
        lastName: lastName,
        status: VerificationStatus.pending,
        type: type,
        documents: documents,
        submissionDate: DateTime.now(),
        expiryDate: DateTime.now().add(const Duration(days: 365)), // 1 year validity
      );

      // Submit to API
      await ApiClient.submitVerification(verification.toJson());

      state = state.copyWith(
        verification: verification,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> uploadDocument({
    required DocumentType type,
    required String filename,
    required List<int> fileBytes,
  }) async {
    try {
      // Simulate file upload
      final uploadResponse = await ApiClient.uploadVerificationDocument(
        type: type.toString().split('.').last,
        filename: filename,
        fileBytes: fileBytes,
      );

      final document = VerificationDocument(
        id: uploadResponse['id'],
        type: type,
        url: uploadResponse['url'],
        filename: filename,
        uploadDate: DateTime.now(),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> requestProfessionalVerification(String agentId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await ApiClient.requestProfessionalVerification({
        'agentId': agentId,
        'userId': 'current_user_id',
      });

      // Update verification status
      if (state.verification != null) {
        final updatedVerification = InvestorVerification(
          id: state.verification!.id,
          userId: state.verification!.userId,
          email: state.verification!.email,
          firstName: state.verification!.firstName,
          lastName: state.verification!.lastName,
          status: VerificationStatus.underReview,
          type: VerificationType.professionalAgent,
          documents: state.verification!.documents,
          submissionDate: state.verification!.submissionDate,
          reviewDate: DateTime.now(),
          expiryDate: state.verification!.expiryDate,
          reviewerId: agentId,
          additionalData: state.verification!.additionalData,
        );

        state = state.copyWith(
          verification: updatedVerification,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  // Mock verification for demo purposes
  InvestorVerification? _createMockVerification() {
    // Return null to simulate unverified user initially
    return null;

    // Uncomment below to simulate a verified user
    /*
    return InvestorVerification(
      id: 'mock_verification_1',
      userId: 'current_user_id',
      email: 'investor@example.com',
      firstName: 'John',
      lastName: 'Doe',
      status: VerificationStatus.approved,
      type: VerificationType.selfSubmitted,
      documents: [
        VerificationDocument(
          id: 'doc_1',
          type: DocumentType.governmentId,
          url: 'https://example.com/id.jpg',
          filename: 'government_id.jpg',
          uploadDate: DateTime.now().subtract(const Duration(days: 7)),
        ),
        VerificationDocument(
          id: 'doc_2',
          type: DocumentType.selfieWithId,
          url: 'https://example.com/selfie.jpg',
          filename: 'selfie_with_id.jpg',
          uploadDate: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
      submissionDate: DateTime.now().subtract(const Duration(days: 7)),
      reviewDate: DateTime.now().subtract(const Duration(days: 1)),
      expiryDate: DateTime.now().add(const Duration(days: 358)),
      reviewerId: 'reviewer_1',
      reviewerName: 'Sarah Wilson',
      reviewNotes: 'All documents verified successfully.',
    );
    */
  }
}

// Providers
final verificationProvider = StateNotifierProvider<VerificationNotifier, VerificationState>((ref) {
  return VerificationNotifier();
});

// Computed providers
final canInvestProvider = Provider<bool>((ref) {
  final verificationState = ref.watch(verificationProvider);
  return verificationState.isVerified;
});

final verificationStatusProvider = Provider<String>((ref) {
  final verificationState = ref.watch(verificationProvider);
  if (verificationState.verification == null) {
    return 'Not Started';
  }
  return verificationState.verification!.statusDisplayName;
});