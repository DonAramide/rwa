import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/asset_upload_models.dart';
import '../models/user_role.dart';
import '../services/asset_upload_service.dart';

/// State for asset upload management
class AssetUploadState {
  final List<AssetUpload> uploads;
  final List<AssetUpload> pendingUploads;
  final UploadStatistics? statistics;
  final bool isLoading;
  final String? error;
  final AssetUpload? currentUpload;

  const AssetUploadState({
    this.uploads = const [],
    this.pendingUploads = const [],
    this.statistics,
    this.isLoading = false,
    this.error,
    this.currentUpload,
  });

  AssetUploadState copyWith({
    List<AssetUpload>? uploads,
    List<AssetUpload>? pendingUploads,
    UploadStatistics? statistics,
    bool? isLoading,
    String? error,
    AssetUpload? currentUpload,
  }) {
    return AssetUploadState(
      uploads: uploads ?? this.uploads,
      pendingUploads: pendingUploads ?? this.pendingUploads,
      statistics: statistics ?? this.statistics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentUpload: currentUpload ?? this.currentUpload,
    );
  }
}

/// Asset upload notifier for state management
class AssetUploadNotifier extends StateNotifier<AssetUploadState> {
  AssetUploadNotifier() : super(const AssetUploadState());

  /// Initialize upload for a user role
  Future<void> initializeUpload({
    required UserRole userRole,
    required String uploaderId,
    required String uploaderName,
    required String uploaderEmail,
  }) async {
    final source = AssetUploadService.getUploadSourceFromRole(userRole);

    final newUpload = AssetUpload(
      id: _generateUploadId(),
      uploaderId: uploaderId,
      uploaderName: uploaderName,
      uploaderEmail: uploaderEmail,
      source: source,
      uploaderRole: userRole,
      title: '',
      description: '',
      location: '',
      assetType: '',
      listingType: AssetListingType.fullSale,
      totalValue: 0,
      uploadDate: DateTime.now(),
    );

    state = state.copyWith(currentUpload: newUpload);
  }

