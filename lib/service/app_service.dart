import 'dart:async';
import 'dart:io';
import 'package:event_taxi/event_taxi.dart';
import 'package:logger/logger.dart';
import 'package:my_bismuth_wallet/bus/events.dart';
import 'package:my_bismuth_wallet/model/db/account.dart';
import 'package:my_bismuth_wallet/network/model/request/send_tx_request.dart';
import 'package:my_bismuth_wallet/network/model/response/addlistlim_response.dart';
import 'package:my_bismuth_wallet/network/model/response/alias_get_response.dart';
import 'package:my_bismuth_wallet/network/model/response/balance_get_response.dart';
import 'package:my_bismuth_wallet/network/model/response/mpinsert_response.dart';
import 'package:my_bismuth_wallet/network/model/response/servers_wallet_legacy.dart';
import 'package:diacritic/diacritic.dart';
import 'package:my_bismuth_wallet/network/model/response/wstatusget_response.dart';
import 'package:my_bismuth_wallet/service/http_service.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:synchronized/synchronized.dart';

class AppService {
  final Logger log = sl.get<Logger>();

  Socket _socket;

  // connection status
  bool _isConnected;
  bool _isConnecting;
  bool suspended; // When the app explicity closes the connection

  // Lock instance for synchronization
  Lock _lock;
  String allMessages = "";

  AppService() {
    _isConnected = false;
    _isConnecting = false;
    suspended = false;
    _lock = Lock();
    initCommunication(unsuspend: true);
  }

  // Re-connect handling
  bool _isInRetryState = false;
  StreamSubscription<dynamic> reconnectStream;

  /// Retry up to once per 1 seconds
  Future<void> reconnectToService() async {
    if (_isInRetryState) {
      return;
    } else if (reconnectStream != null) {
      reconnectStream.cancel();
    }
    _isInRetryState = true;
    //log.d("Retrying connection...");
    Future<dynamic> delayed = new Future.delayed(new Duration(milliseconds: 100));
    delayed.then((_) {
      return true;
    });
    reconnectStream = delayed.asStream().listen((_) {
      //log.d("Attempting connection to service");
      initCommunication(unsuspend: true);
      _isInRetryState = false;
    });
  }

