// @dart=2.9

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:event_taxi/event_taxi.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Project imports:
import 'package:my_bismuth_wallet/bus/events.dart';
import 'package:my_bismuth_wallet/model/token_ref.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/network/model/response/servers_wallet_legacy.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response.dart';
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
import 'package:my_bismuth_wallet/service_locator.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';

class HttpService {
  final Logger log = sl.get<Logger>();

  Future<ServerWalletLegacyResponse> getBestServerWalletLegacyResponse() async {
    List<ServerWalletLegacyResponse> serverWalletLegacyResponseList =
        new List<ServerWalletLegacyResponse>();
    ServerWalletLegacyResponse serverWalletLegacyResponse =
        new ServerWalletLegacyResponse();

    String walletServer = await sl.get<SharedPrefsUtil>().getWalletServer();
    if (walletServer != "auto") {
      if (walletServer.split(":").length > 1) {
        serverWalletLegacyResponse.ip = walletServer.split(":")[0];
        serverWalletLegacyResponse.port =
            int.tryParse(walletServer.split(":")[1]);
      }

      return serverWalletLegacyResponse;
    }

    try {
      final http.Response response = await http.get(
          Uri.parse("https://api.bismuth.live/servers/wallet/legacy.json"),
          headers: {
            'content-type': 'application/json',
            'access-Control-Allow-Origin': '*'
          });

      if (response.statusCode == 200) {
        String reply = response.body;
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
    } catch (e) {
      print(e);
    }
    //print("Server Wallet : " +
    //    serverWalletLegacyResponse.ip +
    //    ":" +
    //    serverWalletLegacyResponse.port.toString());
    return serverWalletLegacyResponse;
  }

  Future<SimplePriceResponse> getSimplePrice(String currency) async {
    //print("getSimplePrice");
    SimplePriceResponse simplePriceResponse = new SimplePriceResponse();
    simplePriceResponse.currency = currency;

    try {
      http.Response response = await http.get(
          Uri.parse(
              "https://api.coingecko.com/api/v3/simple/price?ids=bismuth&vs_currencies=BTC"),
          headers: {
            'content-type': 'application/json',
            'access-Control-Allow-Origin': '*'
          });

      if (response.statusCode == 200) {
        String reply = response.body;
        SimplePriceBtcResponse simplePriceBtcResponse =
            simplePriceBtcResponseFromJson(reply);
        simplePriceResponse.btcPrice = simplePriceBtcResponse.bismuth.btc;
      }

      response = await http.get(
          Uri.parse(
              "https://api.coingecko.com/api/v3/simple/price?ids=bismuth&vs_currencies=" +
                  currency),
          headers: {
            'content-type': 'application/json',
            'access-Control-Allow-Origin': '*'
          });

      if (response.statusCode == 200) {
        String reply = response.body;
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
    } catch (e) {}
    return simplePriceResponse;
  }

  Future<bool> isTokensBalance(String address) async {
    try {
      String tokensApi = await sl.get<SharedPrefsUtil>().getTokensApi();
      Uri uri;
      try {
        uri = Uri.parse(tokensApi + address);
      } catch (FormatException) {
        return false;
      }

      http.Response response = await http.get(uri, headers: {
        'content-type': 'application/json',
        'access-Control-Allow-Origin': '*'
      });

      if (response.statusCode == 200) {
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

    try {
      String tokensApi = await sl.get<SharedPrefsUtil>().getTokensApi();

      final http.Response response =
          await http.get(Uri.parse(tokensApi + address), headers: {
        'content-type': 'application/json',
        'access-Control-Allow-Origin': '*'
      });

      if (response.statusCode == 200) {
        String reply = response.body;
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

    try {
      final http.Response response = await http
          .get(Uri.parse("https://bismuth.today/api/tokens/"), headers: {
        'content-type': 'application/json',
        'access-Control-Allow-Origin': '*'
      });

      if (response.statusCode == 200) {
        String reply = response.body;
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

  Future<int> getEggPrice() async {
    int price = 0;
    try {
      final http.Response response = await http.get(
          Uri.parse("https://dragginator.com/api/info.php?type=price"),
          headers: {
            'content-type': 'application/json',
            'access-Control-Allow-Origin': '*'
          });

      if (response.statusCode == 200) {
        String reply = response.body;
        price = int.tryParse(
            reply.replaceAll('[', '').replaceAll(']', '').split(',')[0]);
      }
    } catch (e) {}
    return price;
  }
}
