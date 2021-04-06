// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:my_bismuth_wallet/network/model/response/dragginator_infos_from_dna_response.dart';
import 'package:my_bismuth_wallet/network/model/response/dragginator_list_from_address_response.dart';
import 'package:my_bismuth_wallet/service_locator.dart';

class DragginatorService {
  final Logger log = sl.get<Logger>();

  Future<List> getEggsAndDragonsListFromAddress(String address) async {
    List<DragginatorListFromAddressResponse> dragginatorListFromAddressResponseList;

    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(
          Uri.parse("https://dragginator.com/api/info.php?address="+address+"&type=list"));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        dragginatorListFromAddressResponseList =
            dragginatorListFromAddressResponseFromJson(reply);

      }
    } catch (e) {
      print(e);
    } finally {
      httpClient.close();
    }
 
    return dragginatorListFromAddressResponseList;
  }

Future<DragginatorInfosFromDnaResponse> getInfosFromDna(String dna) async {
    DragginatorInfosFromDnaResponse dragginatorInfosFromDnaResponse;

    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(
          Uri.parse("https://dragginator.com/api/info.php?egg="+dna+"&type=egg_info"));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        dragginatorInfosFromDnaResponse =
            dragginatorInfosFromDnaResponseFromJson(reply);

      }
    } catch (e) {
      print(e);
    } finally {
      httpClient.close();
    }
 
    return dragginatorInfosFromDnaResponse;
  }
}
