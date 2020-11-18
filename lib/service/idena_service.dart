import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:my_idena_wallet/network/model/response/address_response.dart';
import 'package:my_idena_wallet/network/model/response/address_txs_response.dart';

class IdenaService {
  var logger = Logger();

  Future<AddressResponse> getAddressResponse(String address) async {
    AddressResponse addressResponse;
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
    } catch (e) {
    } finally {
      httpClient.close();
    }
    return addressResponse;
  }

  Future<AddressTxsResponse> getAddressTxsResponse(String address, int limit) async {
    AddressTxsResponse addressTxsResponse;
    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient
          .getUrl(Uri.parse("https://api.idena.io/api/Address/" + address + "/Txs?limit=" + limit.toString()));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        addressTxsResponse = addressTxsResponseFromJson(reply);
      }
    } catch (e) {
    } finally {
      httpClient.close();
    }
    return addressTxsResponse;
  }
}
