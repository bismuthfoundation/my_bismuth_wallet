// To parse this JSON data, do
//
//     final balanceGetResponse = balanceGetResponseFromJson(jsonString);

// @dart=2.9

import 'dart:convert';

BalanceGetResponse balanceGetResponseFromJson(String str) => BalanceGetResponse.fromJson(json.decode(str));

String balanceGetResponseToJson(BalanceGetResponse data) => json.encode(data.toJson());

class BalanceGetResponse {
    BalanceGetResponse({
        this.address,
        this.balance,
        this.totalCredits,
        this.totalDebits,
        this.totalFees,
        this.totalRewards,
        this.balanceNoMempool,
    });

    String address;
    String balance;
    String totalCredits;
    String totalDebits;
    String totalFees;
    String totalRewards;
    String balanceNoMempool;

    factory BalanceGetResponse.fromJson(Map<String, dynamic> json) => BalanceGetResponse(
        balance: json['balance'],
        totalCredits: json['total_credits'],
        totalDebits: json['total_debits'],
        totalFees: json['total_fees'],
        totalRewards: json['total_rewards'],
        balanceNoMempool: json['balance_no_mempool'],
    );

    Map<String, dynamic> toJson() => {
        'balance': balance,
        'total_credits': totalCredits,
        'total_debits': totalDebits,
        'total_fees': totalFees,
        'total_rewards': totalRewards,
        'balance_no_mempool': balanceNoMempool,
    };
}
