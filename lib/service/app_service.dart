// @dart=2.9

// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:diacritic/diacritic.dart';
import 'package:event_taxi/event_taxi.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:my_bismuth_wallet/bus/events.dart';
import 'package:my_bismuth_wallet/network/model/request/send_tx_request.dart';
import 'package:my_bismuth_wallet/network/model/response/addlistlim_response.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/network/model/response/alias_get_response.dart';
import 'package:my_bismuth_wallet/network/model/response/balance_get_response.dart';
import 'package:my_bismuth_wallet/network/model/response/mpinsert_response.dart';
import 'package:my_bismuth_wallet/network/model/response/servers_wallet_legacy.dart';
import 'package:my_bismuth_wallet/network/model/response/wstatusget_response.dart';
import 'package:my_bismuth_wallet/service/http_service.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:web_socket_channel/io.dart';

class AppService {
  final Logger log = sl.get<Logger>();

  // Lock instance for synchronization
  String allMessages = "";

  String getLengthBuffer(String message) {
    return message == null ? null : message.length.toString().padLeft(10, '0');
  }

  Future<void> getWStatusGetResponse() async {
    //print("getWStatusGetResponse");

    try {
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await sl.get<HttpService>().getBestServerWalletLegacyResponse();
      if (serverWalletLegacyResponse.ip == null ||
          serverWalletLegacyResponse.port == null) {
        EventTaxiImpl.singleton().fire(
            ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
      } else {
        IOWebSocketChannel _webSocket;
        Socket _socket;
        if (kIsWeb) {
          _webSocket = IOWebSocketChannel.connect(
              serverWalletLegacyResponse.ip +
                  ':' +
                  serverWalletLegacyResponse.port.toString());
        } else {
          _socket = await Socket.connect(
              serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port,
              timeout: Duration(seconds: 3));
        }

        EventTaxiImpl.singleton().fire(ConnStatusEvent(
            status: ConnectionStatus.CONNECTED,
            server: serverWalletLegacyResponse.ip +
                ":" +
                serverWalletLegacyResponse.port.toString()));

        //Establish the onData, and onDone callbacks
        String message = "";
        if (kIsWeb) {
          _webSocket.stream.listen((data) {
            if (data != null) {
              message += new String.fromCharCodes(data).trim();
              if (message != null &&
                  message.length >= 10 &&
                  int.tryParse(message.substring(0, 10)) != null &&
                  message.length ==
                      10 + int.tryParse(message.substring(0, 10))) {
                message = message.substring(
                    10, 10 + int.tryParse(message.substring(0, 10)));
                WStatusGetResponse wStatusGetResponse =
                    wStatusGetResponseFromJson(message);
                if (wStatusGetResponse == null) {
                  EventTaxiImpl.singleton().fire(ConnStatusEvent(
                      status: ConnectionStatus.DISCONNECTED, server: ""));
                }
              }
            }
          }, onError: ((error, StackTrace trace) {
            //print("Error");
          }), onDone: () {
            //print("Done");
            _socket.destroy();
          }, cancelOnError: false);
        } else {
          _socket.listen((data) {
            if (data != null) {
              message += new String.fromCharCodes(data).trim();
              if (message != null &&
                  message.length >= 10 &&
                  int.tryParse(message.substring(0, 10)) != null &&
                  message.length ==
                      10 + int.tryParse(message.substring(0, 10))) {
                message = message.substring(
                    10, 10 + int.tryParse(message.substring(0, 10)));
                WStatusGetResponse wStatusGetResponse =
                    wStatusGetResponseFromJson(message);
                if (wStatusGetResponse == null) {
                  EventTaxiImpl.singleton().fire(ConnStatusEvent(
                      status: ConnectionStatus.DISCONNECTED, server: ""));
                }
              }
            }
          }, onError: ((error, StackTrace trace) {
            //print("Error");
          }), onDone: () {
            //print("Done");
            _socket.destroy();
          }, cancelOnError: false);
        }

        //Send the request
        String method = '"wstatusget"';

        _socket.write(getLengthBuffer(method) + method);
      }
    } catch (e) {
      //print("pb socket" + e.toString());
      EventTaxiImpl.singleton().fire(
          ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
    } finally {}
  }

  Future<void> getAlias(String address) async {
    //print("getAlias");

    try {
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await sl.get<HttpService>().getBestServerWalletLegacyResponse();
      if (serverWalletLegacyResponse.ip == null ||
          serverWalletLegacyResponse.port == null) {
        EventTaxiImpl.singleton().fire(
            ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
      } else {
        Socket _socket = await Socket.connect(
            serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port,
            timeout: Duration(seconds: 3));

        EventTaxiImpl.singleton().fire(ConnStatusEvent(
            status: ConnectionStatus.CONNECTED,
            server: serverWalletLegacyResponse.ip +
                ":" +
                serverWalletLegacyResponse.port.toString()));

        //Establish the onData, and onDone callbacks
        String message = "";
        _socket.listen((data) {
          if (data != null) {
            message += new String.fromCharCodes(data).trim();
            if (message != null &&
                message.length >= 10 &&
                int.tryParse(message.substring(0, 10)) != null &&
                message.length == 10 + int.tryParse(message.substring(0, 10))) {
              message = message.substring(
                  10, 10 + int.tryParse(message.substring(0, 10)));
              List alias = aliasGetResponseFromJson(message);
              //print("fire AliasListEvent");
              EventTaxiImpl.singleton().fire(AliasListEvent(response: alias));
            }
          }
        }, onError: ((error, StackTrace trace) {
          //print("Error");
        }), onDone: () {
          //print("Done");
          _socket.destroy();
        }, cancelOnError: false);

        //Send the request
        String method = '"aliasget"';
        String param = '"' + address + '"';

        _socket.write(
            getLengthBuffer(method) + method + getLengthBuffer(param) + param);
      }
    } catch (e) {
      //print("pb socket" + e.toString());
      EventTaxiImpl.singleton().fire(
          ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
    } finally {}
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

  Future<void> getAddressTxsResponse(String address, int limit) async {
    AddressTxsResponse addressTxsResponse = new AddressTxsResponse();

    addressTxsResponse.tokens =
        await sl.get<HttpService>().getTokensBalance(address);

    addressTxsResponse.result = new List<AddressTxsResponseResult>();

    try {
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await sl.get<HttpService>().getBestServerWalletLegacyResponse();

      if (serverWalletLegacyResponse.ip == null ||
          serverWalletLegacyResponse.port == null) {
        EventTaxiImpl.singleton().fire(
            ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
      } else {
        IOWebSocketChannel _webSocket;
        Socket _socket;
        if (kIsWeb) {
          _webSocket = IOWebSocketChannel.connect(
              serverWalletLegacyResponse.ip +
                  ':' +
                  serverWalletLegacyResponse.port.toString());
        } else {
          _socket = await Socket.connect(
              serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port,
              timeout: Duration(seconds: 3));
        }

        EventTaxiImpl.singleton().fire(ConnStatusEvent(
            status: ConnectionStatus.CONNECTED,
            server: serverWalletLegacyResponse.ip +
                ":" +
                serverWalletLegacyResponse.port.toString()));

        //Establish the onData, and onDone callbacks
        String message = "";
        if (kIsWeb) {
          _webSocket.stream.listen((data) {
            if (data != null) {
              message += new String.fromCharCodes(data).trim();
              //print("response : " + message);
              //print("response length : " + message.length.toString());
              if (message != null &&
                  message.length >= 10 &&
                  int.tryParse(message.substring(0, 10)) != null) {
                // Parse mempool tx
                int mempoolTxListStringLength =
                    int.tryParse(message.substring(0, 10));
                if (message.length >= 10 + mempoolTxListStringLength) {
                  String mempoolTxListString =
                      message.substring(10, 10 + mempoolTxListStringLength);
                  int mempoolTxListStringEnd = 10 + mempoolTxListStringLength;
                  //print(
                  //    "getAddressTxsResponse (memPool) : " + mempoolTxListString);
                  List mempoolTxs =
                      addlistlimResponseFromJson(mempoolTxListString);

                  // Parse blockchain tx
                  if (message.length >= 10 + mempoolTxListStringEnd) {
                    int blockchainTxListStringLength = int.tryParse(
                        message.substring(mempoolTxListStringEnd,
                            10 + mempoolTxListStringEnd));
                    if (message.length >=
                        10 +
                            mempoolTxListStringEnd +
                            blockchainTxListStringLength) {
                      String blockchainTxListString = message.substring(
                          10 + mempoolTxListStringEnd,
                          10 +
                              mempoolTxListStringEnd +
                              blockchainTxListStringLength);
                      //print("getAddressTxsResponse (blockchain) : " +
                      //    blockchainTxListString);
                      List blockChainTxs =
                          addlistlimResponseFromJson(blockchainTxListString);

                      List txs = new List();
                      txs.addAll(mempoolTxs);
                      txs.addAll(blockChainTxs);

                      EventTaxiImpl.singleton()
                          .fire(TransactionsListEvent(response: txs));
                      for (int i = txs.length - 1; i >= 0; i--) {
                        AddressTxsResponseResult addressTxResponse =
                            new AddressTxsResponseResult();
                        addressTxResponse.populate(txs[i], address);
                        addressTxResponse.getBisToken();
                        addressTxsResponse.result.add(addressTxResponse);
                      }
                    }
                  }
                }
              } else {
                //print("response length ko : " + message.length.toString());
              }
            }
          }, onError: ((error, StackTrace trace) {
            //print("Error");
          }), onDone: () {
            //print("Done");
            _socket.destroy();
          }, cancelOnError: false);
        } else {
          _socket.listen((data) {
            if (data != null) {
              message += new String.fromCharCodes(data).trim();
              //print("response : " + message);
              //print("response length : " + message.length.toString());
              if (message != null &&
                  message.length >= 10 &&
                  int.tryParse(message.substring(0, 10)) != null) {
                // Parse mempool tx
                int mempoolTxListStringLength =
                    int.tryParse(message.substring(0, 10));
                if (message.length >= 10 + mempoolTxListStringLength) {
                  String mempoolTxListString =
                      message.substring(10, 10 + mempoolTxListStringLength);
                  int mempoolTxListStringEnd = 10 + mempoolTxListStringLength;
                  //print(
                  //    "getAddressTxsResponse (memPool) : " + mempoolTxListString);
                  List mempoolTxs =
                      addlistlimResponseFromJson(mempoolTxListString);

                  // Parse blockchain tx
                  if (message.length >= 10 + mempoolTxListStringEnd) {
                    int blockchainTxListStringLength = int.tryParse(
                        message.substring(mempoolTxListStringEnd,
                            10 + mempoolTxListStringEnd));
                    if (message.length >=
                        10 +
                            mempoolTxListStringEnd +
                            blockchainTxListStringLength) {
                      String blockchainTxListString = message.substring(
                          10 + mempoolTxListStringEnd,
                          10 +
                              mempoolTxListStringEnd +
                              blockchainTxListStringLength);
                      //print("getAddressTxsResponse (blockchain) : " +
                      //    blockchainTxListString);
                      List blockChainTxs =
                          addlistlimResponseFromJson(blockchainTxListString);

                      List txs = new List();
                      txs.addAll(mempoolTxs);
                      txs.addAll(blockChainTxs);

                      EventTaxiImpl.singleton()
                          .fire(TransactionsListEvent(response: txs));
                      for (int i = txs.length - 1; i >= 0; i--) {
                        AddressTxsResponseResult addressTxResponse =
                            new AddressTxsResponseResult();
                        addressTxResponse.populate(txs[i], address);
                        addressTxResponse.getBisToken();
                        addressTxsResponse.result.add(addressTxResponse);
                      }
                    }
                  }
                }
              } else {
                //print("response length ko : " + message.length.toString());
              }
            }
          }, onError: ((error, StackTrace trace) {
            //print("Error");
          }), onDone: () {
            //print("Done");
            _socket.destroy();
          }, cancelOnError: false);
        }

        //Send the request
        String method = '"addlistlim"';
        String param1 = '"' + address + '"';
        String param2 = '"' + limit.toString() + '"';
        String method2 = '"mpgetfor"';
        _socket.write(getLengthBuffer(method2) +
            method2 +
            getLengthBuffer(param1) +
            param1 +
            getLengthBuffer(method) +
            method +
            getLengthBuffer(param1) +
            param1 +
            getLengthBuffer(param2) +
            param2);
      }
    } catch (e) {
      //print("pb socket" + e.toString());
      EventTaxiImpl.singleton().fire(
          ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
    } finally {}
  }

  Future<void> getBalanceGetResponse(String address, bool activeBus) async {
    BalanceGetResponse balanceGetResponse = new BalanceGetResponse();

    try {
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await sl.get<HttpService>().getBestServerWalletLegacyResponse();
      if (serverWalletLegacyResponse.ip == null ||
          serverWalletLegacyResponse.port == null) {
        EventTaxiImpl.singleton().fire(
            ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
      } else {
        IOWebSocketChannel _webSocket;
        Socket _socket;
        if (kIsWeb) {
          _webSocket = IOWebSocketChannel.connect(
              serverWalletLegacyResponse.ip +
                  ':' +
                  serverWalletLegacyResponse.port.toString());
        } else {
          _socket = await Socket.connect(
              serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port,
              timeout: Duration(seconds: 3));
        }

        EventTaxiImpl.singleton().fire(ConnStatusEvent(
            status: ConnectionStatus.CONNECTED,
            server: serverWalletLegacyResponse.ip +
                ":" +
                serverWalletLegacyResponse.port.toString()));

        //Establish the onData, and onDone callbacks
        String message = "";
        if (kIsWeb) {
          _webSocket.stream.listen((data) {
            if (data != null) {
              message += new String.fromCharCodes(data).trim();
              if (message != null &&
                  message.length >= 10 &&
                  int.tryParse(message.substring(0, 10)) != null &&
                  message.length ==
                      10 + int.tryParse(message.substring(0, 10))) {
                message = message.substring(
                    10, 10 + int.tryParse(message.substring(0, 10)));
                balanceGetResponse = balanceGetResponseFromJson(message);
                balanceGetResponse.address = address;
                //print(message);
                if (activeBus) {
                  EventTaxiImpl.singleton()
                      .fire(BalanceGetEvent(response: balanceGetResponse));
                }
              }
            }
          }, onError: ((error, StackTrace trace) {
            //print("Error");
          }), onDone: () {
            //print("Done");
            _socket.destroy();
          }, cancelOnError: false);
        } else {
          _socket.listen((data) {
            if (data != null) {
              message += new String.fromCharCodes(data).trim();
              if (message != null &&
                  message.length >= 10 &&
                  int.tryParse(message.substring(0, 10)) != null &&
                  message.length ==
                      10 + int.tryParse(message.substring(0, 10))) {
                message = message.substring(
                    10, 10 + int.tryParse(message.substring(0, 10)));
                balanceGetResponse = balanceGetResponseFromJson(message);
                balanceGetResponse.address = address;
                //print(message);
                if (activeBus) {
                  EventTaxiImpl.singleton()
                      .fire(BalanceGetEvent(response: balanceGetResponse));
                }
              }
            }
          }, onError: ((error, StackTrace trace) {
            //print("Error");
          }), onDone: () {
            //print("Done");
            _socket.destroy();
          }, cancelOnError: false);
        }

        //Send the request
        String method = '"balancegetjson"';
        String param = '"' + address + '"';

        _socket.write(
            getLengthBuffer(method) + method + getLengthBuffer(param) + param);
      }
    } catch (e) {
      //print("pb socket" + e.toString());
      EventTaxiImpl.singleton().fire(
          ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
    } finally {}
  }

  Future<void> sendTx(
      String address,
      String amount,
      String destination,
      String openfield,
      String operation,
      String publicKey,
      String privateKey) async {
    SendTxRequest sendTxRequest = new SendTxRequest();
    Tx tx = new Tx();
    //print("address : " + address);
    //print("amount : " + amount);
    //print("destination : " + destination);
    //print("publicKey : " + publicKey);
    //print("privateKey : " + privateKey);

    try {
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await sl.get<HttpService>().getBestServerWalletLegacyResponse();

      if (serverWalletLegacyResponse.ip == null ||
          serverWalletLegacyResponse.port == null) {
        EventTaxiImpl.singleton().fire(
            ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
      } else {
        Socket _socket = await Socket.connect(
            serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port,
            timeout: Duration(seconds: 3));

        EventTaxiImpl.singleton().fire(ConnStatusEvent(
            status: ConnectionStatus.CONNECTED,
            server: serverWalletLegacyResponse.ip +
                ":" +
                serverWalletLegacyResponse.port.toString()));

        //print('Connected to: '
        //    '${_socket.remoteAddress.address}:${_socket.remotePort}');
        //Establish the onData, and onDone callbacks
        _socket.listen((data) {
          if (data != null) {
            String message = new String.fromCharCodes(data).trim();
            if (message != null &&
                message.length >= 10 &&
                int.tryParse(message.substring(0, 10)) != null &&
                message.length == 10 + int.tryParse(message.substring(0, 10))) {
              message = message.substring(
                  10, 10 + int.tryParse(message.substring(0, 10)));
              //print("Response sendTx : " + message);
              List<String> sendTxResponse = mpinsertResponseFromJson(message);
              if (sendTxResponse.length < 4 ||
                  sendTxResponse[3].contains("Success") == false) {
                EventTaxiImpl.singleton()
                    .fire(TransactionSendEvent(response: sendTxResponse[1]));
              } else {
                EventTaxiImpl.singleton()
                    .fire(TransactionSendEvent(response: "Success"));
              }
            }
          }
        }, onError: ((error, StackTrace trace) {
          //print("Error");
        }), onDone: () {
          //print("Done");
          _socket.destroy();
        }, cancelOnError: false);

        //Send the request
        // Substract 3 sec to limit the issue with future tx
        DateTime timeBefore4sec =
            DateTime.now().subtract(new Duration(seconds: 4));
        tx.timestamp = timeBefore4sec
                .toUtc()
                .microsecondsSinceEpoch
                .toString()
                .substring(0, 10) +
            "." +
            timeBefore4sec
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
        String message =
            getLengthBuffer(method) + method + getLengthBuffer(param) + param;
        //print("message: " + message);
        _socket.write(message);
      }
    } catch (e) {
      //print("pb socket" + e.toString());
      EventTaxiImpl.singleton().fire(
          ConnStatusEvent(status: ConnectionStatus.DISCONNECTED, server: ""));
    } finally {}
  }
}
