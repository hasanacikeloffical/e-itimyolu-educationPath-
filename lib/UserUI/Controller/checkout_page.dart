import 'package:education_path/UserUI/Controller/AuthController/AuthController.dart';
import 'package:education_path/UserUI/View/ViewComponent/paymentresultpageviewcomponent.dart';
import 'package:flutter/material.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;
  final double discountAmount;
  final double subtotal;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
    required this.discountAmount,
    required this.subtotal,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthController.instance;
  bool _isLoading = false;

  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await _auth.getProfile();
    if (profile != null && mounted) {
      _addressCtrl.text = profile['address']?['line'] ?? '';
      _cityCtrl.text = profile['address']?['city'] ?? '';
      _postalCodeCtrl.text = profile['address']?['postalCode'] ?? '';
    }
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final addressInfo = {
        'line': _addressCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'postalCode': _postalCodeCtrl.text.trim(),
      };

      await _auth.placeOrder(
        cartItems: widget.cartItems,
        totalAmount: widget.totalAmount,
        addressInfo: addressInfo,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const PaymentResultPage(success: true)),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş oluşturulurken bir hata oluştu: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Siparişi Tamamla'),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                theme,
                cs,
                title: 'Sipariş Özeti',
                child: _buildOrderSummary(theme, cs),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                theme,
                cs,
                title: 'Teslimat Adresi',
                child: _buildAddressForm(theme, cs),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme, cs),
    );
  }

  Widget _buildSectionCard(ThemeData theme, ColorScheme cs,
      {required String title, required Widget child}) {
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme, ColorScheme cs) {
    return Column(
      children: [
        _buildSummaryRow(
            'Ara Toplam', '${widget.subtotal.toStringAsFixed(2)} TL', theme),
        if (widget.discountAmount > 0)
          _buildSummaryRow('Öğrenci İndirimi',
              '-${widget.discountAmount.toStringAsFixed(2)} TL', theme,
              color: Colors.green.shade700),
        const Divider(height: 24),
        _buildSummaryRow('Toplam Tutar',
            '${widget.totalAmount.toStringAsFixed(2)} TL', theme,
            isTotal: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme,
      {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isTotal
                  ? theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)
                  : theme.textTheme.bodyLarge?.copyWith(color: color)),
          Text(value,
              style: isTotal
                  ? theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: color)
                  : theme.textTheme.bodyLarge?.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildAddressForm(ThemeData theme, ColorScheme cs) {
    return Column(
      children: [
        TextFormField(
          controller: _addressCtrl,
          decoration: const InputDecoration(labelText: 'Adres Satırı'),
          validator: (v) => v!.trim().isEmpty ? 'Adres boş bırakılamaz.' : null,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _cityCtrl,
                decoration: const InputDecoration(labelText: 'Şehir'),
                validator: (v) =>
                    v!.trim().isEmpty ? 'Şehir boş bırakılamaz.' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _postalCodeCtrl,
                decoration: const InputDecoration(labelText: 'Posta Kodu'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.trim().isEmpty ? 'Posta kodu boş bırakılamaz.' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar(ThemeData theme, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(20).copyWith(top: 10),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
        border:
            Border(top: BorderSide(color: cs.outlineVariant.withOpacity(0.2))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping_outlined, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text('Ödeme Yöntemi: Kapıda Ödeme',
                  style: TextStyle(color: cs.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _placeOrder,
              icon: _isLoading
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 3),
                    )
                  : const Icon(Icons.check_circle_outline_rounded),
              label: Text(_isLoading ? 'İşleniyor...' : 'Siparişi Tamamla'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
