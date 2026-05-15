enum SubscriptionTier { free, pro }

class SubscriptionState {
  final SubscriptionTier tier;
  final DateTime? expiresAt;
  final bool isActive;

  const SubscriptionState({
    required this.tier,
    this.expiresAt,
    this.isActive = false,
  });
}

/// 支付渠道抽象接口
/// v0.1 使用 NoopBillingProvider，v0.3+ 实现 Google Play / App Store
abstract class BillingProvider {
  Future<void> initialize();
  Future<SubscriptionState> getSubscriptionStatus();
  Future<bool> purchase(SubscriptionTier tier);
  Future<bool> restorePurchases();
  Stream<SubscriptionState> get onSubscriptionChanged;
}
