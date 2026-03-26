import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' show PlatformDispatcher;

import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/model/db/hiveDB.dart';
import 'package:my_bismuth_wallet/model/address.dart';
import 'package:my_bismuth_wallet/model/bis_url.dart';
import 'package:my_bismuth_wallet/model/vault_web.dart';
import 'package:my_bismuth_wallet/network/model/block_types.dart';
import 'package:my_bismuth_wallet/network/model/response/address_txs_response.dart';
import 'package:my_bismuth_wallet/util/app_ffi/keys/mnemonics.dart';
import 'package:my_bismuth_wallet/util/app_ffi/keys/seeds.dart';
import 'package:my_bismuth_wallet/util/address_derivation.dart';
import 'package:my_bismuth_wallet/util/numberutil.dart';
import 'package:my_bismuth_wallet/web/browser_qr_scanner.dart';
import 'package:my_bismuth_wallet/web/browser_wallet_network_service.dart';
import 'package:my_bismuth_wallet/web/passkey_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    runApp(_StartupErrorApp(message: details.toStringShort()));
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
    runApp(_StartupErrorApp(message: '$error\n\n$stackTrace'));
    return true;
  };

  try {
    await DBHelper.setupDatabase();
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    runApp(MyBismuthWalletWebApp(preferences: preferences));
  } catch (error, stackTrace) {
    runApp(_StartupErrorApp(message: '$error\n\n$stackTrace'));
  }
}

Locale _localeForLanguageCode(String languageCode) {
  switch (languageCode) {
    case 'fr':
      return const Locale('fr', 'FR');
    case 'de':
      return const Locale('de', 'DE');
    case 'id':
      return const Locale('id', 'ID');
    case 'nl':
      return const Locale('nl', 'NL');
    case 'es':
      return const Locale('es', 'ES');
    case 'it':
      return const Locale('it', 'IT');
    case 'en':
    default:
      return const Locale('en', 'US');
  }
}

const Map<String, Map<String, String>> _webStrings =
    <String, Map<String, String>>{
  'en': <String, String>{
    'settings': 'Settings',
    'currency': 'Currency',
    'language': 'Language',
    'security': 'Security',
    'set_wallet_password': 'Set Wallet PIN',
    'auth_method': 'Authentication Method',
    'backup_seed_phrase': 'Backup Seed Phrase',
    'close': 'Close',
    'send': 'Send',
    'receive': 'Receive',
    'transactions': 'Transactions',
    'address_hint': 'Enter Address',
    'scan_qr': 'Scan QR Code',
    'enter_amount': 'Enter Amount',
    'fees': 'Fees',
    'operation': 'Operation',
  },
  'fr': <String, String>{
    'settings': 'Parametres',
    'currency': 'Devise',
    'language': 'Langue',
    'security': 'Securite',
    'set_wallet_password': 'Definir le code PIN du portefeuille',
    'auth_method': "Methode d'authentification",
    'backup_seed_phrase': 'Sauvegarder la phrase secrete',
    'close': 'Fermer',
    'send': 'Envoyer',
    'receive': 'Recevoir',
    'transactions': 'Transactions',
    'address_hint': "Entrer l'adresse",
    'scan_qr': 'Scanner le code QR',
    'enter_amount': 'Entrer le montant',
    'fees': 'Frais',
    'operation': 'Operation',
  },
  'de': <String, String>{
    'settings': 'Einstellungen',
    'currency': 'Wahrung',
    'language': 'Sprache',
    'security': 'Sicherheit',
    'set_wallet_password': 'Wallet-PIN festlegen',
    'auth_method': 'Authentifizierungsmethode',
    'backup_seed_phrase': 'Seed-Phrase sichern',
    'close': 'Schliessen',
    'send': 'Senden',
    'receive': 'Empfangen',
    'transactions': 'Transaktionen',
    'address_hint': 'Adresse eingeben',
    'scan_qr': 'QR-Code scannen',
    'enter_amount': 'Betrag eingeben',
    'fees': 'Gebuhren',
    'operation': 'Operation',
  },
  'id': <String, String>{
    'settings': 'Pengaturan',
    'currency': 'Mata Uang',
    'language': 'Bahasa',
    'security': 'Keamanan',
    'set_wallet_password': 'Atur PIN Wallet',
    'auth_method': 'Metode Otentikasi',
    'backup_seed_phrase': 'Cadangkan Frasa Seed',
    'close': 'Tutup',
    'send': 'Kirim',
    'receive': 'Terima',
    'transactions': 'Transaksi',
    'address_hint': 'Masukkan Alamat',
    'scan_qr': 'Pindai Kode QR',
    'enter_amount': 'Masukkan Jumlah',
    'fees': 'Biaya',
    'operation': 'Operasi',
  },
  'nl': <String, String>{
    'settings': 'Instellingen',
    'currency': 'Valuta',
    'language': 'Taal',
    'security': 'Beveiliging',
    'set_wallet_password': 'Wallet-PIN instellen',
    'auth_method': 'Authenticatiemethode',
    'backup_seed_phrase': 'Seedzin back-uppen',
    'close': 'Sluiten',
    'send': 'Verzenden',
    'receive': 'Ontvangen',
    'transactions': 'Transacties',
    'address_hint': 'Adres invoeren',
    'scan_qr': 'QR-code scannen',
    'enter_amount': 'Bedrag invoeren',
    'fees': 'Kosten',
    'operation': 'Operatie',
  },
  'es': <String, String>{
    'settings': 'Configuracion',
    'currency': 'Moneda',
    'language': 'Idioma',
    'security': 'Seguridad',
    'set_wallet_password': 'Establecer PIN de la billetera',
    'auth_method': 'Metodo de autenticacion',
    'backup_seed_phrase': 'Respaldar frase secreta',
    'close': 'Cerrar',
    'send': 'Enviar',
    'receive': 'Recibir',
    'transactions': 'Transacciones',
    'address_hint': 'Ingresar direccion',
    'scan_qr': 'Escanear codigo QR',
    'enter_amount': 'Ingresar monto',
    'fees': 'Comisiones',
    'operation': 'Operacion',
  },
  'it': <String, String>{
    'settings': 'Impostazioni',
    'currency': 'Valuta',
    'language': 'Lingua',
    'security': 'Sicurezza',
    'set_wallet_password': 'Imposta PIN del wallet',
    'auth_method': 'Metodo di autenticazione',
    'backup_seed_phrase': 'Backup frase segreta',
    'close': 'Chiudi',
    'send': 'Invia',
    'receive': 'Ricevi',
    'transactions': 'Transazioni',
    'address_hint': 'Inserisci indirizzo',
    'scan_qr': 'Scansiona codice QR',
    'enter_amount': 'Inserisci importo',
    'fees': 'Commissioni',
    'operation': 'Operazione',
  },
};

String _tr(BuildContext context, String key) {
  final String languageCode = Localizations.localeOf(context).languageCode;
  return _webStrings[languageCode]?[key] ?? _webStrings['en']![key] ?? key;
}

class _StartupErrorApp extends StatelessWidget {
  final String message;

  const _StartupErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF081018),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 12),
              const Text(
                'Browser Startup Error',
                style: TextStyle(
                  color: Color(0xFFFF8A80),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'The web wallet failed before the UI finished loading.',
                style: TextStyle(
                  color: Color(0xFFF4F7FB),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    message,
                    style: const TextStyle(
                      color: Color(0xFFF4F7FB),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyBismuthWalletWebApp extends StatelessWidget {
  final SharedPreferences preferences;

  const MyBismuthWalletWebApp({super.key, required this.preferences});

  @override
  Widget build(BuildContext context) {
    const _Palette palette = _Palette(
      background: Color(0xFF081018),
      surface: Color(0xFF0F1A27),
      surfaceAlt: Color(0xFF122033),
      primary: Color(0xFF2EE6A6),
      secondary: Color(0xFF77C8FF),
      text: Color(0xFFF4F7FB),
      muted: Color(0xFF9EB0C5),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Bismuth Wallet',
      locale: _localeForLanguageCode(
        preferences.getString('extension_language') ?? 'en',
      ),
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('en'),
        Locale('fr'),
        Locale('de'),
        Locale('id'),
        Locale('nl'),
        Locale('es'),
        Locale('it'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: palette.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: palette.primary,
          secondary: palette.secondary,
          surface: palette.surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF18263A),
          hoverColor: const Color(0xFF21324B),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF304763),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF304763),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: palette.primary.withValues(alpha: 0.8),
              width: 1.4,
            ),
          ),
          hintStyle: TextStyle(
            color: palette.muted.withValues(alpha: 0.8),
          ),
          labelStyle: TextStyle(
            color: palette.muted,
          ),
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: palette.text,
              displayColor: palette.text,
            ),
      ),
      home: _ExtensionShell(
        preferences: preferences,
        palette: palette,
      ),
    );
  }
}

class _ExtensionShell extends StatefulWidget {
  final SharedPreferences preferences;
  final _Palette palette;

  const _ExtensionShell({
    required this.preferences,
    required this.palette,
  });

  @override
  State<_ExtensionShell> createState() => _ExtensionShellState();
}

class _ExtensionShellState extends State<_ExtensionShell> {
  static const String _nameKey = 'extension_profile_name';
  static const String _networkKey = 'extension_network';
  static const String _currencyKey = 'extension_currency';
  static const String _languageKey = 'extension_language';
  static const String _authMethodKey = 'extension_auth_method';
  static const String _noticeKey = 'extension_notice_acknowledged';
  static const String _launchCountKey = 'extension_launch_count';
  static const String _customWebsocketEndpointKey =
      'extension_custom_websocket_endpoint';
  static const int _transactionBatchSize = 5;
  static const Duration _networkDisconnectGracePeriod = Duration(seconds: 30);
  static const Duration _bannerMessageDuration = Duration(seconds: 5);

  final Vault _vault = Vault();
  final DBHelper _db = DBHelper();
  final BrowserWalletNetworkService _networkService =
      BrowserWalletNetworkService();
  final GlobalKey _browserWalletSectionKey = GlobalKey();
  Timer? _autoRefreshTimer;
  Timer? _statusMessageTimer;
  Timer? _errorMessageTimer;
  Timer? _sendStatusMessageTimer;
  Timer? _sendErrorMessageTimer;
  late final TextEditingController _mnemonicController;
  late final TextEditingController _destinationController;
  late final TextEditingController _amountController;
  late final TextEditingController _operationController;
  late final TextEditingController _openfieldController;
  late final TextEditingController _tokenAmountController;
  late final TextEditingController _tokenMessageController;
  late final TextEditingController _customWebsocketEndpointController;
  late final TextEditingController _unlockPasswordController;

  late String _network;
  late String _currencyCode;
  late String _languageCode;
  late String _authMethod;
  late bool _noticeAcknowledged;
  late int _launchCount;

  bool _loading = true;
  bool _working = false;
  String? _statusMessage;
  String? _errorMessage;
  String? _networkErrorMessage;
  String? _sendStatusMessage;
  String? _sendErrorMessage;
  BrowserWalletSubmitResult? _lastSubmitResult;
  String? _lastSubmitAmountLabel;
  String? _seed;
  String? _mnemonic;
  String? _pendingSeed;
  String? _pendingMnemonic;
  bool _showMnemonicVerificationView = false;
  List<_MnemonicCheckPrompt> _mnemonicVerificationPrompts =
      <_MnemonicCheckPrompt>[];
  final Map<int, String> _mnemonicVerificationAnswers = <int, String>{};
  String? _mnemonicVerificationError;
  List<Account> _accounts = <Account>[];
  Account? _selectedAccount;
  BrowserWalletSnapshot? _snapshot;
  bool _networkLoading = false;
  bool _showRefreshActivity = false;
  DateTime? _networkFailureStartedAt;
  bool _showSettingsView = false;
  String _settingsBackLabel = 'Wallet';
  bool _walletServerConnecting = false;
  int _assetTabIndex = 0;
  bool _showAccountDetails = false;
  int _accountDetailViewIndex = 0;
  String? _selectedTokenName;
  int _visibleBisTransactions = _transactionBatchSize;
  int _visibleTokenTransactions = _transactionBatchSize;
  String? _trackedStatusMessage;
  String? _trackedErrorMessage;
  String? _trackedSendStatusMessage;
  String? _trackedSendErrorMessage;
  BrowserWalletProtectionStatus _protectionStatus =
      const BrowserWalletProtectionStatus(
    hasLegacySeed: false,
    hasProtectedWallet: false,
    hasPinProtection: false,
    hasPasskeyProtection: false,
    passkeySupported: false,
    passkeyPrfCapable: false,
    passkeyUnavailableReason: null,
    failedPinAttempts: 0,
    pinLockedUntil: null,
  );
  bool _walletLocked = false;

  bool get _isOptionsView => true;
  bool get _hasWallet =>
      _seed != null && _seed!.isNotEmpty && _selectedAccount != null;
  String get _profileName =>
      widget.preferences.getString(_nameKey) ?? 'Web Wallet';

  static const List<String> _supportedCurrencies = <String>[
    'USD',
    'EUR',
    'BTC',
    'GBP',
  ];

  static const Map<String, String> _supportedLanguages = <String, String>{
    'en': 'English',
    'fr': 'Francais',
    'de': 'Deutsch',
    'id': 'Bahasa Indonesia',
    'nl': 'Nederlands',
    'es': 'Espaniol',
    'it': 'Italiano',
  };

  static const Map<String, String> _supportedAuthMethods = <String, String>{
    'biometrics': 'Biometrics',
    'fingerprint': 'Fingerprint',
    'face_id': 'Face ID',
  };

