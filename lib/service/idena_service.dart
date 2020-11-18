import 'dart:convert';
import 'dart:io';
import 'package:event_taxi/event_taxi.dart';
import 'package:logger/logger.dart';
import 'package:my_idena_wallet/bus/events.dart';
import 'package:my_idena_wallet/bus/subscribe_event.dart';
import 'package:my_idena_wallet/network/model/response/address_response.dart';
import 'package:my_idena_wallet/network/model/response/address_txs_response.dart';

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
      EventTaxiImpl.singleton().fire(PriceEvent(response: addressResponse));
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
}
