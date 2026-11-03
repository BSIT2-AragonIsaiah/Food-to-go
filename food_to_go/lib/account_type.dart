import 'package:supabase_flutter/supabase_flutter.dart';

enum AccountType {
  regular('Regular', 'regular'),
  foodStall('Food stall', 'foodstall'),
  admin('Admin', 'admin');

  const AccountType(this.label, this.metadataValue);

  final String label;
  final String metadataValue;

  static AccountType fromUser(User user) {
    if (user.appMetadata['account_type'] == 'admin') {
      return AccountType.admin;
    }
    if (user.userMetadata?['account_type'] == 'foodstall') {
      return AccountType.foodStall;
    }
    return AccountType.regular;
  }
}