  @override
  void initState() {
    super.initState();
    _mnemonicController = TextEditingController();
    _destinationController = TextEditingController();
    _amountController = TextEditingController();
    _operationController = TextEditingController();
    _openfieldController = TextEditingController();
    _tokenAmountController = TextEditingController();
    _tokenMessageController = TextEditingController();
    _customWebsocketEndpointController = TextEditingController(
      text: widget.preferences.getString(_customWebsocketEndpointKey) ?? '',
    );
    _unlockPasswordController = TextEditingController();
    _network = widget.preferences.getString(_networkKey) ?? 'mainnet';
    _currencyCode = widget.preferences.getString(_currencyKey) ?? 'USD';
    _languageCode = widget.preferences.getString(_languageKey) ?? 'en';
    _authMethod = widget.preferences.getString(_authMethodKey) ?? 'biometrics';
    _noticeAcknowledged = widget.preferences.getBool(_noticeKey) ?? false;
    _launchCount = (widget.preferences.getInt(_launchCountKey) ?? 0) + 1;
    widget.preferences.setInt(_launchCountKey, _launchCount);
    _applyStoredWalletServerConfiguration();
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _maybeAutoRefreshNetworkData(),
    );
    _loadWalletState();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _statusMessageTimer?.cancel();
    _errorMessageTimer?.cancel();
    _sendStatusMessageTimer?.cancel();
    _sendErrorMessageTimer?.cancel();
    _mnemonicController.dispose();
    _destinationController.dispose();
    _amountController.dispose();
    _operationController.dispose();
    _openfieldController.dispose();
    _tokenAmountController.dispose();
    _tokenMessageController.dispose();
    _customWebsocketEndpointController.dispose();
    _unlockPasswordController.dispose();
    super.dispose();
  }

  Future<void> _maybeAutoRefreshNetworkData() async {
    if (!mounted || _loading || _working || _networkLoading || !_hasWallet) {
      return;
    }
    await _refreshNetworkData(showActivity: false);
  }

  Future<void> _loadWalletState() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final BrowserWalletProtectionStatus protectionStatus =
          await _vault.getProtectionStatus();
      if (protectionStatus.hasProtectedWallet) {
        setState(() {
          _protectionStatus = protectionStatus;
          _walletLocked = true;
          _seed = null;
          _mnemonic = null;
          _accounts = <Account>[];
          _selectedAccount = null;
          _snapshot = null;
          _networkErrorMessage = null;
          _showAccountDetails = false;
          _loading = false;
        });
        return;
      }

      final String seed = await _vault.getSeed();
      if (seed.isEmpty) {
        setState(() {
          _protectionStatus = protectionStatus;
          _walletLocked = false;
          _seed = null;
          _mnemonic = null;
          _accounts = <Account>[];
          _selectedAccount = null;
          _snapshot = null;
          _networkErrorMessage = null;
          _showAccountDetails = false;
          _loading = false;
        });
        return;
      }

      await _applyUnlockedSeed(seed, protectionStatus: protectionStatus);
      await _refreshNetworkData();
    } catch (error) {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load browser wallet data: $error';
      });
    }
  }

  Future<void> _applyUnlockedSeed(
    String seed, {
    BrowserWalletProtectionStatus? protectionStatus,
  }) async {
    final List<Account> accounts = await _db.getAccounts(seed);
    Account? account = await _db.getSelectedAccount(seed);
    account ??= await _db.getMainAccount(seed);

    if (!mounted) {
      return;
    }

    setState(() {
      _protectionStatus = protectionStatus ?? _protectionStatus;
      _walletLocked = false;
      _seed = seed;
      _mnemonic = AppMnemomics.seedToMnemonic(seed).join(' ');
      _accounts = accounts;
      _selectedAccount = account;
      _loading = false;
      _unlockPasswordController.clear();
    });
  }

  Future<void> _unlockWalletWithPin() async {
    final String pin = _unlockPasswordController.text.trim();
    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Enter the 6-digit wallet PIN to unlock this wallet.';
      });
      return;
    }

    setState(() {
      _working = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final String seed = await _vault.unlockProtectedSeedWithPin(pin);
      final BrowserWalletProtectionStatus protectionStatus =
          await _vault.getProtectionStatus();
      await _applyUnlockedSeed(seed, protectionStatus: protectionStatus);
      await _refreshNetworkData();
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _statusMessage = 'Wallet unlocked with PIN.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _errorMessage = 'PIN unlock failed: $error';
      });
    }
  }

  Future<void> _unlockWalletWithPasskey() async {
    setState(() {
      _working = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final String seed = await _vault.unlockProtectedSeedWithPasskey();
      final BrowserWalletProtectionStatus protectionStatus =
          await _vault.getProtectionStatus();
      await _applyUnlockedSeed(seed, protectionStatus: protectionStatus);
      await _refreshNetworkData();
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _statusMessage = 'Wallet unlocked with passkey.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _errorMessage = 'Passkey unlock failed: $error';
      });
    }
  }

  void _lockWallet() {
    setState(() {
      _walletLocked = _protectionStatus.hasProtectedWallet;
      _seed = null;
      _mnemonic = null;
      _accounts = <Account>[];
      _selectedAccount = null;
      _snapshot = null;
      _networkErrorMessage = null;
      _showAccountDetails = false;
      _unlockPasswordController.clear();
      _statusMessage = 'Wallet locked.';
      _sendStatusMessage = null;
      _sendErrorMessage = null;
    });
  }

  Future<void> _setCurrency(String value) async {
    await widget.preferences.setString(_currencyKey, value);
    if (!mounted) {
      return;
    }
    setState(() {
      _currencyCode = value;
      _snapshot = null;
    });
    if (_hasWallet) {
      await _refreshNetworkData();
    }
  }

  Future<void> _setLanguage(String value) async {
    await widget.preferences.setString(_languageKey, value);
    if (!mounted) {
      return;
    }
    setState(() {
      _languageCode = value;
      _statusMessage =
          'Language preference saved. Full browser-shell localization is not wired yet.';
    });
  }

  Future<void> _setAuthMethod(String value) async {
    await widget.preferences.setString(_authMethodKey, value);
    if (!mounted) {
      return;
    }
    setState(() {
      _authMethod = value;
      _statusMessage =
          'Authentication preference saved. Browser enforcement is not wired yet.';
    });
  }

  Future<void> _addDerivedAccount() async {
    final String seed = _seed ?? await _vault.getSeed();
    if (seed.isEmpty) {
      setState(() {
        _errorMessage = 'Seed is unavailable in the browser vault.';
      });
      return;
    }

    setState(() {
      _working = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      final Account account = await _db.addAccount(
        seed,
        nameBuilder: 'Account %1',
      );
      await _selectAccount(account, openDetails: false);
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _statusMessage =
            'New deterministic account created from the wallet seed.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _errorMessage = 'Failed to create a new account: $error';
      });
    }
  }

  Future<void> _selectAccount(Account account,
      {bool openDetails = true}) async {
    final String seed = _seed ?? await _vault.getSeed();
    if (seed.isEmpty) {
      return;
    }

    await _db.changeAccount(account);
    final List<Account> accounts = await _db.getAccounts(seed);
    final Account? selected = accounts.cast<Account?>().firstWhere(
        (Account? item) => item?.index == account.index,
        orElse: () => account);

    if (!mounted) {
      return;
    }

    setState(() {
      _accounts = accounts;
      _selectedAccount = selected;
      _snapshot = null;
      _networkErrorMessage = null;
      _showAccountDetails = openDetails;
      _accountDetailViewIndex = 0;
      _selectedTokenName = null;
      _sendStatusMessage = null;
      _sendErrorMessage = null;
      _lastSubmitResult = null;
      _visibleBisTransactions = _transactionBatchSize;
      _visibleTokenTransactions = _transactionBatchSize;
    });
    await _refreshNetworkData();
  }

  void _showOverviewHome() {
    setState(() {
      _showAccountDetails = false;
      _accountDetailViewIndex = 0;
      _selectedTokenName = null;
      _visibleBisTransactions = _transactionBatchSize;
      _visibleTokenTransactions = _transactionBatchSize;
    });
  }

  void _clearSendDrafts() {
    _destinationController.clear();
    _amountController.clear();
    _operationController.clear();
    _openfieldController.clear();
    _tokenAmountController.clear();
    _tokenMessageController.clear();
    _sendStatusMessage = null;
    _sendErrorMessage = null;
    _lastSubmitResult = null;
    _lastSubmitAmountLabel = null;
  }

  void _setAccountDetailView(int index) {
    setState(() {
      _accountDetailViewIndex = index;
      if (index != 2 && index != 3 && index != 4) {
        _selectedTokenName = null;
      }
      if (index == 1) {
        _clearSendDrafts();
      }
      if (index == 0) {
        _visibleBisTransactions = _transactionBatchSize;
      }
    });
  }

  void _setTokenSendView() {
    if (_selectedTokenName == null) {
      _setAccountDetailView(1);
      return;
    }
    setState(() {
      _accountDetailViewIndex = 4;
      _clearSendDrafts();
    });
  }

  void _selectToken(String tokenName) {
    setState(() {
      _accountDetailViewIndex = 3;
      _selectedTokenName = tokenName;
      _visibleTokenTransactions = _transactionBatchSize;
    });
  }

  void _openTokenDetail(String tokenName) {
    setState(() {
      _showAccountDetails = true;
      _accountDetailViewIndex = 3;
      _selectedTokenName = tokenName;
      _visibleTokenTransactions = _transactionBatchSize;
    });
  }

  void _showTokenBalances() {
    setState(() {
      _accountDetailViewIndex = 3;
      _selectedTokenName = null;
      _visibleTokenTransactions = _transactionBatchSize;
    });
  }

  void _returnToSelectedTokenTransactions() {
    if (_selectedTokenName == null) {
      return;
    }
    setState(() {
      _accountDetailViewIndex = 3;
      _sendStatusMessage = null;
      _sendErrorMessage = null;
      _lastSubmitResult = null;
      _lastSubmitAmountLabel = null;
      _visibleTokenTransactions = _transactionBatchSize;
    });
  }

  void _returnToAccountTransactions() {
    setState(() {
      _accountDetailViewIndex = 0;
      _sendStatusMessage = null;
      _sendErrorMessage = null;
      _lastSubmitResult = null;
      _lastSubmitAmountLabel = null;
      _visibleBisTransactions = _transactionBatchSize;
    });
  }

  void _showMoreBisTransactions(int total) {
    setState(() {
      _visibleBisTransactions =
          (_visibleBisTransactions + _transactionBatchSize).clamp(
        _transactionBatchSize,
        total,
      );
    });
  }

  void _showLessBisTransactions() {
    setState(() {
      _visibleBisTransactions = _transactionBatchSize;
    });
  }

  void _showMoreTokenTransactions(int total) {
    setState(() {
      _visibleTokenTransactions =
          (_visibleTokenTransactions + _transactionBatchSize).clamp(
        _transactionBatchSize,
        total,
      );
    });
  }

  void _showLessTokenTransactions() {
    setState(() {
      _visibleTokenTransactions = _transactionBatchSize;
    });
  }

  Future<void> _copySelectedAccountAddress() async {
    final String address = _selectedAccount?.address ?? '';
    if (address.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: address));
    if (!mounted) {
      return;
    }
    setState(() {
      _statusMessage = 'Account address copied to clipboard.';
    });
  }

  Future<void> _promptRenameSelectedAccount() async {
    final Account? account = _selectedAccount;
    if (account == null) {
      return;
    }

    final TextEditingController controller = TextEditingController(
      text: account.name ?? '',
    );

    try {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Rename Account'),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Account label',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final String newName = controller.text.trim();
                  if (newName.isEmpty) {
                    return;
                  }
                  await _db.changeAccountName(account, newName);
                  final String seed = _seed ?? await _vault.getSeed();
                  final List<Account> accounts =
                      seed.isEmpty ? _accounts : await _db.getAccounts(seed);
                  final Account? updatedSelected = accounts
                      .where((Account item) => item.index == account.index)
                      .cast<Account?>()
                      .firstWhere(
                        (Account? item) => item != null,
                        orElse: () => account,
                      );
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _accounts = accounts;
                    _selectedAccount = updatedSelected;
                    _statusMessage = 'Account label updated.';
                    _errorMessage = null;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _setAssetTab(int index) async {
    setState(() {
      _assetTabIndex = index;
    });

    if (index == 1 && _hasWallet && !_networkLoading) {
      await _refreshNetworkData();
    }
  }

  void _openOptionsPage() {
    final BuildContext? targetContext = _browserWalletSectionKey.currentContext;
    if (targetContext == null) {
      return;
    }

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  void _openSettingsView({String fromLabel = 'Wallet'}) {
    setState(() {
      _showSettingsView = true;
      _settingsBackLabel = fromLabel;
      _statusMessage = null;
      _errorMessage = null;
    });
  }

  void _closeSettingsView() {
    setState(() {
      _showSettingsView = false;
    });
  }

  void _applyStoredWalletServerConfiguration() {
    final String endpoint = _customWebsocketEndpointController.text.trim();
    if (endpoint.isEmpty) {
      _networkService.resetLegacyWebSocketUrl();
      return;
    }
    _networkService.configureLegacyWebSocketUrl(endpoint);
  }

  Future<void> _connectCustomWebsocketEndpoint() async {
    final String endpoint = _customWebsocketEndpointController.text.trim();
    if (endpoint.isEmpty) {
      setState(() {
        _errorMessage = 'Enter a valid websocket endpoint.';
      });
      return;
    }

    final String previousUrl = _networkService.legacyWebSocketUrl;

    setState(() {
      _walletServerConnecting = true;
      _statusMessage = null;
      _errorMessage = null;
    });

    _networkService.configureLegacyWebSocketUrl(endpoint);

    try {
      await _networkService.testLegacyConnection();
      await widget.preferences.setString(
        _customWebsocketEndpointKey,
        endpoint,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _walletServerConnecting = false;
        _statusMessage = 'Connected to websocket endpoint.';
        _networkErrorMessage = null;
        _networkFailureStartedAt = null;
      });

      if (_hasWallet) {
        await _refreshNetworkData(showActivity: false);
      }
    } catch (error) {
      _networkService.configureLegacyWebSocketUrl(previousUrl);
      if (!mounted) {
        return;
      }
      setState(() {
        _walletServerConnecting = false;
        _errorMessage = 'Failed to connect to wallet server: $error';
      });
    }
  }

  Future<void> _openWalletManager() async {
    if (!_isOptionsView) {
      _openOptionsPage();
      return;
    }

    final BuildContext? targetContext = _browserWalletSectionKey.currentContext;
    if (targetContext == null) {
      return;
    }

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  Future<void> _createWallet() async {
    try {
      final String seed = await _generateDerivableSeed();
      final String mnemonic = AppMnemomics.seedToMnemonic(seed).join(' ');
      if (!mounted) {
        return;
      }
      setState(() {
        _pendingSeed = seed;
        _pendingMnemonic = mnemonic;
        _showMnemonicVerificationView = false;
        _mnemonicVerificationPrompts = <_MnemonicCheckPrompt>[];
        _mnemonicVerificationAnswers.clear();
        _mnemonicVerificationError = null;
        _errorMessage = null;
        _statusMessage =
            'Wallet generated locally. Back up the seed phrase before saving it into this web app.';
      });
      if (!_isOptionsView) {
        _openOptionsPage();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Wallet setup failed: $error';
      });
    }
  }

  Future<void> _confirmPendingWallet() async {
    final String? seed = _pendingSeed;
    if (seed == null || seed.isEmpty) {
      setState(() {
        _errorMessage = 'Generate a browser wallet first before saving it.';
      });
      return;
    }

    await _persistWallet(
      seed: seed,
      profileName: _profileName,
      statusMessage:
          'Browser wallet created and stored locally in this browser profile.',
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _pendingSeed = null;
      _pendingMnemonic = null;
      _showMnemonicVerificationView = false;
      _mnemonicVerificationPrompts = <_MnemonicCheckPrompt>[];
      _mnemonicVerificationAnswers.clear();
      _mnemonicVerificationError = null;
    });
  }

  Future<void> _confirmPendingWalletWithVerification() async {
    final String? mnemonic = _pendingMnemonic;
    if (mnemonic == null || mnemonic.isEmpty) {
      setState(() {
        _errorMessage = 'Generate a browser wallet first before saving it.';
      });
      return;
    }

    final List<String> words = mnemonic
        .split(RegExp(r'\s+'))
        .map((String word) => word.trim())
        .where((String word) => word.isNotEmpty)
        .toList();
    if (words.length < 5) {
      setState(() {
        _errorMessage = 'Mnemonic verification could not be prepared.';
      });
      return;
    }

    setState(() {
      _mnemonicVerificationPrompts = _mnemonicVerificationPrompts.isEmpty
          ? _buildMnemonicCheckPrompts(words)
          : _mnemonicVerificationPrompts;
      _showMnemonicVerificationView = true;
      _mnemonicVerificationError = null;
      _errorMessage = null;
    });
  }

  void _returnToPendingWalletPreview() {
    setState(() {
      _showMnemonicVerificationView = false;
      _mnemonicVerificationError = null;
    });
  }

  void _selectMnemonicVerificationAnswer(int position, String answer) {
    setState(() {
      _mnemonicVerificationAnswers[position] = answer;
      _mnemonicVerificationError = null;
    });
  }

  Future<void> _submitMnemonicVerification() async {
    final bool allAnswered = _mnemonicVerificationAnswers.length ==
        _mnemonicVerificationPrompts.length;
    if (!allAnswered) {
      setState(() {
        _mnemonicVerificationError =
            'Answer each prompt before saving the browser wallet.';
      });
      return;
    }

    final bool matches = _mnemonicVerificationPrompts.every(
      (_MnemonicCheckPrompt prompt) =>
          _mnemonicVerificationAnswers[prompt.position] == prompt.correctWord,
    );
    if (!matches) {
      setState(() {
        _mnemonicVerificationError =
            'One or more answers are incorrect. Go back and check the mnemonic again.';
      });
      return;
    }

    await _confirmPendingWallet();
  }

  List<_MnemonicCheckPrompt> _buildMnemonicCheckPrompts(
    List<String> words, {
    int promptCount = 5,
    int optionCount = 4,
  }) {
    final Random random = Random();
    final List<int> positions =
        List<int>.generate(words.length, (int index) => index)..shuffle(random);
    final List<String> distinctWords = words.toSet().toList();
    final List<_MnemonicCheckPrompt> prompts = <_MnemonicCheckPrompt>[];

    for (final int wordIndex in positions.take(promptCount)) {
      final String correctWord = words[wordIndex];
      final List<String> distractors = distinctWords
          .where((String word) => word != correctWord)
          .toList()
        ..shuffle(random);
      final List<String> options = <String>[
        correctWord,
        ...distractors.take(optionCount - 1),
      ]..shuffle(random);
      prompts.add(
        _MnemonicCheckPrompt(
          position: wordIndex + 1,
          correctWord: correctWord,
          options: options,
        ),
      );
    }

    prompts.sort(
      (_MnemonicCheckPrompt a, _MnemonicCheckPrompt b) =>
          a.position.compareTo(b.position),
    );
    return prompts;
  }

  Future<void> _copyPendingWalletSecret(String secret, String label) async {
    await Clipboard.setData(ClipboardData(text: secret));
    if (!mounted) {
      return;
    }
    setState(() {
      _statusMessage = '$label copied to the clipboard.';
      _errorMessage = null;
    });
  }

  void _discardPendingWallet() {
    setState(() {
      _pendingSeed = null;
      _pendingMnemonic = null;
      _showMnemonicVerificationView = false;
      _mnemonicVerificationPrompts = <_MnemonicCheckPrompt>[];
      _mnemonicVerificationAnswers.clear();
      _mnemonicVerificationError = null;
      _statusMessage = 'Unsaved generated wallet discarded.';
      _errorMessage = null;
    });
  }

  Future<void> _promptWalletPassword() async {
    final TextEditingController pinController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    try {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Set Wallet PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Create a 6-digit PIN for daily browser wallet unlock. Recovery still depends on the seed phrase.',
                ),
                const SizedBox(height: 12),
                _PinEntryField(
                  controller: pinController,
                  label: '6-digit PIN',
                ),
                const SizedBox(height: 12),
                _PinEntryField(
                  controller: confirmController,
                  label: 'Confirm PIN',
                ),
                const SizedBox(height: 16),
                _PinPad(
                  onDigitPressed: (String digit) {
                    if (pinController.text.length < 6) {
                      pinController.text = '${pinController.text}$digit';
                      return;
                    }
                    if (confirmController.text.length < 6) {
                      confirmController.text =
                          '${confirmController.text}$digit';
                    }
                  },
                  onBackspace: () {
                    if (confirmController.text.isNotEmpty) {
                      confirmController.text = confirmController.text.substring(
                        0,
                        confirmController.text.length - 1,
                      );
                      return;
                    }
                    if (pinController.text.isNotEmpty) {
                      pinController.text = pinController.text.substring(
                        0,
                        pinController.text.length - 1,
                      );
                    }
                  },
                  onClear: () {
                    if (confirmController.text.isNotEmpty) {
                      confirmController.clear();
                      return;
                    }
                    pinController.clear();
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  final String pin = pinController.text.trim();
                  final String confirm = confirmController.text.trim();
                  final String? seed = _seed;
                  if (seed == null || seed.isEmpty) {
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _errorMessage =
                          'Unlock or create a browser wallet before setting a PIN.';
                    });
                    Navigator.of(context).pop();
                    return;
                  }
                  if (pin.isEmpty || confirm.isEmpty) {
                    return;
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(pin)) {
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _errorMessage = 'Wallet PIN must be exactly 6 digits.';
                    });
                    return;
                  }
                  if (pin != confirm) {
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _errorMessage = 'PIN confirmation does not match.';
                    });
                    return;
                  }
                  await _vault.protectSeedWithPin(
                    seed: seed,
                    pin: pin,
                  );
                  final BrowserWalletProtectionStatus protectionStatus =
                      await _vault.getProtectionStatus();
                  if (!mounted) {
                    return;
                  }
                  setState(() {
                    _protectionStatus = protectionStatus;
                    _statusMessage =
                        'Wallet PIN enabled. Future sessions will require unlocking the wallet.';
                    _errorMessage = null;
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } finally {
      pinController.dispose();
      confirmController.dispose();
    }
  }

  Future<void> _showBackupSeedPhrase() async {
    final String? mnemonic = _mnemonic;
    if (mnemonic == null || mnemonic.isEmpty) {
      setState(() {
        _errorMessage =
            'No browser wallet seed phrase is available to back up.';
      });
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Backup Seed Phrase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Store this 24-word phrase offline. Anyone with it can control this wallet.',
              ),
              const SizedBox(height: 12),
              SelectableText(
                mnemonic,
                style: const TextStyle(height: 1.5),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: mnemonic));
                if (!mounted) {
                  return;
                }
                setState(() {
                  _statusMessage = 'Seed phrase copied to the clipboard.';
                });
                Navigator.of(context).pop();
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _promptEnablePasskeyUnlock() async {
    final String? seed = _seed;
    if (seed == null || seed.isEmpty) {
      setState(() {
        _errorMessage = 'Unlock the browser wallet before enrolling a passkey.';
      });
      return;
    }
    if (!_protectionStatus.hasPinProtection) {
      setState(() {
        _errorMessage =
            'Set a 6-digit wallet PIN before enabling passkey unlock.';
      });
      return;
    }

    final TextEditingController pinController = TextEditingController();
    try {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Enable Passkey Unlock'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Confirm the current 6-digit wallet PIN, then approve the browser passkey prompt on this device.',
                ),
                const SizedBox(height: 12),
                _PinEntryField(
                  controller: pinController,
                  label: 'Current wallet PIN',
                ),
                const SizedBox(height: 16),
                _PinPad(
                  onDigitPressed: (String digit) {
                    if (pinController.text.length < 6) {
                      pinController.text = '${pinController.text}$digit';
                    }
                  },
                  onBackspace: () {
                    if (pinController.text.isNotEmpty) {
                      pinController.text = pinController.text.substring(
                        0,
                        pinController.text.length - 1,
                      );
                    }
                  },
                  onClear: pinController.clear,
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );

      if (confirmed != true) {
        return;
      }

      final String pin = pinController.text.trim();
      if (pin.isEmpty) {
        setState(() {
          _errorMessage =
              'Enter the 6-digit wallet PIN before adding a passkey.';
        });
        return;
      }

      setState(() {
        _working = true;
        _errorMessage = null;
        _statusMessage = null;
      });

      await _vault.enablePasskeyUnlock(seed: seed, pin: pin);
      final BrowserWalletProtectionStatus protectionStatus =
          await _vault.getProtectionStatus();
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _protectionStatus = protectionStatus;
        _statusMessage =
            'Passkey unlock enabled for this browser wallet on this device.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      final BrowserWalletProtectionStatus protectionStatus =
          await _vault.getProtectionStatus();
      setState(() {
        _working = false;
        _protectionStatus = protectionStatus;
        if (error is PasskeyPrfUnavailableException) {
          _errorMessage =
              'Passkey unlock is not available on this device/browser because the authenticator does not expose the PRF extension needed for local wallet unlock. Keep using the wallet PIN on this profile.';
        } else {
          _errorMessage = 'Passkey enrollment failed: $error';
        }
      });
    } finally {
      pinController.dispose();
    }
  }

  Future<String> _generateDerivableSeed() async {
    const int maxAttempts = 32;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final String seed = AppSeeds.generateSeed();
      try {
        await AddressDerivation.seedToAddress(seed, 0);
        return seed;
      } catch (_) {
        continue;
      }
    }
    throw StateError(
      'Unable to generate a valid browser wallet seed after $maxAttempts attempts.',
    );
  }

  Future<void> _importWallet() async {
    final String normalized = _mnemonicController.text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
    final List<String> words =
        normalized.isEmpty ? <String>[] : normalized.split(' ');

    if (words.length != 24 || !AppMnemomics.validateMnemonic(words)) {
      setState(() {
        _errorMessage =
            'Enter a valid 24-word BIP39 mnemonic before importing.';
      });
      return;
    }

    await _persistWallet(
      seed: AppMnemomics.mnemonicListToSeed(words),
      profileName: _profileName,
      statusMessage: 'Mnemonic imported into the hosted web wallet.',
      discoverExistingAccounts: true,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _pendingSeed = null;
      _pendingMnemonic = null;
      _showMnemonicVerificationView = false;
      _mnemonicVerificationPrompts = <_MnemonicCheckPrompt>[];
      _mnemonicVerificationAnswers.clear();
      _mnemonicVerificationError = null;
    });
  }

  Future<void> _scanQrForImport() async {
    final String? rawValue = await showBrowserQrScannerDialog(context);
    if (rawValue == null || !mounted) {
      return;
    }

    final String normalized = rawValue.trim();
    final String compactLower =
        normalized.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    if (AppSeeds.isValidSeed(normalized.toUpperCase())) {
      final String mnemonic =
          AppMnemomics.seedToMnemonic(normalized.toUpperCase()).join(' ');
      setState(() {
        _mnemonicController.text = mnemonic;
        _errorMessage = null;
        _statusMessage =
            'Seed QR scanned. The corresponding 24-word mnemonic has been loaded for import.';
      });
      return;
    }

    final List<String> words =
        compactLower.isEmpty ? <String>[] : compactLower.split(' ');
    if (words.length == 24 && AppMnemomics.validateMnemonic(words)) {
      setState(() {
        _mnemonicController.text = words.join(' ');
        _errorMessage = null;
        _statusMessage = 'Mnemonic QR scanned and loaded for import.';
      });
      return;
    }

    setState(() {
      _errorMessage =
          'QR code does not contain a valid 24-word mnemonic or 64-character seed.';
    });
  }

  Future<void> _scanQrForSend() async {
    final String? rawValue = await showBrowserQrScannerDialog(context);
    if (rawValue == null || !mounted) {
      return;
    }

    final String normalized = rawValue.trim();
    final String lower = normalized.toLowerCase();

    try {
      if (lower.startsWith('bis://')) {
        final BisUrl bisUrl = await BisUrl().getInfo(normalized);
        final String destination = bisUrl.address?.trim() ?? '';
        if (!Address(destination).isValid()) {
          throw FormatException(
              'QR payment request does not contain a valid address.');
        }

        setState(() {
          _destinationController.text = destination;
          _amountController.text = bisUrl.amount?.trim() ?? '';
          _operationController.text = bisUrl.operation?.trim() ?? '';
          _openfieldController.text = bisUrl.openfield?.trim() ?? '';
          _sendErrorMessage = null;
          _sendStatusMessage = 'Payment QR scanned and send form prefilled.';
        });
        return;
      }

      if (Address(normalized).isValid()) {
        setState(() {
          _destinationController.text = normalized;
          _sendErrorMessage = null;
          _sendStatusMessage = 'Address QR scanned and destination prefilled.';
        });
        return;
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sendErrorMessage = 'Could not parse payment QR: $error';
      });
      return;
    }

    setState(() {
      _sendErrorMessage =
          'QR code does not contain a valid Bismuth payment request or destination address.';
    });
  }

  Future<void> _persistWallet({
    required String seed,
    required String profileName,
    required String statusMessage,
    bool discoverExistingAccounts = false,
  }) async {
    setState(() {
      _working = true;
      _errorMessage = null;
      _statusMessage = discoverExistingAccounts
          ? 'Scanning deterministic accounts from the imported seed...'
          : null;
    });

    try {
      await _ensureBrowserSecrets();
      await _db.dropAccounts();
      final String primaryAddress =
          await AddressDerivation.seedToAddress(seed, 0);
      final List<Account> accounts = discoverExistingAccounts
          ? await _discoverAccountsForSeed(
              seed,
              profileName: profileName,
              gapLimit: 2,
            )
          : <Account>[
              Account(
                index: 0,
                name: profileName,
                lastAccess: 1,
                selected: true,
                address: primaryAddress,
                balance: '0',
                dragginatorDna: '',
                dragginatorStatus: '',
              ),
            ];

      for (final Account account in accounts) {
        await _db.saveAccount(account);
      }
      await _vault.setSeed(seed);
      await _loadWalletState();

      _mnemonicController.clear();

      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _statusMessage = discoverExistingAccounts
            ? '$statusMessage Recovered ${accounts.length} account${accounts.length == 1 ? '' : 's'} from this seed.'
            : statusMessage;
      });
    } catch (error) {
      setState(() {
        _working = false;
        _errorMessage = 'Wallet setup failed: $error';
      });
    }
  }

  Future<List<Account>> _discoverAccountsForSeed(
    String seed, {
    required String profileName,
    int gapLimit = 2,
    int maxScan = 50,
  }) async {
    final List<Account> discoveredAccounts = <Account>[];
    int consecutiveUnused = 0;

    for (int index = 0; index < maxScan; index++) {
      final String address = await AddressDerivation.seedToAddress(seed, index);
      bool hasUsage = false;
      try {
        hasUsage = await _networkService.addressHasUsage(address);
      } catch (_) {
        hasUsage = false;
      }

      if (hasUsage) {
        consecutiveUnused = 0;
        discoveredAccounts.add(
          Account(
            index: index,
            name: index == 0 ? profileName : 'Account ${index + 1}',
            lastAccess: discoveredAccounts.isEmpty ? 1 : 0,
            selected: discoveredAccounts.isEmpty,
            address: address,
            balance: '0',
            dragginatorDna: '',
            dragginatorStatus: '',
          ),
        );
        continue;
      }

      consecutiveUnused++;
      if (consecutiveUnused >= gapLimit) {
        break;
      }
    }

    if (discoveredAccounts.isNotEmpty) {
      return discoveredAccounts;
    }

    return <Account>[
      Account(
        index: 0,
        name: profileName,
        lastAccess: 1,
        selected: true,
        address: await AddressDerivation.seedToAddress(seed, 0),
        balance: '0',
        dragginatorDna: '',
        dragginatorStatus: '',
      ),
    ];
  }

  Future<void> _ensureBrowserSecrets() async {
    final String encryptionPhrase = await _vault.getEncryptionPhrase();
    if (encryptionPhrase.isEmpty) {
      await _vault.writeEncryptionPhrase(
        '${AppSeeds.generateSeed().substring(0, 32)}:${AppSeeds.generateSeed().substring(0, 8)}',
      );
    }

    final String sessionKey = await _vault.getSessionKey();
    if (sessionKey.isEmpty) {
      await _vault.updateSessionKey();
    }
  }

  Future<void> _resetWallet() async {
    setState(() {
      _working = true;
      _errorMessage = null;
      _statusMessage = null;
    });

    try {
      await _vault.deleteAll();
      await _db.dropAll();
      _mnemonicController.clear();
      await _loadWalletState();

      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _statusMessage =
            'Browser wallet data cleared from this browser profile.';
      });
    } catch (error) {
      setState(() {
        _working = false;
        _errorMessage = 'Failed to reset browser wallet data: $error';
      });
    }
  }

  bool get _apiConnected {
    if (_snapshot == null) {
      return false;
    }
    final DateTime now = DateTime.now();
    if (_networkFailureStartedAt != null &&
        now.difference(_networkFailureStartedAt!) >=
            _networkDisconnectGracePeriod) {
      return false;
    }
    return true;
  }

  Future<void> _refreshNetworkData({bool showActivity = true}) async {
    if (_networkLoading) {
      return;
    }

    final Account? account = _selectedAccount;
    if (account?.address == null || account!.address!.isEmpty) {
      return;
    }

    setState(() {
      _networkLoading = true;
      _showRefreshActivity = showActivity;
    });

    try {
      final BrowserWalletSnapshot snapshot = await _networkService.loadSnapshot(
        address: account.address!,
        currencyCode: _currencyCode,
      );

      if (!mounted) {
        return;
      }

      if (_selectedAccount != null) {
        await _db.updateAccountBalance(
          _selectedAccount!,
          snapshot.balance.balance ?? '0',
        );
      }

      final String seed = _seed ?? '';
      final List<Account> accounts =
          seed.isEmpty ? _accounts : await _db.getAccounts(seed);
      await _refreshAllAccountBalances(accounts);
      final int? selectedIndex = _selectedAccount?.index;
      final Account? updatedSelected = accounts
          .where((Account item) => item.index == selectedIndex)
          .cast<Account?>()
          .firstWhere((Account? item) => item != null,
              orElse: () => _selectedAccount);

      setState(() {
        _accounts = accounts;
        _selectedAccount = updatedSelected;
        _snapshot = snapshot;
        _networkLoading = false;
        _showRefreshActivity = false;
        _networkErrorMessage = null;
        _networkFailureStartedAt = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _networkLoading = false;
        _showRefreshActivity = false;
        _networkErrorMessage = _describeNetworkError(error);
        _networkFailureStartedAt ??= DateTime.now();
      });
    }
  }

  String _describeNetworkError(Object error) {
    final String raw = error.toString();
    if (raw.contains('XMLHttpRequest error')) {
      return 'Live network sync failed: browser CORS blocked the hosted web app from calling the remote HTTP APIs. The Chrome extension can use those endpoints via host permissions, but the PWA needs the APIs to send CORS headers or be exposed through a same-origin reverse proxy.';
    }
    return 'Live network sync failed: $raw';
  }

  Future<void> _refreshAllAccountBalances(List<Account> accounts) async {
    for (final Account account in accounts) {
      final String? address = account.address;
      if (address == null || address.isEmpty) {
        continue;
      }
      try {
        final String balance =
            await _networkService.loadAccountBalance(address);
        account.balance = balance;
        await _db.updateAccountBalance(account, balance);
      } catch (_) {
        continue;
      }
    }
  }

  Future<void> _submitSendTransaction() async {
    final Account? account = _selectedAccount;
    final String destination = _destinationController.text.trim();
    final String amount = _amountController.text.trim();
    final String operation = _operationController.text.trim();
    final String openfield = _openfieldController.text.trim();

    if (account?.address == null || account!.address!.isEmpty) {
      setState(() {
        _sendErrorMessage = 'No active browser wallet account is available.';
      });
      return;
    }
    if (destination.isEmpty) {
      setState(() {
        _sendErrorMessage = 'Destination address is required.';
      });
      return;
    }
    if (!Address(destination).isValid()) {
      setState(() {
        _sendErrorMessage = 'Destination address format looks invalid.';
      });
      return;
    }
    if ((double.tryParse(amount) ?? 0) <= 0) {
      setState(() {
        _sendErrorMessage = 'Enter a valid amount greater than zero.';
      });
      return;
    }
    final double amountValue = double.tryParse(amount) ?? 0;
    final double estimatedFee = _estimateFees(
      openfield: openfield,
      operation: operation,
    );
    final double balanceValue =
        double.tryParse(_snapshot?.balance.balance ?? '0') ?? 0;
    if (balanceValue > 0 && amountValue + estimatedFee > balanceValue) {
      setState(() {
        _sendErrorMessage =
            'Amount plus estimated fee exceeds the current wallet balance.';
      });
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Transaction'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Send $amount BIS to:'),
              const SizedBox(height: 8),
              SelectableText(
                destination,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text('Estimated fee: ${estimatedFee.toStringAsFixed(6)} BIS'),
              if (operation.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text('Operation: $operation'),
              ],
              if (openfield.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  'Openfield:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  openfield,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _working = true;
      _sendStatusMessage = null;
      _sendErrorMessage = null;
      _lastSubmitResult = null;
    });

    try {
      final String seed = _seed ?? await _vault.getSeed();
      if (seed.isEmpty) {
        throw StateError('Seed is unavailable in the browser vault.');
      }

      final int index = account.index ?? 0;
      final String publicKeyBase64 =
          await AddressDerivation.seedToPublicKeyBase64(seed, index);
      final String privateKeyHex =
          await AddressDerivation.seedToPrivateKey(seed, index);
      final BrowserWalletSubmitResult result =
          await _networkService.submitTransaction(
        address: account.address!,
        destination: destination,
        amount: amount,
        operation: operation.isEmpty ? '' : removeDiacritics(operation),
        openfield: openfield,
        publicKeyBase64: publicKeyBase64,
        privateKeyHex: privateKeyHex,
      );

      if (!mounted) {
        return;
      }

      if (result.success) {
        _amountController.clear();
        _operationController.clear();
        _openfieldController.clear();
        await _refreshNetworkData();
        setState(() {
          _working = false;
          _sendStatusMessage =
              'Transaction submitted to the network mempool successfully.';
          _lastSubmitResult = result;
        });
      } else {
        setState(() {
          _working = false;
          _sendErrorMessage = 'Transaction rejected: ${result.message}';
          _lastSubmitResult = result;
        });
      }
    } catch (error) {
      setState(() {
        _working = false;
        _sendErrorMessage = 'Transaction submission failed: $error';
      });
    }
  }

  Future<void> _submitTokenSendTransaction() async {
    final Account? account = _selectedAccount;
    final String tokenName = _selectedTokenName ?? '';
    final String destination = _destinationController.text.trim();
    final String tokenAmount = _tokenAmountController.text.trim();
    final String message = _tokenMessageController.text.trim();

    if (account?.address == null || account!.address!.isEmpty) {
      setState(() {
        _sendErrorMessage = 'No active browser wallet account is available.';
      });
      return;
    }
    if (tokenName.isEmpty) {
      setState(() {
        _sendErrorMessage = 'No token is selected for this transfer.';
      });
      return;
    }
    if (destination.isEmpty) {
      setState(() {
        _sendErrorMessage = 'Enter a destination address first.';
      });
      return;
    }
    if (!Address(destination).isValid()) {
      setState(() {
        _sendErrorMessage = 'Destination address format is invalid.';
      });
      return;
    }
    if (tokenAmount.isEmpty) {
      setState(() {
        _sendErrorMessage = 'Enter a token amount first.';
      });
      return;
    }

    final int requestedAmount = int.tryParse(tokenAmount) ?? -1;
    if (requestedAmount <= 0) {
      setState(() {
        _sendErrorMessage = 'Token amount must be a positive integer.';
      });
      return;
    }

    final BisToken? selectedToken =
        _snapshot?.tokens.cast<BisToken?>().firstWhere(
              (BisToken? token) => token?.tokenName == tokenName,
              orElse: () => null,
            );
    final int availableAmount = selectedToken?.tokensQuantity ?? 0;
    if (availableAmount > 0 && requestedAmount > availableAmount) {
      setState(() {
        _sendErrorMessage =
            'Token amount exceeds the current token balance for this account.';
      });
      return;
    }

    final String messagePayload = message.isEmpty
        ? ''
        : ':${json.encode(<String, String>{'message': message})}';
    final String openfield = '$tokenName:$tokenAmount$messagePayload';

    setState(() {
      _working = true;
      _sendStatusMessage = null;
      _sendErrorMessage = null;
      _lastSubmitResult = null;
      _lastSubmitAmountLabel = null;
    });

    try {
      final String seed = _seed ?? await _vault.getSeed();
      if (seed.isEmpty) {
        throw StateError('Seed is unavailable in the browser vault.');
      }

      final int index = account.index ?? 0;
      final String publicKeyBase64 =
          await AddressDerivation.seedToPublicKeyBase64(seed, index);
      final String privateKeyHex =
          await AddressDerivation.seedToPrivateKey(seed, index);
      final BrowserWalletSubmitResult result =
          await _networkService.submitTransaction(
        address: account.address!,
        destination: destination,
        amount: '0',
        operation: 'token:transfer',
        openfield: openfield,
        publicKeyBase64: publicKeyBase64,
        privateKeyHex: privateKeyHex,
      );

      if (!mounted) {
        return;
      }

      if (result.success) {
        _tokenAmountController.clear();
        _tokenMessageController.clear();
        await _refreshNetworkData();
        setState(() {
          _working = false;
          _sendStatusMessage = 'Token transfer sent successfully.';
          _lastSubmitResult = result;
          _lastSubmitAmountLabel = '$tokenAmount $tokenName';
        });
      } else {
        setState(() {
          _working = false;
          _sendErrorMessage = 'Token transfer rejected: ${result.message}';
          _lastSubmitResult = result;
        });
      }
    } catch (error) {
      setState(() {
        _working = false;
        _sendErrorMessage = 'Token transfer submission failed: $error';
      });
    }
  }

  double _estimateFees({
    required String openfield,
    required String operation,
  }) {
    const double feeBase = 0.01;
    double fees = feeBase + (openfield.length / 100000);
    if (openfield.startsWith('alias=')) {
      fees += 1;
    }
    if (operation == 'token:issue') {
      fees += 10;
    }
    if (operation == 'alias:register') {
      fees += 1;
    }
    return fees;
  }

  void _syncBannerTimer({
    required String? currentMessage,
    required String? trackedMessage,
    required Timer? timer,
    required String? Function() getTrackedMessage,
    required void Function(String?) setTrackedMessage,
    required void Function(Timer?) setTimer,
    required void Function() clearMessage,
  }) {
    if (currentMessage == null) {
      timer?.cancel();
      setTimer(null);
      if (trackedMessage != null) {
        setTrackedMessage(null);
      }
      return;
    }

    if (trackedMessage == currentMessage && timer != null) {
      return;
    }

    timer?.cancel();
    setTrackedMessage(currentMessage);
    setTimer(
      Timer(_bannerMessageDuration, () {
        if (!mounted || currentMessage != getTrackedMessage()) {
          return;
        }
        setState(clearMessage);
      }),
    );
  }

  void _syncBannerTimers() {
    _syncBannerTimer(
      currentMessage: _statusMessage,
      trackedMessage: _trackedStatusMessage,
      timer: _statusMessageTimer,
      getTrackedMessage: () => _trackedStatusMessage,
      setTrackedMessage: (String? value) => _trackedStatusMessage = value,
      setTimer: (Timer? timer) => _statusMessageTimer = timer,
      clearMessage: () {
        _statusMessage = null;
        _trackedStatusMessage = null;
        _statusMessageTimer?.cancel();
        _statusMessageTimer = null;
      },
    );
    _syncBannerTimer(
      currentMessage: _errorMessage,
      trackedMessage: _trackedErrorMessage,
      timer: _errorMessageTimer,
      getTrackedMessage: () => _trackedErrorMessage,
      setTrackedMessage: (String? value) => _trackedErrorMessage = value,
      setTimer: (Timer? timer) => _errorMessageTimer = timer,
      clearMessage: () {
        _errorMessage = null;
        _trackedErrorMessage = null;
        _errorMessageTimer?.cancel();
        _errorMessageTimer = null;
      },
    );
    _syncBannerTimer(
      currentMessage: _sendStatusMessage,
      trackedMessage: _trackedSendStatusMessage,
      timer: _sendStatusMessageTimer,
      getTrackedMessage: () => _trackedSendStatusMessage,
      setTrackedMessage: (String? value) => _trackedSendStatusMessage = value,
      setTimer: (Timer? timer) => _sendStatusMessageTimer = timer,
      clearMessage: () {
        _sendStatusMessage = null;
        _trackedSendStatusMessage = null;
        _sendStatusMessageTimer?.cancel();
        _sendStatusMessageTimer = null;
      },
    );
    _syncBannerTimer(
      currentMessage: _sendErrorMessage,
      trackedMessage: _trackedSendErrorMessage,
      timer: _sendErrorMessageTimer,
      getTrackedMessage: () => _trackedSendErrorMessage,
      setTrackedMessage: (String? value) => _trackedSendErrorMessage = value,
      setTimer: (Timer? timer) => _sendErrorMessageTimer = timer,
      clearMessage: () {
        _sendErrorMessage = null;
        _trackedSendErrorMessage = null;
        _sendErrorMessageTimer?.cancel();
        _sendErrorMessageTimer = null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _syncBannerTimers();
    final bool useFullPageView = true;
    final Widget content = _walletLocked
        ? _LockedWalletView(shell: this)
        : _showSettingsView
            ? _SettingsView(shell: this)
            : useFullPageView
                ? _OptionsView(shell: this)
                : _PopupView(shell: this);
    final Widget localizedContent = Localizations.override(
      context: context,
      locale: _localeForLanguageCode(_languageCode),
      child: Builder(
        builder: (BuildContext context) {
          if (useFullPageView) {
            return Scaffold(
              body: SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: content,
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 600),
                        child: content,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );

    return localizedContent;
  }
}

class _PopupView extends StatelessWidget {
  final _ExtensionShellState shell;

  const _PopupView({required this.shell});

  @override
  Widget build(BuildContext context) {
    final _Palette palette = shell.widget.palette;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double horizontalPadding = screenWidth <= 360 ? 10 : 18;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[palette.background, const Color(0xFF0D1622)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          14,
          horizontalPadding,
          18,
        ),
        child: shell._loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (!shell._hasWallet)
                    Row(
                      children: <Widget>[
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              shell._openSettingsView(fromLabel: 'Popup'),
                          icon: const Icon(Icons.settings_outlined),
                          tooltip: 'Settings',
                        ),
                      ],
                    ),
                  if (!shell._hasWallet) ...<Widget>[
                    _HeaderCard(
                      palette: palette,
                      profileName: shell._profileName,
                      network: shell._network,
                      launchCount: shell._launchCount,
                      onOpenOptions:
                          shell._isOptionsView ? null : shell._openOptionsPage,
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (shell._hasWallet)
                    Expanded(
                      child: SingleChildScrollView(
                        child: shell._showAccountDetails
                            ? _AccountDetailPanel(
                                palette: palette,
                                shell: shell,
                                compact: true,
                              )
                            : _WalletOverviewPanel(
                                palette: palette,
                                shell: shell,
                                compact: true,
                              ),
                      ),
                    )
                  else
                    _EmptyWalletCard(
                      palette: palette,
                      working: shell._working,
                      onCreateWallet: shell._createWallet,
                      onOpenOptions: shell._openOptionsPage,
                    ),
                  if (!shell._hasWallet) ...<Widget>[
                    const SizedBox(height: 14),
                    _StatusCard(
                      palette: palette,
                      noticeAcknowledged: shell._noticeAcknowledged,
                      hasWallet: shell._hasWallet,
                    ),
                    const SizedBox(height: 14),
                    _ActionCard(
                      palette: palette,
                      hasWallet: shell._hasWallet,
                      isOptionsView: shell._isOptionsView,
                      onManageWallet: shell._openWalletManager,
                    ),
                  ],
                  if (shell._statusMessage != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _BannerCard(
                      palette: palette,
                      color: palette.primary,
                      message: shell._statusMessage!,
                    ),
                  ],
                  if (shell._errorMessage != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _BannerCard(
                      palette: palette,
                      color: const Color(0xFFFF8A80),
                      message: shell._errorMessage!,
                    ),
                  ],
                  if (shell._networkErrorMessage != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _BannerCard(
                      palette: palette,
                      color: const Color(0xFFF8C15D),
                      message: shell._networkErrorMessage!,
                    ),
                  ],
                  if (shell._sendStatusMessage != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _BannerCard(
                      palette: palette,
                      color: palette.primary,
                      message: shell._sendStatusMessage!,
                    ),
                  ],
                  if (shell._sendErrorMessage != null) ...<Widget>[
                    const SizedBox(height: 12),
                    _BannerCard(
                      palette: palette,
                      color: const Color(0xFFFF8A80),
                      message: shell._sendErrorMessage!,
                    ),
                  ],
                  if (!shell._hasWallet) ...<Widget>[
                    const Spacer(),
                    Text(
                      'This hosted wallet is wired for browser-safe seed storage. The next migration step is bringing transaction, signing, and network workflows into the web runtime.',
                      style: TextStyle(
                        color: palette.muted,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _OptionsView extends StatelessWidget {
  final _ExtensionShellState shell;

  const _OptionsView({required this.shell});

  @override
  Widget build(BuildContext context) {
    final _Palette palette = shell.widget.palette;
    final bool showFirstOpenLayout = !shell._hasWallet;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: showFirstOpenLayout
          ? _FirstOpenOptionsLayout(shell: shell, palette: palette)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: SizedBox(
                          key: shell._browserWalletSectionKey,
                          child: shell._loading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 28),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                )
                              : shell._showAccountDetails
                                  ? _AccountDetailPanel(
                                      palette: palette,
                                      shell: shell,
                                      compact: false,
                                    )
                                  : _WalletOverviewPanel(
                                      palette: palette,
                                      shell: shell,
                                      compact: false,
                                    ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (shell._statusMessage != null) ...<Widget>[
                  const SizedBox(height: 18),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _BannerCard(
                        palette: palette,
                        color: palette.primary,
                        message: shell._statusMessage!,
                      ),
                    ),
                  ),
                ],
                if (shell._errorMessage != null) ...<Widget>[
                  const SizedBox(height: 18),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _BannerCard(
                        palette: palette,
                        color: const Color(0xFFFF8A80),
                        message: shell._errorMessage!,
                      ),
                    ),
                  ),
                ],
                if (shell._networkErrorMessage != null) ...<Widget>[
                  const SizedBox(height: 18),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _BannerCard(
                        palette: palette,
                        color: const Color(0xFFF8C15D),
                        message: shell._networkErrorMessage!,
                      ),
                    ),
                  ),
                ],
                if (shell._sendStatusMessage != null) ...<Widget>[
                  const SizedBox(height: 18),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _BannerCard(
                        palette: palette,
                        color: palette.primary,
                        message: shell._sendStatusMessage!,
                      ),
                    ),
                  ),
                ],
                if (shell._sendErrorMessage != null) ...<Widget>[
                  const SizedBox(height: 18),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 760),
                      child: _BannerCard(
                        palette: palette,
                        color: const Color(0xFFFF8A80),
                        message: shell._sendErrorMessage!,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _FirstOpenOptionsLayout extends StatelessWidget {
  final _ExtensionShellState shell;
  final _Palette palette;

  const _FirstOpenOptionsLayout({
    required this.shell,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 92,
            height: 92,
            child: SvgPicture.asset(
              'assets/bis_logo_web.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _SectionCard(
              palette: palette,
              title: 'My Bismuth Wallet',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Import 24-word mnemonic',
                          style: TextStyle(
                            color: palette.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: shell._mnemonicController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'abandon ability able ...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: FilledButton.icon(
                          onPressed:
                              shell._working ? null : shell._createWallet,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Create Wallet'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              shell._working ? null : shell._importWallet,
                          icon: const Icon(Icons.download_outlined),
                          label: const Text('Import Wallet'),
                        ),
                      ),
                    ],
                  ),
                  if (shell._pendingSeed != null &&
                      shell._pendingMnemonic != null) ...<Widget>[
                    const SizedBox(height: 18),
                    shell._showMnemonicVerificationView
                        ? _MnemonicVerificationView(
                            palette: palette,
                            prompts: shell._mnemonicVerificationPrompts,
                            answers: shell._mnemonicVerificationAnswers,
                            errorText: shell._mnemonicVerificationError,
                            working: shell._working,
                            onBack: shell._returnToPendingWalletPreview,
                            onAnswerSelected:
                                shell._selectMnemonicVerificationAnswer,
                            onConfirm: shell._submitMnemonicVerification,
                          )
                        : _PendingWalletPreview(
                            palette: palette,
                            seed: shell._pendingSeed!,
                            mnemonic: shell._pendingMnemonic!,
                            working: shell._working,
                            onCopySeed: () => shell._copyPendingWalletSecret(
                              shell._pendingSeed!,
                              'Generated seed',
                            ),
                            onCopyMnemonic: () =>
                                shell._copyPendingWalletSecret(
                              shell._pendingMnemonic!,
                              'Generated mnemonic',
                            ),
                            onDiscard: shell._discardPendingWallet,
                            onConfirm:
                                shell._confirmPendingWalletWithVerification,
                          ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: shell._working ? null : shell._scanQrForImport,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Import QR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (shell._statusMessage != null) ...<Widget>[
          const SizedBox(height: 18),
          _BannerCard(
            palette: palette,
            color: palette.primary,
            message: shell._statusMessage!,
          ),
        ],
        if (shell._errorMessage != null) ...<Widget>[
          const SizedBox(height: 18),
          _BannerCard(
            palette: palette,
            color: const Color(0xFFFF8A80),
            message: shell._errorMessage!,
          ),
        ],
        if (shell._networkErrorMessage != null) ...<Widget>[
          const SizedBox(height: 18),
          _BannerCard(
            palette: palette,
            color: const Color(0xFFF8C15D),
            message: shell._networkErrorMessage!,
          ),
        ],
      ],
    );
  }
}

class _SettingsView extends StatelessWidget {
  final _ExtensionShellState shell;

  const _SettingsView({required this.shell});

  @override
  Widget build(BuildContext context) {
    final _Palette palette = shell.widget.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: shell._closeSettingsView,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
              TextButton(
                onPressed: shell._closeSettingsView,
                child: Text('Back to ${shell._settingsBackLabel}'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _tr(context, 'settings'),
            style: TextStyle(
              color: palette.text,
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            palette: palette,
            title: 'Network',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (shell._statusMessage != null) ...<Widget>[
                  _BannerCard(
                    palette: palette,
                    color: palette.primary,
                    message: shell._statusMessage!,
                  ),
                  const SizedBox(height: 12),
                ],
                if (shell._errorMessage != null) ...<Widget>[
                  _BannerCard(
                    palette: palette,
                    color: const Color(0xFFFF8A80),
                    message: shell._errorMessage!,
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: shell._customWebsocketEndpointController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Websocket API Endpoint',
                    hintText: 'wss://example.org/api/web-socket/',
                  ),
                ),
                const SizedBox(height: 12),
                if (shell._walletServerConnecting) ...<Widget>[
                  const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: shell._walletServerConnecting
                      ? null
                      : shell._connectCustomWebsocketEndpoint,
                  child: const Text('Connect'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            palette: palette,
            title: 'Preferences',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  initialValue: shell._currencyCode,
                  items: _ExtensionShellState._supportedCurrencies
                      .map(
                        (String currency) => DropdownMenuItem<String>(
                          value: currency,
                          child: Text(currency),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      shell._setCurrency(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: _tr(context, 'currency'),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: shell._languageCode,
                  items: _ExtensionShellState._supportedLanguages.entries
                      .map(
                        (MapEntry<String, String> language) =>
                            DropdownMenuItem<String>(
                          value: language.key,
                          child: Text(language.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      shell._setLanguage(value);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: _tr(context, 'language'),
                  ),
                ),
                const SizedBox(height: 16),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    iconColor: palette.text,
                    collapsedIconColor: palette.text,
                    title: Text(_tr(context, 'security')),
                    children: <Widget>[
                      _StatusRow(
                        label: 'Wallet lock',
                        value: shell._protectionStatus.hasProtectedWallet
                            ? 'Protected'
                            : 'Legacy local storage',
                        valueColor: shell._protectionStatus.hasProtectedWallet
                            ? palette.primary
                            : const Color(0xFFF8C15D),
                      ),
                      const SizedBox(height: 12),
                      _StatusRow(
                        label: 'PIN unlock',
                        value: shell._protectionStatus.hasPinProtection
                            ? 'Enabled'
                            : 'Disabled',
                        valueColor: shell._protectionStatus.hasPinProtection
                            ? palette.secondary
                            : palette.muted,
                      ),
                      const SizedBox(height: 12),
                      if (shell._protectionStatus.hasPinProtection) ...<Widget>[
                        _StatusRow(
                          label: 'PIN attempts',
                          value: shell._protectionStatus.failedPinAttempts
                              .toString(),
                          valueColor: shell._protectionStatus.isPinLocked
                              ? const Color(0xFFFF8A80)
                              : palette.muted,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (shell._protectionStatus.isPinLocked) ...<Widget>[
                        Text(
                          'PIN unlock is temporarily locked due to repeated failed attempts. Wait for the cooldown to expire before trying again.',
                          style: TextStyle(
                            color: palette.muted,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      _StatusRow(
                        label: 'Passkey unlock',
                        value: shell._protectionStatus.hasPasskeyProtection
                            ? 'Enabled'
                            : shell._protectionStatus.canEnrollPasskey
                                ? 'Available'
                                : 'Unsupported',
                        valueColor: shell._protectionStatus.hasPasskeyProtection
                            ? palette.secondary
                            : shell._protectionStatus.canEnrollPasskey
                                ? const Color(0xFFF8C15D)
                                : palette.muted,
                      ),
                      const SizedBox(height: 12),
                      if (shell._protectionStatus.passkeyUnavailableReason !=
                          null) ...<Widget>[
                        Text(
                          shell._protectionStatus.passkeyUnavailableReason!,
                          style: TextStyle(
                            color: palette.muted,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (!shell._protectionStatus.hasPasskeyProtection &&
                          shell._protectionStatus.passkeySupported &&
                          !shell._protectionStatus.passkeyPrfCapable &&
                          shell._protectionStatus.passkeyUnavailableReason ==
                              null) ...<Widget>[
                        Text(
                          'This browser reports passkey support, but not the PRF capability required for local wallet unlock on this profile.',
                          style: TextStyle(
                            color: palette.muted,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: shell._promptWalletPassword,
                          icon: const Icon(Icons.lock_outline),
                          label: Text(_tr(context, 'set_wallet_password')),
                        ),
                      ),
                      if (shell._protectionStatus.canEnrollPasskey) ...<Widget>[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: shell._working
                                ? null
                                : shell._promptEnablePasskeyUnlock,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Enable Passkey Unlock'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (shell._protectionStatus.hasProtectedWallet &&
                          !shell._walletLocked)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed:
                                shell._working ? null : shell._lockWallet,
                            icon: const Icon(Icons.lock_clock_outlined),
                            label: const Text('Lock Wallet Now'),
                          ),
                        ),
                      if (shell._protectionStatus.hasProtectedWallet &&
                          !shell._walletLocked)
                        const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: shell._authMethod,
                        items:
                            _ExtensionShellState._supportedAuthMethods.entries
                                .map(
                                  (MapEntry<String, String> method) =>
                                      DropdownMenuItem<String>(
                                    value: method.key,
                                    child: Text(method.value),
                                  ),
                                )
                                .toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            shell._setAuthMethod(value);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: _tr(context, 'auth_method'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: shell._showBackupSeedPhrase,
                    icon: const Icon(Icons.key_outlined),
                    label: Text(_tr(context, 'backup_seed_phrase')),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: shell._working ? null : shell._resetWallet,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Reset Browser Wallet'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LockedWalletView extends StatelessWidget {
  final _ExtensionShellState shell;

  const _LockedWalletView({required this.shell});

  @override
  Widget build(BuildContext context) {
    final _Palette palette = shell.widget.palette;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: _SectionCard(
            palette: palette,
            title: 'Unlock Browser Wallet',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  shell._protectionStatus.hasPasskeyProtection
                      ? 'This browser wallet is locked. Unlock it with a passkey or the 6-digit wallet PIN.'
                      : 'This browser wallet is locked. Unlock it with the 6-digit wallet PIN.',
                  style: TextStyle(
                    color: palette.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                if (shell._protectionStatus.hasPasskeyProtection) ...<Widget>[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: shell._working
                          ? null
                          : shell._unlockWalletWithPasskey,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Unlock With Passkey'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (shell._protectionStatus.hasPinProtection) ...<Widget>[
                  _PinEntryField(
                    controller: shell._unlockPasswordController,
                    label: '6-digit wallet PIN',
                    enabled: !shell._working,
                    onSubmitted: (_) => shell._unlockWalletWithPin(),
                  ),
                  const SizedBox(height: 12),
                  _PinPad(
                    enabled:
                        !shell._working && !shell._protectionStatus.isPinLocked,
                    onDigitPressed: (String digit) {
                      if (shell._unlockPasswordController.text.length < 6) {
                        shell._unlockPasswordController.text =
                            '${shell._unlockPasswordController.text}$digit';
                      }
                    },
                    onBackspace: () {
                      final String current =
                          shell._unlockPasswordController.text;
                      if (current.isNotEmpty) {
                        shell._unlockPasswordController.text =
                            current.substring(
                          0,
                          current.length - 1,
                        );
                      }
                    },
                    onClear: shell._unlockPasswordController.clear,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          shell._working || shell._protectionStatus.isPinLocked
                              ? null
                              : shell._unlockWalletWithPin,
                      icon: const Icon(Icons.lock_open_outlined),
                      label: const Text('Unlock With PIN'),
                    ),
                  ),
                ],
                if (shell._protectionStatus.isPinLocked) ...<Widget>[
                  const SizedBox(height: 14),
                  _BannerCard(
                    palette: palette,
                    color: const Color(0xFFF8C15D),
                    message:
                        'PIN unlock is temporarily rate-limited after repeated failures. Wait for the cooldown and try again.',
                  ),
                ],
                if (shell._working) ...<Widget>[
                  const SizedBox(height: 14),
                  const LinearProgressIndicator(),
                ],
                if (shell._errorMessage != null) ...<Widget>[
                  const SizedBox(height: 14),
                  _BannerCard(
                    palette: palette,
                    color: const Color(0xFFFF8A80),
                    message: shell._errorMessage!,
                  ),
                ],
                if (shell._statusMessage != null) ...<Widget>[
                  const SizedBox(height: 14),
                  _BannerCard(
                    palette: palette,
                    color: palette.primary,
                    message: shell._statusMessage!,
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  'Recovery still depends on the seed phrase. Passkeys only protect local access on this browser profile.',
                  style: TextStyle(
                    color: palette.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinEntryField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  const _PinEntryField({
    required this.controller,
    required this.label,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, Widget? child) {
        return TextField(
          controller: controller,
          readOnly: true,
          obscureText: true,
          enableInteractiveSelection: false,
          enabled: enabled,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: label,
            counterText: '${value.text.length}/6',
          ),
          onSubmitted: onSubmitted,
        );
      },
    );
  }
}

class _PinPad extends StatelessWidget {
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool enabled;

  const _PinPad({
    required this.onDigitPressed,
    required this.onBackspace,
    required this.onClear,
    this.enabled = true,
  });

  static const List<String> _digits = <String>[
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0',
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _digits.length + 2,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (BuildContext context, int index) {
            if (index == 9) {
              return _PinPadButton(
                label: 'Clear',
                enabled: enabled,
                onPressed: onClear,
              );
            }
            if (index == 11) {
              return _PinPadButton(
                icon: Icons.backspace_outlined,
                enabled: enabled,
                onPressed: onBackspace,
              );
            }
            final String digit = index == 10 ? '0' : _digits[index];
            return _PinPadButton(
              label: digit,
              enabled: enabled,
              fillColor: colorScheme.surfaceContainerHighest.withValues(
                alpha: enabled ? 1 : 0.45,
              ),
              onPressed: () => onDigitPressed(digit),
            );
          },
        ),
      ],
    );
  }
}

class _PinPadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool enabled;
  final Color? fillColor;

  const _PinPadButton({
    this.label,
    this.icon,
    required this.onPressed,
    required this.enabled,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color background =
        fillColor ?? colorScheme.surfaceContainerHigh.withValues(alpha: 0.88);

    return FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: colorScheme.onSurface,
        disabledBackgroundColor: background,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      child: icon != null ? Icon(icon) : Text(label!),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final _Palette palette;
  final String profileName;
  final String network;
  final int launchCount;
  final VoidCallback? onOpenOptions;

  const _HeaderCard({
    required this.palette,
    required this.profileName,
    required this.network,
    required this.launchCount,
    this.onOpenOptions,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      palette: palette,
      title: 'Hosted Wallet',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(9),
                child: SvgPicture.asset(
                  'assets/bis_logo_web.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'My Bismuth Wallet',
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profileName,
                      style: TextStyle(
                        color: palette.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ChipLabel(
                palette: palette,
                label: 'Installable PWA',
                color: palette.primary,
              ),
              _ChipLabel(
                palette: palette,
                label: network == 'mainnet'
                    ? 'Mainnet profile'
                    : 'Testnet profile',
                color: palette.secondary,
                onTap: onOpenOptions,
              ),
              _ChipLabel(
                palette: palette,
                label: 'Launch #$launchCount',
                color: const Color(0xFFF8C15D),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WalletOverviewPanel extends StatelessWidget {
  final _Palette palette;
  final _ExtensionShellState shell;
  final bool compact;

  const _WalletOverviewPanel({
    required this.palette,
    required this.shell,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final Account? selectedAccount = shell._selectedAccount;
    final BrowserWalletSnapshot? snapshot = shell._snapshot;
    final String selectedBalance = NumberUtil.getRawAsUsableString(
      selectedAccount?.balance ?? snapshot?.balance.balance ?? '0',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionCard(
          palette: palette,
          title: 'My Bismuth Wallet',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: compact ? 0.86 : 0.5,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: selectedAccount == null
                          ? null
                          : () => shell._selectAccount(selectedAccount),
                      borderRadius: BorderRadius.circular(20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: compact ? 124 : 108,
                          padding: EdgeInsets.all(compact ? 5 : 9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Color(0xFF7CA9E8),
                                Color(0xFF93B7EF),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                right: -22,
                                top: -14,
                                child: Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.14),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 14,
                                bottom: -52,
                                child: Container(
                                  width: 134,
                                  height: 134,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: compact ? 8 : 2,
                                  right: compact ? 4 : 0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            'Bismuth',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: const Color(0xFF081018),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: compact ? 8 : 12),
                                        Transform.translate(
                                          offset: Offset(
                                            compact ? -5 : 0,
                                            compact ? 5 : 0,
                                          ),
                                          child: SizedBox(
                                            width: compact ? 20 : 24,
                                            height: compact ? 20 : 24,
                                            child: SvgPicture.asset(
                                              'assets/bis_logo_web.svg',
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '$selectedBalance BIS',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: const Color(0xFF081018),
                                        fontSize: compact ? 16 : 19,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    if (selectedAccount?.address?.isNotEmpty ==
                                        true) ...<Widget>[
                                      SizedBox(height: compact ? 2 : 6),
                                      Text(
                                        _shortAddress(
                                            selectedAccount!.address!),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: const Color(0xFF081018)
                                              .withValues(alpha: 0.72),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  _OverviewTabButton(
                    palette: palette,
                    label: 'Wallets',
                    selected: shell._assetTabIndex == 0,
                    onTap: () => shell._setAssetTab(0),
                  ),
                  const SizedBox(width: 12),
                  _OverviewTabButton(
                    palette: palette,
                    label: 'Tokens',
                    selected: shell._assetTabIndex == 1,
                    onTap: () => shell._setAssetTab(1),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: shell._working ? null : shell._addDerivedAccount,
                    child: const Text('Add new'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: shell._assetTabIndex == 0
                    ? _WalletAccountsList(
                        key: const ValueKey<String>('wallets'),
                        palette: palette,
                        accounts: shell._accounts,
                        selectedIndex: selectedAccount?.index,
                        onSelectAccount: shell._selectAccount,
                      )
                    : _WalletTokensList(
                        key: const ValueKey<String>('tokens'),
                        palette: palette,
                        account: selectedAccount,
                        snapshot: snapshot,
                        onSelectToken: shell._openTokenDetail,
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountDetailPanel extends StatelessWidget {
  final _Palette palette;
  final _ExtensionShellState shell;
  final bool compact;

  const _AccountDetailPanel({
    required this.palette,
    required this.shell,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final Account? account = shell._selectedAccount;
    final bool apiConnected = shell._apiConnected;
    if (account == null) {
      return _SectionCard(
        palette: palette,
        title: 'Browser Wallet',
        child: Text(
          'No browser wallet account is selected yet.',
          style: TextStyle(
            color: palette.muted,
            fontSize: 13,
            height: 1.45,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            OutlinedButton.icon(
              onPressed: shell._showOverviewHome,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Wallets'),
            ),
            Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 2, right: 6),
                  child: _ApiStatusDot(
                    color: apiConnected
                        ? const Color(0xFF9DD852)
                        : const Color(0xFFE45858),
                    tooltip: apiConnected
                        ? 'API connection established'
                        : 'No API connection established',
                  ),
                ),
                IconButton(
                  onPressed: () => shell._openSettingsView(fromLabel: 'Wallet'),
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: 'Settings',
                  style: IconButton.styleFrom(
                    backgroundColor: palette.surfaceAlt,
                    foregroundColor: palette.text,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SelectedAccountHeroCard(
          palette: palette,
          account: account,
          snapshot: shell._snapshot,
          networkLoading: shell._networkLoading,
          showRefreshActivity: shell._showRefreshActivity,
          apiConnected: apiConnected,
          onRefresh: shell._refreshNetworkData,
          onOpenSettings: () => shell._openSettingsView(fromLabel: 'Wallet'),
          onReturnToTransactions: shell._returnToAccountTransactions,
          selectedTokenName: shell._selectedTokenName,
          onRenameAccount: shell._promptRenameSelectedAccount,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _OverviewTabButton(
              palette: palette,
              label: 'Send',
              selected: shell._accountDetailViewIndex == 1 ||
                  shell._accountDetailViewIndex == 4,
              onTap: shell._selectedTokenName != null
                  ? shell._setTokenSendView
                  : () => shell._setAccountDetailView(1),
            ),
            _OverviewTabButton(
              palette: palette,
              label: 'Receive',
              selected: shell._accountDetailViewIndex == 2,
              onTap: () => shell._setAccountDetailView(2),
            ),
            _OverviewTabButton(
              palette: palette,
              label: 'Tokens',
              selected: shell._accountDetailViewIndex == 3,
              onTap: shell._selectedTokenName != null
                  ? shell._showTokenBalances
                  : () => shell._setAccountDetailView(3),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _SectionCard(
          palette: palette,
          title: _detailSectionTitle(
            shell._accountDetailViewIndex,
            selectedTokenName: shell._selectedTokenName,
          ),
          child: _DetailContentSwitch(
            palette: palette,
            shell: shell,
            account: account,
          ),
        ),
      ],
    );
  }

  String _detailSectionTitle(int index, {String? selectedTokenName}) {
    switch (index) {
      case 1:
        return 'Send';
      case 4:
        return 'Send';
      case 2:
        return 'Receive';
      case 3:
        return selectedTokenName == null ? 'Tokens' : 'Transaction History';
      case 0:
      default:
        return 'Transaction History';
    }
  }
}

class _ApiStatusDot extends StatelessWidget {
  final Color color;
  final String tooltip;

  const _ApiStatusDot({
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedAccountHeroCard extends StatelessWidget {
  final _Palette palette;
  final Account account;
  final BrowserWalletSnapshot? snapshot;
  final bool networkLoading;
  final bool showRefreshActivity;
  final bool apiConnected;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSettings;
  final VoidCallback onReturnToTransactions;
  final String? selectedTokenName;
  final Future<void> Function() onRenameAccount;

  const _SelectedAccountHeroCard({
    required this.palette,
    required this.account,
    required this.snapshot,
    required this.networkLoading,
    required this.showRefreshActivity,
    required this.apiConnected,
    required this.onRefresh,
    required this.onOpenSettings,
    required this.onReturnToTransactions,
    required this.selectedTokenName,
    required this.onRenameAccount,
  });

  @override
  Widget build(BuildContext context) {
    final Account account = this.account;
    final BrowserWalletSnapshot? snapshot = this.snapshot;
    final String? selectedTokenName = this.selectedTokenName;
    final String balanceRaw =
        snapshot?.balance.balance ?? account.balance ?? '0';
    final String balanceDisplay = NumberUtil.getRawAsUsableString(balanceRaw);
    final bool isTokenHero = selectedTokenName != null;
    final BisToken? selectedToken = selectedTokenName == null
        ? null
        : snapshot?.tokens.cast<BisToken?>().firstWhere(
              (BisToken? token) => token?.tokenName == selectedTokenName,
              orElse: () => null,
            );
    final String heroTitle = '${selectedTokenName ?? 'Bismuth'} balance';
    final String heroAmount = selectedToken == null
        ? '$balanceDisplay BIS'
        : '${selectedToken.tokensQuantity ?? 0} ${selectedToken.tokenName}';
    final double localValue = snapshot == null
        ? 0
        : double.parse(balanceRaw) * snapshot.localCurrencyPrice;
    final String currencyCode = snapshot?.currencyCode ?? 'USD';
    final int transactionCount = snapshot?.transactions.length ?? 0;
    final int tokenTransactionCount = selectedTokenName == null
        ? 0
        : snapshot?.tokenTransactions
                .where((BrowserWalletTokenTransaction transaction) =>
                    transaction.tokenName == selectedTokenName)
                .length ??
            0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isTokenHero
                ? const <Color>[
                    Color(0xFFEAAAF7),
                    Color(0xFFF2C7FA),
                  ]
                : const <Color>[
                    Color(0xFF7CA9E8),
                    Color(0xFF93B7EF),
                  ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              right: -58,
              top: -52,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -36,
              bottom: -132,
              child: Container(
                width: 312,
                height: 312,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        heroTitle,
                        style: const TextStyle(
                          color: Color(0xFF081018),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: showRefreshActivity ? null : onRefresh,
                      icon: showRefreshActivity
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      color: const Color(0xFF081018),
                      tooltip: 'Refresh live data',
                    ),
                    const SizedBox(width: 6),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onReturnToTransactions,
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          width: 32,
                          height: 32,
                          child: SvgPicture.asset(
                            'assets/bis_logo_web.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  heroAmount,
                  style: const TextStyle(
                    color: Color(0xFF081018),
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot == null
                      ? 'Waiting for first network sync'
                      : selectedToken == null
                          ? 'Approx. ${localValue.toStringAsFixed(6)} $currencyCode • $transactionCount recent tx'
                          : '$tokenTransactionCount token tx on this account',
                  style: TextStyle(
                    color: const Color(0xFF081018).withValues(alpha: 0.72),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: SelectableText(
                        account.address ?? '',
                        style: TextStyle(
                          color:
                              const Color(0xFF081018).withValues(alpha: 0.82),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: IconButton(
                        onPressed: account.address?.isEmpty == false
                            ? () async {
                                await Clipboard.setData(
                                  ClipboardData(text: account.address ?? ''),
                                );
                              }
                            : null,
                        icon: const Icon(Icons.copy_rounded),
                        iconSize: 18,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        color: const Color(0xFF081018),
                        tooltip: 'Copy address',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    _AccountMetaChip(
                      label: 'Account label',
                      value: account.name ?? 'Account',
                      onTap: onRenameAccount,
                    ),
                    _AccountMetaChip(
                      label: 'Index',
                      value: '${account.index ?? 0}',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailContentSwitch extends StatelessWidget {
  final _Palette palette;
  final _ExtensionShellState shell;
  final Account account;

  const _DetailContentSwitch({
    required this.palette,
    required this.shell,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    switch (shell._accountDetailViewIndex) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (shell._lastSubmitResult == null)
              _SendTransactionCard(
                palette: palette,
                destinationController: shell._destinationController,
                amountController: shell._amountController,
                operationController: shell._operationController,
                openfieldController: shell._openfieldController,
                working: shell._working,
                estimatedFee: shell._estimateFees(
                  openfield: shell._openfieldController.text.trim(),
                  operation: shell._operationController.text.trim(),
                ),
                onScanQr: shell._scanQrForSend,
                onSubmit: shell._submitSendTransaction,
              ),
            if (shell._lastSubmitResult != null) ...<Widget>[
              const SizedBox(height: 18),
              _SubmitResultCard(
                palette: palette,
                result: shell._lastSubmitResult!,
                amountLabel: shell._lastSubmitAmountLabel,
                transactions: shell._lastSubmitAmountLabel == null
                    ? shell._snapshot?.transactions ??
                        const <AddressTxsResponseResult>[]
                    : const <AddressTxsResponseResult>[],
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: shell._returnToAccountTransactions,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Return to Account'),
                ),
              ),
            ],
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (shell._lastSubmitResult == null)
              _TokenSendTransactionCard(
                palette: palette,
                tokenName: shell._selectedTokenName ?? '',
                destinationController: shell._destinationController,
                amountController: shell._tokenAmountController,
                messageController: shell._tokenMessageController,
                working: shell._working,
                onSubmit: shell._submitTokenSendTransaction,
              ),
            if (shell._lastSubmitResult != null) ...<Widget>[
              if (shell._lastSubmitResult == null) const SizedBox(height: 18),
              _SubmitResultCard(
                palette: palette,
                result: shell._lastSubmitResult!,
                amountLabel: shell._lastSubmitAmountLabel,
                transactions: const <AddressTxsResponseResult>[],
              ),
              if (shell._selectedTokenName != null) ...<Widget>[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: shell._returnToSelectedTokenTransactions,
                    icon: const Icon(Icons.arrow_back),
                    label: Text('Return to ${shell._selectedTokenName}'),
                  ),
                ),
              ],
            ],
          ],
        );
      case 2:
        return _ReceiveAccountCard(
          palette: palette,
          address: account.address ?? '',
          onCopy: shell._copySelectedAccountAddress,
        );
      case 3:
        return shell._selectedTokenName == null
            ? _WalletTokensList(
                palette: palette,
                account: account,
                snapshot: shell._snapshot,
                onSelectToken: shell._selectToken,
                onBackToTransactions: shell._returnToAccountTransactions,
              )
            : _TokenTransactionsCard(
                palette: palette,
                account: account,
                tokenName: shell._selectedTokenName!,
                transactions: shell._snapshot?.tokenTransactions ??
                    const <BrowserWalletTokenTransaction>[],
                visibleCount: shell._visibleTokenTransactions,
                onBackToTokens: shell._showTokenBalances,
                onShowMore: shell._showMoreTokenTransactions,
                onShowLess: shell._showLessTokenTransactions,
              );
      case 0:
      default:
        return _RecentTransactionsCard(
          palette: palette,
          transactions: shell._snapshot?.transactions ??
              const <AddressTxsResponseResult>[],
          visibleCount: shell._visibleBisTransactions,
          onShowMore: shell._showMoreBisTransactions,
          onShowLess: shell._showLessBisTransactions,
        );
    }
  }
}

class _ReceiveAccountCard extends StatelessWidget {
  final _Palette palette;
  final String address;
  final Future<void> Function() onCopy;

  const _ReceiveAccountCard({
    required this.palette,
    required this.address,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: CustomPaint(
              size: const Size.square(220),
              painter: QrPainter(
                data: address,
                version: 6,
                gapless: false,
                errorCorrectionLevel: QrErrorCorrectLevel.Q,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF081018),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF081018),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: SelectableText(
                  address,
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: onCopy,
                icon: const Icon(Icons.copy_all_outlined),
                tooltip: 'Copy address',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccountMetaChip extends StatelessWidget {
  final String label;
  final String value;
  final Future<void> Function()? onTap;

  const _AccountMetaChip({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: TextStyle(
                  color: const Color(0xFF081018).withValues(alpha: 0.64),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onTap != null) ...<Widget>[
                const SizedBox(width: 6),
                Icon(
                  Icons.edit_outlined,
                  size: 12,
                  color: const Color(0xFF081018).withValues(alpha: 0.6),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF081018),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: content,
      ),
    );
  }
}

class _OverviewTabButton extends StatelessWidget {
  final _Palette palette;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OverviewTabButton({
    required this.palette,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? palette.primary.withValues(alpha: 0.18)
              : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? palette.primary.withValues(alpha: 0.5)
                : Colors.white10,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? palette.primary : palette.text,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _WalletAccountsList extends StatelessWidget {
  final _Palette palette;
  final List<Account> accounts;
  final int? selectedIndex;
  final Future<void> Function(Account account) onSelectAccount;

  const _WalletAccountsList({
    super.key,
    required this.palette,
    required this.accounts,
    required this.selectedIndex,
    required this.onSelectAccount,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return Text(
        'No deterministic accounts have been derived yet.',
        style: TextStyle(
          color: palette.muted,
          fontSize: 13,
          height: 1.45,
        ),
      );
    }

    return Column(
      children: accounts.map((Account account) {
        final bool selected = account.index == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(bottom: account == accounts.last ? 0 : 12),
          child: _AccountListItem(
            palette: palette,
            account: account,
            selected: selected,
            onTap: () => onSelectAccount(account),
          ),
        );
      }).toList(),
    );
  }
}

class _AccountListItem extends StatelessWidget {
  final _Palette palette;
  final Account account;
  final bool selected;
  final VoidCallback onTap;

  const _AccountListItem({
    required this.palette,
    required this.account,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String balance =
        NumberUtil.getRawAsUsableString(account.balance ?? '0');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected
                ? palette.primary.withValues(alpha: 0.08)
                : const Color(0xFFF4F7FB).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? palette.primary.withValues(alpha: 0.45)
                  : Colors.white10,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(7),
                child: SvgPicture.asset(
                  'assets/bis_logo_web.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      account.address == null || account.address!.isEmpty
                          ? account.name ?? 'Account'
                          : _shortAddress(account.address!),
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${account.name ?? 'Account'} • $balance BIS',
                      style: TextStyle(
                        color: palette.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: selected ? palette.primary : palette.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TokenSendTransactionCard extends StatelessWidget {
  final _Palette palette;
  final String tokenName;
  final TextEditingController destinationController;
  final TextEditingController amountController;
  final TextEditingController messageController;
  final bool working;
  final Future<void> Function() onSubmit;

  const _TokenSendTransactionCard({
    required this.palette,
    required this.tokenName,
    required this.destinationController,
    required this.amountController,
    required this.messageController,
    required this.working,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Send $tokenName',
            style: TextStyle(
              color: palette.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: destinationController,
            decoration: InputDecoration(
              labelText: _tr(context, 'address_hint'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: false,
            ),
            decoration: InputDecoration(
              labelText: 'Amount ($tokenName)',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Optional message',
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Operation is automatically set to token:transfer and the openfield is generated for you.',
            style: TextStyle(
              color: palette.muted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: working ? null : onSubmit,
              icon: working
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: const Text('Send'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletTokensList extends StatelessWidget {
  final _Palette palette;
  final Account? account;
  final BrowserWalletSnapshot? snapshot;
  final void Function(String tokenName)? onSelectToken;
  final VoidCallback? onBackToTransactions;

  const _WalletTokensList({
    super.key,
    required this.palette,
    required this.account,
    required this.snapshot,
    this.onSelectToken,
    this.onBackToTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final List<BisToken> tokens = snapshot?.tokens ?? const <BisToken>[];
    if (snapshot == null) {
      return Text(
        'Loading token balances for the selected account...',
        style: TextStyle(
          color: palette.muted,
          fontSize: 13,
          height: 1.45,
        ),
      );
    }

    if (tokens.isEmpty) {
      return Text(
        'No token balances were found for ${_shortAddress(account?.address ?? 'this account')} yet.',
        style: TextStyle(
          color: palette.muted,
          fontSize: 13,
          height: 1.45,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (onBackToTransactions != null) ...<Widget>[
          TextButton.icon(
            onPressed: onBackToTransactions,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Transactions'),
            style: TextButton.styleFrom(
              foregroundColor: palette.primary,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          'Token balances for ${_shortAddress(account?.address ?? '')}',
          style: TextStyle(
            color: palette.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...tokens.map((BisToken token) {
          final String tokenName = token.tokenName?.trim().isNotEmpty == true
              ? token.tokenName!.trim()
              : 'Token';
          final String quantity = token.tokensQuantity?.toString() ?? '0';
          return Padding(
            padding: EdgeInsets.only(bottom: token == tokens.last ? 0 : 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSelectToken == null
                    ? null
                    : () => onSelectToken!(tokenName),
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7FB).withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF77C8FF).withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.token_outlined,
                          size: 22,
                          color: Color(0xFF77C8FF),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              tokenName,
                              style: TextStyle(
                                color: palette.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$quantity $tokenName',
                              style: TextStyle(
                                color: palette.muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.chevron_right,
                        color: palette.muted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TokenTransactionsCard extends StatelessWidget {
  final _Palette palette;
  final Account account;
  final String tokenName;
  final List<BrowserWalletTokenTransaction> transactions;
  final int visibleCount;
  final VoidCallback onBackToTokens;
  final ValueChanged<int> onShowMore;
  final VoidCallback onShowLess;

  const _TokenTransactionsCard({
    required this.palette,
    required this.account,
    required this.tokenName,
    required this.transactions,
    required this.visibleCount,
    required this.onBackToTokens,
    required this.onShowMore,
    required this.onShowLess,
  });

  @override
  Widget build(BuildContext context) {
    final List<BrowserWalletTokenTransaction> filtered = transactions
        .where((BrowserWalletTokenTransaction transaction) =>
            transaction.tokenName == tokenName)
        .toList();
    final List<BrowserWalletTokenTransaction> visible =
        filtered.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: onBackToTokens,
          icon: const Icon(Icons.arrow_back),
          label: const Text('Back to Tokens'),
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          Text(
            'No token transactions were found for $tokenName on this account yet.',
            style: TextStyle(
              color: palette.muted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        if (filtered.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _tr(context, 'transactions'),
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                for (final BrowserWalletTokenTransaction transaction
                    in visible) ...<Widget>[
                  _TokenTransactionRow(
                    palette: palette,
                    accountAddress: account.address ?? '',
                    transaction: transaction,
                  ),
                  if (transaction != visible.last) const SizedBox(height: 10),
                ],
                if (filtered.length > 5) ...<Widget>[
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      if (visible.length < filtered.length)
                        TextButton(
                          onPressed: () => onShowMore(filtered.length),
                          child: const Text('Show more transactions'),
                        ),
                      if (visible.length > 5)
                        TextButton(
                          onPressed: onShowLess,
                          child: const Text('Show less'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _TokenTransactionRow extends StatelessWidget {
  final _Palette palette;
  final String accountAddress;
  final BrowserWalletTokenTransaction transaction;

  const _TokenTransactionRow({
    required this.palette,
    required this.accountAddress,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReceive = transaction.recipient == accountAddress;
    final bool isPending = transaction.isPending;
    final Color accent =
        isReceive ? const Color(0xFF2EE6A6) : const Color(0xFFF8C15D);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  Text(
                    '${isReceive ? 'Receive' : 'Send'} ${transaction.amount} ${transaction.tokenName}',
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9F43).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color:
                              const Color(0xFFFF9F43).withValues(alpha: 0.45),
                        ),
                      ),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          color: Color(0xFFFFC27A),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isReceive
                    ? Address(transaction.sender).getShortString()
                    : Address(transaction.recipient).getShortString(),
                style: TextStyle(
                  color: palette.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTimestamp(transaction.timestamp),
          style: TextStyle(
            color: palette.muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime? value) {
    if (value == null) {
      return '';
    }
    final DateTime local = value.toLocal();
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }
}

class _EmptyWalletCard extends StatelessWidget {
  final _Palette palette;
  final bool working;
  final Future<void> Function() onCreateWallet;
  final VoidCallback onOpenOptions;

  const _EmptyWalletCard({
    required this.palette,
    required this.working,
    required this.onCreateWallet,
    required this.onOpenOptions,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      palette: palette,
      title: 'No Browser Wallet Yet',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'You can already create a browser-stored seed here. Importing an existing mnemonic is available in the wallet setup view on this page.',
            style: TextStyle(
              color: palette.muted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: working ? null : onCreateWallet,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Create Browser Wallet'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenOptions,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Wallet Setup'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final _Palette palette;
  final bool noticeAcknowledged;
  final bool hasWallet;

  const _StatusCard({
    required this.palette,
    required this.noticeAcknowledged,
    required this.hasWallet,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      palette: palette,
      title: 'Current Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StatusRow(
            label: 'PWA shell',
            value: 'Ready',
            valueColor: palette.primary,
          ),
          const SizedBox(height: 10),
          _StatusRow(
            label: 'Browser wallet storage',
            value: hasWallet ? 'Active' : 'Not initialized',
            valueColor: hasWallet ? palette.secondary : const Color(0xFFF8C15D),
          ),
          const SizedBox(height: 10),
          _StatusRow(
            label: 'Migration notice',
            value: noticeAcknowledged ? 'Acknowledged' : 'Visible',
            valueColor: noticeAcknowledged
                ? palette.secondary
                : const Color(0xFFFF8A80),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _Palette palette;
  final bool hasWallet;
  final bool isOptionsView;
  final Future<void> Function() onManageWallet;

  const _ActionCard({
    required this.palette,
    required this.hasWallet,
    required this.isOptionsView,
    required this.onManageWallet,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      palette: palette,
      title: 'Next Actions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onManageWallet,
              icon: const Icon(Icons.open_in_new),
              label: Text(
                hasWallet
                    ? 'Manage Browser Wallet'
                    : 'Open Wallet Setup',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isOptionsView
                ? 'Jump to the browser wallet section on this page.'
                : hasWallet
                    ? 'Open the wallet manager and jump to the browser wallet section.'
                    : 'Use the wallet setup view to import an existing mnemonic or adjust wallet settings.',
            style: TextStyle(
              color: palette.muted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _MnemonicCheckPrompt {
  final int position;
  final String correctWord;
  final List<String> options;

  const _MnemonicCheckPrompt({
    required this.position,
    required this.correctWord,
    required this.options,
  });
}

class _MnemonicVerificationView extends StatelessWidget {
  final _Palette palette;
  final List<_MnemonicCheckPrompt> prompts;
  final Map<int, String> answers;
  final String? errorText;
  final bool working;
  final VoidCallback onBack;
  final void Function(int position, String answer) onAnswerSelected;
  final Future<void> Function() onConfirm;

  const _MnemonicVerificationView({
    required this.palette,
    required this.prompts,
    required this.answers,
    required this.errorText,
    required this.working,
    required this.onBack,
    required this.onAnswerSelected,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final bool allAnswered = answers.length == prompts.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: const Color(0xFFF8C15D).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextButton.icon(
            onPressed: working ? null : onBack,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Back'),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: palette.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Confirm Mnemonic Backup',
            style: TextStyle(
              color: palette.text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the correct words for these random positions before the wallet is stored in this browser profile.',
            style: TextStyle(
              color: palette.muted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          for (final _MnemonicCheckPrompt prompt in prompts) ...<Widget>[
            Text(
              'Word #${prompt.position}',
              style: TextStyle(
                color: palette.text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: prompt.options.map((String option) {
                final bool selected = answers[prompt.position] == option;
                return ChoiceChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: working
                      ? null
                      : (_) => onAnswerSelected(prompt.position, option),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
          ],
          if (errorText != null) ...<Widget>[
            Text(
              errorText!,
              style: const TextStyle(
                color: Color(0xFFFF8A80),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
          ],
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: working ? null : onBack,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: working || !allAnswered ? null : onConfirm,
                  child: const Text('Confirm and Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PendingWalletPreview extends StatelessWidget {
  final _Palette palette;
  final String seed;
  final String mnemonic;
  final bool working;
  final Future<void> Function() onCopySeed;
  final Future<void> Function() onCopyMnemonic;
  final VoidCallback onDiscard;
  final Future<void> Function() onConfirm;

  const _PendingWalletPreview({
    required this.palette,
    required this.seed,
    required this.mnemonic,
    required this.working,
    required this.onCopySeed,
    required this.onCopyMnemonic,
    required this.onDiscard,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: const Color(0xFFF8C15D).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Back Up Before Saving',
            style: TextStyle(
              color: palette.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This wallet is only generated in memory right now. Save the seed and mnemonic first, then confirm to store it in this browser profile.',
            style: TextStyle(
              color: palette.muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Generated seed',
            value: seed,
            multiLine: true,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: working ? null : onCopySeed,
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Copy Seed'),
            ),
          ),
          const SizedBox(height: 12),
          _MnemonicPreview(
            mnemonic: mnemonic,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: working ? null : onCopyMnemonic,
              icon: const Icon(Icons.copy_all_outlined),
              label: const Text('Copy Mnemonic'),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: working ? null : onDiscard,
                  child: const Text('Discard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: working ? null : onConfirm,
                  child: const Text('Save Browser Wallet'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SendTransactionCard extends StatelessWidget {
  final _Palette palette;
  final TextEditingController destinationController;
  final TextEditingController amountController;
  final TextEditingController operationController;
  final TextEditingController openfieldController;
  final bool working;
  final double estimatedFee;
  final Future<void> Function() onScanQr;
  final Future<void> Function() onSubmit;

  const _SendTransactionCard({
    required this.palette,
    required this.destinationController,
    required this.amountController,
    required this.operationController,
    required this.openfieldController,
    required this.working,
    required this.estimatedFee,
    required this.onScanQr,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _tr(context, 'send'),
            style: TextStyle(
              color: palette.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: destinationController,
            decoration: InputDecoration(
              labelText: _tr(context, 'address_hint'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: working ? null : onScanQr,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(_tr(context, 'scan_qr')),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(
              signed: false,
              decimal: true,
            ),
            decoration: InputDecoration(
              labelText: '${_tr(context, 'enter_amount')} (BIS)',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_tr(context, 'fees')}: ${estimatedFee.toStringAsFixed(6)} BIS',
            style: TextStyle(
              color: palette.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: operationController,
            decoration: InputDecoration(
              labelText: _tr(context, 'operation'),
              hintText: 'Optional',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: openfieldController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Openfield',
              hintText: 'Optional payload',
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: working ? null : onSubmit,
              icon: working
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_tr(context, 'send')),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  final _Palette palette;
  final List<AddressTxsResponseResult> transactions;
  final int visibleCount;
  final ValueChanged<int> onShowMore;
  final VoidCallback onShowLess;

  const _RecentTransactionsCard({
    required this.palette,
    required this.transactions,
    required this.visibleCount,
    required this.onShowMore,
    required this.onShowLess,
  });

  @override
  Widget build(BuildContext context) {
    final List<AddressTxsResponseResult> visible =
        transactions.take(visibleCount).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _tr(context, 'transactions'),
            style: TextStyle(
              color: palette.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            Text(
              'No recent transactions loaded yet.',
              style: TextStyle(
                color: palette.muted,
                fontSize: 12,
              ),
            ),
          for (final AddressTxsResponseResult tx in visible) ...<Widget>[
            _RecentTxRow(
              palette: palette,
              transaction: tx,
            ),
            if (tx != visible.last) const SizedBox(height: 10),
          ],
          if (transactions.length > 5) ...<Widget>[
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                if (visible.length < transactions.length)
                  TextButton(
                    onPressed: () => onShowMore(transactions.length),
                    child: const Text('Show more transactions'),
                  ),
                if (visible.length > 5)
                  TextButton(
                    onPressed: onShowLess,
                    child: const Text('Show less'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmitResultCard extends StatelessWidget {
  final _Palette palette;
  final BrowserWalletSubmitResult result;
  final List<AddressTxsResponseResult> transactions;
  final String? amountLabel;

  const _SubmitResultCard({
    required this.palette,
    required this.result,
    required this.transactions,
    this.amountLabel,
  });

  @override
  Widget build(BuildContext context) {
    final AddressTxsResponseResult? matchedTransaction =
        _matchSubmittedTransaction();
    final Color accent =
        result.success ? const Color(0xFF2EE6A6) : const Color(0xFFFF8A80);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            result.success ? 'Last Submission' : 'Submission Error',
            style: TextStyle(
              color: palette.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'Status',
            value: result.message,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Amount',
            value: amountLabel ?? '${result.amount} BIS',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Destination',
            value: result.destination,
            multiLine: true,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Signature',
            value: _shorten(result.signature),
          ),
          if (matchedTransaction != null) ...<Widget>[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Matched history item',
              value:
                  '${matchedTransaction.getFormattedAmount()} BIS • ${matchedTransaction.hash ?? matchedTransaction.signature ?? ''}',
              multiLine: true,
            ),
          ],
        ],
      ),
    );
  }

  AddressTxsResponseResult? _matchSubmittedTransaction() {
    final String signaturePrefix = result.signature.length >= 12
        ? result.signature.substring(0, 12)
        : result.signature;
    for (final AddressTxsResponseResult tx in transactions) {
      if (tx.signature == result.signature) {
        return tx;
      }
      if ((tx.signature ?? '').startsWith(signaturePrefix)) {
        return tx;
      }
    }
    return null;
  }

  String _shorten(String value) {
    if (value.length <= 24) {
      return value;
    }
    return '${value.substring(0, 16)}...${value.substring(value.length - 8)}';
  }
}

class _RecentTxRow extends StatelessWidget {
  final _Palette palette;
  final AddressTxsResponseResult transaction;

  const _RecentTxRow({
    required this.palette,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReceive = transaction.type == BlockTypes.RECEIVE;
    final bool isPending = transaction.isPending;
    final BisToken? token = transaction.getBisToken();
    final bool isTokenTransfer = transaction.isTokenTransfer() && token != null;
    final Color accent = isTokenTransfer
        ? const Color(0xFF77C8FF)
        : isReceive
            ? const Color(0xFF2EE6A6)
            : const Color(0xFFF8C15D);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 5),
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: <Widget>[
                  Text(
                    _buildPrimaryLabel(
                      isReceive: isReceive,
                      isTokenTransfer: isTokenTransfer,
                      token: token,
                      context: context,
                    ),
                    style: TextStyle(
                      color: palette.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isPending)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9F43).withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color:
                              const Color(0xFFFF9F43).withValues(alpha: 0.45),
                        ),
                      ),
                      child: const Text(
                        'Pending',
                        style: TextStyle(
                          color: Color(0xFFFFC27A),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                transaction.getShortString(),
                style: TextStyle(
                  color: palette.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTimestamp(transaction.timestamp),
          style: TextStyle(
            color: palette.muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _buildPrimaryLabel({
    required bool isReceive,
    required bool isTokenTransfer,
    required BisToken? token,
    BuildContext? context,
  }) {
    final String receiveLabel =
        context == null ? 'Receive' : _tr(context, 'receive');
    final String sendLabel = context == null ? 'Send' : _tr(context, 'send');
    if (isTokenTransfer && token != null) {
      final String quantity =
          token.tokensQuantity?.toString() ?? transaction.amount ?? '0';
      final String tokenName = token.tokenName?.trim().isNotEmpty == true
          ? token.tokenName!.trim()
          : 'token';
      return '${isReceive ? receiveLabel : sendLabel} $quantity $tokenName';
    }

    return '${isReceive ? receiveLabel : sendLabel} ${transaction.getFormattedAmount()} BIS';
  }

  String _formatTimestamp(DateTime? value) {
    if (value == null) {
      return '';
    }
    final DateTime local = value.toLocal();
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day $hour:$minute';
  }
}

String _shortAddress(String address) {
  if (address.length <= 16) {
    return address;
  }
  return '${address.substring(0, 10)}...${address.substring(address.length - 6)}';
}

List<List<String>> _buildMnemonicColumns(List<String> words) {
  if (words.isEmpty) {
    return const <List<String>>[];
  }

  const int columns = 3;
  final int rows = (words.length / columns).ceil();
  final List<List<String>> result = List<List<String>>.generate(
    columns,
    (_) => <String>[],
  );

  for (int column = 0; column < columns; column++) {
    for (int row = 0; row < rows; row++) {
      final int index = column * rows + row;
      if (index >= words.length) {
        continue;
      }
      result[column].add('${index + 1}. ${words[index]}');
    }
  }

  return result.where((List<String> column) => column.isNotEmpty).toList();
}

class _SectionCard extends StatelessWidget {
  final _Palette palette;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.palette,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x42000000),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: palette.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final _Palette palette;
  final Color color;
  final String message;

  const _BannerCard({
    required this.palette,
    required this.color,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: palette.text,
          fontSize: 13,
          height: 1.4,
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final _Palette palette;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ChipLabel({
    required this.palette,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: palette.text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (onTap == null) {
      return chip;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: chip,
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool multiLine;

  const _InfoRow({
    required this.label,
    required this.value,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9EB0C5),
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: TextStyle(
            fontSize: multiLine ? 13 : 14,
            height: multiLine ? 1.5 : 1.3,
          ),
        ),
      ],
    );
  }
}

class _MnemonicPreview extends StatelessWidget {
  final String mnemonic;

  const _MnemonicPreview({
    required this.mnemonic,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> words = mnemonic
        .split(RegExp(r'\s+'))
        .map((String word) => word.trim())
        .where((String word) => word.isNotEmpty)
        .toList();
    final List<List<String>> columns = _buildMnemonicColumns(words);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '24-word mnemonic',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9EB0C5),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List<Widget>.generate(columns.length, (int columnIndex) {
            final List<String> entries = columns[columnIndex];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: columnIndex == columns.length - 1 ? 0 : 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.map((String entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: SelectableText(
                        entry,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _Palette {
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color primary;
  final Color secondary;
  final Color text;
  final Color muted;

  const _Palette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.secondary,
    required this.text,
    required this.muted,
  });
}
