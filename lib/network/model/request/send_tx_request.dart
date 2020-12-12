// To parse this JSON data, do
//
//     final sendTxRequest = sendTxRequestFromJson(jsonString);

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

import 'package:bs58check/bs58check.dart' as bs58check;

import 'package:pointycastle/random/fortuna_random.dart';
import 'package:pointycastle/signers/ecdsa_signer.dart';

List<SendTxRequest> sendTxRequestFromJson(String str) =>
    List<SendTxRequest>.from(
        json.decode(str).map((x) => SendTxRequest.fromJson(x)));

String sendTxRequestToJson(List<SendTxRequest> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SendTxRequest {
  SendTxRequest({
    this.id,
    this.tx,
    this.buffer,
    this.signature,
    this.publicKey,
    this.websocketCommand,
  });

  int id;
  Tx tx;
  String buffer;
  String signature;
  String publicKey;
  String websocketCommand;

  BigInt uint8ListToBigInt(Uint8List bytes) {
    BigInt read(int start, int end) {
      if (end - start <= 4) {
        int result = 0;
        for (int i = end - 1; i >= start; i--) {
          result = result * 256 + bytes[i];
        }

        return BigInt.from(result);
      }
      int mid = start + ((end - start) >> 1);
      final result = read(start, mid) +
          read(mid, end) * (BigInt.one << ((mid - start) * 8));

      return result;
    }

    return read(0, bytes.length);
  }

  Uint8List bigIntToUint8List(BigInt number) {
    int bytes = (number.bitLength + 7) >> 3;
    final b256 = BigInt.from(256);
    final result = Uint8List(bytes);

    for (int i = 0; i < bytes; i++) {
      result[i] = number.remainder(b256).toInt();
      number = number >> 8;
    }

    return result;
  }

  String signString(String privateKey58, String msgToSign) {

    final Signer signer = Signer('SHA-1/ECDSA');
    final privateKey = ECPrivateKey(
      uint8ListToBigInt(bs58check.decode(privateKey58)),
      ECDomainParameters('secp256k1'),
    );

    final privParams = () => ParametersWithRandom(
          PrivateKeyParameter<ECPrivateKey>(privateKey),
          genSecure(),
        );

    signer.reset();
    signer.init(true, privParams());
    final Signature s = signer.generateSignature(stringToUint8List(msgToSign));
    final String sig = s.toString();
    final List sigXY = sig.substring(1, sig.length - 1).split(',');
    final Uint8List sigX = bigIntToUint8List(BigInt.parse(sigXY[0]));
    final Uint8List sigY = bigIntToUint8List(BigInt.parse(sigXY[1]));
    final String sig58 = bs58check.encode(Uint8List.fromList(sigX + sigY));
    print("sig58: " + sig58);
    return sig58;
  }

  Uint8List stringToUint8List(String s) => Uint8List.fromList(s.codeUnits);

  FortunaRandom genSecure() {
    final secureRandom = FortunaRandom();
    final random = Random.secure();

    const int seedLength = 32;
    const int randomMax = 255;
    final Uint8List uint8list = Uint8List(seedLength);

    for (int i = 0; i < seedLength; i++) {
      uint8list[i] = random.nextInt(randomMax);
    }

    final KeyParameter keyParameter = KeyParameter(uint8list);
    secureRandom.seed(keyParameter);

    return secureRandom;
  }

  void buildSignature(String privateKey) async {
    String privateKey58 = bs58check.encode(utf8.encode(privateKey));
    signature = signString(privateKey58, buffer);
    print("signature: " + signature);

    //signature = base64.encode(bs58check.decode(signature));
    signature = base64.encode(utf8.encode(signature));
    print("signature: " + signature);

    
  }

  factory SendTxRequest.fromJson(Map<String, dynamic> json) => SendTxRequest(
        id: json["id"],
        tx: Tx.fromJson(json["tx"]),
        buffer: json["buffer"],
        signature: json["signature"],
        publicKey: json["public_key"],
        websocketCommand: json["websocket_command"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tx": tx.toJson(),
        "buffer": buffer,
        "signature": signature,
        "public_key": publicKey,
        "websocket_command": websocketCommand,
      };

  String buildCommand() {
    String command = '["' + tx.timestamp + '",';
    command += '"' + tx.address + '", ';
    command += '"' + tx.recipient + '", ';
    command += '"' + tx.amount + '", ';
    command += '"' + signature + '", ';
    command += '"' + publicKey + '", ';
    command += '"' + tx.operation + '", ';
    command += '"' + tx.openfield + '"]';
    print("command : " + command);
    return command;
  }
}

class Tx {
  Tx({
    this.timestamp,
    this.address,
    this.recipient,
    this.amount,
    this.operation,
    this.openfield,
  });

  String timestamp;
  String address;
  String recipient;
  String amount;
  String operation;
  String openfield;

  factory Tx.fromJson(Map<String, dynamic> json) => Tx(
        timestamp: json["timestamp"],
        address: json["address"],
        recipient: json["recipient"],
        amount: json["amount"],
        operation: json["operation"],
        openfield: json["openfield"],
      );

  Map<String, dynamic> toJson() => {
        "timestamp": timestamp,
        "address": address,
        "recipient": recipient,
        "amount": amount,
        "operation": operation,
        "openfield": openfield,
      };

  String buildBufferValue() {
    String _buffer = "('" +
        timestamp +
        "', '" +
        address +
        "', '" +
        recipient +
        "', '" +
        amount +
        "', '" +
        operation +
        "', '" +
        openfield +
        "')";
    print("_buffer : " + _buffer);
    return _buffer;
  }
}
