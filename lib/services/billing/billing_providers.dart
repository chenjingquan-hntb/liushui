import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'billing_provider.dart';
import 'noop_billing_provider.dart';

final billingProvider = Provider.autoDispose<BillingProvider>((ref) {
  return NoopBillingProvider();
});

final subscriptionStateProvider = StreamProvider<SubscriptionState>((ref) {
  final billing = ref.watch(billingProvider);
  return billing.onSubscriptionChanged;
});
