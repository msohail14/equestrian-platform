import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/primary_button.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final PaymentService _paymentService = PaymentService();
  Map<String, dynamic>? _subscription;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await _paymentService.getMySubscription();
      setState(() {
        _subscription = data['subscription'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load subscription';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Subscription'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _isLoading
          ? const LoadingState(message: 'Loading subscription...')
          : _error != null
              ? ErrorState(message: _error!, onRetry: _loadSubscription)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_subscription != null)
                        _buildCurrentPlan()
                      else
                        _buildNoPlan(),
                      const SizedBox(height: 32),
                      Text(
                        'Available Plans',
                        style: AppTextStyles.h2.copyWith(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      _buildPlanCard(
                        name: 'Basic',
                        price: '49 SAR/month',
                        features: [
                          'Up to 5 bookings/month',
                          'Basic coach access',
                          'Email support',
                        ],
                        planType: 'basic',
                        amount: 49,
                      ),
                      const SizedBox(height: 12),
                      _buildPlanCard(
                        name: 'Premium',
                        price: '149 SAR/quarter',
                        features: [
                          'Unlimited bookings',
                          'Priority coach access',
                          'Direct coach messaging',
                          'Detailed progress reports',
                        ],
                        planType: 'premium',
                        amount: 149,
                        isPopular: true,
                      ),
                      const SizedBox(height: 12),
                      _buildPlanCard(
                        name: 'Pro',
                        price: '499 SAR/year',
                        features: [
                          'Everything in Premium',
                          'Personal training plan',
                          'Competition prep support',
                          'VIP event access',
                        ],
                        planType: 'pro',
                        amount: 499,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildCurrentPlan() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Plan',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            (_subscription!['plan_type'] as String).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Status: ${_subscription!['status']}',
            style: const TextStyle(color: Colors.white70),
          ),
          Text(
            'Expires: ${_subscription!['end_date']}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPlan() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.card_membership, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'No active subscription',
            style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose a plan below to get started',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String name,
    required String price,
    required List<String> features,
    required String planType,
    required double amount,
    bool isPopular = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? AppColors.primary : Colors.grey[300]!,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 12)]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary)),
              if (isPopular) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(price, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: TextStyle(color: AppColors.textSecondary))),
              ],
            ),
          )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Subscribe',
              onPressed: () => _handleSubscribe(planType, amount),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscribe(String planType, double amount) async {
    try {
      final result = await _paymentService.initiatePayment(
        amount: amount,
        provider: 'tappay',
        paymentType: 'subscription',
        metadata: {'plan_type': planType},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment initiated: ${result['transaction_id']}. '
                'Complete payment through the provider.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to initiate payment. Please try again.')),
        );
      }
    }
  }
}
