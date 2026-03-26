import 'dart:convert';
import 'dart:typed_data';

import 'package:my_bismuth_wallet/model/address.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';

class BisUrl {
  String? contactName;
  String? address;
  String? amount;
  String? operation;
  String? openfield;
  String? comment;
  bool? isTokenToSend;
  int? tokenToSendQty;
  String? tokenName;

  BisUrl({
    this.contactName,
    this.address,
    this.amount,
    this.operation,
    this.openfield,
    this.comment,
    this.isTokenToSend,
    this.tokenName,
    this.tokenToSendQty,
  });

  Future<BisUrl> getInfo(String link) async {
    final BisUrl bisUrl = BisUrl();
    bool legacyFormat = true;

    if (link.contains('bis://pay/')) {
      link = link.replaceAll('bis://pay/', '');
    } else {
      legacyFormat = false;
      link = link.replaceAll('bis://', '');
    }

    final List<String> params = link.split('/');
    final Address parsedAddress =
        params.isNotEmpty ? Address(params[0]) : Address('');

    if (params.length > 1) {
      amount = params[1];
    }
    if (params.length > 2) {
      operation = legacyFormat
          ? _decodeLegacyBase85(params[2])
          : _decodeUrlSafeBase64(params[2]);
    }
    if (params.length > 3) {
      openfield = legacyFormat
          ? _decodeLegacyBase85(params[3])
          : _decodeUrlSafeBase64(params[3]);
    }

    isTokenToSend = false;
    if (operation == AddressTxsResponseResult.TOKEN_TRANSFER) {
      isTokenToSend = true;
      final List<String> openfieldSplit = (openfield ?? '').split(':');
      if (openfieldSplit.isNotEmpty && openfieldSplit[0].isNotEmpty) {
        tokenName = openfieldSplit[0];
      }
      if (openfieldSplit.length > 1 && openfieldSplit[1].isNotEmpty) {
        tokenToSendQty = int.tryParse(openfieldSplit[1]);
      }
      if (openfieldSplit.length > 3 && openfieldSplit[3].length > 1) {
        comment = openfieldSplit[3]
            .substring(0, openfieldSplit[3].length - 1)
            .replaceAll('"', '');
      }
    }

    bisUrl.address = parsedAddress.address;
    bisUrl.isTokenToSend = isTokenToSend;
    bisUrl.tokenToSendQty = tokenToSendQty;
    bisUrl.amount = amount;
    bisUrl.openfield = openfield;
    bisUrl.comment = comment;
    bisUrl.contactName = null;
    bisUrl.operation = operation;
    bisUrl.tokenName = tokenName;
    return bisUrl;
  }

  String _decodeUrlSafeBase64(String value) {
    if (value.isEmpty) {
      return '';
    }
    final String normalized =
        value.padRight(value.length + ((4 - value.length % 4) % 4), '=');
    return utf8.decode(base64Url.decode(normalized));
  }

  String _decodeLegacyBase85(String value) {
    if (value.trim().isEmpty) {
      return '';
    }

    const String alphabet =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!#\$%&()*+-;<=>?@^_`{|}~';
    final List<int> baseMap = List<int>.filled(256, 255);
    for (int i = 0; i < alphabet.length; i++) {
      baseMap[alphabet.codeUnitAt(i)] = i;
    }

    const List<int> ignored = <int>[0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x20];
    final Uint8List bytes = Uint8List.fromList(value.codeUnits);
    final int dataLength = bytes.length;
    int padding = dataLength % 5 == 0 ? 0 : 5 - dataLength % 5;
    final Uint8List result = Uint8List(4 * (dataLength / 5).ceil());

    int nextValidByte(int index) {
      while (index < dataLength && ignored.contains(bytes[index])) {
        padding = (padding + 1) % 5;
        index++;
      }
      return index;
    }

    int writeIndex = 0;
    for (int i = 0; i < dataLength;) {
      int value85 = 0;

      i = nextValidByte(i);
      value85 = baseMap[bytes[i]] * 52200625;

      i = nextValidByte(i + 1);
      value85 += (i >= dataLength ? 84 : baseMap[bytes[i]]) * 614125;

      i = nextValidByte(i + 1);
      value85 += (i >= dataLength ? 84 : baseMap[bytes[i]]) * 7225;

      i = nextValidByte(i + 1);
      value85 += (i >= dataLength ? 84 : baseMap[bytes[i]]) * 85;

      i = nextValidByte(i + 1);
      value85 += (i >= dataLength ? 84 : baseMap[bytes[i]]);

      i = nextValidByte(i + 1);

      result[writeIndex] = value85 >> 24;
      result[writeIndex + 1] = value85 >> 16;
      result[writeIndex + 2] = value85 >> 8;
      result[writeIndex + 3] = value85 & 0xff;
      writeIndex += 4;
    }

    return String.fromCharCodes(result.sublist(0, writeIndex - padding));
  }
}
