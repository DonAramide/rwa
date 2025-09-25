import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/assets_provider.dart';
import '../providers/portfolio_provider.dart';
import '../core/api_client.dart';
import 'agent_selection.dart';

class InvestmentForm extends ConsumerStatefulWidget {
  final Asset asset;
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const InvestmentForm({
    super.key,
    required this.asset,
    this.onSuccess,
    this.onCancel,
  });

  @override
  ConsumerState<InvestmentForm> createState() => _InvestmentFormState();
}

class _InvestmentFormState extends ConsumerState<InvestmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  double _investmentAmount = 0.0;
  bool _isLoading = false;
  String? _error;
  bool _hasAcceptedTerms = false;
  bool _needsVerification = false;
  String? _selectedVerificationMethod;
  String? _selectedAgentId;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _needsVerification = widget.asset.verificationRequired && widget.asset.lastVerifiedAt == null;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    setState(() {
      _investmentAmount = amount;
    });
  }

  Future<void> _submitInvestment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_needsVerification && _selectedVerificationMethod == null) {
      setState(() {
        _error = 'Please select a verification method';
      });
      return;
    }
    if (!_hasAcceptedTerms) {
      setState(() {
        _error = 'Please accept the terms and conditions';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await ApiClient.createInvestment(
        assetId: widget.asset.id,
        amount: _investmentAmount,
        verificationMethod: _selectedVerificationMethod,
        agentId: _selectedAgentId,
      );

      // Refresh portfolio after successful investment
      ref.read(portfolioProvider.notifier).refreshPortfolio();

      // Show success dialog
      if (mounted) {
        _showSuccessDialog(result);
      }
    } catch (e) {
      setState(() {
        _error = 'Investment failed: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Investment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have successfully invested \$${_investmentAmount.toStringAsFixed(2)} in ${widget.asset.title}.'),
            const SizedBox(height: 16),
            const Text('Next steps:'),
            const SizedBox(height: 8),
            const Text('• Investment confirmation will be sent to your email'),
            const Text('• Tokens will be minted to your wallet'),
            const Text('• You can track your investment in the Portfolio'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSuccess?.call();
            },
            child: const Text('View Portfolio'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAssetInfo(),
                      const SizedBox(height: 16),
                      _buildInvestmentAmount(),
                      const SizedBox(height: 16),
                      if (_needsVerification) ...[
                        _buildVerificationSection(),
                        const SizedBox(height: 16),
                      ],
                      _buildTermsCheckbox(),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorMessage(),
                      ],
                      const SizedBox(height: 24),
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invest in ${widget.asset.title}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Type: ${widget.asset.type} • Status: ${widget.asset.status}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asset Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.asset.nav != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Current NAV:'),
                  Text(
                    '\$${widget.asset.nav!.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expected Return:'),
                Text('8-12% APY', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Minimum Investment:'),
                Text('\$1,000', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Investment Amount (\$)',
            prefixIcon: Icon(Icons.attach_money),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter investment amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount < 1000) {
              return 'Minimum investment is \$1,000';
            }
            if (amount > 100000) {
              return 'Maximum investment is \$100,000';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Estimated shares: ${_investmentAmount > 0 && widget.asset.nav != null ? (_investmentAmount / widget.asset.nav!).toStringAsFixed(2) : '0.00'}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationSection() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Verification Required',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'This asset requires verification before investment. Choose your preferred method:',
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Self-Verification'),
              subtitle: const Text('Verify the asset yourself (Free)'),
              value: 'self',
              groupValue: _selectedVerificationMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedVerificationMethod = value;
                  });
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Professional Agent'),
              subtitle: const Text('Hire a verification agent (\$50)'),
              value: 'agent',
              groupValue: _selectedVerificationMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedVerificationMethod = value;
                  });
                }
              },
            ),
            if (_selectedVerificationMethod == 'agent') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AgentSelectionDialog(
                        assetId: widget.asset.id,
                        onAgentSelected: (agentId) {
                          setState(() {
                            _selectedAgentId = agentId;
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Agent selected! You can now proceed with investment.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        onCancel: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_search),
                  label: const Text('Select Verification Agent'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return CheckboxListTile(
      title: const Text('I agree to the terms and conditions'),
      subtitle: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terms and conditions will be shown here')),
          );
        },
        child: Text(
          'Read terms and conditions',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
      value: _hasAcceptedTerms,
      onChanged: (value) {
        setState(() {
          _hasAcceptedTerms = value ?? false;
        });
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onCancel,
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitInvestment,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Invest Now'),
          ),
        ),
      ],
    );
  }
}

