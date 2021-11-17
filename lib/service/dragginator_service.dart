// @dart=2.9

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

// Project imports:
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

    try {
      final http.Response response = await http.get(
          Uri.parse("https://dragginator.com/api/info.php?address=" +
              address +
              "&type=list"),
          headers: {
            'content-type': 'application/json',
            'access-Control-Allow-Origin': '*'
          });

      if (response.statusCode == 200) {
        String reply = response.body;
        dragginatorListFromAddressResponseList =
            dragginatorListFromAddressResponseFromJson(reply);
      }
    } catch (e) {
      print(e);
    }

    return dragginatorListFromAddressResponseList;
  }

  Future<DragginatorInfosFromDnaResponse> getInfosFromDna(String dna) async {
    DragginatorInfosFromDnaResponse dragginatorInfosFromDnaResponse;

    try {
      final http.Response response = await http.get(
          Uri.parse("https://dragginator.com/api/info.php?egg=" +
              dna +
              "&type=egg_info"),
          headers: {
            'content-type': 'application/json',
            'access-Control-Allow-Origin': '*'
          });
      if (response.statusCode == 200) {
        String reply = response.body;
        dragginatorInfosFromDnaResponse =
            dragginatorInfosFromDnaResponseFromJson(reply);
      }
    } catch (e) {}

    return dragginatorInfosFromDnaResponse;
  }

  Future<List<String>> getEggsCompatible(String dna) async {
    List<String> dragginatorMergeListCompatible;

    try {
      final http.Response response = await http.get(
          Uri.parse("https://dragginator.com/api/merge/" + dna + "/"),
          headers: {
            'content-type': 'application/json',
            'access-Control-Allow-Origin': '*'
          });

      if (response.statusCode == 200) {
        String reply = response.body;
        dragginatorMergeListCompatible =
            dragginatorMergeListCompatibleResponseFromJson(reply);
      }
    } catch (e) {
      print(e);
    }

    return dragginatorMergeListCompatible;
  }

  Future<List<String>> getMergeListReasonsNotCompatible(
      String dna1, String dna2) async {
    List<String> dragginatorMergeListReasonsNotCompatible;

    try {
      final http.Response response = await http.get(
          Uri.parse(
              "https://dragginator.com/api/merge/" + dna1 + "/" + dna2 + "/"),
          headers: {
            'content-type': 'application/json',
            'access-Control-Allow-Origin': '*'
          });

      if (response.statusCode == 200) {
        String reply = response.body;
        dragginatorMergeListReasonsNotCompatible =
            dragginatorMergeListReasonsNotCompatibleResponseFromJson(reply);
      }
    } catch (e) {
      print(e);
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
