import 'dart:async';
import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:my_bismuth_wallet/network/model/response/addlistlim_response.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/network/model/response/balance_get_response.dart';
import 'package:my_bismuth_wallet/network/model/response/mpinsert_response.dart';
import 'package:my_bismuth_wallet/network/model/response/tokens_balance_get_response.dart';
import 'package:my_bismuth_wallet/util/address_derivation.dart';

class BrowserWalletSnapshot {
  final BalanceGetResponse balance;
  final List<AddressTxsResponseResult> transactions;
  final List<BisToken> tokens;
  final List<BrowserWalletTokenTransaction> tokenTransactions;
  final double btcPrice;
  final double localCurrencyPrice;
  final String currencyCode;

  const BrowserWalletSnapshot({
    required this.balance,
    required this.transactions,
    required this.tokens,
    required this.tokenTransactions,
    required this.btcPrice,
    required this.localCurrencyPrice,
    required this.currencyCode,
  });
}

class BrowserWalletTokenTransaction {
  final String tokenName;
  final int blockHeight;
  final DateTime? timestamp;
  final String sender;
  final String recipient;
  final String amount;
  final bool isPending;

  const BrowserWalletTokenTransaction({
    required this.tokenName,
    required this.blockHeight,
    required this.timestamp,
    required this.sender,
    required this.recipient,
    required this.amount,
    this.isPending = false,
  });
}

class BrowserWalletSubmitResult {
  final bool success;
  final String message;
  final String signature;
  final String timestamp;
  final String destination;
  final String amount;
  final String? rawResponse;

  const BrowserWalletSubmitResult({
    required this.success,
    required this.message,
    required this.signature,
    required this.timestamp,
    required this.destination,
    required this.amount,
    this.rawResponse,
  });
}

class BrowserWalletNetworkService {
  static const String _defaultWebSocketUrl =
      String.fromEnvironment(
    'BROWSER_WALLET_WEBSOCKET_URL',
    defaultValue: 'wss://bismuth.world/api/web-socket/',
  );
  static const String _explorerApiBase = String.fromEnvironment(
    'BROWSER_WALLET_EXPLORER_API_BASE',
    defaultValue: 'https://bismuth.im/api/',
  );
  static const String _tokenBalanceApi = String.fromEnvironment(
    'BROWSER_WALLET_TOKEN_BALANCE_API',
    defaultValue: 'https://bismuth.im/api/token/balances/',
  );
  static const String _tokenTransactionsApi = String.fromEnvironment(
    'BROWSER_WALLET_TOKEN_TRANSACTIONS_API',
    defaultValue: 'https://bismuth.im/api/token/transactions/',
  );

  final http.Client _httpClient;
  String _legacyWebSocketUrl;
  BrowserWalletNetworkService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client(),
        _legacyWebSocketUrl = _defaultWebSocketUrl;

  String get legacyWebSocketUrl => _legacyWebSocketUrl;

  void configureLegacyWebSocketUrl(String url) {
    _legacyWebSocketUrl = url;
  }

  void resetLegacyWebSocketUrl() {
    _legacyWebSocketUrl = _defaultWebSocketUrl;
  }

  Future<void> testLegacyConnection() async {
    await _sendLegacyRequest(
      commandFrames: <dynamic>['wstatusget'],
      expectedFrames: 1,
    );
  }

