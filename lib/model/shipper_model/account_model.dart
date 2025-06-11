import 'package:supabase_flutter/supabase_flutter.dart';

class Account {
  final String fullName;
  final String? avatarUrl;

  Account({required this.fullName, this.avatarUrl});
}
class AccountRepository {
  final _supabase = Supabase.instance.client;

  Future<Account?> fetchAccount(int accountId) async {
    final res =
        await _supabase
            .from('account')
            .select('full_name, avatar_url')
            .eq('account_id', accountId)
            .maybeSingle();

    if (res == null) {
      return null;
    }
    return Account(
      fullName: res['full_name'] as String,
      avatarUrl: res['avatar_url'] as String?,
    );
  }

  Future<void> updateAccount(
    int accountId,
    Map<String, dynamic> updateData,
  ) async {
    await _supabase
        .from('account')
        .update(updateData)
        .eq('account_id', accountId);
  }
}
