// Dart imports:
import 'dart:typed_data';

// Project imports:
import 'package:my_bismuth_wallet/util/app_ffi/encrypt/model/keyiv.dart';

/// KDF (Key derivator function) base class
abstract class KDF {
  /// Derive a KeyIV with given password and optional salt
  KeyIV deriveKey(String password, {required Uint8List salt});
}
