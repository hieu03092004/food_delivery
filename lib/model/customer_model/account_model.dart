import 'package:supabase_auth_ui/supabase_auth_ui.dart';

class Account {
  final int accountId;
  final String fullName;

  final String avatarUrl;
  final String phoneNumber;
  final String address;
  final String gender;
  final DateTime? dateOfBirth;

  Account({
    required this.accountId,
    required this.fullName,

    required this.avatarUrl,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    this.dateOfBirth,
  });

  factory Account.fromJson(Map<String, dynamic> json) => Account(
    accountId: json['account_id'] as int,
    fullName: json['full_name']?.toString() ?? '',

    avatarUrl: json['avatar_url']?.toString() ?? '',
    phoneNumber: json['phone_number']?.toString() ?? '',
    address: json['address']?.toString() ?? '',
    gender: json['gender']?.toString() ?? '',
    dateOfBirth: json['date_of_birth'] != null
        ? DateTime.parse(json['date_of_birth'] as String)
        : null,
  );
}
class AccountSnapshot{
  static final _supabase = Supabase.instance.client;

  static Future<Account> getAccount(int id) async {
    final resp = await _supabase.from('account').select().eq('account_id', id).single();
    return Account.fromJson(resp as Map<String, dynamic>);
  }

  static Future<void> updateAccount(Account acc) async {
    await _supabase.from('account').update({
      'full_name': acc.fullName,

      'phone_number': acc.phoneNumber,
      'address': acc.address,
    }).eq('account_id', acc.accountId);
  }
}