  Future<BrowserWalletSnapshot> loadSnapshot({
    required String address,
    String currencyCode = 'USD',
    int transactionLimit = 50,
  }) async {
    final Future<BalanceGetResponse> balanceFuture = _fetchBalance(address);
    final Future<List<AddressTxsResponseResult>> transactionsFuture =
        _fetchTransactions(address, transactionLimit);
    final Future<List<BisToken>> tokensFuture = _fetchTokens(address);
    final Future<List<BrowserWalletTokenTransaction>> tokenTransactionsFuture =
        _fetchTokenTransactions(address);
    final Future<_PriceData> priceFuture = _fetchPriceData(currencyCode);

    final BalanceGetResponse balance = await balanceFuture;
    final List<AddressTxsResponseResult> transactions =
        await transactionsFuture;
    final List<BisToken> tokens = await tokensFuture;
    final List<BrowserWalletTokenTransaction> tokenTransactions =
        await tokenTransactionsFuture;
    final _PriceData priceData = await priceFuture;

    return BrowserWalletSnapshot(
      balance: balance,
      transactions: transactions,
      tokens: tokens,
      tokenTransactions: _mergePendingTokenTransactions(
        confirmedTransactions: tokenTransactions,
        addressTransactions: transactions,
      ),
      btcPrice: priceData.btcPrice,
      localCurrencyPrice: priceData.localCurrencyPrice,
      currencyCode: currencyCode.toUpperCase(),
    );
  }

  Future<String> loadAccountBalance(String address) async {
    final BalanceGetResponse response = await _fetchBalance(address);
    return response.balance ?? '0';
  }

  Future<bool> addressHasUsage(
    String address, {
    int transactionLimit = 1,
  }) async {
    final List<dynamic> results = await Future.wait<dynamic>(<Future<dynamic>>[
      _fetchBalance(address),
      _fetchTransactions(address, transactionLimit),
      _fetchTokens(address),
      _fetchTokenTransactions(address),
    ]);

    final BalanceGetResponse balance = results[0] as BalanceGetResponse;
    final List<AddressTxsResponseResult> transactions =
        results[1] as List<AddressTxsResponseResult>;
    final List<BisToken> tokens = results[2] as List<BisToken>;
    final List<BrowserWalletTokenTransaction> tokenTransactions =
        results[3] as List<BrowserWalletTokenTransaction>;

    final double balanceValue = double.tryParse(balance.balance ?? '0') ?? 0;
    return balanceValue > 0 ||
        transactions.isNotEmpty ||
        tokens.isNotEmpty ||
        tokenTransactions.isNotEmpty;
  }

  Future<BrowserWalletSubmitResult> submitTransaction({
    required String address,
    required String destination,
    required String amount,
    required String operation,
    required String openfield,
    required String publicKeyBase64,
    required String privateKeyHex,
  }) async {
    final DateTime timestamp =
        DateTime.now().subtract(const Duration(seconds: 4));
    final String timestampValue =
        '${timestamp.toUtc().microsecondsSinceEpoch.toString().substring(0, 10)}.'
        '${timestamp.toUtc().microsecondsSinceEpoch.toString().substring(10, 12)}';
    final String normalizedOperation = removeDiacritics(operation);
    final String normalizedOpenfield = removeDiacritics(openfield);
    final String normalizedAmount =
        (double.tryParse(amount) ?? 0).toStringAsFixed(8);
    final String buffer =
        "('$timestampValue', '$address', '$destination', '$normalizedAmount', '$normalizedOperation', '$normalizedOpenfield')";
    final String signature = await AddressDerivation.signBuffer(
      privateKeyHex: privateKeyHex,
      buffer: buffer,
    );
    final String payload = await _sendLegacyRequest(
      commandFrames: <dynamic>[
        'mpinsert',
        <String>[
          timestampValue,
          address,
          destination,
          normalizedAmount,
          signature,
          publicKeyBase64,
          normalizedOperation,
          normalizedOpenfield,
        ],
      ],
      expectedFrames: 1,
    );

    final List<String> response = mpinsertResponseFromJson(payload);
    if (response.length >= 4 && response[3].contains('Success')) {
      return BrowserWalletSubmitResult(
        success: true,
        message: 'Success',
        signature: signature,
        timestamp: timestampValue,
        destination: destination,
        amount: normalizedAmount,
        rawResponse: payload,
      );
    }
    if (response.length > 1) {
      return BrowserWalletSubmitResult(
        success: false,
        message: response[1],
        signature: signature,
        timestamp: timestampValue,
        destination: destination,
        amount: normalizedAmount,
        rawResponse: payload,
      );
    }
    return BrowserWalletSubmitResult(
      success: false,
      message: payload,
      signature: signature,
      timestamp: timestampValue,
      destination: destination,
      amount: normalizedAmount,
      rawResponse: payload,
    );
  }

