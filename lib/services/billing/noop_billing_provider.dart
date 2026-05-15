import 'dart:async';
import 'billing_provider.dart';

class NoopBillingProvider implements BillingProvider {
  @override
  Future<void> initialize() async {}

  @override
  Future<SubscriptionState> getSubscriptionStatus() async {
    return const SubscriptionState(tier: SubscriptionTier.free, isActive: false);
  }

  @override
  Future<bool> purchase(SubscriptionTier tier) async => false;

  @override
  Future<bool> restorePurchases() async => false;

  @override
  Stream<SubscriptionState> get onSubscriptionChanged =>
      const Stream.empty();
}
