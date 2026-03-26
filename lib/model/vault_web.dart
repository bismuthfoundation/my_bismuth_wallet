import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:my_bismuth_wallet/util/app_ffi/encrypt/crypter.dart';
import 'package:my_bismuth_wallet/util/helpers.dart';
import 'package:my_bismuth_wallet/util/encrypt.dart';
import 'package:my_bismuth_wallet/util/random_util.dart';
import 'package:my_bismuth_wallet/web/passkey_service.dart';

class PinUnlockLockedException implements Exception {
  const PinUnlockLockedException(this.lockedUntil);

  final DateTime lockedUntil;

  Duration get remaining => lockedUntil.difference(DateTime.now().toUtc());

  @override
  String toString() {
    final Duration duration = remaining;
    final int totalSeconds = duration.inSeconds <= 0 ? 0 : duration.inSeconds;
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    if (minutes > 0) {
      return 'Too many failed PIN attempts. Try again in ${minutes}m ${seconds}s.';
    }
    return 'Too many failed PIN attempts. Try again in ${seconds}s.';
  }
}

class BrowserWalletProtectionStatus {
  const BrowserWalletProtectionStatus({
    required this.hasLegacySeed,
    required this.hasProtectedWallet,
    required this.hasPinProtection,
    required this.hasPasskeyProtection,
    required this.passkeySupported,
    required this.passkeyPrfCapable,
    required this.passkeyUnavailableReason,
    required this.failedPinAttempts,
    required this.pinLockedUntil,
  });

  final bool hasLegacySeed;
  final bool hasProtectedWallet;
  final bool hasPinProtection;
  final bool hasPasskeyProtection;
  final bool passkeySupported;
  final bool passkeyPrfCapable;
  final String? passkeyUnavailableReason;
  final int failedPinAttempts;
  final DateTime? pinLockedUntil;

  bool get isProtected => hasProtectedWallet;
  bool get isLocked => hasProtectedWallet;
  bool get isPinLocked =>
      pinLockedUntil != null && pinLockedUntil!.isAfter(DateTime.now().toUtc());
  bool get canEnrollPasskey =>
      passkeySupported &&
      passkeyPrfCapable &&
      hasPinProtection &&
      !isPinLocked &&
      (passkeyUnavailableReason == null || passkeyUnavailableReason!.isEmpty);
}

class _ProtectedWalletRecord {
  const _ProtectedWalletRecord({
    required this.version,
    required this.encryptedSeed,
    required this.pinWrappedDek,
    required this.passkeyWrappedDek,
    required this.passkeyCredentialId,
    required this.updatedAt,
  });

  final int version;
  final String encryptedSeed;
  final String? pinWrappedDek;
  final String? passkeyWrappedDek;
  final String? passkeyCredentialId;
  final String updatedAt;

  bool get hasPinProtection =>
      pinWrappedDek != null && pinWrappedDek!.isNotEmpty;

  bool get hasPasskeyProtection =>
      passkeyWrappedDek != null &&
      passkeyWrappedDek!.isNotEmpty &&
      passkeyCredentialId != null &&
      passkeyCredentialId!.isNotEmpty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'version': version,
      'encryptedSeed': encryptedSeed,
      'pinWrappedDek': pinWrappedDek,
      'passkeyWrappedDek': passkeyWrappedDek,
      'passkeyCredentialId': passkeyCredentialId,
      'updatedAt': updatedAt,
    };
  }

  factory _ProtectedWalletRecord.fromJson(Map<String, dynamic> json) {
    return _ProtectedWalletRecord(
      version: (json['version'] as num?)?.toInt() ?? 1,
      encryptedSeed: json['encryptedSeed'] as String? ?? '',
      pinWrappedDek: (json['pinWrappedDek'] as String?) ??
          (json['passwordWrappedDek'] as String?),
      passkeyWrappedDek: json['passkeyWrappedDek'] as String?,
      passkeyCredentialId: json['passkeyCredentialId'] as String?,
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }
}