  Future<BalanceGetResponse> _fetchBalance(String address) async {
    final http.Response response = await _httpClient.get(
      Uri.parse('$_explorerApiBase'
          'node/balancegetjson:$address'),
      headers: const <String, String>{
        'content-type': 'application/json',
        'access-control-allow-origin': '*',
      },
    );
    if (response.statusCode != 200) {
      throw StateError(
        'Confirmed balance lookup failed with status ${response.statusCode}.',
      );
    }

    final BalanceGetResponse parsed = balanceGetResponseFromJson(response.body);
    parsed.address = address;
    return parsed;
  }

  Future<List<AddressTxsResponseResult>> _fetchTransactions(
    String address,
    int limit,
  ) async {
    final Future<String> mempoolFuture = _sendLegacyRequest(
      commandFrames: <dynamic>[
        'mpgetfor',
        address,
      ],
      expectedFrames: 1,
    );
    final Future<String> blockchainFuture = _fetchConfirmedTransactions(
      address,
      limit,
    );
    final List<String> payloads = await Future.wait(<Future<String>>[
      mempoolFuture,
      blockchainFuture,
    ]);

    final List<dynamic> mempool = addlistlimResponseFromJson(payloads[0]);
    final List<dynamic> blockchain = _decodeConfirmedTransactions(payloads[1]);

    final List<AddressTxsResponseResult> pendingTransactions =
        mempool.map((dynamic item) {
      final AddressTxsResponseResult tx = AddressTxsResponseResult();
      tx.populate(List<dynamic>.from(item as List<dynamic>), address);
      tx.isPending = true;
      return tx;
    }).toList();

    final List<AddressTxsResponseResult> confirmedTransactions =
        blockchain.map((dynamic item) {
      final AddressTxsResponseResult tx = AddressTxsResponseResult();
      tx.populate(_normalizeTransactionRow(item), address);
      tx.isPending = false;
      return tx;
    }).toList();

    final List<AddressTxsResponseResult> transactions =
        <AddressTxsResponseResult>[
      ...pendingTransactions.where(
        (AddressTxsResponseResult pendingTx) => !confirmedTransactions.any(
          (AddressTxsResponseResult confirmedTx) =>
              _transactionsReferToSameTransfer(pendingTx, confirmedTx),
        ),
      ),
      ...confirmedTransactions,
    ];

    transactions.sort((AddressTxsResponseResult a, AddressTxsResponseResult b) {
      final DateTime aTimestamp =
          a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTimestamp =
          b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTimestamp.compareTo(aTimestamp);
    });

    return transactions;
  }

  Future<String> _fetchConfirmedTransactions(String address, int limit) async {
    final http.Response response = await _httpClient.get(
      Uri.parse('$_explorerApiBase'
          'node/addlistlimjson:$address:$limit'),
      headers: const <String, String>{
        'content-type': 'application/json',
        'access-control-allow-origin': '*',
      },
    );
    if (response.statusCode != 200) {
      throw StateError(
        'Confirmed transaction lookup failed with status ${response.statusCode}.',
      );
    }
    return response.body;
  }

  List<dynamic> _decodeConfirmedTransactions(String payload) {
    final dynamic decoded = json.decode(payload);
    if (decoded is List<dynamic>) {
      return decoded;
    }
    return const <dynamic>[];
  }

