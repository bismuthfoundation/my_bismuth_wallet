
// Dart imports:
import 'dart:core';

// Object to represent an account address or address URI, and provide useful utilities
class Address {
  String _address = '';
  String _amount = '';

  Address(String value) {
    _address = value;
  }

  String get address => _address;

  String get amount => _amount;

  String getShortString() {
    if (_address.length < 21) {
      return _address;
    } else {
      return _address.substring(0, 11) +
          "..." +
          _address.substring(_address.length - 6);
    }
  }

  String getShortString2() {
    if (_address.length < 21) {
      return _address;
    } else {
      return _address.substring(0, 18) +
          "..." +
          _address.substring(_address.length - 6);
    }
  }

  String getShorterString() {
    if (_address.length < 21) {
      return _address;
    } else {
      return _address.substring(0, 9) +
          "..." +
          _address.substring(_address.length - 4);
    }
  }

  bool isValid() {
    final String normalized = _address.trim();
    if (normalized.isEmpty || normalized.contains(' ')) {
      return false;
    }

    // Modern Bismuth addresses use the Bis1... base58 format.
    final RegExp modernAddress = RegExp(r'^Bis1[1-9A-HJ-NP-Za-km-z]{20,80}$');
    if (modernAddress.hasMatch(normalized)) {
      return true;
    }

    // Legacy RSA addresses are the SHA-224 hex digest of the PEM public key.
    final RegExp legacyRsa = RegExp(r'^[A-Fa-f0-9]{56}$');
    if (legacyRsa.hasMatch(normalized)) {
      return true;
    }

    return false;
  }
}
