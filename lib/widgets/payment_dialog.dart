import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/payment.dart';

class PaymentDialog extends StatefulWidget {
  final double amount;
  final VoidCallback? onCancel;
  final Function(PaymentTransaction)? onPaymentSuccess;
  final Function(String)? onPaymentError;

  const PaymentDialog({
    super.key,
    required this.amount,
    this.onCancel,
    this.onPaymentSuccess,
    this.onPaymentError,
  });

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String _cardBrand = '';

  // Keep validation simple to avoid GetX issues
  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final cleaned = value.replaceAll(' ', '');
    if (cleaned.length < 13 || cleaned.length > 19) return 'Invalid length';
    return null; // Skip Luhn for now to avoid complexity
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final parts = value.split('/');
    if (parts.length != 2) return 'MM/YY format';
    final month = int.tryParse(parts[0]) ?? 0;
    final year = int.tryParse(parts[1]) ?? 0;
    if (month < 1 || month > 12) return 'Invalid month';
    final now = DateTime.now();
    if (year < (now.year % 100)) return 'Expired';
    if (year == (now.year % 100) && month < now.month) return 'Expired';
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 3 || value.length > 4) return '3-4 digits';
    return null;
  }

  String? _validateCardholder(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (value.trim().length < 2) return 'Full name required';
    return null;
  }

  void _onCardNumberChanged() {
    final cleaned = _cardNumberController.text.replaceAll(' ', '');
    String brand = 'Unknown';
    if (cleaned.startsWith('4')) brand = 'Visa';
    else if (cleaned.startsWith('5') || cleaned.startsWith('2')) brand = 'Mastercard';
    else if (cleaned.startsWith('3')) brand = 'American Express';
    setState(() => _cardBrand = brand);
  }

  void _onExpiryChanged() {
    if (_expiryController.text.length == 2 && !_expiryController.text.contains('/')) {
      _expiryController.text += '/';
      _expiryController.selection = TextSelection.fromPosition(
        TextPosition(offset: _expiryController.text.length)
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _cardNumberController.addListener(_onCardNumberChanged);
    _expiryController.addListener(_onExpiryChanged);
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(seconds: 2));

      // Create transaction
      final transaction = PaymentTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        amount: widget.amount,
        status: 'success',
        processor: 'braintree_trial',
        createdAt: DateTime.now(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onPaymentSuccess?.call(transaction);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Payment failed: ${e.toString()}';
        _isLoading = false;
      });
      widget.onPaymentError?.call(e.toString());
    }
  }

  Widget _buildCardIcon() {
    Color color = Colors.grey;
    switch (_cardBrand.toLowerCase()) {
      case 'visa': color = Colors.blue; break;
      case 'mastercard': color = Colors.red; break;
      case 'american express': color = Colors.green; break;
    }
    return Icon(Icons.credit_card, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment, color: Colors.blue, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Secure Payment\n\$${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Form
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Card Number
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          hintText: '1234 5678 9012 3456',
                          prefixIcon: _buildCardIcon(),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(19),
                          CardNumberInputFormatter(),
                        ],
                        validator: _validateCardNumber,
                      ),
                      const SizedBox(height: 16),

                      // Expiry & CVV
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              decoration: const InputDecoration(
                                labelText: 'Expiry (MM/YY)',
                                hintText: 'MM/YY',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                                ExpiryDateInputFormatter(),
                              ],
                              validator: _validateExpiry,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                                hintText: '123',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              validator: _validateCvv,
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Cardholder
                      TextFormField(
                        controller: _cardholderController,
                        decoration: const InputDecoration(
                          labelText: 'Cardholder Name',
                          hintText: 'John Doe',
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                        validator: _validateCardholder,
                        onFieldSubmitted: (_) => _processPayment(),
                      ),

                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            border: Border.all(color: Colors.red.shade200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade800),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Pay Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom input formatters for better UX

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(
        offset: string.length,
      ),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;

    if (oldValue.selection.baseOffset == 0) {
      return newValue;
    }

    if (text.length >= 2 && !text.contains('/') && oldValue.text.length < text.length) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(
        offset: text.length,
      ),
    );
  }
}