  List<dynamic> _normalizeTransactionRow(dynamic item) {
    if (item is List<dynamic>) {
      return List<dynamic>.from(item);
    }
    if (item is Map<String, dynamic>) {
      return <dynamic>[
        _lookupValue(
            item, const <String>['block_height', 'blockheight', 'height'], 0),
        _lookupValue(item, const <String>['timestamp', 'time'], 0),
        _lookupValue(item, const <String>['address', 'from', 'sender'], ''),
        _lookupValue(item, const <String>['recipient', 'to'], ''),
        _lookupValue(item, const <String>['amount'], '0'),
        _lookupValue(item, const <String>['signature', 'txid', 'hash'], ''),
        _lookupValue(item, const <String>['public_key', 'publickey'], ''),
        _lookupValue(item, const <String>['block_hash', 'blockhash'], ''),
        _lookupValue(item, const <String>['fee'], 0),
        _lookupValue(item, const <String>['reward'], 0),
        _lookupValue(item, const <String>['operation'], ''),
        _lookupValue(item, const <String>['openfield'], ''),
      ];
    }
    return const <dynamic>[];
  }

  dynamic _lookupValue(
    Map<String, dynamic> row,
    List<String> keys,
    dynamic fallback,
  ) {
    for (final String key in keys) {
      if (row.containsKey(key)) {
        return row[key];
      }
    }
    return fallback;
  }

  bool _transactionsReferToSameTransfer(
    AddressTxsResponseResult first,
    AddressTxsResponseResult second,
  ) {
    final String firstSignature = (first.signature ?? '').trim();
    final String secondSignature = (second.signature ?? '').trim();
    if (firstSignature.isNotEmpty && secondSignature.isNotEmpty) {
      if (firstSignature == secondSignature ||
          firstSignature.startsWith(secondSignature) ||
          secondSignature.startsWith(firstSignature)) {
        return true;
      }
    }

    final bool sameSender =
        _normalizeText(first.from) == _normalizeText(second.from);
    final bool sameRecipient =
        _normalizeText(first.recipient) == _normalizeText(second.recipient);
    final bool sameAmount = _amountsMatch(first.amount, second.amount);
    final bool sameOperation =
        _normalizeText(first.operation) == _normalizeText(second.operation);
    final bool sameOpenfield =
        _normalizeText(first.openfield) == _normalizeText(second.openfield);
    if (!(sameSender &&
        sameRecipient &&
        sameAmount &&
        sameOperation &&
        sameOpenfield)) {
      return false;
    }

    final DateTime? firstTimestamp = first.timestamp;
    final DateTime? secondTimestamp = second.timestamp;
    if (firstTimestamp == null || secondTimestamp == null) {
      return true;
    }

    final int timestampDifference =
        firstTimestamp.difference(secondTimestamp).inSeconds.abs();
    return timestampDifference <= 3600;
  }

  String _normalizeText(String? value) => (value ?? '').trim();

  bool _amountsMatch(String? first, String? second) {
    final String left = _normalizeText(first);
    final String right = _normalizeText(second);
    if (left == right) {
      return true;
    }

    final num? leftValue = num.tryParse(left);
    final num? rightValue = num.tryParse(right);
    if (leftValue == null || rightValue == null) {
      return false;
    }

    return (leftValue - rightValue).abs() < 0.00000001;
  }

  Future<List<BisToken>> _fetchTokens(String address) async {
    final http.Response response = await _httpClient.get(
      Uri.parse('$_tokenBalanceApi$address'),
      headers: const <String, String>{
        'content-type': 'application/json',
        'access-control-allow-origin': '*',
      },
    );

    if (response.statusCode != 200) {
      return <BisToken>[];
    }

    final List<List<dynamic>> decoded =
        tokensBalanceGetResponseFromJson(response.body);
    return decoded
        .map((List<dynamic> token) {
          final int quantity =
              token.length > 1 ? _normalizeTokenQuantity(token[1]) : 0;
          return BisToken(
            tokenName: token.isNotEmpty ? token[0]?.toString() : null,
            tokensQuantity: quantity,
          );
        })
        .where((BisToken token) =>
            (token.tokenName?.trim().isNotEmpty ?? false) &&
            (token.tokensQuantity ?? 0) > 0)
        .toList();
  }

