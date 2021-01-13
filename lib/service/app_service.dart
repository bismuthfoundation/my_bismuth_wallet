import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:event_taxi/event_taxi.dart';
import 'package:logger/logger.dart';
import 'package:my_bismuth_wallet/bus/events.dart';
import 'package:my_bismuth_wallet/bus/subscribe_event.dart';
import 'package:my_bismuth_wallet/model/token_ref.dart';
import 'package:my_bismuth_wallet/network/model/request/send_tx_request.dart';
import 'package:my_bismuth_wallet/network/model/response/addlistlim_response.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/network/model/response/balance_get_response.dart';
import 'package:my_bismuth_wallet/network/model/response/mpinsert_response.dart';
import 'package:my_bismuth_wallet/network/model/response/servers_wallet_legacy.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response.dart';
import 'package:diacritic/diacritic.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_aed.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_ars.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_aud.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_brl.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_btc.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_cad.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_chf.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_clp.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_cny.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_czk.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_dkk.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_eur.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_gbp.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_hkd.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_huf.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_idr.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_ils.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_inr.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_jpy.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_krw.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_kwd.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_mxn.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_myr.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_nok.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_nzd.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_php.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_pkr.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_pln.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_rub.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_sar.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_sek.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_sgd.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_thb.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_try.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_twd.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_usd.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_zar.dart';
import 'package:my_bismuth_wallet/network/model/response/tokens_balance_get_response.dart';
import 'package:my_bismuth_wallet/network/model/response/tokens_list_get_response.dart';
import 'package:my_bismuth_wallet/network/model/response/wstatusget_response.dart';
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';

class AppService {
  var logger = Logger();

  String getLengthBuffer(String message) {
    return message == null ? null : message.length.toString().padLeft(10, '0');
  }

