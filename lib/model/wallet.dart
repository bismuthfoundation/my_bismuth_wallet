import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:my_bismuth_wallet/model/available_currency.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/util/numberutil.dart';

/// Main wallet object that's passed around the app via state
class AppWallet {
  static const String defaultRepresentative = '0xf2b4f700d2975abd39000587f9788f66afedf691';

  bool _loading; // Whether or not app is initially loading
  bool _historyLoading; // Whether or not we have received initial account history response
  String _address;
  double _accountBalance;
  String _representative;
  String _localCurrencyPrice;
  String _btcPrice;
  List<AddressTxsResponseResult> _history;
  List<BisToken> _tokens;


  AppWallet({String address, double accountBalance, 
                String representative, String localCurrencyPrice,String btcPrice, 
                List<AddressTxsResponseResult> history, bool loading, bool historyLoading, List<BisToken> tokens}) {
    this._address = address;
    this._accountBalance = accountBalance ?? 0;
    this._representative = representative;
    this._localCurrencyPrice = localCurrencyPrice ?? "0";
    this._btcPrice = btcPrice ?? "0";
    this._history = history ?? new List<AddressTxsResponseResult>();
    this._tokens = tokens ?? new List<BisToken>();
    this._loading = loading ?? true;
    this._historyLoading = historyLoading  ?? true;
  }

  String get address => _address;

  set address(String address) {
    this._address = address;
  }

  double get accountBalance => _accountBalance;

  set accountBalance(double accountBalance) {
    this._accountBalance = accountBalance;
  }

  // Get pretty account balance version
  String getAccountBalanceDisplay() {
    if (accountBalance == null) {
      return "0";
    }
    return NumberUtil.getRawAsUsableString(_accountBalance.toString());
  }


  String getLocalCurrencyPrice(AvailableCurrency currency, {String locale = "en_US"}) {
    Decimal converted = Decimal.parse(_localCurrencyPrice) * NumberUtil.getRawAsUsableDecimal(_accountBalance.toString());
    return NumberFormat.currency(locale:locale, symbol: currency.getCurrencySymbol()).format(converted.toDouble());
  }

  set localCurrencyPrice(String value) {
    _localCurrencyPrice = value;
  }

  String get localCurrencyConversion {
    return _localCurrencyPrice;
  }

  String get btcPrice {
    Decimal converted = Decimal.parse(_btcPrice) * NumberUtil.getRawAsUsableDecimal(_accountBalance.toString());
    // Show 4 decimal places for BTC price if its >= 0.0001 BTC, otherwise 6 decimals
    if (converted >= Decimal.parse("0.0001")) {
      return new NumberFormat("#,##0.0000", "en_US").format(converted.toDouble());
    } else {
      return new NumberFormat("#,##0.000000000", "en_US").format(converted.toDouble());
    }
  }

  set btcPrice(String value) {
    _btcPrice = value;
  }

  String get representative {
   return _representative ?? defaultRepresentative;
  }

  set representative(String value) {
    _representative = value;
  }

  List<AddressTxsResponseResult> get history => _history;

  set history(List<AddressTxsResponseResult> value) {
    _history = value;
  }

  List<BisToken> get tokens => _tokens;

  set tokens(List<BisToken> value) {
    _tokens = value;
  }

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
  }

  bool get historyLoading => _historyLoading;

  set historyLoading(bool value) {
    _historyLoading = value;
  }
}