  Future<List<BrowserWalletTokenTransaction>> _fetchTokenTransactions(
    String address,
  ) async {
    final http.Response response = await _httpClient.get(
      Uri.parse('$_tokenTransactionsApi$address'),
      headers: const <String, String>{
        'content-type': 'application/json',
        'access-control-allow-origin': '*',
      },
    );

    if (response.statusCode != 200) {
      return const <BrowserWalletTokenTransaction>[];
    }

    final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
    final List<BrowserWalletTokenTransaction> transactions =
        decoded.map((dynamic item) {
      final List<dynamic> row = item as List<dynamic>;
      final int timestampSeconds =
          row.length > 2 ? _normalizeTokenQuantity(row[2]) : 0;
      return BrowserWalletTokenTransaction(
        tokenName: row.isNotEmpty ? row[0]?.toString() ?? '' : '',
        blockHeight: row.length > 1 ? _normalizeTokenQuantity(row[1]) : 0,
        timestamp: timestampSeconds > 0
            ? DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000)
            : null,
        sender: row.length > 3 ? row[3]?.toString() ?? '' : '',
        recipient: row.length > 4 ? row[4]?.toString() ?? '' : '',
        amount: row.length > 5 ? row[5]?.toString() ?? '0' : '0',
        isPending: false,
      );
    }).toList();

    transactions.sort(
        (BrowserWalletTokenTransaction a, BrowserWalletTokenTransaction b) {
      final DateTime aTimestamp =
          a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTimestamp =
          b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTimestamp.compareTo(aTimestamp);
    });

