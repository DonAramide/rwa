import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/api_client.dart';
import 'auth_provider.dart';

final banksProvider = StateNotifierProvider<BanksNotifier, BanksState>((ref) {
  return BanksNotifier(ref.read(apiClientProvider));
});

class BanksState {
  final List<Map<String, dynamic>> banks;
  final Map<String, dynamic>? selectedBank;
  final List<Map<String, dynamic>> bankProposals;
  final bool isLoading;
  final String? error;
  final String? selectedBankId;

  BanksState({
    this.banks = const [],
    this.selectedBank,
    this.bankProposals = const [],
    this.isLoading = false,
    this.error,
    this.selectedBankId,
  });

  BanksState copyWith({
    List<Map<String, dynamic>>? banks,
    Map<String, dynamic>? selectedBank,
    List<Map<String, dynamic>>? bankProposals,
    bool? isLoading,
    String? error,
    String? selectedBankId,
  }) {
    return BanksState(
      banks: banks ?? this.banks,
      selectedBank: selectedBank ?? this.selectedBank,
      bankProposals: bankProposals ?? this.bankProposals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedBankId: selectedBankId ?? this.selectedBankId,
    );
  }
}

class BanksNotifier extends StateNotifier<BanksState> {
  final ApiClient _apiClient;

  BanksNotifier(this._apiClient) : super(BanksState());

  Future<void> loadBanks({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final banks = await _apiClient.getAllBanks(status: status);
      state = state.copyWith(
        banks: banks.cast<Map<String, dynamic>>(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadBankById(String bankId) async {
    try {
      final bank = await _apiClient.getBankById(bankId);
      state = state.copyWith(
        selectedBank: bank,
        selectedBankId: bankId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> createBank(Map<String, dynamic> bankData) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final newBank = await _apiClient.createBank(bankData);
      final updatedBanks = List<Map<String, dynamic>>.from(state.banks);
      updatedBanks.add(newBank);

      state = state.copyWith(
        banks: updatedBanks,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateBank(String bankId, Map<String, dynamic> updateData) async {
    try {
      final updatedBank = await _apiClient.updateBank(bankId, updateData);

      final updatedBanks = state.banks.map((bank) {
        if (bank['id'] == bankId) {
          return {...bank, ...updatedBank};
        }
        return bank;
      }).toList();

      state = state.copyWith(
        banks: updatedBanks,
        selectedBank: state.selectedBankId == bankId
            ? {...state.selectedBank ?? {}, ...updatedBank}
            : state.selectedBank,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateBankStatus(String bankId, String status) async {
    try {
      await _apiClient.updateBankStatus(bankId, status);

      final updatedBanks = state.banks.map((bank) {
        if (bank['id'] == bankId) {
          return {...bank, 'status': status};
        }
        return bank;
      }).toList();

      state = state.copyWith(
        banks: updatedBanks,
        selectedBank: state.selectedBankId == bankId
            ? {...state.selectedBank ?? {}, 'status': status}
            : state.selectedBank,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteBank(String bankId) async {
    try {
      await _apiClient.deleteBank(bankId);

      final updatedBanks = state.banks.where((bank) => bank['id'] != bankId).toList();

      state = state.copyWith(
        banks: updatedBanks,
        selectedBank: state.selectedBankId == bankId ? null : state.selectedBank,
        selectedBankId: state.selectedBankId == bankId ? null : state.selectedBankId,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> loadBankProposals({String? bankId, String? status}) async {
    try {
      final proposals = await _apiClient.getBankProposals(
        bankId: bankId,
        status: status,
      );
      state = state.copyWith(
        bankProposals: proposals.cast<Map<String, dynamic>>(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> approveProposal(String proposalId, {String? notes}) async {
    try {
      await _apiClient.approveProposal(proposalId, notes: notes);

      // Update proposal status in local state
      final updatedProposals = state.bankProposals.map((proposal) {
        if (proposal['id'] == proposalId) {
          return {...proposal, 'status': 'approved'};
        }
        return proposal;
      }).toList();

      state = state.copyWith(bankProposals: updatedProposals);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectProposal(String proposalId, {String? reason}) async {
    try {
      await _apiClient.rejectProposal(proposalId, reason: reason);

      // Update proposal status in local state
      final updatedProposals = state.bankProposals.map((proposal) {
        if (proposal['id'] == proposalId) {
          return {...proposal, 'status': 'rejected'};
        }
        return proposal;
      }).toList();

      state = state.copyWith(bankProposals: updatedProposals);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void selectBank(String bankId) {
    state = state.copyWith(selectedBankId: bankId);
    loadBankById(bankId);
  }

  void clearSelection() {
    state = state.copyWith(
      selectedBank: null,
      selectedBankId: null,
    );
  }

  // Helper getters
  List<Map<String, dynamic>> get activeBanks {
    return state.banks.where((bank) => bank['status'] == 'active').toList();
  }

  List<Map<String, dynamic>> get pendingBanks {
    return state.banks.where((bank) => bank['status'] == 'pending').toList();
  }

  List<Map<String, dynamic>> get suspendedBanks {
    return state.banks.where((bank) => bank['status'] == 'suspended').toList();
  }

  List<Map<String, dynamic>> get pendingProposals {
    return state.bankProposals.where((proposal) => proposal['status'] == 'pending').toList();
  }
}