class Vault {
  static const String seedKey = 'fbismuth_seed';
  static const String encryptionKey = 'fbismuth_secret_phrase';
  static const String pinKey = 'fbismuth_pin';
  static const String sessionKey = 'fencsess_key';
  static const String _browserSecretKey = 'fbismuth_browser_secret';
  static const String _protectedWalletKey = 'fbismuth_wallet_security_v1';
  static const String _passkeyUnavailableReasonKey =
      'fbismuth_passkey_unavailable_reason';
  static const String _pinFailedAttemptsKey = 'fbismuth_pin_failed_attempts';
  static const String _pinLockedUntilKey = 'fbismuth_pin_locked_until';

  final BrowserPasskeyService _passkeyService = BrowserPasskeyService();

  Future<bool> legacy() async {
    return false;
  }

  Future<String> _write(String key, String value) async {
    await setEncrypted(key, value);
    return value;
  }

  Future<String> _read(String key, {String defaultValue = ''}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) {
      return defaultValue;
    }
    return getEncrypted(key);
  }

  Future<void> deleteAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(encryptionKey);
    await prefs.remove(seedKey);
    await prefs.remove(pinKey);
    await prefs.remove(sessionKey);
    await prefs.remove(_browserSecretKey);
    await prefs.remove(_protectedWalletKey);
    await prefs.remove(_passkeyUnavailableReasonKey);
    await prefs.remove(_pinFailedAttemptsKey);
    await prefs.remove(_pinLockedUntilKey);
  }

  Future<String> getSeed() async {
    return _read(seedKey);
  }

  Future<String> setSeed(String seed) async {
    return _write(seedKey, seed);
  }

  Future<void> deleteSeed() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(seedKey);
  }

  Future<BrowserWalletProtectionStatus> getProtectionStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool passkeySupported = await _passkeyService.isSupported();
    final bool passkeyPrfCapable = passkeySupported
        ? await _passkeyService.isPrfCapableCandidate()
        : false;
    final _ProtectedWalletRecord? record = await _readProtectedWalletRecord();
    final String? passkeyUnavailableReason =
        _normalizeReason(prefs.getString(_passkeyUnavailableReasonKey));
    final int failedPinAttempts = prefs.getInt(_pinFailedAttemptsKey) ?? 0;
    final DateTime? pinLockedUntil =
        _parseDateTime(prefs.getString(_pinLockedUntilKey));

    return BrowserWalletProtectionStatus(
      hasLegacySeed: (prefs.getString(seedKey) ?? '').isNotEmpty,
      hasProtectedWallet: record != null && record.encryptedSeed.isNotEmpty,
      hasPinProtection: record?.hasPinProtection ?? false,
      hasPasskeyProtection: record?.hasPasskeyProtection ?? false,
      passkeySupported: passkeySupported,
      passkeyPrfCapable: passkeyPrfCapable,
      passkeyUnavailableReason: passkeyUnavailableReason,
      failedPinAttempts: failedPinAttempts,
      pinLockedUntil: pinLockedUntil,
    );
  }

  Future<void> protectSeedWithPin({
    required String seed,
    required String pin,
  }) async {
    _validatePin(pin);
    final String dek = _generateDek();
    final String encryptedSeed = _encryptUtf8String(seed, dek);
    final String pinWrappedDek = _encryptUtf8String(dek, pin);

    await _writeProtectedWalletRecord(
      _ProtectedWalletRecord(
        version: 1,
        encryptedSeed: encryptedSeed,
        pinWrappedDek: pinWrappedDek,
        passkeyWrappedDek: null,
        passkeyCredentialId: null,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    await _clearPasskeyUnavailableReason();
    await _clearPinFailures();
    await deleteSeed();
    await deletePin();
  }

  Future<void> enablePasskeyUnlock({
    required String seed,
    required String pin,
  }) async {
    final _ProtectedWalletRecord? existing = await _readProtectedWalletRecord();
    if (existing == null || !existing.hasPinProtection) {
      throw StateError(
        'Set a 6-digit wallet PIN before enabling passkey unlock.',
      );
    }
    _validatePin(pin);
    _ensurePinNotLocked(await SharedPreferences.getInstance());
    _decryptUtf8String(existing.pinWrappedDek!, pin);

    final BrowserPasskeyCredential credential;
    try {
      credential = await _passkeyService.createCredential(
        userName: 'browser-wallet',
        displayName: 'my Bismuth Wallet',
      );
    } on PasskeyPrfUnavailableException {
      await _setPasskeyUnavailableReason(
        'This device passkey provider supports biometric sign-in, but not the PRF extension required for local wallet unlock.',
      );
      rethrow;
    }
    final String dek = _generateDek();
    final String encryptedSeed = _encryptUtf8String(seed, dek);
    final String pinWrappedDek = _encryptUtf8String(dek, pin);
    final String passkeyWrappedDek = _encryptUtf8String(dek, credential.secret);

    await _writeProtectedWalletRecord(
      _ProtectedWalletRecord(
        version: 1,
        encryptedSeed: encryptedSeed,
        pinWrappedDek: pinWrappedDek,
        passkeyWrappedDek: passkeyWrappedDek,
        passkeyCredentialId: credential.credentialId,
        updatedAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
    await _clearPasskeyUnavailableReason();
    await deleteSeed();
  }

  Future<String> unlockProtectedSeedWithPin(String pin) async {
    final _ProtectedWalletRecord record = await _requireProtectedWalletRecord();
    if (!record.hasPinProtection) {
      throw StateError('PIN unlock is not enabled for this wallet.');
    }
    _validatePin(pin);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _ensurePinNotLocked(prefs);

    try {
      final String dek = _decryptUtf8String(record.pinWrappedDek!, pin);
      await _clearPinFailures();
      return _decryptUtf8String(record.encryptedSeed, dek);
    } catch (_) {
      await _registerFailedPinAttempt(prefs);
      rethrow;
    }
  }

  Future<String> unlockProtectedSeedWithPasskey() async {
    final _ProtectedWalletRecord record = await _requireProtectedWalletRecord();
    if (!record.hasPasskeyProtection) {
      throw StateError('Passkey unlock is not enabled for this wallet.');
    }

    final String secret = await _passkeyService.getAssertionSecret(
      record.passkeyCredentialId!,
    );
    final String dek = _decryptUtf8String(record.passkeyWrappedDek!, secret);
    return _decryptUtf8String(record.encryptedSeed, dek);
  }

  Future<String> getEncryptionPhrase() async {
    return _read(encryptionKey);
  }

  Future<String> writeEncryptionPhrase(String secret) async {
    return _write(encryptionKey, secret);
  }

  Future<String> getSessionKey() async {
    return _read(sessionKey);
  }

  Future<String> updateSessionKey() async {
    final String key = RandomUtil.generateEncryptionSecret(25);
    await writeSessionKey(key);
    return key;
  }

  Future<String> writeSessionKey(String key) async {
    return _write(sessionKey, key);
  }

  Future<void> deleteEncryptionPhrase() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(encryptionKey);
  }

  Future<String> getPin() async {
    return _read(pinKey);
  }

  Future<String> writePin(String pin) async {
    return _write(pinKey, pin);
  }

  Future<void> deletePin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(pinKey);
  }

  Future<void> setEncrypted(String key, String value) async {
    final String secret = await getSecret();
    final Salsa20Encryptor encrypter = Salsa20Encryptor(
      secret.substring(0, secret.length - 8),
      secret.substring(secret.length - 8),
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, encrypter.encrypt(value));
  }

  Future<String> getEncrypted(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encrypted = prefs.getString(key) ?? '';
    if (encrypted.isEmpty) {
      return '';
    }
    final String secret = await getSecret();
    final Salsa20Encryptor encrypter = Salsa20Encryptor(
      secret.substring(0, secret.length - 8),
      secret.substring(secret.length - 8),
    );
    return encrypter.decrypt(encrypted);
  }

  Future<String> getSecret() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? existing = prefs.getString(_browserSecretKey);
    if (existing != null && existing.length > 8) {
      return existing;
    }

    final String generated =
        '${RandomUtil.generateEncryptionSecret(32)}${RandomUtil.generateEncryptionSecret(8)}';
    await prefs.setString(_browserSecretKey, generated);
    return generated;
  }

  Future<_ProtectedWalletRecord?> _readProtectedWalletRecord() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String raw = prefs.getString(_protectedWalletKey) ?? '';
    if (raw.isEmpty) {
      return null;
    }

    final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
    final _ProtectedWalletRecord record = _ProtectedWalletRecord.fromJson(json);
    if (record.encryptedSeed.isEmpty) {
      return null;
    }
    return record;
  }

  Future<_ProtectedWalletRecord> _requireProtectedWalletRecord() async {
    final _ProtectedWalletRecord? record = await _readProtectedWalletRecord();
    if (record == null) {
      throw StateError(
          'No protected wallet is stored in this browser profile.');
    }
    return record;
  }

  Future<void> _writeProtectedWalletRecord(
      _ProtectedWalletRecord record) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_protectedWalletKey, jsonEncode(record.toJson()));
  }

  Future<void> _setPasskeyUnavailableReason(String reason) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_passkeyUnavailableReasonKey, reason);
  }

  Future<void> _clearPasskeyUnavailableReason() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_passkeyUnavailableReasonKey);
  }

  String? _normalizeReason(String? value) {
    if (value == null) {
      return null;
    }
    final String trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _validatePin(String pin) {
    if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
      throw StateError('Wallet PIN must be exactly 6 digits.');
    }
  }

  DateTime? _parseDateTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc();
  }

  void _ensurePinNotLocked(SharedPreferences prefs) {
    final DateTime? lockedUntil = _parseDateTime(
      prefs.getString(_pinLockedUntilKey),
    );
    if (lockedUntil != null && lockedUntil.isAfter(DateTime.now().toUtc())) {
      throw PinUnlockLockedException(lockedUntil);
    }
  }

  Future<void> _registerFailedPinAttempt(SharedPreferences prefs) async {
    final int failedAttempts = (prefs.getInt(_pinFailedAttemptsKey) ?? 0) + 1;
    await prefs.setInt(_pinFailedAttemptsKey, failedAttempts);

    final Duration? cooldown = _cooldownForFailedAttempts(failedAttempts);
    if (cooldown != null) {
      final DateTime lockedUntil = DateTime.now().toUtc().add(cooldown);
      await prefs.setString(_pinLockedUntilKey, lockedUntil.toIso8601String());
      throw PinUnlockLockedException(lockedUntil);
    }
  }

  Future<void> _clearPinFailures() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinFailedAttemptsKey);
    await prefs.remove(_pinLockedUntilKey);
  }

  Duration? _cooldownForFailedAttempts(int failedAttempts) {
    if (failedAttempts >= 12) {
      return const Duration(hours: 1);
    }
    if (failedAttempts >= 10) {
      return const Duration(minutes: 15);
    }
    if (failedAttempts >= 8) {
      return const Duration(minutes: 5);
    }
    if (failedAttempts >= 5) {
      return const Duration(seconds: 30);
    }
    return null;
  }

  String _generateDek() {
    return RandomUtil.generateEncryptionSecret(48);
  }

  String _encryptUtf8String(String value, String password) {
    final Uint8List encrypted = AppCrypt.encrypt(
      AppHelpers.stringToBytesUtf8(value),
      password,
    );
    return base64.encode(encrypted);
  }

  String _decryptUtf8String(String encoded, String password) {
    final Uint8List encrypted = Uint8List.fromList(base64.decode(encoded));
    final Uint8List decrypted = AppCrypt.decrypt(encrypted, password);
    return AppHelpers.bytesToUtf8String(decrypted);
  }
}
