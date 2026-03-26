import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart' as asn1lib;
import 'package:pointycastle/pointycastle.dart';

class BismuthTransactionSigner {
  String signBuffer({
    required String privateKeyHex,
    required String buffer,
  }) {
    final Signer signer = Signer('SHA-256/ECDSA');
    final ECPrivateKey privateKey = ECPrivateKey(
      BigInt.parse(privateKeyHex, radix: 16),
      ECDomainParameters('secp256k1'),
    );
    final PrivateKeyParameter<ECPrivateKey> privateParams =
        PrivateKeyParameter<ECPrivateKey>(privateKey);

    final SecureRandom random = SecureRandom('AES/CTR/PRNG');
    final KeyParameter keyParam = KeyParameter(_secureRandomBytes(16));
    final ParametersWithIV<KeyParameter> params =
        ParametersWithIV<KeyParameter>(keyParam, _secureRandomBytes(16));
    random.seed(params);

    signer
      ..reset()
      ..init(true, ParametersWithRandom(privateParams, random));

    ECSignature signature =
        signer.generateSignature(utf8.encode(buffer)) as ECSignature;
    signature = signature.normalize(ECDomainParameters('secp256k1'));

    final asn1lib.ASN1Sequence topLevel = asn1lib.ASN1Sequence()
      ..add(asn1lib.ASN1Integer(signature.r))
      ..add(asn1lib.ASN1Integer(signature.s));

    return base64.encode(topLevel.encodedBytes);
  }

  Uint8List _secureRandomBytes(int length) {
    final Random random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(255)),
    );
  }
}
