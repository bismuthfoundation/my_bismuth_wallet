import 'dart:convert';
import 'dart:io';
import 'package:event_taxi/event_taxi.dart';
import 'package:logger/logger.dart';
import 'package:my_idena_wallet/bus/events.dart';
import 'package:my_idena_wallet/bus/subscribe_event.dart';
import 'package:my_idena_wallet/model/available_currency.dart';
import 'package:my_idena_wallet/network/model/response/address_response.dart';
import 'package:my_idena_wallet/network/model/response/address_txs_response.dart';
import 'package:my_idena_wallet/network/model/response/simple_price_response.dart';
import 'package:my_idena_wallet/network/model/response/simple_price_response_ars.dart';
import 'package:my_idena_wallet/network/model/response/simple_price_response_btc.dart';
import 'package:my_idena_wallet/network/model/response/simple_price_response_eur.dart';

class IdenaService {
  var logger = Logger();

  Future<AddressResponse> getAddressResponse(String address) async {
    AddressResponse addressResponse = new AddressResponse();
    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient
          .getUrl(Uri.parse("https://api.idena.io/api/Address/" + address));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        addressResponse = addressResponseFromJson(reply);
      }
      // Post to callbacks
      EventTaxiImpl.singleton().fire(SubscribeEvent(response: addressResponse));
    } catch (e) {} finally {
      httpClient.close();
    }
    return addressResponse;
  }

  Future<AddressTxsResponse> getAddressTxsResponse(
      String address, int limit) async {
    AddressTxsResponse addressTxsResponse;
    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(
          "https://api.idena.io/api/Address/" +
              address +
              "/Txs?limit=" +
              limit.toString()));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        print(reply);
        addressTxsResponse = addressTxsResponseFromJson(reply);
      }
    } catch (e) {
      print(e);
    } finally {
      httpClient.close();
    }
    return addressTxsResponse;
  }

  Future<SimplePriceResponse> getSimplePrice(String currency) async {
    SimplePriceResponse simplePriceResponse = new SimplePriceResponse();
    simplePriceResponse.currency = currency;

    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(
          "https://api.coingecko.com/api/v3/simple/price?ids=idena&vs_currencies=BTC"));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        SimplePriceBtcResponse simplePriceBtcResponse =
            simplePriceBtcResponseFromJson(reply);
        simplePriceResponse.btcPrice = simplePriceBtcResponse.idena.btc;
      }

      request = await httpClient.getUrl(Uri.parse(
          "https://api.coingecko.com/api/v3/simple/price?ids=idena&vs_currencies=" +
              currency));
      request.headers.set('content-type', 'application/json');
      response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        switch (currency.toUpperCase()) {
          case "EUR":
            SimplePriceEurResponse simplePriceLocalResponse =
                simplePriceEurResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.idena.eur;
            break;
          case "ARS":
            SimplePriceArsResponse simplePriceLocalResponse =
                simplePriceArsResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.idena.ars;
            break;
          // TODO: compléter
          default:
            simplePriceResponse.localCurrencyPrice = 0;
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
}
