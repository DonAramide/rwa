import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../models/asset.dart';
import '../providers/wallet_provider.dart';
import '../models/wallet.dart';
import '../features/wallet/wallet_connect_screen.dart';
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
  String _paymentMethod = 'fiat'; // 'fiat' or 'crypto'
  CryptoCurrency? _selectedCurrency;

  // Document verification
  List<Map<String, dynamic>> _uploadedDocuments = [];
  bool _isDocumentVerifying = false;
  Map<String, bool?> _documentVerificationResults = {};
  bool _requiresDocumentVerification = true;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
    _needsVerification = widget.asset.verificationRequired;
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
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _error = 'Please fix the errors above before proceeding with your investment.';
      });
      return;
    }

    if (_needsVerification && _selectedVerificationMethod == null) {
      setState(() {
        _error = 'Asset verification is required. Please select either Self-Verification or Professional Agent verification.';
      });
      return;
    }

    if (_requiresDocumentVerification && _selectedVerificationMethod == 'self') {
      if (_uploadedDocuments.isEmpty) {
        setState(() {
          _error = 'Document verification required. Please upload your identification documents to verify your identity.';
        });
        return;
      }

      // Check if all documents are verified
      final unverifiedDocs = _uploadedDocuments.where((doc) =>
        _documentVerificationResults[doc['id'] as String] != true
      ).toList();

      if (unverifiedDocs.isNotEmpty) {
        setState(() {
          _error = 'Document verification in progress. Please wait for AI verification to complete before investing.';
        });
        return;
      }
    }

    if (!_hasAcceptedTerms) {
      setState(() {
        _error = 'You must accept the Terms and Conditions to proceed with your investment.';
      });
      return;
    }

    if (_paymentMethod == 'crypto') {
      final walletState = ref.read(walletProvider);
      if (!walletState.isConnected) {
        setState(() {
          _error = 'Cryptocurrency payment selected but no wallet connected. Please connect your wallet or switch to traditional payment.';
        });
        return;
      }
      if (_selectedCurrency == null) {
        setState(() {
          _error = 'Please select which cryptocurrency you want to use for payment (ETH, USDC, or USDT).';
        });
        return;
      }

      // Check if user has sufficient balance
      final walletState2 = ref.read(walletProvider);
      final balance = walletState2.balances[_selectedCurrency!.symbol] ?? 0.0;
      final requiredAmount = _getCryptoAmount();

      if (balance < requiredAmount) {
        setState(() {
          _error = 'Insufficient ${_selectedCurrency!.symbol} balance. Required: ${requiredAmount.toStringAsFixed(6)}, Available: ${balance.toStringAsFixed(6)}';
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_paymentMethod == 'crypto') {
        await _processCryptoPayment();
      } else {
        // Traditional payment processing
        await Future.delayed(const Duration(seconds: 2));
      }

      // Show success dialog
      if (mounted) {
        _showSuccessDialog();
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

  Future<void> _processCryptoPayment() async {
    final walletNotifier = ref.read(walletProvider.notifier);

    // Convert USD amount to crypto amount (simplified)
    final cryptoAmount = _convertToCrypto(_investmentAmount, _selectedCurrency!);

    // For demo purposes, we'll simulate the transaction
    // In a real implementation, this would involve:
    // 1. Getting the smart contract address
    // 2. Calling the investment contract
    // 3. Transferring tokens to the contract

    await Future.delayed(const Duration(seconds: 3)); // Simulate blockchain transaction

    // In a real app, you would:
    // final transaction = await walletNotifier.sendTransaction(
    //   toAddress: 'CONTRACT_ADDRESS',
    //   amount: cryptoAmount,
    //   currency: _selectedCurrency!,
    // );
  }

  BigInt _convertToCrypto(double usdAmount, CryptoCurrency currency) {
    // Simplified conversion - in reality you'd use real exchange rates
    double cryptoPrice;
    switch (currency.symbol) {
      case 'ETH':
        cryptoPrice = 2000.0; // ETH price in USD
        break;
      case 'USDC':
      case 'USDT':
        cryptoPrice = 1.0; // Stablecoin
        break;
      default:
        cryptoPrice = 1.0;
    }

    final cryptoAmount = usdAmount / cryptoPrice;
    final decimals = BigInt.from(10).pow(currency.decimals);
    return BigInt.from(cryptoAmount * decimals.toDouble());
  }

  void _showSuccessDialog() {
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
                      _buildPaymentMethod(),
                      const SizedBox(height: 16),
                      if (_needsVerification) ...[
                        _buildVerificationSection(),
                        const SizedBox(height: 16),
                      ],
                      if (_requiresDocumentVerification && _selectedVerificationMethod == 'self') ...[
                        _buildDocumentVerificationSection(),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Current NAV:'),
                Text(
                  widget.asset.formattedNav,
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
              return 'Investment amount is required. Please enter an amount to proceed.';
            }
            final amount = double.tryParse(value);
            if (amount == null) {
              return 'Please enter a valid numeric amount (e.g., 1000, 5000.50)';
            }
            if (amount <= 0) {
              return 'Investment amount must be greater than \$0';
            }
            if (amount < 1000) {
              return 'Minimum investment is \$1,000. Current amount: \$${amount.toStringAsFixed(2)}';
            }
            if (amount > 100000) {
              return 'Maximum investment is \$100,000. Current amount: \$${amount.toStringAsFixed(2)}';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Estimated shares: ${_investmentAmount > 0 ? (_investmentAmount / double.parse(widget.asset.nav)).toStringAsFixed(2) : '0.00'}',
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
                        assetId: widget.asset.id.toString(),
                        onAgentSelected: () {
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

  Widget _buildPaymentMethod() {
    final walletState = ref.watch(walletProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Credit Card / Bank Transfer'),
              subtitle: const Text('Traditional payment methods'),
              value: 'fiat',
              groupValue: _paymentMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _paymentMethod = value;
                    _selectedCurrency = null;
                  });
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Cryptocurrency'),
              subtitle: const Text('Pay with ETH, USDC, or USDT'),
              value: 'crypto',
              groupValue: _paymentMethod,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _paymentMethod = value;
                  });
                }
              },
            ),
            if (_paymentMethod == 'crypto') ...[
              const SizedBox(height: 16),
              if (!walletState.isConnected) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please connect your wallet to pay with cryptocurrency',
                          style: TextStyle(color: Colors.orange[700]),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WalletConnectScreen(),
                            ),
                          );
                        },
                        child: const Text('Connect'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Wallet connected: ${walletState.connectedWallet!.shortAddress}',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CryptoCurrency>(
                  decoration: const InputDecoration(
                    labelText: 'Select Cryptocurrency',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCurrency,
                  items: walletState.supportedCurrencies.map((currency) {
                    final balance = walletState.balances[currency.symbol] ?? 0.0;
                    return DropdownMenuItem(
                      value: currency,
                      child: Row(
                        children: [
                          Text(currency.symbol),
                          const SizedBox(width: 8),
                          Text('(${currency.name})'),
                          const Spacer(),
                          Text(
                            'Balance: ${balance.toStringAsFixed(currency.decimals == 18 ? 4 : currency.decimals)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                  },
                  validator: (value) {
                    if (_paymentMethod == 'crypto' && value == null) {
                      return 'Please select a cryptocurrency';
                    }
                    return null;
                  },
                ),
                if (_selectedCurrency != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Amount to pay:'),
                            Text(
                              '${_getCryptoAmount().toStringAsFixed(_selectedCurrency!.decimals == 18 ? 6 : _selectedCurrency!.decimals)} ${_selectedCurrency!.symbol}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Network fees:'),
                            Text(
                              '~\$5-10',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ],
        ),
      ),
    );
  }

  double _getCryptoAmount() {
    if (_selectedCurrency == null || _investmentAmount == 0) return 0.0;

    // Simplified conversion - in reality you'd use real exchange rates
    switch (_selectedCurrency!.symbol) {
      case 'ETH':
        return _investmentAmount / 2000.0; // Assuming ETH = $2000
      case 'USDC':
      case 'USDT':
        return _investmentAmount; // 1:1 with USD
      default:
        return _investmentAmount;
    }
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

  Widget _buildDocumentVerificationSection() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_user, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'AI Document Verification',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload your identification documents for AI-powered verification. Our system will compare your documents with the verified asset images.',
            ),
            const SizedBox(height: 16),

            // Document upload button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isDocumentVerifying ? null : _pickAndUploadDocument,
                icon: _isDocumentVerifying
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.upload_file),
                label: Text(_isDocumentVerifying
                  ? 'Verifying Documents...'
                  : 'Upload Identification Documents'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            if (_uploadedDocuments.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Uploaded Documents:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._uploadedDocuments.map((doc) => _buildDocumentItem(doc)),
            ],

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'AI Verification Process:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• AI compares your uploaded documents with admin-verified asset images\n'
                    '• Facial recognition matches your ID photo with selfie (if provided)\n'
                    '• Document authenticity and validity are automatically checked\n'
                    '• Verification typically completes within 30-60 seconds',
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(Map<String, dynamic> doc) {
    final docId = doc['id'] as String;
    final isVerified = _documentVerificationResults[docId] == true;
    final isVerifying = _documentVerificationResults[docId] == null;
    final isFailed = _documentVerificationResults[docId] == false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isVerified
            ? Colors.green
            : isFailed
              ? Colors.red
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified
              ? Icons.check_circle
              : isFailed
                ? Icons.error
                : Icons.description,
            color: isVerified
              ? Colors.green
              : isFailed
                ? Colors.red
                : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc['name'],
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  doc['type'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isVerifying)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'VERIFIED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            )
          else if (isFailed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'FAILED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
        withData: true,
      );

      if (result != null) {
        setState(() {
          _isDocumentVerifying = true;
        });

        for (final file in result.files) {
          if (file.bytes != null) {
            final documentId = DateTime.now().millisecondsSinceEpoch.toString() + file.name;
            final document = {
              'id': documentId,
              'name': file.name,
              'type': _getDocumentType(file.extension ?? ''),
              'size': file.size,
              'data': file.bytes,
              'uploadTime': DateTime.now(),
            };

            setState(() {
              _uploadedDocuments.add(document);
              _documentVerificationResults[documentId] = null; // Verifying
            });

            // Start AI verification
            _verifyDocumentWithAI(document);
          }
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to upload documents: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isDocumentVerifying = false;
      });
    }
  }

  String _getDocumentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'Image Document';
      case 'pdf':
        return 'PDF Document';
      default:
        return 'Document';
    }
  }

  Future<void> _verifyDocumentWithAI(Map<String, dynamic> document) async {
    try {
      // Simulate AI verification process
      await Future.delayed(const Duration(seconds: 3));

      // Simulate AI image comparison with asset images
      // In real implementation, this would:
      // 1. Send document to AI service
      // 2. Compare with admin-verified asset images
      // 3. Perform facial recognition if applicable
      // 4. Check document authenticity

      // For demo, randomly determine verification result with bias toward success
      final random = DateTime.now().millisecondsSinceEpoch % 100;
      final isVerified = random > 15; // 85% success rate for demo

      setState(() {
        _documentVerificationResults[document['id'] as String] = isVerified;
      });

      if (isVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI verification successful for ${document['name']}! Document matches verified asset images.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI verification failed for ${document['name']}. Please upload a clearer image or try another document.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _documentVerificationResults[document['id'] as String] = false;
        _error = 'AI verification failed: ${e.toString()}';
      });
    }
  }
}