  Future<ServerWalletLegacyResponse> getBestServerWalletLegacyResponse() async {
    List<ServerWalletLegacyResponse> serverWalletLegacyResponseList =
        new List<ServerWalletLegacyResponse>();
    ServerWalletLegacyResponse serverWalletLegacyResponse =
        new ServerWalletLegacyResponse();

    String walletServer = await sl.get<SharedPrefsUtil>().getWalletServer();
    if (walletServer != "auto") {
      serverWalletLegacyResponse.ip = walletServer.split(":")[0];
      serverWalletLegacyResponse.port =
          int.tryParse(walletServer.split(":")[1]);
      return serverWalletLegacyResponse;
    }

    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(
          Uri.parse("http://api.bismuth.live/servers/wallet/legacy.json"));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        //print("serverWalletLegacyResponseList=" + reply);
        serverWalletLegacyResponseList =
            serverWalletLegacyResponseFromJson(reply);

        // Best server active with less clients
        serverWalletLegacyResponseList
            .removeWhere((element) => element.active == false);
        serverWalletLegacyResponseList.sort((a, b) {
          return a.clients
              .toString()
              .toLowerCase()
              .compareTo(b.clients.toString().toLowerCase());
        });
        if (serverWalletLegacyResponseList.length > 0) {
          serverWalletLegacyResponse = serverWalletLegacyResponseList[0];
        }
      }
    } catch (e) {} finally {
      httpClient.close();
    }
    //print("Server Wallet : " +
    //    serverWalletLegacyResponse.ip +
    //    ":" +
    //    serverWalletLegacyResponse.port.toString());
    return serverWalletLegacyResponse;
  }

  Future<BalanceGetResponse> getBalanceGetResponse(
      String address, bool activeBus) async {
    BalanceGetResponse balanceGetResponse = new BalanceGetResponse();
    Completer<BalanceGetResponse> _completer =
        new Completer<BalanceGetResponse>();
    try {
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await getBestServerWalletLegacyResponse();
      //print("serverWalletLegacyResponse.ip : " + serverWalletLegacyResponse.ip);
      //print("serverWalletLegacyResponse.port : " +
      //    serverWalletLegacyResponse.port.toString());

      Socket _socket = await Socket.connect(
          serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port);

      //print('Connected to: '
      //   '${_socket.remoteAddress.address}:${_socket.remotePort}');
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
            balanceGetResponse = balanceGetResponseFromJson(message);
            balanceGetResponse.address = address;
            //print(message);
            if (activeBus) {
              EventTaxiImpl.singleton()
                  .fire(SubscribeEvent(response: balanceGetResponse));
            }

            _completer.complete(balanceGetResponse);
          }
        }
      }, onError: ((error, StackTrace trace) {
        //print("Error");
        _completer.complete(balanceGetResponse);
      }), onDone: () {
        //print("Done");
        _socket.destroy();
      }, cancelOnError: false);

      //Send the request
      String method = '"balancegetjson"';
      String param = '"' + address + '"';

      _socket.write(
          getLengthBuffer(method) + method + getLengthBuffer(param) + param);
    } catch (e) {
      //print("pb socket" + e.toString());
    } finally {}
    return _completer.future;
  }

  Future<AddressTxsResponse> getAddressTxsResponse(
      String address, int limit) async {
    AddressTxsResponse addressTxsResponse = new AddressTxsResponse();

    addressTxsResponse.tokens = await getTokensBalance(address);

    addressTxsResponse.result = new List<AddressTxsResponseResult>();
    Completer<AddressTxsResponse> _completer =
        new Completer<AddressTxsResponse>();
    try {
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await getBestServerWalletLegacyResponse();
      //print("serverWalletLegacyResponse.ip : " + serverWalletLegacyResponse.ip);
      //print("serverWalletLegacyResponse.port : " +
      //    serverWalletLegacyResponse.port.toString());

      Socket _socket = await Socket.connect(
          serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port);

      //print('Connected to: '
      //   '${_socket.remoteAddress.address}:${_socket.remotePort}');
      //Establish the onData, and onDone callbacks
      String message = "";
      _socket.listen((data) {
        if (data != null) {
          message += new String.fromCharCodes(data).trim();
          //print("response : " + message);
          //print("response length : " + message.length.toString());
          if (message != null &&
              message.length >= 10 &&
              int.tryParse(message.substring(0, 10)) != null &&
              message.length == 10 + int.tryParse(message.substring(0, 10))) {
            message = message.substring(
                10, 10 + int.tryParse(message.substring(0, 10)));
            //print("getAddressTxsResponse : " + message);
            List txs = addlistlimResponseFromJson(message);
            for (int i = txs.length - 1; i >= 0; i--) {
              AddressTxsResponseResult addressTxResponse =
                  new AddressTxsResponseResult();
              addressTxResponse.populate(txs[i], address);
              addressTxResponse.getBisToken();
              addressTxsResponse.result.add(addressTxResponse);
            }
            _completer.complete(addressTxsResponse);
          } else {
            //print("response length ko : " + message.length.toString());
            //_completer.complete(addressTxsResponse);
          }
        }
      }, onError: ((error, StackTrace trace) {
        //print("Error");
        _completer.complete(addressTxsResponse);
      }), onDone: () {
        //print("Done");
        _socket.destroy();
      }, cancelOnError: false);

      //Send the request
      String method = '"addlistlim"';
      String param1 = '"' + address + '"';
      String param2 = '"' + limit.toString() + '"';
      _socket.write(getLengthBuffer(method) +
          method +
          getLengthBuffer(param1) +
          param1 +
          getLengthBuffer(param2) +
          param2);
    } catch (e) {
      //print("pb socket" + e.toString());
    } finally {}
    return _completer.future;
  }

  Future<SimplePriceResponse> getSimplePrice(String currency) async {
    SimplePriceResponse simplePriceResponse = new SimplePriceResponse();
    simplePriceResponse.currency = currency;

    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(
          "https://api.coingecko.com/api/v3/simple/price?ids=bismuth&vs_currencies=BTC"));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        SimplePriceBtcResponse simplePriceBtcResponse =
            simplePriceBtcResponseFromJson(reply);
        simplePriceResponse.btcPrice = simplePriceBtcResponse.bismuth.btc;
      }

      request = await httpClient.getUrl(Uri.parse(
          "https://api.coingecko.com/api/v3/simple/price?ids=bismuth&vs_currencies=" +
              currency));
      request.headers.set('content-type', 'application/json');
      response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        switch (currency.toUpperCase()) {
          case "ARS":
            SimplePriceArsResponse simplePriceLocalResponse =
                simplePriceArsResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.ars;
            break;
          case "AUD":
            SimplePriceAudResponse simplePriceLocalResponse =
                simplePriceAudResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.aud;
            break;
          case "BRL":
            SimplePriceBrlResponse simplePriceLocalResponse =
                simplePriceBrlResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.brl;
            break;
          case "CAD":
            SimplePriceCadResponse simplePriceLocalResponse =
                simplePriceCadResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.cad;
            break;
          case "CHF":
            SimplePriceChfResponse simplePriceLocalResponse =
                simplePriceChfResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.chf;
            break;
          case "CLP":
            SimplePriceClpResponse simplePriceLocalResponse =
                simplePriceClpResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.clp;
            break;
          case "CNY":
            SimplePriceCnyResponse simplePriceLocalResponse =
                simplePriceCnyResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.cny;
            break;
          case "CZK":
            SimplePriceCzkResponse simplePriceLocalResponse =
                simplePriceCzkResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.czk;
            break;
          case "DKK":
            SimplePriceDkkResponse simplePriceLocalResponse =
                simplePriceDkkResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.dkk;
            break;
          case "EUR":
            SimplePriceEurResponse simplePriceLocalResponse =
                simplePriceEurResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.eur;
            break;
          case "GBP":
            SimplePriceGbpResponse simplePriceLocalResponse =
                simplePriceGbpResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.gbp;
            break;
          case "HKD":
            SimplePriceHkdResponse simplePriceLocalResponse =
                simplePriceHkdResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.hkd;
            break;
          case "HUF":
            SimplePriceHufResponse simplePriceLocalResponse =
                simplePriceHufResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.huf;
            break;
          case "IDR":
            SimplePriceIdrResponse simplePriceLocalResponse =
                simplePriceIdrResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.idr;
            break;
          case "ILS":
            SimplePriceIlsResponse simplePriceLocalResponse =
                simplePriceIlsResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.ils;
            break;
          case "INR":
            SimplePriceInrResponse simplePriceLocalResponse =
                simplePriceInrResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.inr;
            break;
          case "JPY":
            SimplePriceJpyResponse simplePriceLocalResponse =
                simplePriceJpyResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.jpy;
            break;
          case "KRW":
            SimplePriceKrwResponse simplePriceLocalResponse =
                simplePriceKrwResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.krw;
            break;
          case "KWD":
            SimplePriceKwdResponse simplePriceLocalResponse =
                simplePriceKwdResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.kwd;
            break;
          case "MXN":
            SimplePriceMxnResponse simplePriceLocalResponse =
                simplePriceMxnResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.mxn;
            break;
          case "MYR":
            SimplePriceMyrResponse simplePriceLocalResponse =
                simplePriceMyrResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.myr;
            break;
          case "NOK":
            SimplePriceNokResponse simplePriceLocalResponse =
                simplePriceNokResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.nok;
            break;
          case "NZD":
            SimplePriceNzdResponse simplePriceLocalResponse =
                simplePriceNzdResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.nzd;
            break;
          case "PHP":
            SimplePricePhpResponse simplePriceLocalResponse =
                simplePricePhpResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.php;
            break;
          case "PKR":
            SimplePricePkrResponse simplePriceLocalResponse =
                simplePricePkrResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.pkr;
            break;
          case "PLN":
            SimplePricePlnResponse simplePriceLocalResponse =
                simplePricePlnResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.pln;
            break;
          case "RUB":
            SimplePriceRubResponse simplePriceLocalResponse =
                simplePriceRubResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.rub;
            break;
          case "SAR":
            SimplePriceSarResponse simplePriceLocalResponse =
                simplePriceSarResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.sar;
            break;
          case "SEK":
            SimplePriceSekResponse simplePriceLocalResponse =
                simplePriceSekResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.sek;
            break;
          case "SGD":
            SimplePriceSgdResponse simplePriceLocalResponse =
                simplePriceSgdResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.sgd;
            break;
          case "THB":
            SimplePriceThbResponse simplePriceLocalResponse =
                simplePriceThbResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.thb;
            break;
          case "TRY":
            SimplePriceTryResponse simplePriceLocalResponse =
                simplePriceTryResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.tryl;
            break;
          case "TWD":
            SimplePriceTwdResponse simplePriceLocalResponse =
                simplePriceTwdResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.twd;
            break;
          case "AED":
            SimplePriceAedResponse simplePriceLocalResponse =
                simplePriceAedResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.aed;
            break;
          case "ZAR":
            SimplePriceZarResponse simplePriceLocalResponse =
                simplePriceZarResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.zar;
            break;
          case "USD":
          default:
            SimplePriceUsdResponse simplePriceLocalResponse =
                simplePriceUsdResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.bismuth.usd;
            break;
        }
      }
      // Post to callbacks
      EventTaxiImpl.singleton().fire(PriceEvent(response: simplePriceResponse));
    } catch (e) {} finally {
      httpClient.close();
    }
    return simplePriceResponse;
  }

  Future<String> sendTx(
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

    Completer<String> _completer = new Completer<String>();
    try {
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await getBestServerWalletLegacyResponse();
      //print("serverWalletLegacyResponse.ip : " + serverWalletLegacyResponse.ip);
      //print("serverWalletLegacyResponse.port : " +
      //    serverWalletLegacyResponse.port.toString());

      Socket _socket = await Socket.connect(
          serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port);

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
              _completer.complete(sendTxResponse[1]);
            } else {
              _completer.complete("Success");
            }
          }
        }
      }, onError: ((error, StackTrace trace) {
        //print("Error");
        _completer.complete("Error");
      }), onDone: () {
        //print("Done");
        _socket.destroy();
      }, cancelOnError: false);

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
      String message =
          getLengthBuffer(method) + method + getLengthBuffer(param) + param;
      //print("message: " + message);
      _socket.write(message);
    } catch (e) {
      //print("pb socket" + e.toString());
    } finally {}
    return _completer.future;
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

  Future<WStatusGetResponse> getWStatusGetResponse() async {
    WStatusGetResponse wStatusGetResponse = new WStatusGetResponse();
    Completer<WStatusGetResponse> _completer =
        new Completer<WStatusGetResponse>();
    try {
      ServerWalletLegacyResponse serverWalletLegacyResponse =
          await getBestServerWalletLegacyResponse();
      //print("serverWalletLegacyResponse.ip : " + serverWalletLegacyResponse.ip);
      //print("serverWalletLegacyResponse.port : " +
      //    serverWalletLegacyResponse.port.toString());

      Socket _socket = await Socket.connect(
              serverWalletLegacyResponse.ip, serverWalletLegacyResponse.port)
          .timeout(const Duration(seconds: 3));

      //print('Connected to: '
      //   '${_socket.remoteAddress.address}:${_socket.remotePort}');
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
            wStatusGetResponse = wStatusGetResponseFromJson(message);
            //print(message);
            _completer.complete(wStatusGetResponse);
          }
        }
      }, onError: ((error, StackTrace trace) {
        //print("Error");
        _completer.complete(wStatusGetResponse);
      }), onDone: () {
        //print("Done");
        _socket.destroy();
      }, cancelOnError: false);

      //Send the request
      String method = '"wstatusget"';

      _socket.write(getLengthBuffer(method) + method);
    } catch (e) {
      //print("pb socket" + e.toString());
      _completer.complete(null);
    } finally {}
    return _completer.future;
  }

  Future<bool> isTokensBalance(String address) async {
    HttpClient httpClient = new HttpClient();
    try {
      String tokensApi = await sl.get<SharedPrefsUtil>().getTokensApi();
      Uri uri;
      try {
        uri = Uri.parse(tokensApi + address);
      } catch (FormatException) {
        return false;
      }

      HttpClientRequest request = await httpClient.getUrl(uri);
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        var tokensBalanceGetResponse = tokensBalanceGetResponseFromJson(reply);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<List<BisToken>> getTokensBalance(String address) async {
    List<BisToken> bisTokenList = new List<BisToken>();

    HttpClient httpClient = new HttpClient();
    try {
      String tokensApi = await sl.get<SharedPrefsUtil>().getTokensApi();
      HttpClientRequest request =
          await httpClient.getUrl(Uri.parse(tokensApi + address));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        var tokensBalanceGetResponse = tokensBalanceGetResponseFromJson(reply);

        for (int i = 0; i < tokensBalanceGetResponse.length; i++) {
          BisToken bisToken = new BisToken(
              tokenName: tokensBalanceGetResponse[i][0],
              tokensQuantity: tokensBalanceGetResponse[i][1]);
          bisTokenList.add(bisToken);
        }
      }
    } catch (e) {}
    return bisTokenList;
  }

  Future<List<TokenRef>> getTokensReflist() async {
    List<TokenRef> tokensRefList = new List<TokenRef>();

    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient
          .getUrl(Uri.parse("https://bismuth.today/api/tokens/"));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        var tokensRefListGetResponse = tokensListGetResponseFromJson(reply);

        for (int i = 0; i < tokensRefListGetResponse.length; i++) {
          TokenRef tokenRef = new TokenRef();
          tokenRef.token = tokensRefListGetResponse.keys.elementAt(i);
          tokenRef.creator = tokensRefListGetResponse.values.elementAt(i)[0];
          tokenRef.totalSupply =
              tokensRefListGetResponse.values.elementAt(i)[1];
          tokenRef.creationDate = DateTime.fromMillisecondsSinceEpoch(
              (tokensRefListGetResponse.values.elementAt(i)[2] * 1000).toInt());
          tokensRefList.add(tokenRef);
        }
      }
    } catch (e) {}
    return tokensRefList;
  }
}
