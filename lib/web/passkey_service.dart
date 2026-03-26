import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class PasskeyPrfUnavailableException implements Exception {
  const PasskeyPrfUnavailableException();

  @override
  String toString() {
    return 'This browser authenticator completed passkey verification, but did not provide the PRF extension needed for local wallet unlock.';
  }
}

class BrowserPasskeyCredential {
  const BrowserPasskeyCredential({
    required this.credentialId,
    required this.secret,
  });

  final String credentialId;
  final String secret;
}

class BrowserPasskeyService {
  static const String _rpName = 'my Bismuth Wallet';
  static const String _rpId = '';
  static const String _prfSaltLabel =
      'my-bismuth-wallet-passkey-seed-unlock-v1';

  JSObject? get _credentialsApi {
    final JSObject navigator = JSObject.fromInteropObject(web.window.navigator);
    final JSAny? credentials = navigator['credentials'];
    if (credentials == null || credentials.isUndefinedOrNull) {
      return null;
    }
    return credentials as JSObject;
  }

  Future<bool> isSupported() async {
    final JSObject? credentials = _credentialsApi;
    if (credentials == null) {
      return false;
    }

    final JSObject windowObject = JSObject.fromInteropObject(web.window);
    final JSAny? pkc = windowObject['PublicKeyCredential'];
    if (pkc == null || pkc.isUndefinedOrNull) {
      return false;
    }
    return true;
  }

  Future<bool> isPrfCapableCandidate() async {
    final JSObject? credentials = _credentialsApi;
    if (credentials == null) {
      return false;
    }

    final JSObject windowObject = JSObject.fromInteropObject(web.window);
    final JSAny? pkcAny = windowObject['PublicKeyCredential'];
    if (pkcAny == null || pkcAny.isUndefinedOrNull) {
      return false;
    }

    final JSObject pkc = pkcAny as JSObject;
    final JSAny? getClientCapabilitiesAny = pkc['getClientCapabilities'];
    if (getClientCapabilitiesAny == null ||
        getClientCapabilitiesAny.isUndefinedOrNull) {
      // Older browsers do not expose a capability probe. Keep the option
      // available until we confirm incompatibility during enrollment.
      return true;
    }

    try {
      final JSObject capabilities =
          await pkc.callMethodVarArgs<JSPromise<JSObject>>(
        'getClientCapabilities'.toJS,
        const <JSAny?>[],
      ).toDart;
      final JSAny? prfAny = capabilities['prf'];
      if (prfAny == null || prfAny.isUndefinedOrNull) {
        return true;
      }
      return (prfAny as JSBoolean).toDart;
    } catch (_) {
      return true;
    }
  }

  Future<BrowserPasskeyCredential> createCredential({
    required String userName,
    String displayName = 'Browser Wallet',
  }) async {
    final JSObject credentials = _requireCredentialsApi();
    final Uint8List challenge = _randomBytes(32);
    final Uint8List userId = _randomBytes(32);
    final Uint8List prfSalt = Uint8List.fromList(
      utf8.encode(_prfSaltLabel),
    );

    final JSObject publicKey = JSObject()
      ..['challenge'] = challenge.toJS
      ..['rp'] = (JSObject()..['name'] = _rpName.toJS)
      ..['user'] = (JSObject()
        ..['id'] = userId.toJS
        ..['name'] = userName.toJS
        ..['displayName'] = displayName.toJS)
      ..['pubKeyCredParams'] = <JSAny?>[
        (JSObject()
          ..['type'] = 'public-key'.toJS
          ..['alg'] = (-257).toJS),
        (JSObject()
          ..['type'] = 'public-key'.toJS
          ..['alg'] = (-7).toJS),
      ].toJS
      ..['timeout'] = 60000.toJS
      ..['attestation'] = 'none'.toJS
      ..['authenticatorSelection'] = (JSObject()
        ..['authenticatorAttachment'] = 'platform'.toJS
        ..['residentKey'] = 'preferred'.toJS
        ..['userVerification'] = 'required'.toJS)
      ..['extensions'] = (JSObject()
        ..['prf'] =
            (JSObject()..['eval'] = (JSObject()..['first'] = prfSalt.toJS)));

    if (_rpId.isNotEmpty) {
      publicKey['rpId'] = _rpId.toJS;
    }

    final JSObject options = JSObject()..['publicKey'] = publicKey;
    final JSObject created =
        await credentials.callMethodVarArgs<JSPromise<JSObject>>(
      'create'.toJS,
      <JSAny?>[options],
    ).toDart;

    final String credentialId = _bufferToBase64Url(created['rawId']!);
    final String secret = await getAssertionSecret(credentialId);
    if (secret.isEmpty) {
      throw const PasskeyPrfUnavailableException();
    }

    return BrowserPasskeyCredential(
      credentialId: credentialId,
      secret: secret,
    );
  }