  // Connect to server
  Future<void> initCommunication({bool unsuspend = false}) async {
    if (_isConnected || _isConnecting) {
      return;
    } else if (suspended && !unsuspend) {
      return;
    } else if (!unsuspend) {
      reconnectToService();
      return;
    }
    _isConnecting = true;
    try {
      _isConnecting = true;
      suspended = false;
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await sl.get<HttpService>().getBestServerWalletLegacyResponse();
      //print("serverWalletLegacyResponse.ip : " + serverWalletLegacyResponse.ip);
      //print("serverWalletLegacyResponse.port : " +
      //    serverWalletLegacyResponse.port.toString());
      if (serverWalletLegacyResponse.ip == null ||
          serverWalletLegacyResponse.port == null) {
        _isConnected = false;
        _isConnecting = false;
        EventTaxiImpl.singleton().fire(
            ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
      } else {
        _socket = await Socket.connect(
            serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port);
        //log.d("Connected to service");
        _isConnecting = false;
        _isConnected = true;

        EventTaxiImpl.singleton().fire(ConnStatusEvent(
            status: ConnectionStatus.CONNECTED,
            server: serverWalletLegacyResponse.ip +
                ":" +
                serverWalletLegacyResponse.port.toString()));
        _socket.listen(_onMessageReceived,
            onDone: connectionClosed, onError: connectionClosedError);
      }
    } catch (e) {
      log.e("Error from service ${e.toString()}", e);
      _isConnected = false;
      _isConnecting = false;
      EventTaxiImpl.singleton().fire(
          ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
    }
  }

  // Send message
  bool _send(String message) {
    allMessages = "";
    bool writeOk = false;
    bool reset = false;
    try {
      if (_socket != null && _isConnected) {
        _socket.write(message);
        writeOk = true;
      } else {
        reset = true; // Re-establish connection
      }
    } catch (e) {
      reset = true;
    } finally {
      if (reset) {
        if (!_isConnecting && !suspended) {
          initCommunication();
        }
      }
    }
    return writeOk;
  }

  // Connection closed (normally)
  void connectionClosed() {
    _isConnected = false;
    _isConnecting = false;
    //log.d("disconnected from service");
    // Send disconnected message
    EventTaxiImpl.singleton().fire(
        ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
  }

  // Connection closed (with error)
  void connectionClosedError(e) {
    _isConnected = false;
    _isConnecting = false;
    log.w("disconnected from service with error ${e.toString()}");
    // Send disconnected message
    EventTaxiImpl.singleton().fire(
        ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
  }

  // Close connection
  void reset({bool suspend = false}) {
    suspended = suspend;
    if (_socket != null) {
      _socket.close();
      _isConnected = false;
      _isConnecting = false;
    }
  }

  Future<void> _onMessageReceived(dynamic data) async {
    //print("_onMessageReceived");
    if (suspended) {
      //print("suspended");
      return;
    }
    await _lock.synchronized(() async {
      _isConnected = true;
      _isConnecting = false;
      allMessages += new String.fromCharCodes(data).trim();
      //print("response : " + allMessages);
      //print("response length : " + allMessages.length.toString());
      String message = "";
      int lengthMessage = 0;
      if (allMessages != null && allMessages.length >= 10) {
        // For each messages
        for (int i = 0; i < allMessages.length; i = i + 10 + lengthMessage) {
          try {
            if (allMessages.length >= i + 10) {
              lengthMessage = int.tryParse(allMessages.substring(i, i + 10));
              if (lengthMessage != null &&
                  allMessages.length >= i + 10 + lengthMessage) {
                //print("allMessage: " + allMessages);
                message = allMessages.substring(i + 10, i + 10 + lengthMessage);

                //print("message: " + message);
                //int.tryParse(message.substring(0, 10)) != null &&
                //message.length == 10 + int.tryParse(message.substring(0, 10))) {
                //message =
                //  message.substring(10, 10 + int.tryParse(message.substring(0, 10)));

                // Determine the type of response
                if (message.contains("clients") &&
                    message.contains("version") &&
                    message.contains("max_clients")) {
                  WStatusGetResponse wStatusGetResponse =
                      wStatusGetResponseFromJson(message);
                  EventTaxiImpl.singleton()
                      .fire(WStatusGetEvent(response: wStatusGetResponse));
                } else if (message.contains("balance") &&
                    message.contains("total_credits") &&
                    message.contains("total_debits")) {
                  BalanceGetResponse balanceGetResponse =
                      balanceGetResponseFromJson(message);
                  //print("fire BalanceGetEvent");
                  EventTaxiImpl.singleton()
                      .fire(BalanceGetEvent(response: balanceGetResponse));
                } else if (message.length > 2 &&
                    message.substring(0, 3) == '[["' &&
                    message.substring(message.length - 3, message.length) ==
                        '"]]') {
                  List alias = aliasGetResponseFromJson(message);
                  //print("fire AliasListEvent");
                  EventTaxiImpl.singleton()
                      .fire(AliasListEvent(response: alias));
                } else if (message.contains("[[") && message.contains("]]") ||
                    message == "[]") {
                  List txs = addlistlimResponseFromJson(message);
                  //print("fire TransactionsListEvent");
                  EventTaxiImpl.singleton()
                      .fire(TransactionsListEvent(response: txs));
                } else if (message.length > 1 &&
                    message.substring(0, 1) == "[" &&
                    message.substring(message.length - 1, message.length) ==
                        "]") {
                  //print("allMessages : " + allMessages);
                  //print("transactionSendEvent message : " + message);
                  //print("fire TransactionSendEvent");
                  List<String> sendTxResponse =
                      mpinsertResponseFromJson(message);
                  if (sendTxResponse.length < 4 ||
                      sendTxResponse[3].contains("Success") == false) {
                    EventTaxiImpl.singleton().fire(
                        TransactionSendEvent(response: sendTxResponse[1]));
                  } else {
                    EventTaxiImpl.singleton()
                        .fire(TransactionSendEvent(response: "Success"));
                  }
                }
              } else {
                lengthMessage = allMessages.length + 1;
              }
            } else {
              //print("message incomplete");
            }
          } catch (e) {
            //print("error: " + e);
          }
        }
      } else {
        //print("message null or < 10");
      }

      return;
    });
  }

  String getLengthBuffer(String message) {
    return message == null ? null : message.length.toString().padLeft(10, '0');
  }

  void getBalanceGetResponse(Account account) {
    //print("getBalanceGetResponse");
    try {
      //Send the request
      String method = '"balancegetjson"';
      String param = '"' + account.address + '"';
      String sendMessage =
          getLengthBuffer(method) + method + getLengthBuffer(param) + param;
      _send(sendMessage);
    } catch (e) {
      //print("pb socket" + e.toString());
    }
  }

  void getAddressTxsResponse(String address, int limit) {
    //print("getAddressTxsResponse");
    try {
      //Send the request
      String method = '"addlistlim"';
      String param1 = '"' + address + '"';
      String param2 = '"' + limit.toString() + '"';

      String sendMessage = getLengthBuffer(method) +
          method +
          getLengthBuffer(param1) +
          param1 +
          getLengthBuffer(param2) +
          param2;
      _send(sendMessage);
    } catch (e) {
      //print("pb socket" + e.toString());
    }
  }

  void getAddressTxsInMempoolResponse(String address) {
    //print("getAddressTxsInMempoolResponse");
    try {
      //Send the request
      String method = '"mpgetfor"';
      String param1 = '"' + address + '"';

      String sendMessage =
          getLengthBuffer(method) + method + getLengthBuffer(param1) + param1;
      _send(sendMessage);
    } catch (e) {
      //print("pb socket" + e.toString());
    }
  }

  void getAlias(String address) {
    //print("getAlias");
    try {
      //Send the request
      String method = '"aliasget"';
      String param1 = '"' + address + '"';

      String sendMessage =
          getLengthBuffer(method) + method + getLengthBuffer(param1) + param1;
      _send(sendMessage);
    } catch (e) {
      //print("pb socket" + e.toString());
    }
  }

  bool sendTx(String address, String amount, String destination,
      String openfield, String operation, String publicKey, String privateKey) {
    SendTxRequest sendTxRequest = new SendTxRequest();
    Tx tx = new Tx();
    //print("address : " + address);
    //print("amount : " + amount);
    //print("destination : " + destination);
    //print("publicKey : " + publicKey);
    //print("privateKey : " + privateKey);

    try {
      //Send the request
      // Substract 2 sec to limit the issue with future tx
      DateTime timeBefore2sec =
          DateTime.now().subtract(new Duration(seconds: 2));
      tx.timestamp = timeBefore2sec
              .toUtc()
              .microsecondsSinceEpoch
              .toString()
              .substring(0, 10) +
          "." +
          timeBefore2sec
              .toUtc()
              .microsecondsSinceEpoch
              .toString()
              .substring(10, 12);
      tx.address = address;
      tx.recipient = destination;
      tx.amount = double.tryParse(amount).toStringAsFixed(8);
      tx.operation = removeDiacritics(operation);
      tx.openfield = removeDiacritics(openfield);

      sendTxRequest.id = 0;
      sendTxRequest.tx = tx;
      sendTxRequest.buffer = tx.buildBufferValue();

      sendTxRequest.publicKey = publicKey;
      sendTxRequest.buildSignature(privateKey);
      sendTxRequest.websocketCommand = "";

      String method = '"mpinsert"';
      String param = sendTxRequest.buildCommand();
      String sendMessage =
          getLengthBuffer(method) + method + getLengthBuffer(param) + param;
      //print("sendMessage: " + sendMessage);
      //print("_send n° 1");
      if (_send(sendMessage) == false) {
        // Try again once
        Future.delayed(const Duration(seconds: 2), () {
          //print("_send n° 2");
          return _send(sendMessage);
        });
      } else {
        return true;
      }
    } catch (e) {
      //print("pb socket" + e.toString());
    }
  }

  double getFeesEstimation(String openfield, String operation) {
    const double FEE_BASE = 0.01;
    double fees = FEE_BASE;
    if (openfield != null) {
      fees += (openfield.length / 100000);
      if (openfield.startsWith("alias=")) {
        fees += 1;
      }
    }
    if (operation != null) {
      if (operation == "token:issue") {
        fees += 10;
      }
      if (operation == "alias:register") {
        fees += 1;
      }
    }

    //print("getFeesEstimation: " + fees.toString());
    return fees;
  }

  void getWStatusGetResponse() {
    try {
      //Send the request
      String method = '"wstatusget"';
      String sendMessage = getLengthBuffer(method) + method;
      _send(sendMessage);
    } catch (e) {
      //print("pb socket" + e.toString());
    }
  }
}