  /// Update current upload details
  void updateUploadDetails({
    String? title,
    String? description,
    String? location,
    String? assetType,
    AssetListingType? listingType,
    double? totalValue,
    double? pricePerShare,
    int? totalShares,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    if (state.currentUpload == null) return;

    final updatedUpload = state.currentUpload!.copyWith(
      title: title ?? state.currentUpload!.title,
      description: description ?? state.currentUpload!.description,
      location: location ?? state.currentUpload!.location,
      assetType: assetType ?? state.currentUpload!.assetType,
      listingType: listingType ?? state.currentUpload!.listingType,
      totalValue: totalValue ?? state.currentUpload!.totalValue,
      pricePerShare: pricePerShare ?? state.currentUpload!.pricePerShare,
      totalShares: totalShares ?? state.currentUpload!.totalShares,
      tags: tags ?? state.currentUpload!.tags,
      metadata: metadata ?? state.currentUpload!.metadata,
    );

    state = state.copyWith(currentUpload: updatedUpload);
  }

  /// Add documents to current upload
  void addDocuments(List<AssetDocument> documents) {
    if (state.currentUpload == null) return;

    final existingDocs = state.currentUpload!.documents;
    final updatedDocs = [...existingDocs, ...documents];

    final updatedUpload = state.currentUpload!.copyWith(documents: updatedDocs);
    state = state.copyWith(currentUpload: updatedUpload);
  }

  /// Remove document from current upload
  void removeDocument(String documentId) {
    if (state.currentUpload == null) return;

    final updatedDocs = state.currentUpload!.documents
        .where((doc) => doc.id != documentId)
        .toList();

    final updatedUpload = state.currentUpload!.copyWith(documents: updatedDocs);
    state = state.copyWith(currentUpload: updatedUpload);
  }

  /// Submit asset upload
  Future<bool> submitUpload({required List<File> documentFiles}) async {
    if (state.currentUpload == null) return false;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await AssetUploadService.uploadAsset(
        upload: state.currentUpload!,
        documentFiles: documentFiles,
      );

      if (result.success) {
        // Add to uploads list
        final updatedUploads = [...state.uploads, state.currentUpload!];

        state = state.copyWith(
          uploads: updatedUploads,
          currentUpload: null,
          isLoading: false,
        );

        // Refresh statistics
        await loadStatistics();

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.errors.join(', '),
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Load pending uploads (admin function)
  Future<void> loadPendingUploads({AssetUploadSource? source}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final pending = await AssetUploadService.getPendingUploads(source: source);

      state = state.copyWith(
        pendingUploads: pending,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update upload status (admin function)
  Future<bool> updateUploadStatus({
    required String uploadId,
    required VerificationStatus status,
    String? notes,
    String? rejectionReason,
  }) async {
    try {
      final success = await AssetUploadService.updateUploadStatus(
        uploadId: uploadId,
        status: status,
        notes: notes,
        rejectionReason: rejectionReason,
      );

      if (success) {
        // Update local state
        final updatedPending = state.pendingUploads.map((upload) {
          if (upload.id == uploadId) {
            return upload.copyWith(
              verificationStatus: status,
              verificationNotes: notes,
              rejectionReason: rejectionReason,
            );
          }
          return upload;
        }).toList();

        // Remove from pending if approved or rejected
        final filteredPending = status == VerificationStatus.approved ||
                               status == VerificationStatus.rejected
            ? updatedPending.where((u) => u.id != uploadId).toList()
            : updatedPending;

        state = state.copyWith(pendingUploads: filteredPending);

        // Refresh statistics
        await loadStatistics();
      }

      return success;
    } catch (e) {
      debugPrint('Error updating upload status: $e');
      return false;
    }
  }

  /// Load upload statistics
  Future<void> loadStatistics() async {
    try {
      final stats = await AssetUploadService.getUploadStatistics();
      state = state.copyWith(statistics: stats);
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  /// Clear current upload
  void clearCurrentUpload() {
    state = state.copyWith(currentUpload: null);
  }

  /// Validate current upload
  AssetUploadValidation? validateCurrentUpload(List<File> documentFiles) {
    if (state.currentUpload == null) return null;

    return AssetUploadService.validateUpload(
      upload: state.currentUpload!,
      documentFiles: documentFiles,
    );
  }

  /// Get upload requirements for current user role
  UploadRequirements? getCurrentUploadRequirements() {
    if (state.currentUpload == null) return null;
    return UploadRequirements.forSource(state.currentUpload!.source);
  }

  String _generateUploadId() {
    return 'upload_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000).toString().padLeft(3, '0')}';
  }
}

/// Providers
final assetUploadProvider = StateNotifierProvider<AssetUploadNotifier, AssetUploadState>((ref) {
  return AssetUploadNotifier();
});

/// Computed providers
final pendingUploadsCountProvider = Provider<int>((ref) {
  final state = ref.watch(assetUploadProvider);
  return state.pendingUploads.length;
});

final uploadsBySourceProvider = Provider<Map<AssetUploadSource, int>>((ref) {
  final state = ref.watch(assetUploadProvider);
  final map = <AssetUploadSource, int>{};

  for (final upload in state.uploads) {
    map[upload.source] = (map[upload.source] ?? 0) + 1;
  }

  return map;
});

final currentUploadProgressProvider = Provider<double>((ref) {
  final state = ref.watch(assetUploadProvider);
  if (state.currentUpload == null) return 0.0;

  final upload = state.currentUpload!;
  final requirements = UploadRequirements.forSource(upload.source);

  var progress = 0.0;

  // Basic details (30%)
  if (upload.title.isNotEmpty && upload.description.isNotEmpty &&
      upload.location.isNotEmpty && upload.totalValue > 0) {
    progress += 0.3;
  }

  // Asset type and listing type (20%)
  if (upload.assetType.isNotEmpty) {
    progress += 0.2;
  }

  // Documents (50%)
  if (requirements.requiredDocuments.isNotEmpty) {
    final uploadedTypes = upload.documents.map((d) => d.documentType).toSet();
    final requiredCount = requirements.requiredDocuments.length;
    final uploadedCount = requirements.requiredDocuments
        .where((reqType) => uploadedTypes.contains(reqType))
        .length;

    progress += 0.5 * (uploadedCount / requiredCount);
  } else {
    // If no required docs, full progress for this section
    progress += 0.5;
  }

  return progress.clamp(0.0, 1.0);
});

/// Upload requirements provider for a specific role
final uploadRequirementsProvider = Provider.family<UploadRequirements, UserRole>((ref, role) {
  return AssetUploadService.getRequirements(role);
});

/// Filtered uploads provider
final filteredUploadsProvider = Provider.family<List<AssetUpload>, Map<String, dynamic>>((ref, filters) {
  final state = ref.watch(assetUploadProvider);
  var uploads = state.uploads.toList();

  // Filter by source
  if (filters['source'] != null) {
    final source = filters['source'] as AssetUploadSource;
    uploads = uploads.where((u) => u.source == source).toList();
  }

  // Filter by status
  if (filters['status'] != null) {
    final status = filters['status'] as VerificationStatus;
    uploads = uploads.where((u) => u.verificationStatus == status).toList();
  }

  // Filter by listing type
  if (filters['listingType'] != null) {
    final listingType = filters['listingType'] as AssetListingType;
    uploads = uploads.where((u) => u.listingType == listingType).toList();
  }

  // Sort by upload date (newest first)
  uploads.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));

  return uploads;
});