  Future<String> getAssertionSecret(String credentialId) async {
    final JSObject credentials = _requireCredentialsApi();
    final Uint8List challenge = _randomBytes(32);
    final Uint8List prfSalt = Uint8List.fromList(
      utf8.encode(_prfSaltLabel),
    );
    final JSObject allowCredential = JSObject()
      ..['type'] = 'public-key'.toJS
      ..['id'] = _base64UrlToBytes(credentialId).toJS;

    final JSObject publicKey = JSObject()
      ..['challenge'] = challenge.toJS
      ..['timeout'] = 60000.toJS
      ..['userVerification'] = 'required'.toJS
      ..['allowCredentials'] = <JSAny?>[allowCredential].toJS
      ..['extensions'] = (JSObject()
        ..['prf'] =
            (JSObject()..['eval'] = (JSObject()..['first'] = prfSalt.toJS)));

    if (_rpId.isNotEmpty) {
      publicKey['rpId'] = _rpId.toJS;
    }

    final JSObject options = JSObject()..['publicKey'] = publicKey;
    final JSObject assertion =
        await credentials.callMethodVarArgs<JSPromise<JSObject>>(
      'get'.toJS,
      <JSAny?>[options],
    ).toDart;

    final String secret = _extractPrfSecret(assertion);
    if (secret.isEmpty) {
      throw const PasskeyPrfUnavailableException();
    }
    return secret;
  }

  JSObject _requireCredentialsApi() {
    final JSObject? credentials = _credentialsApi;
    if (credentials == null) {
      throw StateError('WebAuthn credentials API is unavailable.');
    }
    return credentials;
  }

  String _extractPrfSecret(JSObject credential) {
    try {
      final JSObject extensionResults = credential.callMethodVarArgs<JSObject>(
        'getClientExtensionResults'.toJS,
        const <JSAny?>[],
      );
      final JSAny? prfAny = extensionResults['prf'];
      if (prfAny == null || prfAny.isUndefinedOrNull) {
        return '';
      }
      final JSObject prf = prfAny as JSObject;
      final JSAny? resultsAny = prf['results'];
      if (resultsAny == null || resultsAny.isUndefinedOrNull) {
        return '';
      }
      final JSObject results = resultsAny as JSObject;
      final JSAny? first = results['first'];
      if (first == null || first.isUndefinedOrNull) {
        return '';
      }
      return base64UrlEncode(
        Uint8List.view((first as JSArrayBuffer).toDart),
      );
    } catch (_) {
      return '';
    }
  }

  Uint8List _randomBytes(int length) {
    final Random random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  String _bufferToBase64Url(JSAny value) {
    return base64UrlEncode(
      Uint8List.view((value as JSArrayBuffer).toDart),
    );
  }

  Uint8List _base64UrlToBytes(String value) {
    return Uint8List.fromList(base64Url.decode(base64Url.normalize(value)));
  }
}