    return transactions;
  }

  List<BrowserWalletTokenTransaction> _mergePendingTokenTransactions({
    required List<BrowserWalletTokenTransaction> confirmedTransactions,
    required List<AddressTxsResponseResult> addressTransactions,
  }) {
    final List<BrowserWalletTokenTransaction> pendingTransactions =
        addressTransactions
            .where((AddressTxsResponseResult tx) =>
                tx.isPending && tx.isTokenTransfer())
            .map((AddressTxsResponseResult tx) {
              final BisToken? token = tx.getBisToken();
              return BrowserWalletTokenTransaction(
                tokenName: token?.tokenName ?? '',
                blockHeight: tx.blockHeight ?? 0,
                timestamp: tx.timestamp,
                sender: tx.from ?? '',
                recipient: tx.recipient ?? '',
                amount: token?.tokensQuantity?.toString() ?? tx.amount ?? '0',
                isPending: true,
              );
            })
            .where(
                (BrowserWalletTokenTransaction tx) => tx.tokenName.isNotEmpty)
            .toList();

    final List<BrowserWalletTokenTransaction> merged =
        <BrowserWalletTokenTransaction>[
      ...pendingTransactions,
      ...confirmedTransactions,
    ];

    merged.sort(
        (BrowserWalletTokenTransaction a, BrowserWalletTokenTransaction b) {
      if (a.isPending != b.isPending) {
        return a.isPending ? -1 : 1;
      }
      final DateTime aTimestamp =
          a.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bTimestamp =
          b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTimestamp.compareTo(aTimestamp);
    });

    return merged;
  }

  int _normalizeTokenQuantity(dynamic rawValue) {
    if (rawValue is int) {
      return rawValue;
    }
    if (rawValue is num) {
      return rawValue.toInt();
    }

    final String text = rawValue?.toString().trim() ?? '';
    if (text.isEmpty) {
      return 0;
    }

    return num.tryParse(text)?.toInt() ?? 0;
  }

  Future<_PriceData> _fetchPriceData(String currencyCode) async {
    final String lowerCurrency = currencyCode.toLowerCase();
    final Uri btcUri = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price?ids=bismuth&vs_currencies=btc',
    );
    final Uri localUri = Uri.parse(
      'https://api.coingecko.com/api/v3/simple/price?ids=bismuth&vs_currencies=$lowerCurrency',
    );

    final http.Response btcResponse = await _httpClient.get(btcUri);
    final http.Response localResponse = await _httpClient.get(localUri);

    double btcPrice = 0;
    double localCurrencyPrice = 0;

    if (btcResponse.statusCode == 200) {
      final Map<String, dynamic> jsonBody =
          json.decode(btcResponse.body) as Map<String, dynamic>;
      btcPrice = ((jsonBody['bismuth'] as Map<String, dynamic>)['btc'] as num?)
              ?.toDouble() ??
          0;
    }

    if (localResponse.statusCode == 200) {
      final Map<String, dynamic> jsonBody =
          json.decode(localResponse.body) as Map<String, dynamic>;
      localCurrencyPrice =
          ((jsonBody['bismuth'] as Map<String, dynamic>)[lowerCurrency] as num?)
                  ?.toDouble() ??
              0;
    }

    return _PriceData(
      btcPrice: btcPrice,
      localCurrencyPrice: localCurrencyPrice,
    );
  }

  Future<List<String>> _sendLegacyRequestFrames({
    required List<dynamic> commandFrames,
    required int expectedFrames,
  }) async {
    final Uri uri = Uri.parse(_legacyWebSocketUrl);
    final WebSocketChannel channel = WebSocketChannel.connect(uri);
    final Completer<List<String>> completer = Completer<List<String>>();
    final List<String> messages = <String>[];
    late final StreamSubscription<dynamic> subscription;

    subscription = channel.stream.listen(
      (dynamic data) {
        final List<String> frames = _normalizeSocketData(data);
        messages.addAll(frames);
        if (messages.length >= expectedFrames && !completer.isCompleted) {
          completer.complete(messages.take(expectedFrames).toList());
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(
            StateError('Socket closed before the response completed.'),
          );
        }
      },
      cancelOnError: true,
    );

    channel.sink.add(json.encode(commandFrames));

    try {
      return await completer.future.timeout(const Duration(seconds: 8));
    } finally {
      await subscription.cancel();
      await channel.sink.close();
    }
  }

  Future<String> _sendLegacyRequest({
    required List<dynamic> commandFrames,
    required int expectedFrames,
  }) async {
    final List<String> frames = await _sendLegacyRequestFrames(
      commandFrames: commandFrames,
      expectedFrames: expectedFrames,
    );
    return frames.first;
  }

  List<String> _normalizeSocketData(dynamic data) {
    final String payload;
    if (data is String) {
      payload = data.trim();
    } else if (data is List<int>) {
      payload = utf8.decode(data).trim();
    } else {
      payload = data.toString().trim();
    }

    if (payload.isEmpty) {
      return const <String>[];
    }

    try {
      json.decode(payload);
      return <String>[payload];
    } on FormatException {
      return _extractLegacyFrames(payload);
    }
  }

  List<String> _extractLegacyFrames(String payload) {
    final List<String> frames = <String>[];
    int cursor = 0;

    while (payload.length >= cursor + 10) {
      final int? frameLength =
          int.tryParse(payload.substring(cursor, cursor + 10));
      if (frameLength == null || payload.length < cursor + 10 + frameLength) {
        break;
      }

      final int payloadStart = cursor + 10;
      final int payloadEnd = payloadStart + frameLength;
      frames.add(payload.substring(payloadStart, payloadEnd));
      cursor = payloadEnd;
    }

    if (frames.isNotEmpty) {
      return frames;
    }
    return <String>[payload];
  }
}

class _PriceData {
  final double btcPrice;
  final double localCurrencyPrice;

  const _PriceData({
    required this.btcPrice,
    required this.localCurrencyPrice,
  });
}
