// @dart=2.9

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/network/model/response/dragginator_infos_from_dna_response.dart';
import 'package:my_bismuth_wallet/network/model/response/dragginator_list_from_address_response.dart';
import 'package:my_bismuth_wallet/network/model/response/dragginator_merge_list_compatible_response.dart';
import 'package:my_bismuth_wallet/network/model/response/dragginator_merge_list_reasons_not_compatible_response.dart';
import 'package:my_bismuth_wallet/service_locator.dart';

class DragginatorService {
  final Logger log = sl.get<Logger>();

  Future<List> getEggsAndDragonsListFromAddress(String address) async {
    List<DragginatorListFromAddressResponse>
        dragginatorListFromAddressResponseList;

    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(
          "https://dragginator.com/api/info.php?address=" +
              address +
              "&type=list"));
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
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(
          "https://dragginator.com/api/info.php?egg=" +
              dna +
              "&type=egg_info"));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        dragginatorInfosFromDnaResponse =
            dragginatorInfosFromDnaResponseFromJson(reply);
      }
    } catch (e) {
    } finally {
      httpClient.close();
    }

    return dragginatorInfosFromDnaResponse;
  }

  Future<List<String>> getEggsCompatible(String dna) async {
    List<String>
        dragginatorMergeListCompatible;

    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient
          .getUrl(Uri.parse("https://dragginator.com/api/merge/" + dna + "/"));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        dragginatorMergeListCompatible =
            dragginatorMergeListCompatibleResponseFromJson(reply);
      }
    } catch (e) {
      print(e);
    } finally {
      httpClient.close();
    }

    return dragginatorMergeListCompatible;
  }

  Future<List<String>> getMergeListReasonsNotCompatible(String dna1, String dna2) async {
    List<String>
        dragginatorMergeListReasonsNotCompatible;

    HttpClient httpClient = new HttpClient();
    try {
      HttpClientRequest request = await httpClient
          .getUrl(Uri.parse("https://dragginator.com/api/merge/"+dna1+"/"+dna2+"/"));
      request.headers.set('content-type', 'application/json');
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String reply = await response.transform(utf8.decoder).join();
        dragginatorMergeListReasonsNotCompatible =
            dragginatorMergeListReasonsNotCompatibleResponseFromJson(reply);
      }
    } catch (e) {
      print(e);
    } finally {
      httpClient.close();
    }

    return dragginatorMergeListReasonsNotCompatible;
  }

  bool isEggOwner(List<BisToken> tokens) {
    if (tokens == null) {
      return false;
    } else {
      for (int i = 0; i < tokens.length; i++) {
        if (tokens[i].tokenName == "egg" && tokens[i].tokensQuantity > 0) {
          return true;
        }
      }
      return false;
    }
  }
}
