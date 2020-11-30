import 'dart:convert';
import 'dart:io';
import 'package:event_taxi/event_taxi.dart';
import 'package:logger/logger.dart';
import 'package:my_bismuth_wallet/bus/events.dart';
import 'package:my_bismuth_wallet/bus/subscribe_event.dart';
import 'package:my_bismuth_wallet/network/model/response/address_response.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_btc.dart';
import 'package:my_bismuth_wallet/network/model/response/simple_price_response_usd.dart';


class AppService {
  var logger = Logger();

  Future<AddressResponse> getAddressResponse(String address) async {
    AddressResponse addressResponse = new AddressResponse();
    addressResponse.result = new Result();
    addressResponse.result.address = address;
    addressResponse.result.balance = "0";
    addressResponse.result.stake = "0";

    /*HttpClient httpClient = new HttpClient();
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
    }*/
    EventTaxiImpl.singleton().fire(SubscribeEvent(response: addressResponse));
    return addressResponse;
  }

  Future<AddressTxsResponse> getAddressTxsResponse(
      String address, int limit) async {
    AddressTxsResponse addressTxsResponse = new AddressTxsResponse();
    addressTxsResponse.result = new List<AddressTxsResponseResult>();
    /*HttpClient httpClient = new HttpClient();
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
        addressTxsResponse = addressTxsResponseFromJson(reply);
      }
    } catch (e) {
    } finally {
      httpClient.close();
    }*/

    return addressTxsResponse;
  }

  Future<SimplePriceResponse> getSimplePrice(String currency) async {
    SimplePriceResponse simplePriceResponse = new SimplePriceResponse();
    simplePriceResponse.currency = currency;

    /*HttpClient httpClient = new HttpClient();
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
          case "USD":
          default:
             SimplePriceUsdResponse simplePriceLocalResponse =
                simplePriceUsdResponseFromJson(reply);
            simplePriceResponse.localCurrencyPrice =
                simplePriceLocalResponse.idena.usd;
            break;

        }
      }
      // Post to callbacks
      EventTaxiImpl.singleton().fire(PriceEvent(response: simplePriceResponse));
    } catch (e) {} finally {
      httpClient.close();
    }*/
    simplePriceResponse.localCurrencyPrice = 0;
    simplePriceResponse.btcPrice = 0;
    EventTaxiImpl.singleton().fire(PriceEvent(response: simplePriceResponse));
    return simplePriceResponse;
  }
}
