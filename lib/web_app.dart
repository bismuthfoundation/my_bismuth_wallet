import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:decimal/decimal.dart';
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
    case 'ru':
      return const Locale('ru', 'RU');
    case 'pl':
      return const Locale('pl', 'PL');
    case 'zh':
      return const Locale('zh', 'CN');
    case 'ja':
      return const Locale('ja', 'JP');
    case 'ko':
      return const Locale('ko', 'KR');
    case 'en':
    default:
      return const Locale('en', 'US');
  }
}

const Map<String, Map<String, String>> _webStrings =
    <String, Map<String, String>>{
  'en': <String, String>{
    'settings': 'Settings',
    'network': 'Network',
    'custom_websocket_api_endpoint': 'Custom Websocket API Endpoint',
    'preferences': 'Preferences',
    'currency': 'Currency',
    'language': 'Language',
    'theme': 'Theme',
    'auto': 'Auto',
    'dark': 'Dark',
    'light': 'Light',
    'mybismuth_non_custodial_wallet': 'myBismuth Non-Custodial Wallet',
    'security': 'Security',
    'wallet_lock': 'Wallet lock',
    'protected': 'Protected',
    'legacy_local_storage': 'Legacy local storage',
    'pin_unlock': 'PIN unlock',
    'pin_attempts': 'PIN attempts',
    'enabled': 'Enabled',
    'disabled': 'Disabled',
    'passkey_unlock': 'Passkey unlock',
    'available': 'Available',
    'unsupported': 'Unsupported',
    'manage': 'Manage',
    'reset_browser_wallet': 'Reset Browser Wallet',
    'connect': 'Connect',
    'enable_passkey_unlock': 'Enable Passkey Unlock',
    'lock_wallet_now': 'Lock Wallet Now',
    'set_wallet_password': 'Set Wallet PIN',
    'auth_method': 'Authentication Method',
    'backup_seed_phrase': 'Backup Seed Phrase',
    'close': 'Close',
    'cancel': 'Cancel',
    'continue': 'Continue',
    'confirm': 'Confirm',
    'save': 'Save',
    'back_to': 'Back to',
    'wallet': 'Wallet',
    'popup': 'Popup',
    'send': 'Send',
    'receive': 'Receive',
    'tokens': 'Tokens',
    'transactions': 'Transactions',
    'back_to_wallets': 'Back to Wallets',
    'back_to_tokens': 'Back to Tokens',
    'account_label': 'Account label',
    'rename_account': 'Rename Account',
    'show_more_transactions': 'Show more transactions',
    'show_less': 'Show less',
    'api_connection_established': 'API connection established',
    'no_api_connection_established': 'No API connection established',
    'refresh_live_data': 'Refresh live data',
    'waiting_for_first_network_sync': 'Waiting for first network sync',
    'copy_address': 'Copy address',
    'wallet_locked': 'Wallet locked.',
    'account_address_copied': 'Account address copied to clipboard.',
    'account_label_updated': 'Account label updated.',
    'websocket_connected': 'Connected to websocket endpoint.',
    'current_status': 'Current Status',
    'browser_wallet_storage': 'Browser wallet storage',
    'active': 'Active',
    'not_initialized': 'Not initialized',
    'migration_notice': 'Migration notice',
    'acknowledged': 'Acknowledged',
    'visible': 'Visible',
    'next_actions': 'Next Actions',
    'manage_browser_wallet': 'Manage Browser Wallet',
    'open_wallet_setup': 'Open Wallet Setup',
    'jump_to_browser_wallet_section':
        'Jump to the browser wallet section on this page.',
    'open_wallet_manager_browser_wallet_section':
        'Open the wallet manager and jump to the browser wallet section.',
    'use_wallet_setup_view':
        'Use the wallet setup view to import an existing mnemonic or adjust wallet settings.',
    'language_preference_saved': 'Language preference saved.',
    'auth_preference_saved':
        'Authentication preference saved. Browser enforcement is not wired yet.',
    'theme_preference_saved': 'Theme preference saved.',
    'failed_load_browser_wallet_data':
        'Failed to load browser wallet data: {error}',
    'enter_wallet_pin_to_unlock':
        'Enter the 6-digit wallet PIN to unlock this wallet.',
    'wallet_unlocked_with_pin': 'Wallet unlocked with PIN.',
    'pin_unlock_failed': 'PIN unlock failed: {error}',
    'wallet_unlocked_with_passkey': 'Wallet unlocked with passkey.',
    'passkey_unlock_failed': 'Passkey unlock failed: {error}',
    'seed_unavailable_browser_vault':
        'Seed is unavailable in the browser vault.',
    'new_deterministic_account_created':
        'New deterministic account created from the wallet seed.',
    'failed_create_new_account': 'Failed to create a new account: {error}',
    'live_transaction_detail_lookup_failed':
        'Live transaction detail lookup failed. Showing locally available transaction data instead.',
    'enter_valid_websocket_endpoint': 'Enter a valid websocket endpoint.',
    'failed_connect_wallet_server':
        'Failed to connect to wallet server: {error}',
    'wallet_generated_locally':
        'Wallet generated locally. Back up the seed phrase before saving it into this web app.',
    'wallet_setup_failed': 'Wallet setup failed: {error}',
    'generate_wallet_before_saving':
        'Generate a browser wallet first before saving it.',
    'mnemonic_verification_not_prepared':
        'Mnemonic verification could not be prepared.',
    'answer_each_prompt':
        'Answer each prompt before saving the browser wallet.',
    'mnemonic_answers_incorrect':
        'One or more answers are incorrect. Go back and check the mnemonic again.',
    'copied_to_clipboard': '{label} copied to the clipboard.',
    'unsaved_generated_wallet_discarded': 'Unsaved generated wallet discarded.',
    'set_wallet_pin_title': 'Set Wallet PIN',
    'set_wallet_pin_description':
        'Create a 6-digit PIN for daily browser wallet unlock. Recovery still depends on the seed phrase.',
    'six_digit_pin': '6-digit PIN',
    'confirm_pin': 'Confirm PIN',
    'unlock_or_create_wallet_before_pin':
        'Unlock or create a browser wallet before setting a PIN.',
    'wallet_pin_must_be_6_digits': 'Wallet PIN must be exactly 6 digits.',
    'pin_confirmation_no_match': 'PIN confirmation does not match.',
    'wallet_pin_enabled':
        'Wallet PIN enabled. Future sessions will require unlocking the wallet.',
    'no_seed_phrase_available':
        'No browser wallet seed phrase is available to back up.',
    'backup_seed_phrase_title': 'Backup Seed Phrase',
    'backup_seed_phrase_description':
        'Store this 24-word phrase offline. Anyone with it can control this wallet.',
    'copy': 'Copy',
    'seed_phrase_copied': 'Seed phrase copied to the clipboard.',
    'unlock_wallet_before_passkey':
        'Unlock the browser wallet before enrolling a passkey.',
    'set_pin_before_passkey':
        'Set a 6-digit wallet PIN before enabling passkey unlock.',
    'confirm_current_pin_for_passkey':
        'Confirm the current 6-digit wallet PIN, then approve the browser passkey prompt on this device.',
    'current_wallet_pin': 'Current wallet PIN',
    'enter_pin_before_adding_passkey':
        'Enter the 6-digit wallet PIN before adding a passkey.',
    'passkey_unlock_enabled':
        'Passkey unlock enabled for this browser wallet on this device.',
    'passkey_prf_unavailable':
        'Passkey unlock is not available on this device/browser because the authenticator does not expose the PRF extension needed for local wallet unlock. Keep using the wallet PIN on this profile.',
    'passkey_enrollment_failed': 'Passkey enrollment failed: {error}',
    'amount_plus_fee_exceeds_balance':
        'Amount plus estimated fee exceeds the current wallet balance.',
    'confirm_transaction': 'Confirm Transaction',
    'send_amount_to': 'Send {amount} BIS to:',
    'estimated_fee_label': 'Estimated fee: {fee} BIS',
    'operation_value': 'Operation: {value}',
    'transaction_submitted_successfully':
        'Transaction submitted to the network mempool successfully.',
    'transaction_rejected': 'Transaction rejected: {message}',
    'transaction_submission_failed': 'Transaction submission failed: {error}',
    'no_active_browser_wallet_account':
        'No active browser wallet account is available.',
    'no_token_selected_for_transfer': 'No token is selected for this transfer.',
    'enter_destination_address_first': 'Enter a destination address first.',
    'destination_address_invalid': 'Destination address format is invalid.',
    'enter_token_amount_first': 'Enter a token amount first.',
    'token_amount_positive_integer': 'Token amount must be a positive integer.',
    'token_amount_exceeds_balance':
        'Token amount exceeds the current token balance for this account.',
    'token_transfer_sent_successfully': 'Token transfer sent successfully.',
    'token_transfer_rejected': 'Token transfer rejected: {message}',
    'token_transfer_submission_failed':
        'Token transfer submission failed: {error}',
    'hosted_wallet_runtime_notice':
        'This hosted wallet is wired for browser-safe seed storage. The next migration step is bringing transaction, signing, and network workflows into the web runtime.',
    'unlock_browser_wallet': 'Unlock Browser Wallet',
    'locked_wallet_description_with_passkey':
        'This browser wallet is locked. Unlock it with a passkey or the 6-digit wallet PIN.',
    'locked_wallet_description_pin_only':
        'This browser wallet is locked. Unlock it with the 6-digit wallet PIN.',
    'unlock_with_passkey': 'Unlock With Passkey',
    'six_digit_wallet_pin': '6-digit wallet PIN',
    'unlock_with_pin': 'Unlock With PIN',
    'pin_unlock_rate_limited':
        'PIN unlock is temporarily rate-limited after repeated failures. Wait for the cooldown and try again.',
    'recovery_depends_on_seed_phrase':
        'Recovery still depends on the seed phrase. Passkeys only protect local access on this browser profile.',
    'clear': 'Clear',
    'hosted_wallet': 'Hosted Wallet',
    'installable_pwa': 'Installable PWA',
    'mainnet_profile': 'Mainnet profile',
    'testnet_profile': 'Testnet profile',
    'launch_count': 'Launch #{count}',
    'wallets': 'Wallets',
    'add_new': 'Add new',
    'no_deterministic_accounts':
        'No deterministic accounts have been derived yet.',
    'account': 'Account',
    'send_token': 'Send {token}',
    'amount_token': 'Amount ({token})',
    'message': 'Message',
    'optional': 'Optional',
    'optional_message': 'Optional message',
    'optional_payload': 'Optional payload',
    'token_transfer_operation_note':
        'Operation is automatically set to token:transfer and the openfield is generated for you.',
    'loading_token_balances':
        'Loading token balances for the selected account...',
    'this_account': 'this account',
    'no_token_balances_found':
        'No token balances were found for {account} yet.',
    'token_balances_for': 'Token balances for {account}',
    'no_token_transactions_found':
        'No token transactions were found for {token} on this account yet.',
    'no_browser_wallet_yet': 'No Browser Wallet Yet',
    'no_browser_wallet_yet_description':
        'You can already create a browser-stored seed here. Importing an existing mnemonic is available in the wallet setup view on this page.',
    'create_browser_wallet': 'Create Browser Wallet',
    'pwa_shell': 'PWA shell',
    'ready': 'Ready',
    'back': 'Back',
    'confirm_mnemonic_backup': 'Confirm Mnemonic Backup',
    'confirm_mnemonic_backup_description':
        'Select the correct words for these random positions before the wallet is stored in this browser profile.',
    'word_number': 'Word #{position}',
    'confirm_and_save': 'Confirm and Save',
    'back_up_before_saving': 'Back Up Before Saving',
    'back_up_before_saving_description':
        'This wallet is only generated in memory right now. Save the seed and mnemonic first, then confirm to store it in this browser profile.',
    'generated_seed': 'Generated seed',
    'generated_mnemonic': 'Generated mnemonic',
    'copy_seed': 'Copy Seed',
    'copy_mnemonic': 'Copy Mnemonic',
    'discard': 'Discard',
    'save_browser_wallet': 'Save Browser Wallet',
    'import_24_word_mnemonic': 'Import 24-word mnemonic',
    'mnemonic_storage_note':
        'Note: Your mnemonic is stored locally in this browser profile. If you reset the Browser Wallet, the local copy is permanently deleted.',
    'create_wallet': 'Create Wallet',
    'import_wallet': 'Import Wallet',
    'scan_import_qr': 'Scan Import QR',
    'loading_browser_wallet': 'Loading browser wallet...',
    'browser_wallet': 'Browser Wallet',
    'no_browser_wallet_account_selected':
        'No browser wallet account is selected yet.',
    'transaction_history': 'Transaction History',
    'no_recent_transactions_loaded': 'No recent transactions loaded yet.',
    'transaction_detail_unavailable': 'Transaction detail is unavailable.',
    'last_submission': 'Last Submission',
    'submission_error': 'Submission Error',
    'status': 'Status',
    'destination': 'Destination',
    'matched_history_item': 'Matched history item',
    'mnemonic_qr_scanned_loaded': 'Mnemonic QR scanned and loaded for import.',
    'qr_invalid_mnemonic_or_seed':
        'QR code does not contain a valid 24-word mnemonic or 64-character seed.',
    'qr_payment_request_invalid_address':
        'QR payment request does not contain a valid address.',
    'payment_qr_scanned_prefilled':
        'Payment QR scanned and send form prefilled.',
    'address_qr_scanned_prefilled':
        'Address QR scanned and destination prefilled.',
    'could_not_parse_payment_qr': 'Could not parse payment QR: {error}',
    'qr_invalid_bismuth_request':
        'QR code does not contain a valid Bismuth payment request or destination address.',
    'scanning_deterministic_accounts':
        'Scanning deterministic accounts from the imported seed...',
    'opening_account_and_recovering':
        '{status} Opening account 1 now and recovering additional accounts in the background.',
    'failed_reset_browser_wallet_data':
        'Failed to reset browser wallet data: {error}',
    'pin_unlock_temporarily_locked':
        'PIN unlock is temporarily locked due to repeated failed attempts. Wait for the cooldown to expire before trying again.',
    'passkey_support_without_prf':
        'This browser reports passkey support, but not the PRF capability required for local wallet unlock on this profile.',
    'twenty_four_word_mnemonic': '24-word mnemonic',
    'recovered_accounts_from_seed':
        'Recovered {count} accounts from this seed.',
    'balance_title': '{name} Wallet',
    'tx_count': '{count} transactions',
    'token_tx_count_on_account': '{count} {token} transactions',
    'address_hint': 'Enter Address',
    'scan_qr': 'Scan QR Code',
    'amount': 'Amount',
    'enter_amount': 'Enter Amount',
    'fees': 'Fees',
    'operation': 'Operation',
    'transaction_detail': 'Transaction detail',
    'back_to_transactions': 'Back to Transactions',
    'sender': 'Sender',
    'recipient': 'Recipient',
    'timestamp': 'Timestamp',
    'block': 'Block',
    'block_hash': 'Block Hash',
    'transaction_id': 'Transaction ID',
    'transaction_ref': 'Transaction Ref',
    'signature': 'Signature',
    'openfield': 'Openfield',
    'pending': 'Pending',
  },
  'fr': <String, String>{
    'settings': 'Parametres',
    'network': 'Reseau',
    'custom_websocket_api_endpoint':
        'Point de terminaison API Websocket personnalise',
    'preferences': 'Preferences',
    'currency': 'Devise',
    'language': 'Langue',
    'theme': 'Theme',
    'auto': 'Auto',
    'dark': 'Sombre',
    'light': 'Clair',
    'mybismuth_non_custodial_wallet': 'Wallet myBismuth non depositaire',
    'security': 'Securite',
    'wallet_lock': 'Verrouillage du Wallet',
    'protected': 'Protege',
    'legacy_local_storage': 'Stockage local legacy',
    'pin_unlock': 'Deblocage PIN',
    'pin_attempts': 'Tentatives PIN',
    'enabled': 'Active',
    'disabled': 'Desactive',
    'passkey_unlock': 'Deblocage par passkey',
    'available': 'Disponible',
    'unsupported': 'Non pris en charge',
    'manage': 'Gerer',
    'reset_browser_wallet': 'Reinitialiser le Browser Wallet',
    'connect': 'Connecter',
    'enable_passkey_unlock': 'Activer le deblocage par passkey',
    'lock_wallet_now': 'Verrouiller le Wallet',
    'set_wallet_password': 'Definir le code PIN du portefeuille',
    'auth_method': "Methode d'authentification",
    'backup_seed_phrase': 'Sauvegarder la phrase secrete',
    'close': 'Fermer',
    'cancel': 'Annuler',
    'continue': 'Continuer',
    'confirm': 'Confirmer',
    'save': 'Enregistrer',
    'back_to': 'Retour a',
    'wallet': 'Wallet',
    'popup': 'Popup',
    'send': 'Envoyer',
    'receive': 'Recevoir',
    'tokens': 'Tokens',
    'transactions': 'Transactions',
    'back_to_wallets': 'Retour aux Wallets',
    'back_to_tokens': 'Retour aux tokens',
    'account_label': 'Nom du Wallet',
    'rename_account': 'Renommer le compte',
    'show_more_transactions': 'Afficher plus de transactions',
    'show_less': 'Afficher moins',
    'current_status': 'Statut actuel',
    'browser_wallet_storage': 'Stockage du Browser Wallet',
    'active': 'Actif',
    'not_initialized': 'Non initialise',
    'migration_notice': 'Avis de migration',
    'acknowledged': 'Confirme',
    'visible': 'Visible',
    'next_actions': 'Actions suivantes',
    'manage_browser_wallet': 'Gerer le Browser Wallet',
    'open_wallet_setup': 'Ouvrir la configuration du Wallet',
    'copy': 'Copier',
    'clear': 'Effacer',
    'wallets': 'Wallets',
    'add_new': 'Ajouter',
    'account': 'Compte',
    'message': 'Message',
    'optional': 'Optionnel',
    'optional_message': 'Message optionnel',
    'optional_payload': 'Charge utile optionnelle',
    'no_browser_wallet_yet': 'Pas encore de Browser Wallet',
    'create_browser_wallet': 'Creer un Browser Wallet',
    'ready': 'Pret',
    'back': 'Retour',
    'confirm_and_save': 'Confirmer et enregistrer',
    'discard': 'Ignorer',
    'save_browser_wallet': 'Enregistrer le Browser Wallet',
    'create_wallet': 'Creer un Wallet',
    'import_wallet': 'Importer un Wallet',
    'loading_browser_wallet': 'Chargement du Browser Wallet...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': 'Historique des transactions',
    'status': 'Statut',
    'destination': 'Destination',
    'tx_count': '{count} txs',
    'token_tx_count_on_account': '{count} transactions {token}',
    'address_hint': "Entrer l'adresse",
    'scan_qr': 'Scanner le code QR',
    'amount': 'Montant',
    'enter_amount': 'Entrer le montant',
    'fees': 'Frais',
    'operation': 'Operation',
    'transaction_detail': 'Detail de transaction',
    'back_to_transactions': 'Retour aux transactions',
    'sender': 'Expediteur',
    'recipient': 'Destinataire',
    'timestamp': 'Horodatage',
    'block': 'Bloc',
    'block_hash': 'Hash du bloc',
    'transaction_id': 'ID de transaction',
    'transaction_ref': 'Reference de transaction',
    'signature': 'Signature',
    'openfield': 'Openfield',
    'pending': 'En attente',
    'balance_title': '{name} Wallet',
    'api_connection_established': 'Connexion API etablie',
    'no_api_connection_established': 'Aucune connexion API etablie',
    'refresh_live_data': 'Actualiser les donnees en direct',
    'waiting_for_first_network_sync':
        'En attente de la premiere synchronisation reseau',
    'copy_address': "Copier l'adresse",
    'wallet_locked': 'Wallet verrouille.',
    'account_address_copied':
        "Adresse du compte copiee dans le presse-papiers.",
    'account_label_updated': 'Nom du compte mis a jour.',
    'websocket_connected': 'Connecte au point de terminaison websocket.',
    'language_preference_saved': 'Preference de langue enregistree.',
    'theme_preference_saved': 'Preference de theme enregistree.',
    'wallet_unlocked_with_pin': 'Wallet deverrouille avec le PIN.',
    'pin_unlock_failed': 'Echec du deverrouillage PIN : {error}',
    'wallet_unlocked_with_passkey': 'Wallet deverrouille avec la passkey.',
    'passkey_unlock_failed': 'Echec du deverrouillage par passkey : {error}',
    'failed_create_new_account':
        "Echec de creation d'un nouveau compte : {error}",
    'enter_valid_websocket_endpoint':
        'Entrez un point de terminaison websocket valide.',
    'wallet_setup_failed': 'Configuration du Wallet echouee : {error}',
    'copied_to_clipboard': '{label} copie dans le presse-papiers.',
    'unsaved_generated_wallet_discarded':
        'Wallet genere non enregistre ignore.',
    'set_wallet_pin_title': 'Definir le PIN du Wallet',
    'six_digit_pin': 'PIN a 6 chiffres',
    'confirm_pin': 'Confirmer le PIN',
    'wallet_pin_must_be_6_digits':
        'Le PIN du Wallet doit comporter exactement 6 chiffres.',
    'pin_confirmation_no_match': 'La confirmation du PIN ne correspond pas.',
    'backup_seed_phrase_title': 'Sauvegarder la seed phrase',
    'seed_phrase_copied': 'Seed phrase copiee dans le presse-papiers.',
    'current_wallet_pin': 'PIN actuel du Wallet',
    'passkey_enrollment_failed':
        "Echec d'enregistrement de la passkey : {error}",
    'confirm_transaction': 'Confirmer la transaction',
    'send_amount_to': 'Envoyer {amount} BIS a :',
    'estimated_fee_label': 'Frais estimes : {fee} BIS',
    'operation_value': 'Operation : {value}',
    'transaction_rejected': 'Transaction rejetee : {message}',
    'transaction_submission_failed':
        "Echec d'envoi de la transaction : {error}",
    'no_token_selected_for_transfer':
        "Aucun token n'est selectionne pour ce transfert.",
    'enter_destination_address_first':
        "Entrez d'abord une adresse de destination.",
    'destination_address_invalid':
        "Le format de l'adresse de destination est invalide.",
    'enter_token_amount_first': "Entrez d'abord un montant de token.",
    'token_amount_positive_integer':
        'Le montant du token doit etre un entier positif.',
    'token_transfer_sent_successfully':
        'Transfert de token envoye avec succes.',
    'token_transfer_rejected': 'Transfert de token rejete : {message}',
    'unlock_browser_wallet': 'Deverrouiller le Browser Wallet',
    'unlock_with_passkey': 'Deverrouiller avec passkey',
    'six_digit_wallet_pin': 'PIN du Wallet a 6 chiffres',
    'unlock_with_pin': 'Deverrouiller avec PIN',
    'hosted_wallet': 'Wallet heberge',
    'installable_pwa': 'PWA installable',
    'mainnet_profile': 'Profil mainnet',
    'testnet_profile': 'Profil testnet',
    'launch_count': 'Lancement #{count}',
    'send_token': 'Envoyer {token}',
    'amount_token': 'Montant ({token})',
    'this_account': 'ce compte',
    'token_balances_for': 'Soldes de tokens pour {account}',
    'pwa_shell': 'Shell PWA',
    'confirm_mnemonic_backup': 'Confirmer la sauvegarde de la mnemonic',
    'word_number': 'Mot #{position}',
    'back_up_before_saving': "Sauvegarder avant d'enregistrer",
    'generated_seed': 'Seed generee',
    'generated_mnemonic': 'Mnemonic generee',
    'copy_seed': 'Copier la seed',
    'copy_mnemonic': 'Copier la mnemonic',
    'import_24_word_mnemonic': 'Importer une mnemonic de 24 mots',
    'scan_import_qr': "Scanner le QR d'import",
    'no_recent_transactions_loaded':
        'Aucune transaction recente chargee pour le moment.',
    'transaction_detail_unavailable':
        'Le detail de transaction est indisponible.',
    'last_submission': 'Dernier envoi',
    'submission_error': "Erreur d'envoi",
    'matched_history_item': "Element d'historique correspondant",
    'mnemonic_qr_scanned_loaded': 'QR mnemonic scanne et charge pour import.',
    'could_not_parse_payment_qr':
        'Impossible de parser le QR de paiement : {error}',
    'twenty_four_word_mnemonic': 'Mnemonic de 24 mots',
  },
  'de': <String, String>{
    'settings': 'Einstellungen',
    'network': 'Netzwerk',
    'custom_websocket_api_endpoint':
        'Benutzerdefinierter Websocket-API-Endpunkt',
    'preferences': 'Einstellungen',
    'currency': 'Währung',
    'language': 'Sprache',
    'theme': 'Design',
    'auto': 'Auto',
    'mybismuth_non_custodial_wallet': 'myBismuth Wallet ohne Verwahrung',
    'security': 'Sicherheit',
    'wallet_lock': 'Wallet-Sperre',
    'protected': 'Geschützt',
    'legacy_local_storage': 'Veralteter lokaler Speicher',
    'pin_unlock': 'PIN-Entsperrung',
    'pin_attempts': 'PIN-Versuche',
    'enabled': 'Aktiviert',
    'disabled': 'Deaktiviert',
    'passkey_unlock': 'Passkey-Entsperrung',
    'available': 'Verfügbar',
    'unsupported': 'Nicht unterstützt',
    'manage': 'Verwalten',
    'reset_browser_wallet': 'Browser-Wallet zurücksetzen',
    'connect': 'Verbinden',
    'enable_passkey_unlock': 'Passkey-Entsperrung aktivieren',
    'lock_wallet_now': 'Wallet jetzt sperren',
    'set_wallet_password': 'Wallet-PIN festlegen',
    'auth_method': 'Authentifizierungsmethode',
    'backup_seed_phrase': 'Seed-Phrase sichern',
    'close': 'Schließen',
    'cancel': 'Abbrechen',
    'continue': 'Weiter',
    'confirm': 'Bestätigen',
    'save': 'Speichern',
    'back_to': 'Zurück zu',
    'wallet': 'Wallet',
    'popup': 'Popup',
    'send': 'Senden',
    'receive': 'Empfangen',
    'tokens': 'Token',
    'transactions': 'Transaktionen',
    'back_to_wallets': 'Zurück zu Wallets',
    'back_to_tokens': 'Zurück zu Token',
    'account_label': 'Wallet Name',
    'rename_account': 'Konto umbenennen',
    'show_more_transactions': 'Mehr Transaktionen anzeigen',
    'show_less': 'Weniger anzeigen',
    'api_connection_established': 'API-Verbindung hergestellt',
    'no_api_connection_established': 'Keine API-Verbindung hergestellt',
    'refresh_live_data': 'Live-Daten aktualisieren',
    'waiting_for_first_network_sync':
        'Warte auf erste Netzwerksynchronisierung',
    'copy_address': 'Adresse kopieren',
    'wallet_locked': 'Wallet gesperrt.',
    'account_address_copied': 'Kontoadresse in die Zwischenablage kopiert.',
    'account_label_updated': 'Kontobezeichnung aktualisiert.',
    'websocket_connected': 'Mit Websocket-Endpunkt verbunden.',
    'current_status': 'Aktueller Status',
    'browser_wallet_storage': 'Browser-Wallet-Speicher',
    'active': 'Aktiv',
    'not_initialized': 'Nicht initialisiert',
    'migration_notice': 'Migrationshinweis',
    'acknowledged': 'Bestätigt',
    'visible': 'Sichtbar',
    'next_actions': 'Nächste Schritte',
    'manage_browser_wallet': 'Browser-Wallet verwalten',
    'open_wallet_setup': 'Wallet-Einrichtung öffnen',
    'jump_to_browser_wallet_section':
        'Zum Browser-Wallet-Bereich auf dieser Seite springen.',
    'open_wallet_manager_browser_wallet_section':
        'Die Wallet-Verwaltung öffnen und zum Browser-Wallet-Bereich springen.',
    'use_wallet_setup_view':
        'Verwende die Wallet-Einrichtung, um eine vorhandene Mnemonic zu importieren oder Wallet-Einstellungen anzupassen.',
    'language_preference_saved': 'Spracheinstellung gespeichert.',
    'auth_preference_saved':
        'Authentifizierungseinstellung gespeichert. Die Browser-Durchsetzung ist noch nicht vollständig angebunden.',
    'theme_preference_saved': 'Designeinstellung gespeichert.',
    'failed_load_browser_wallet_data':
        'Browser-Wallet-Daten konnten nicht geladen werden: {error}',
    'enter_wallet_pin_to_unlock':
        'Gib die 6-stellige Wallet-PIN ein, um diese Wallet zu entsperren.',
    'wallet_unlocked_with_pin': 'Wallet mit PIN entsperrt.',
    'pin_unlock_failed': 'PIN-Entsperrung fehlgeschlagen: {error}',
    'wallet_unlocked_with_passkey': 'Wallet mit Passkey entsperrt.',
    'passkey_unlock_failed': 'Passkey-Entsperrung fehlgeschlagen: {error}',
    'seed_unavailable_browser_vault':
        'Seed ist im Browser-Tresor nicht verfügbar.',
    'new_deterministic_account_created':
        'Neues deterministisches Konto aus dem Wallet-Seed erstellt.',
    'failed_create_new_account':
        'Neues Konto konnte nicht erstellt werden: {error}',
    'live_transaction_detail_lookup_failed':
        'Live-Abfrage der Transaktionsdetails fehlgeschlagen. Stattdessen werden lokal verfügbare Transaktionsdaten angezeigt.',
    'enter_valid_websocket_endpoint':
        'Gib einen gültigen Websocket-Endpunkt ein.',
    'failed_connect_wallet_server':
        'Verbindung zum Wallet-Server fehlgeschlagen: {error}',
    'wallet_generated_locally':
        'Wallet lokal erzeugt. Sichere die Seed-Phrase, bevor du sie in dieser Web-App speicherst.',
    'wallet_setup_failed': 'Wallet-Einrichtung fehlgeschlagen: {error}',
    'generate_wallet_before_saving':
        'Erzeuge zuerst eine Browser-Wallet, bevor du sie speicherst.',
    'mnemonic_verification_not_prepared':
        'Die Mnemonic-Prüfung konnte nicht vorbereitet werden.',
    'answer_each_prompt':
        'Beantworte jede Abfrage, bevor du die Browser-Wallet speicherst.',
    'mnemonic_answers_incorrect':
        'Eine oder mehrere Antworten sind falsch. Gehe zurück und überprüfe die Mnemonic erneut.',
    'copied_to_clipboard': '{label} wurde in die Zwischenablage kopiert.',
    'unsaved_generated_wallet_discarded':
        'Nicht gespeicherte erzeugte Wallet verworfen.',
    'set_wallet_pin_title': 'Wallet-PIN festlegen',
    'set_wallet_pin_description':
        'Erstelle eine 6-stellige PIN für das tägliche Entsperren der Browser-Wallet. Die Wiederherstellung hängt weiterhin von der Seed-Phrase ab.',
    'six_digit_pin': '6-stellige PIN',
    'confirm_pin': 'PIN bestätigen',
    'unlock_or_create_wallet_before_pin':
        'Entsperre oder erstelle zuerst eine Browser-Wallet, bevor du eine PIN festlegst.',
    'wallet_pin_must_be_6_digits': 'Die Wallet-PIN muss genau 6 Ziffern haben.',
    'pin_confirmation_no_match': 'Die PIN-Bestätigung stimmt nicht überein.',
    'wallet_pin_enabled':
        'Wallet-PIN aktiviert. Zukünftige Sitzungen erfordern das Entsperren der Wallet.',
    'no_seed_phrase_available':
        'Es ist keine Seed-Phrase der Browser-Wallet zum Sichern verfügbar.',
    'backup_seed_phrase_title': 'Seed-Phrase sichern',
    'backup_seed_phrase_description':
        'Bewahre diese 24-Wort-Phrase offline auf. Jeder mit Zugriff darauf kann diese Wallet kontrollieren.',
    'copy': 'Kopieren',
    'seed_phrase_copied': 'Seed-Phrase in die Zwischenablage kopiert.',
    'unlock_wallet_before_passkey':
        'Entsperre die Browser-Wallet, bevor du einen Passkey einrichtest.',
    'set_pin_before_passkey':
        'Lege eine 6-stellige Wallet-PIN fest, bevor du die Passkey-Entsperrung aktivierst.',
    'confirm_current_pin_for_passkey':
        'Bestätige die aktuelle 6-stellige Wallet-PIN und bestätige danach den Browser-Passkey-Dialog auf diesem Gerät.',
    'current_wallet_pin': 'Aktuelle Wallet-PIN',
    'enter_pin_before_adding_passkey':
        'Gib die 6-stellige Wallet-PIN ein, bevor du einen Passkey hinzufügst.',
    'passkey_unlock_enabled':
        'Passkey-Entsperrung für diese Browser-Wallet auf diesem Gerät aktiviert.',
    'passkey_prf_unavailable':
        'Passkey-Entsperrung ist auf diesem Gerät/Browser nicht verfügbar, weil der Authenticator die für die lokale Wallet-Entsperrung benötigte PRF-Erweiterung nicht bereitstellt. Verwende auf diesem Profil weiterhin die Wallet-PIN.',
    'passkey_enrollment_failed': 'Passkey-Einrichtung fehlgeschlagen: {error}',
    'amount_plus_fee_exceeds_balance':
        'Betrag plus geschätzte Gebühr überschreitet das aktuelle Wallet-Guthaben.',
    'confirm_transaction': 'Transaktion bestätigen',
    'send_amount_to': '{amount} BIS senden an:',
    'estimated_fee_label': 'Geschätzte Gebühr: {fee} BIS',
    'operation_value': 'Operation: {value}',
    'transaction_submitted_successfully':
        'Transaktion erfolgreich an den Netzwerk-Mempool übermittelt.',
    'transaction_rejected': 'Transaktion abgelehnt: {message}',
    'transaction_submission_failed':
        'Übermittlung der Transaktion fehlgeschlagen: {error}',
    'no_active_browser_wallet_account':
        'Kein aktives Browser-Wallet-Konto verfügbar.',
    'no_token_selected_for_transfer':
        'Für diese Übertragung ist kein Token ausgewählt.',
    'enter_destination_address_first': 'Gib zuerst eine Zieladresse ein.',
    'destination_address_invalid': 'Das Format der Zieladresse ist ungültig.',
    'enter_token_amount_first': 'Gib zuerst einen Token-Betrag ein.',
    'token_amount_positive_integer':
        'Der Token-Betrag muss eine positive ganze Zahl sein.',
    'token_amount_exceeds_balance':
        'Der Token-Betrag überschreitet das aktuelle Token-Guthaben dieses Kontos.',
    'token_transfer_sent_successfully':
        'Token-Übertragung erfolgreich gesendet.',
    'token_transfer_rejected': 'Token-Übertragung abgelehnt: {message}',
    'token_transfer_submission_failed':
        'Übermittlung der Token-Übertragung fehlgeschlagen: {error}',
    'hosted_wallet_runtime_notice':
        'Diese gehostete Wallet verwendet browser-sichere Seed-Speicherung. Der nächste Migrationsschritt ist, Transaktions-, Signatur- und Netzwerkabläufe in die Web-Laufzeit zu verlagern.',
    'unlock_browser_wallet': 'Browser-Wallet entsperren',
    'locked_wallet_description_with_passkey':
        'Diese Browser-Wallet ist gesperrt. Entsperre sie mit einem Passkey oder der 6-stelligen Wallet-PIN.',
    'locked_wallet_description_pin_only':
        'Diese Browser-Wallet ist gesperrt. Entsperre sie mit der 6-stelligen Wallet-PIN.',
    'unlock_with_passkey': 'Mit Passkey entsperren',
    'six_digit_wallet_pin': '6-stellige Wallet-PIN',
    'unlock_with_pin': 'Mit PIN entsperren',
    'pin_unlock_rate_limited':
        'Die PIN-Entsperrung ist nach wiederholten Fehlversuchen vorübergehend begrenzt. Warte auf das Ende der Sperrzeit und versuche es erneut.',
    'recovery_depends_on_seed_phrase':
        'Die Wiederherstellung hängt weiterhin von der Seed-Phrase ab. Passkeys schützen nur den lokalen Zugriff in diesem Browser-Profil.',
    'clear': 'Löschen',
    'hosted_wallet': 'Gehostete Wallet',
    'installable_pwa': 'Installierbare PWA',
    'mainnet_profile': 'Mainnet-Profil',
    'testnet_profile': 'Testnet-Profil',
    'launch_count': 'Start #{count}',
    'wallets': 'Wallets',
    'add_new': 'Neu hinzufügen',
    'no_deterministic_accounts':
        'Es wurden noch keine deterministischen Konten abgeleitet.',
    'account': 'Konto',
    'send_token': '{token} senden',
    'amount_token': 'Betrag ({token})',
    'message': 'Nachricht',
    'optional': 'Optional',
    'optional_message': 'Optionale Nachricht',
    'optional_payload': 'Optionale Nutzlast',
    'token_transfer_operation_note':
        'Die Operation wird automatisch auf token:transfer gesetzt und das Openfield wird für dich erzeugt.',
    'loading_token_balances':
        'Token-Guthaben für das ausgewählte Konto werden geladen...',
    'this_account': 'dieses Konto',
    'no_token_balances_found':
        'Für {account} wurden noch keine Token-Guthaben gefunden.',
    'token_balances_for': 'Token-Guthaben für {account}',
    'no_token_transactions_found':
        'Für {token} wurden auf diesem Konto noch keine Token-Transaktionen gefunden.',
    'no_browser_wallet_yet': 'Noch keine Browser-Wallet',
    'no_browser_wallet_yet_description':
        'Du kannst hier bereits einen im Browser gespeicherten Seed erstellen. Das Importieren einer vorhandenen Mnemonic ist in der Wallet-Einrichtung auf dieser Seite verfügbar.',
    'create_browser_wallet': 'Browser-Wallet erstellen',
    'pwa_shell': 'PWA-Shell',
    'ready': 'Bereit',
    'back': 'Zurück',
    'confirm_mnemonic_backup': 'Mnemonic-Sicherung bestätigen',
    'confirm_mnemonic_backup_description':
        'Wähle die richtigen Wörter für diese zufälligen Positionen aus, bevor die Wallet in diesem Browser-Profil gespeichert wird.',
    'word_number': 'Wort #{position}',
    'confirm_and_save': 'Bestätigen und speichern',
    'back_up_before_saving': 'Vor dem Speichern sichern',
    'back_up_before_saving_description':
        'Diese Wallet ist derzeit nur im Speicher erzeugt. Sichere zuerst Seed und Mnemonic und bestätige dann, um sie in diesem Browser-Profil zu speichern.',
    'generated_seed': 'Erzeugter Seed',
    'generated_mnemonic': 'Erzeugte Mnemonic',
    'copy_seed': 'Seed kopieren',
    'copy_mnemonic': 'Mnemonic kopieren',
    'discard': 'Verwerfen',
    'save_browser_wallet': 'Browser-Wallet speichern',
    'import_24_word_mnemonic': '24-Wort-Mnemonic importieren',
    'mnemonic_storage_note':
        'Hinweis: Deine Mnemonic wird lokal in diesem Browser-Profil gespeichert. Wenn du die Browser-Wallet zurücksetzt, wird die lokale Kopie dauerhaft gelöscht.',
    'create_wallet': 'Wallet erstellen',
    'import_wallet': 'Wallet importieren',
    'scan_import_qr': 'Import-QR scannen',
    'loading_browser_wallet': 'Browser-Wallet wird geladen...',
    'browser_wallet': 'Browser-Wallet',
    'no_browser_wallet_account_selected':
        'Es ist noch kein Browser-Wallet-Konto ausgewählt.',
    'transaction_history': 'Transaktionsverlauf',
    'no_recent_transactions_loaded':
        'Es wurden noch keine aktuellen Transaktionen geladen.',
    'transaction_detail_unavailable': 'Transaktionsdetail ist nicht verfügbar.',
    'last_submission': 'Letzte Übermittlung',
    'submission_error': 'Übermittlungsfehler',
    'status': 'Status',
    'destination': 'Ziel',
    'matched_history_item': 'Zugeordneter Verlaufseintrag',
    'mnemonic_qr_scanned_loaded':
        'Mnemonic-QR gescannt und zum Import geladen.',
    'qr_invalid_mnemonic_or_seed':
        'Der QR-Code enthält keine gültige 24-Wort-Mnemonic oder keinen 64-stelligen Seed.',
    'qr_payment_request_invalid_address':
        'Die QR-Zahlungsanforderung enthält keine gültige Adresse.',
    'payment_qr_scanned_prefilled':
        'Zahlungs-QR gescannt und Sendeformular vorausgefüllt.',
    'address_qr_scanned_prefilled':
        'Adress-QR gescannt und Zieladresse vorausgefüllt.',
    'could_not_parse_payment_qr':
        'Zahlungs-QR konnte nicht verarbeitet werden: {error}',
    'qr_invalid_bismuth_request':
        'Der QR-Code enthält keine gültige Bismuth-Zahlungsanforderung oder Zieladresse.',
    'scanning_deterministic_accounts':
        'Deterministische Konten aus dem importierten Seed werden durchsucht...',
    'opening_account_and_recovering':
        '{status} Konto 1 wird jetzt geöffnet, weitere Konten werden im Hintergrund wiederhergestellt.',
    'failed_reset_browser_wallet_data':
        'Zurücksetzen der Browser-Wallet-Daten fehlgeschlagen: {error}',
    'pin_unlock_temporarily_locked':
        'Die PIN-Entsperrung ist aufgrund wiederholter Fehlversuche vorübergehend gesperrt. Warte, bis die Sperrzeit abgelaufen ist, und versuche es erneut.',
    'passkey_support_without_prf':
        'Dieser Browser meldet Passkey-Unterstützung, aber nicht die PRF-Fähigkeit, die für die lokale Wallet-Entsperrung in diesem Profil erforderlich ist.',
    'twenty_four_word_mnemonic': '24-Wort-Mnemonic',
    'recovered_accounts_from_seed':
        '{count} Konten aus diesem Seed wiederhergestellt.',
    'balance_title': '{name} Wallet',
    'tx_count': '{count} Transaktionen',
    'token_tx_count_on_account': '{count} {token}-Transaktionen',
    'address_hint': 'Adresse eingeben',
    'scan_qr': 'QR-Code scannen',
    'amount': 'Betrag',
    'enter_amount': 'Betrag eingeben',
    'fees': 'Gebühren',
    'operation': 'Operation',
    'transaction_detail': 'Transaktionsdetail',
    'back_to_transactions': 'Zurück zu Transaktionen',
    'sender': 'Sender',
    'recipient': 'Empfänger',
    'timestamp': 'Zeitstempel',
    'block': 'Block',
    'block_hash': 'Block-Hash',
    'transaction_id': 'Transaktions-ID',
    'transaction_ref': 'Transaktionsreferenz',
    'signature': 'Signatur',
    'openfield': 'Openfield',
    'pending': 'Ausstehend',
    'dark': 'Dunkel',
    'light': 'Hell',
  },
  'id': <String, String>{
    'settings': 'Pengaturan',
    'network': 'Jaringan',
    'custom_websocket_api_endpoint': 'Endpoint API Websocket Kustom',
    'preferences': 'Preferensi',
    'currency': 'Mata Uang',
    'language': 'Bahasa',
    'theme': 'Tema',
    'auto': 'Otomatis',
    'dark': 'Gelap',
    'light': 'Terang',
    'mybismuth_non_custodial_wallet': 'Wallet Non-Kustodial myBismuth',
    'security': 'Keamanan',
    'wallet_lock': 'Kunci Wallet',
    'protected': 'Terlindungi',
    'legacy_local_storage': 'Penyimpanan lokal lama',
    'pin_unlock': 'Buka PIN',
    'pin_attempts': 'Percobaan PIN',
    'enabled': 'Aktif',
    'disabled': 'Nonaktif',
    'passkey_unlock': 'Buka dengan passkey',
    'available': 'Tersedia',
    'unsupported': 'Tidak didukung',
    'manage': 'Kelola',
    'reset_browser_wallet': 'Atur Ulang Browser Wallet',
    'connect': 'Hubungkan',
    'enable_passkey_unlock': 'Aktifkan buka dengan passkey',
    'lock_wallet_now': 'Kunci Wallet Sekarang',
    'set_wallet_password': 'Atur PIN Wallet',
    'auth_method': 'Metode Otentikasi',
    'backup_seed_phrase': 'Cadangkan Frasa Seed',
    'close': 'Tutup',
    'cancel': 'Batal',
    'continue': 'Lanjutkan',
    'confirm': 'Konfirmasi',
    'save': 'Simpan',
    'back_to': 'Kembali ke',
    'wallet': 'Wallet',
    'popup': 'Popup',
    'send': 'Kirim',
    'receive': 'Terima',
    'tokens': 'Token',
    'transactions': 'Transaksi',
    'back_to_wallets': 'Kembali ke Wallets',
    'back_to_tokens': 'Kembali ke token',
    'account_label': 'Nama Wallet',
    'rename_account': 'Ubah Nama Akun',
    'show_more_transactions': 'Tampilkan lebih banyak transaksi',
    'show_less': 'Tampilkan lebih sedikit',
    'current_status': 'Status Saat Ini',
    'browser_wallet_storage': 'Penyimpanan Browser Wallet',
    'active': 'Aktif',
    'not_initialized': 'Belum diinisialisasi',
    'migration_notice': 'Catatan migrasi',
    'acknowledged': 'Dikonfirmasi',
    'visible': 'Terlihat',
    'next_actions': 'Tindakan Berikutnya',
    'manage_browser_wallet': 'Kelola Browser Wallet',
    'open_wallet_setup': 'Buka Pengaturan Wallet',
    'copy': 'Salin',
    'clear': 'Hapus',
    'wallets': 'Wallets',
    'add_new': 'Tambah',
    'account': 'Akun',
    'message': 'Pesan',
    'optional': 'Opsional',
    'optional_message': 'Pesan opsional',
    'optional_payload': 'Payload opsional',
    'no_browser_wallet_yet': 'Belum Ada Browser Wallet',
    'create_browser_wallet': 'Buat Browser Wallet',
    'ready': 'Siap',
    'back': 'Kembali',
    'confirm_and_save': 'Konfirmasi dan Simpan',
    'discard': 'Buang',
    'save_browser_wallet': 'Simpan Browser Wallet',
    'create_wallet': 'Buat Wallet',
    'import_wallet': 'Impor Wallet',
    'loading_browser_wallet': 'Memuat Browser Wallet...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': 'Riwayat Transaksi',
    'status': 'Status',
    'destination': 'Tujuan',
    'tx_count': '{count} tx',
    'token_tx_count_on_account': '{count} transaksi {token}',
    'address_hint': 'Masukkan Alamat',
    'scan_qr': 'Pindai Kode QR',
    'amount': 'Jumlah',
    'enter_amount': 'Masukkan Jumlah',
    'fees': 'Biaya',
    'operation': 'Operasi',
    'transaction_detail': 'Detail transaksi',
    'back_to_transactions': 'Kembali ke transaksi',
    'sender': 'Pengirim',
    'recipient': 'Penerima',
    'timestamp': 'Waktu',
    'block': 'Blok',
    'block_hash': 'Hash blok',
    'transaction_id': 'ID transaksi',
    'transaction_ref': 'Referensi transaksi',
    'signature': 'Tanda tangan',
    'openfield': 'Openfield',
    'pending': 'Tertunda',
    'balance_title': '{name} Wallet',
    'api_connection_established': 'Koneksi API berhasil dibuat',
    'no_api_connection_established': 'Koneksi API belum tersedia',
    'refresh_live_data': 'Segarkan data langsung',
    'waiting_for_first_network_sync': 'Menunggu sinkronisasi jaringan pertama',
    'copy_address': 'Salin alamat',
    'wallet_locked': 'Wallet terkunci.',
    'account_address_copied': 'Alamat akun disalin ke clipboard.',
    'account_label_updated': 'Nama akun diperbarui.',
    'websocket_connected': 'Terhubung ke endpoint websocket.',
    'language_preference_saved': 'Preferensi bahasa disimpan.',
    'theme_preference_saved': 'Preferensi tema disimpan.',
    'wallet_unlocked_with_pin': 'Wallet dibuka dengan PIN.',
    'pin_unlock_failed': 'Gagal membuka PIN: {error}',
    'wallet_unlocked_with_passkey': 'Wallet dibuka dengan passkey.',
    'passkey_unlock_failed': 'Gagal membuka passkey: {error}',
    'failed_create_new_account': 'Gagal membuat akun baru: {error}',
    'enter_valid_websocket_endpoint': 'Masukkan endpoint websocket yang valid.',
    'wallet_setup_failed': 'Penyiapan Wallet gagal: {error}',
    'copied_to_clipboard': '{label} disalin ke clipboard.',
    'unsaved_generated_wallet_discarded':
        'Wallet yang dibuat namun belum disimpan dibuang.',
    'set_wallet_pin_title': 'Atur PIN Wallet',
    'six_digit_pin': 'PIN 6 digit',
    'confirm_pin': 'Konfirmasi PIN',
    'wallet_pin_must_be_6_digits': 'PIN Wallet harus tepat 6 digit.',
    'pin_confirmation_no_match': 'Konfirmasi PIN tidak cocok.',
    'backup_seed_phrase_title': 'Cadangkan Seed Phrase',
    'seed_phrase_copied': 'Seed phrase disalin ke clipboard.',
    'current_wallet_pin': 'PIN Wallet Saat Ini',
    'passkey_enrollment_failed': 'Pendaftaran passkey gagal: {error}',
    'confirm_transaction': 'Konfirmasi Transaksi',
    'send_amount_to': 'Kirim {amount} BIS ke:',
    'estimated_fee_label': 'Perkiraan biaya: {fee} BIS',
    'operation_value': 'Operasi: {value}',
    'transaction_rejected': 'Transaksi ditolak: {message}',
    'transaction_submission_failed': 'Pengiriman transaksi gagal: {error}',
    'no_token_selected_for_transfer':
        'Tidak ada token yang dipilih untuk transfer ini.',
    'enter_destination_address_first':
        'Masukkan alamat tujuan terlebih dahulu.',
    'destination_address_invalid': 'Format alamat tujuan tidak valid.',
    'enter_token_amount_first': 'Masukkan jumlah token terlebih dahulu.',
    'token_amount_positive_integer':
        'Jumlah token harus berupa bilangan bulat positif.',
    'token_transfer_sent_successfully': 'Transfer token berhasil dikirim.',
    'token_transfer_rejected': 'Transfer token ditolak: {message}',
    'unlock_browser_wallet': 'Buka Browser Wallet',
    'unlock_with_passkey': 'Buka dengan Passkey',
    'six_digit_wallet_pin': 'PIN Wallet 6 digit',
    'unlock_with_pin': 'Buka dengan PIN',
    'hosted_wallet': 'Wallet Hosted',
    'installable_pwa': 'PWA yang dapat dipasang',
    'mainnet_profile': 'Profil mainnet',
    'testnet_profile': 'Profil testnet',
    'launch_count': 'Peluncuran #{count}',
    'send_token': 'Kirim {token}',
    'amount_token': 'Jumlah ({token})',
    'this_account': 'akun ini',
    'token_balances_for': 'Saldo token untuk {account}',
    'pwa_shell': 'Shell PWA',
    'confirm_mnemonic_backup': 'Konfirmasi Cadangan Mnemonic',
    'word_number': 'Kata #{position}',
    'back_up_before_saving': 'Cadangkan Sebelum Menyimpan',
    'generated_seed': 'Seed yang dihasilkan',
    'generated_mnemonic': 'Mnemonic yang dihasilkan',
    'copy_seed': 'Salin Seed',
    'copy_mnemonic': 'Salin Mnemonic',
    'import_24_word_mnemonic': 'Impor mnemonic 24 kata',
    'scan_import_qr': 'Pindai QR Impor',
    'no_recent_transactions_loaded': 'Belum ada transaksi terbaru yang dimuat.',
    'transaction_detail_unavailable': 'Detail transaksi tidak tersedia.',
    'last_submission': 'Pengiriman Terakhir',
    'submission_error': 'Kesalahan Pengiriman',
    'matched_history_item': 'Item riwayat yang cocok',
    'mnemonic_qr_scanned_loaded':
        'QR mnemonic dipindai dan dimuat untuk impor.',
    'could_not_parse_payment_qr':
        'Tidak dapat memproses QR pembayaran: {error}',
    'twenty_four_word_mnemonic': 'Mnemonic 24 kata',
  },
  'nl': <String, String>{
    'settings': 'Instellingen',
    'network': 'Netwerk',
    'custom_websocket_api_endpoint': 'Aangepast Websocket API-eindpunt',
    'preferences': 'Voorkeuren',
    'currency': 'Valuta',
    'language': 'Taal',
    'theme': 'Thema',
    'auto': 'Auto',
    'dark': 'Donker',
    'light': 'Licht',
    'mybismuth_non_custodial_wallet': 'myBismuth Wallet zonder bewaring',
    'security': 'Beveiliging',
    'wallet_lock': 'Wallet-vergrendeling',
    'protected': 'Beveiligd',
    'legacy_local_storage': 'Verouderde lokale opslag',
    'pin_unlock': 'PIN-ontgrendeling',
    'pin_attempts': 'PIN-pogingen',
    'enabled': 'Ingeschakeld',
    'disabled': 'Uitgeschakeld',
    'passkey_unlock': 'Passkey-ontgrendeling',
    'available': 'Beschikbaar',
    'unsupported': 'Niet ondersteund',
    'manage': 'Beheren',
    'reset_browser_wallet': 'Browser Wallet resetten',
    'connect': 'Verbinden',
    'enable_passkey_unlock': 'Passkey-ontgrendeling inschakelen',
    'lock_wallet_now': 'Wallet nu vergrendelen',
    'set_wallet_password': 'Wallet-PIN instellen',
    'auth_method': 'Authenticatiemethode',
    'backup_seed_phrase': 'Seedzin back-uppen',
    'close': 'Sluiten',
    'cancel': 'Annuleren',
    'continue': 'Doorgaan',
    'confirm': 'Bevestigen',
    'save': 'Opslaan',
    'back_to': 'Terug naar',
    'wallet': 'Wallet',
    'popup': 'Popup',
    'send': 'Verzenden',
    'receive': 'Ontvangen',
    'tokens': 'Tokens',
    'transactions': 'Transacties',
    'back_to_wallets': 'Terug naar Wallets',
    'back_to_tokens': 'Terug naar tokens',
    'account_label': 'Walletnaam',
    'rename_account': 'Account hernoemen',
    'show_more_transactions': 'Meer transacties tonen',
    'show_less': 'Minder tonen',
    'current_status': 'Huidige status',
    'browser_wallet_storage': 'Browser Wallet-opslag',
    'active': 'Actief',
    'not_initialized': 'Niet geinitialiseerd',
    'migration_notice': 'Migratiemelding',
    'acknowledged': 'Bevestigd',
    'visible': 'Zichtbaar',
    'next_actions': 'Volgende acties',
    'manage_browser_wallet': 'Browser Wallet beheren',
    'open_wallet_setup': 'Wallet-instelling openen',
    'copy': 'Kopieren',
    'clear': 'Wissen',
    'wallets': 'Wallets',
    'add_new': 'Toevoegen',
    'account': 'Account',
    'message': 'Bericht',
    'optional': 'Optioneel',
    'optional_message': 'Optioneel bericht',
    'optional_payload': 'Optionele payload',
    'no_browser_wallet_yet': 'Nog geen Browser Wallet',
    'create_browser_wallet': 'Browser Wallet maken',
    'ready': 'Gereed',
    'back': 'Terug',
    'confirm_and_save': 'Bevestigen en opslaan',
    'discard': 'Verwerpen',
    'save_browser_wallet': 'Browser Wallet opslaan',
    'create_wallet': 'Wallet maken',
    'import_wallet': 'Wallet importeren',
    'loading_browser_wallet': 'Browser Wallet laden...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': 'Transactiegeschiedenis',
    'status': 'Status',
    'destination': 'Bestemming',
    'tx_count': '{count} txs',
    'token_tx_count_on_account': '{count} {token}-transacties',
    'address_hint': 'Adres invoeren',
    'scan_qr': 'QR-code scannen',
    'amount': 'Bedrag',
    'enter_amount': 'Bedrag invoeren',
    'fees': 'Kosten',
    'operation': 'Operatie',
    'transaction_detail': 'Transactiedetail',
    'back_to_transactions': 'Terug naar transacties',
    'sender': 'Afzender',
    'recipient': 'Ontvanger',
    'timestamp': 'Tijdstip',
    'block': 'Blok',
    'block_hash': 'Blockhash',
    'transaction_id': 'Transactie-ID',
    'transaction_ref': 'Transactiereferentie',
    'signature': 'Handtekening',
    'openfield': 'Openfield',
    'pending': 'In behandeling',
    'balance_title': '{name} Wallet',
    'api_connection_established': 'API-verbinding tot stand gebracht',
    'no_api_connection_established': 'Geen API-verbinding beschikbaar',
    'refresh_live_data': 'Livegegevens verversen',
    'waiting_for_first_network_sync':
        'Wachten op de eerste netwerksynchronisatie',
    'copy_address': 'Adres kopieren',
    'wallet_locked': 'Wallet vergrendeld.',
    'account_address_copied': 'Accountadres gekopieerd naar klembord.',
    'account_label_updated': 'Accountnaam bijgewerkt.',
    'websocket_connected': 'Verbonden met websocket-eindpunt.',
    'language_preference_saved': 'Taalvoorkeur opgeslagen.',
    'theme_preference_saved': 'Thema-voorkeur opgeslagen.',
    'wallet_unlocked_with_pin': 'Wallet ontgrendeld met PIN.',
    'pin_unlock_failed': 'PIN-ontgrendeling mislukt: {error}',
    'wallet_unlocked_with_passkey': 'Wallet ontgrendeld met passkey.',
    'passkey_unlock_failed': 'Passkey-ontgrendeling mislukt: {error}',
    'failed_create_new_account': 'Nieuw account maken mislukt: {error}',
    'enter_valid_websocket_endpoint': 'Voer een geldig websocket-eindpunt in.',
    'wallet_setup_failed': 'Wallet-instelling mislukt: {error}',
    'copied_to_clipboard': '{label} gekopieerd naar het klembord.',
    'unsaved_generated_wallet_discarded':
        'Niet-opgeslagen gegenereerde Wallet weggegooid.',
    'set_wallet_pin_title': 'Wallet-PIN instellen',
    'six_digit_pin': '6-cijferige PIN',
    'confirm_pin': 'PIN bevestigen',
    'wallet_pin_must_be_6_digits':
        'Wallet-PIN moet precies 6 cijfers bevatten.',
    'pin_confirmation_no_match': 'PIN-bevestiging komt niet overeen.',
    'backup_seed_phrase_title': 'Seed phrase back-uppen',
    'seed_phrase_copied': 'Seed phrase gekopieerd naar het klembord.',
    'current_wallet_pin': 'Huidige Wallet-PIN',
    'passkey_enrollment_failed': 'Passkey-registratie mislukt: {error}',
    'confirm_transaction': 'Transactie bevestigen',
    'send_amount_to': 'Verzend {amount} BIS naar:',
    'estimated_fee_label': 'Geschatte kosten: {fee} BIS',
    'operation_value': 'Operatie: {value}',
    'transaction_rejected': 'Transactie afgewezen: {message}',
    'transaction_submission_failed': 'Transactie indienen mislukt: {error}',
    'no_token_selected_for_transfer':
        'Er is geen token geselecteerd voor deze overdracht.',
    'enter_destination_address_first': 'Voer eerst een bestemmingsadres in.',
    'destination_address_invalid':
        'Het formaat van het bestemmingsadres is ongeldig.',
    'enter_token_amount_first': 'Voer eerst een tokenbedrag in.',
    'token_amount_positive_integer':
        'Het tokenbedrag moet een positief geheel getal zijn.',
    'token_transfer_sent_successfully': 'Tokenoverdracht succesvol verzonden.',
    'token_transfer_rejected': 'Tokenoverdracht afgewezen: {message}',
    'unlock_browser_wallet': 'Browser Wallet ontgrendelen',
    'unlock_with_passkey': 'Ontgrendelen met passkey',
    'six_digit_wallet_pin': '6-cijferige Wallet-PIN',
    'unlock_with_pin': 'Ontgrendelen met PIN',
    'hosted_wallet': 'Gehoste Wallet',
    'installable_pwa': 'Installeerbare PWA',
    'mainnet_profile': 'Mainnet-profiel',
    'testnet_profile': 'Testnet-profiel',
    'launch_count': 'Start #{count}',
    'send_token': '{token} verzenden',
    'amount_token': 'Bedrag ({token})',
    'this_account': 'deze account',
    'token_balances_for': 'Tokensaldi voor {account}',
    'pwa_shell': 'PWA-shell',
    'confirm_mnemonic_backup': 'Mnemonic-back-up bevestigen',
    'word_number': 'Woord #{position}',
    'back_up_before_saving': 'Back-up maken voor opslaan',
    'generated_seed': 'Gegenereerde seed',
    'generated_mnemonic': 'Gegenereerde mnemonic',
    'copy_seed': 'Seed kopieren',
    'copy_mnemonic': 'Mnemonic kopieren',
    'import_24_word_mnemonic': '24-woord mnemonic importeren',
    'scan_import_qr': 'Import-QR scannen',
    'no_recent_transactions_loaded': 'Nog geen recente transacties geladen.',
    'transaction_detail_unavailable': 'Transactiedetail is niet beschikbaar.',
    'last_submission': 'Laatste verzending',
    'submission_error': 'Verzendfout',
    'matched_history_item': 'Overeenkomend geschiedenisitem',
    'mnemonic_qr_scanned_loaded': 'Mnemonic-QR gescand en geladen voor import.',
    'could_not_parse_payment_qr': 'Kon betalings-QR niet verwerken: {error}',
    'twenty_four_word_mnemonic': '24-woord mnemonic',
  },
  'es': <String, String>{
    'settings': 'Configuracion',
    'network': 'Red',
    'custom_websocket_api_endpoint': 'Endpoint API Websocket Personalizado',
    'preferences': 'Preferencias',
    'currency': 'Moneda',
    'language': 'Idioma',
    'theme': 'Tema',
    'auto': 'Auto',
    'dark': 'Oscuro',
    'light': 'Claro',
    'mybismuth_non_custodial_wallet': 'Wallet no custodial myBismuth',
    'security': 'Seguridad',
    'wallet_lock': 'Bloqueo de Wallet',
    'protected': 'Protegido',
    'legacy_local_storage': 'Almacenamiento local heredado',
    'pin_unlock': 'Desbloqueo por PIN',
    'pin_attempts': 'Intentos de PIN',
    'enabled': 'Habilitado',
    'disabled': 'Deshabilitado',
    'passkey_unlock': 'Desbloqueo por passkey',
    'available': 'Disponible',
    'unsupported': 'No compatible',
    'manage': 'Gestionar',
    'reset_browser_wallet': 'Restablecer Browser Wallet',
    'connect': 'Conectar',
    'enable_passkey_unlock': 'Habilitar desbloqueo por passkey',
    'lock_wallet_now': 'Bloquear Wallet Ahora',
    'set_wallet_password': 'Establecer PIN de la billetera',
    'auth_method': 'Metodo de autenticacion',
    'backup_seed_phrase': 'Respaldar frase secreta',
    'close': 'Cerrar',
    'cancel': 'Cancelar',
    'continue': 'Continuar',
    'confirm': 'Confirmar',
    'save': 'Guardar',
    'back_to': 'Volver a',
    'wallet': 'Wallet',
    'popup': 'Popup',
    'send': 'Enviar',
    'receive': 'Recibir',
    'tokens': 'Tokens',
    'transactions': 'Transacciones',
    'back_to_wallets': 'Volver a Wallets',
    'back_to_tokens': 'Volver a tokens',
    'account_label': 'Nombre del Wallet',
    'rename_account': 'Renombrar cuenta',
    'show_more_transactions': 'Mostrar mas transacciones',
    'show_less': 'Mostrar menos',
    'current_status': 'Estado actual',
    'browser_wallet_storage': 'Almacenamiento de Browser Wallet',
    'active': 'Activo',
    'not_initialized': 'No inicializado',
    'migration_notice': 'Aviso de migracion',
    'acknowledged': 'Confirmado',
    'visible': 'Visible',
    'next_actions': 'Siguientes acciones',
    'manage_browser_wallet': 'Gestionar Browser Wallet',
    'open_wallet_setup': 'Abrir configuracion de Wallet',
    'copy': 'Copiar',
    'clear': 'Limpiar',
    'wallets': 'Wallets',
    'add_new': 'Agregar',
    'account': 'Cuenta',
    'message': 'Mensaje',
    'optional': 'Opcional',
    'optional_message': 'Mensaje opcional',
    'optional_payload': 'Carga opcional',
    'no_browser_wallet_yet': 'Aun no hay Browser Wallet',
    'create_browser_wallet': 'Crear Browser Wallet',
    'ready': 'Listo',
    'back': 'Atras',
    'confirm_and_save': 'Confirmar y guardar',
    'discard': 'Descartar',
    'save_browser_wallet': 'Guardar Browser Wallet',
    'create_wallet': 'Crear Wallet',
    'import_wallet': 'Importar Wallet',
    'loading_browser_wallet': 'Cargando Browser Wallet...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': 'Historial de transacciones',
    'status': 'Estado',
    'destination': 'Destino',
    'tx_count': '{count} txs',
    'token_tx_count_on_account': '{count} transacciones de {token}',
    'address_hint': 'Ingresar direccion',
    'scan_qr': 'Escanear codigo QR',
    'amount': 'Monto',
    'enter_amount': 'Ingresar monto',
    'fees': 'Comisiones',
    'operation': 'Operacion',
    'transaction_detail': 'Detalle de transaccion',
    'back_to_transactions': 'Volver a transacciones',
    'sender': 'Remitente',
    'recipient': 'Destinatario',
    'timestamp': 'Marca de tiempo',
    'block': 'Bloque',
    'block_hash': 'Hash del bloque',
    'transaction_id': 'ID de transaccion',
    'transaction_ref': 'Referencia de transaccion',
    'signature': 'Firma',
    'openfield': 'Openfield',
    'pending': 'Pendiente',
    'balance_title': '{name} Wallet',
    'api_connection_established': 'Conexion API establecida',
    'no_api_connection_established': 'No se establecio conexion API',
    'refresh_live_data': 'Actualizar datos en vivo',
    'waiting_for_first_network_sync':
        'Esperando la primera sincronizacion de red',
    'copy_address': 'Copiar direccion',
    'wallet_locked': 'Wallet bloqueado.',
    'account_address_copied': 'Direccion de la cuenta copiada al portapapeles.',
    'account_label_updated': 'Nombre de la cuenta actualizado.',
    'websocket_connected': 'Conectado al endpoint websocket.',
    'language_preference_saved': 'Preferencia de idioma guardada.',
    'theme_preference_saved': 'Preferencia de tema guardada.',
    'wallet_unlocked_with_pin': 'Wallet desbloqueado con PIN.',
    'pin_unlock_failed': 'Error al desbloquear PIN: {error}',
    'wallet_unlocked_with_passkey': 'Wallet desbloqueado con passkey.',
    'passkey_unlock_failed': 'Error al desbloquear con passkey: {error}',
    'failed_create_new_account': 'Error al crear una nueva cuenta: {error}',
    'enter_valid_websocket_endpoint': 'Ingresa un endpoint websocket valido.',
    'wallet_setup_failed': 'La configuracion del Wallet fallo: {error}',
    'copied_to_clipboard': '{label} copiado al portapapeles.',
    'unsaved_generated_wallet_discarded':
        'Wallet generado no guardado descartado.',
    'set_wallet_pin_title': 'Establecer PIN del Wallet',
    'six_digit_pin': 'PIN de 6 digitos',
    'confirm_pin': 'Confirmar PIN',
    'wallet_pin_must_be_6_digits':
        'El PIN del Wallet debe tener exactamente 6 digitos.',
    'pin_confirmation_no_match': 'La confirmacion del PIN no coincide.',
    'backup_seed_phrase_title': 'Respaldar Seed Phrase',
    'seed_phrase_copied': 'Seed phrase copiada al portapapeles.',
    'current_wallet_pin': 'PIN actual del Wallet',
    'passkey_enrollment_failed': 'Error al registrar la passkey: {error}',
    'confirm_transaction': 'Confirmar transaccion',
    'send_amount_to': 'Enviar {amount} BIS a:',
    'estimated_fee_label': 'Comision estimada: {fee} BIS',
    'operation_value': 'Operacion: {value}',
    'transaction_rejected': 'Transaccion rechazada: {message}',
    'transaction_submission_failed': 'Error al enviar la transaccion: {error}',
    'no_token_selected_for_transfer':
        'No hay ningun token seleccionado para esta transferencia.',
    'enter_destination_address_first':
        'Ingresa primero una direccion de destino.',
    'destination_address_invalid':
        'El formato de la direccion de destino no es valido.',
    'enter_token_amount_first': 'Ingresa primero una cantidad de token.',
    'token_amount_positive_integer':
        'La cantidad de token debe ser un entero positivo.',
    'token_transfer_sent_successfully':
        'Transferencia de token enviada con exito.',
    'token_transfer_rejected': 'Transferencia de token rechazada: {message}',
    'unlock_browser_wallet': 'Desbloquear Browser Wallet',
    'unlock_with_passkey': 'Desbloquear con passkey',
    'six_digit_wallet_pin': 'PIN de Wallet de 6 digitos',
    'unlock_with_pin': 'Desbloquear con PIN',
    'hosted_wallet': 'Wallet alojado',
    'installable_pwa': 'PWA instalable',
    'mainnet_profile': 'Perfil mainnet',
    'testnet_profile': 'Perfil testnet',
    'launch_count': 'Inicio #{count}',
    'send_token': 'Enviar {token}',
    'amount_token': 'Cantidad ({token})',
    'this_account': 'esta cuenta',
    'token_balances_for': 'Balances de tokens para {account}',
    'pwa_shell': 'Shell PWA',
    'confirm_mnemonic_backup': 'Confirmar respaldo de mnemonic',
    'word_number': 'Palabra #{position}',
    'back_up_before_saving': 'Respaldar antes de guardar',
    'generated_seed': 'Seed generada',
    'generated_mnemonic': 'Mnemonic generada',
    'copy_seed': 'Copiar Seed',
    'copy_mnemonic': 'Copiar Mnemonic',
    'import_24_word_mnemonic': 'Importar mnemonic de 24 palabras',
    'scan_import_qr': 'Escanear QR de importacion',
    'no_recent_transactions_loaded':
        'Aun no se cargaron transacciones recientes.',
    'transaction_detail_unavailable':
        'El detalle de la transaccion no esta disponible.',
    'last_submission': 'Ultimo envio',
    'submission_error': 'Error de envio',
    'matched_history_item': 'Elemento del historial coincidente',
    'mnemonic_qr_scanned_loaded':
        'QR de mnemonic escaneado y cargado para importar.',
    'could_not_parse_payment_qr':
        'No se pudo interpretar el QR de pago: {error}',
    'twenty_four_word_mnemonic': 'Mnemonic de 24 palabras',
  },
  'it': <String, String>{
    'settings': 'Impostazioni',
    'network': 'Rete',
    'custom_websocket_api_endpoint': 'Endpoint API Websocket Personalizzato',
    'preferences': 'Preferenze',
    'currency': 'Valuta',
    'language': 'Lingua',
    'theme': 'Tema',
    'auto': 'Auto',
    'dark': 'Scuro',
    'light': 'Chiaro',
    'mybismuth_non_custodial_wallet': 'Wallet myBismuth non-custodial',
    'security': 'Sicurezza',
    'wallet_lock': 'Blocco Wallet',
    'protected': 'Protetto',
    'legacy_local_storage': 'Archiviazione locale legacy',
    'pin_unlock': 'Sblocco PIN',
    'pin_attempts': 'Tentativi PIN',
    'enabled': 'Abilitato',
    'disabled': 'Disabilitato',
    'passkey_unlock': 'Sblocco con passkey',
    'available': 'Disponibile',
    'unsupported': 'Non supportato',
    'manage': 'Gestisci',
    'reset_browser_wallet': 'Reimposta Browser Wallet',
    'connect': 'Connetti',
    'enable_passkey_unlock': 'Abilita sblocco con passkey',
    'lock_wallet_now': 'Blocca Wallet Ora',
    'set_wallet_password': 'Imposta PIN del wallet',
    'auth_method': 'Metodo di autenticazione',
    'backup_seed_phrase': 'Backup frase segreta',
    'close': 'Chiudi',
    'cancel': 'Annulla',
    'continue': 'Continua',
    'confirm': 'Conferma',
    'save': 'Salva',
    'back_to': 'Torna a',
    'wallet': 'Wallet',
    'popup': 'Popup',
    'send': 'Invia',
    'receive': 'Ricevi',
    'tokens': 'Token',
    'transactions': 'Transazioni',
    'back_to_wallets': 'Torna ai Wallets',
    'back_to_tokens': 'Torna ai token',
    'account_label': 'Nome Wallet',
    'rename_account': 'Rinomina account',
    'show_more_transactions': 'Mostra piu transazioni',
    'show_less': 'Mostra meno',
    'current_status': 'Stato attuale',
    'browser_wallet_storage': 'Archiviazione Browser Wallet',
    'active': 'Attivo',
    'not_initialized': 'Non inizializzato',
    'migration_notice': 'Avviso di migrazione',
    'acknowledged': 'Confermato',
    'visible': 'Visibile',
    'next_actions': 'Azioni successive',
    'manage_browser_wallet': 'Gestisci Browser Wallet',
    'open_wallet_setup': 'Apri configurazione Wallet',
    'copy': 'Copia',
    'clear': 'Cancella',
    'wallets': 'Wallets',
    'add_new': 'Aggiungi',
    'account': 'Account',
    'message': 'Messaggio',
    'optional': 'Opzionale',
    'optional_message': 'Messaggio opzionale',
    'optional_payload': 'Payload opzionale',
    'no_browser_wallet_yet': 'Nessun Browser Wallet',
    'create_browser_wallet': 'Crea Browser Wallet',
    'ready': 'Pronto',
    'back': 'Indietro',
    'confirm_and_save': 'Conferma e salva',
    'discard': 'Scarta',
    'save_browser_wallet': 'Salva Browser Wallet',
    'create_wallet': 'Crea Wallet',
    'import_wallet': 'Importa Wallet',
    'loading_browser_wallet': 'Caricamento Browser Wallet...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': 'Cronologia transazioni',
    'status': 'Stato',
    'destination': 'Destinazione',
    'tx_count': '{count} tx',
    'token_tx_count_on_account': '{count} transazioni {token}',
    'address_hint': 'Inserisci indirizzo',
    'scan_qr': 'Scansiona codice QR',
    'amount': 'Importo',
    'enter_amount': 'Inserisci importo',
    'fees': 'Commissioni',
    'operation': 'Operazione',
    'transaction_detail': 'Dettaglio transazione',
    'back_to_transactions': 'Torna alle transazioni',
    'sender': 'Mittente',
    'recipient': 'Destinatario',
    'timestamp': 'Timestamp',
    'block': 'Blocco',
    'block_hash': 'Hash blocco',
    'transaction_id': 'ID transazione',
    'transaction_ref': 'Riferimento transazione',
    'signature': 'Firma',
    'openfield': 'Openfield',
    'pending': 'In sospeso',
    'balance_title': '{name} Wallet',
    'api_connection_established': 'Connessione API stabilita',
    'no_api_connection_established': 'Nessuna connessione API stabilita',
    'refresh_live_data': 'Aggiorna dati live',
    'waiting_for_first_network_sync':
        'In attesa della prima sincronizzazione di rete',
    'copy_address': 'Copia indirizzo',
    'wallet_locked': 'Wallet bloccato.',
    'account_address_copied': 'Indirizzo account copiato negli appunti.',
    'account_label_updated': 'Nome account aggiornato.',
    'websocket_connected': 'Connesso all endpoint websocket.',
    'language_preference_saved': 'Preferenza lingua salvata.',
    'theme_preference_saved': 'Preferenza tema salvata.',
    'wallet_unlocked_with_pin': 'Wallet sbloccato con PIN.',
    'pin_unlock_failed': 'Sblocco PIN non riuscito: {error}',
    'wallet_unlocked_with_passkey': 'Wallet sbloccato con passkey.',
    'passkey_unlock_failed': 'Sblocco con passkey non riuscito: {error}',
    'failed_create_new_account':
        'Creazione di un nuovo account non riuscita: {error}',
    'enter_valid_websocket_endpoint': 'Inserisci un endpoint websocket valido.',
    'wallet_setup_failed': 'Configurazione Wallet non riuscita: {error}',
    'copied_to_clipboard': '{label} copiato negli appunti.',
    'unsaved_generated_wallet_discarded':
        'Wallet generato non salvato scartato.',
    'set_wallet_pin_title': 'Imposta PIN del Wallet',
    'six_digit_pin': 'PIN a 6 cifre',
    'confirm_pin': 'Conferma PIN',
    'wallet_pin_must_be_6_digits':
        'Il PIN del Wallet deve essere di esattamente 6 cifre.',
    'pin_confirmation_no_match': 'La conferma del PIN non corrisponde.',
    'backup_seed_phrase_title': 'Backup Seed Phrase',
    'seed_phrase_copied': 'Seed phrase copiata negli appunti.',
    'current_wallet_pin': 'PIN Wallet attuale',
    'passkey_enrollment_failed': 'Registrazione passkey non riuscita: {error}',
    'confirm_transaction': 'Conferma transazione',
    'send_amount_to': 'Invia {amount} BIS a:',
    'estimated_fee_label': 'Commissione stimata: {fee} BIS',
    'operation_value': 'Operazione: {value}',
    'transaction_rejected': 'Transazione rifiutata: {message}',
    'transaction_submission_failed':
        'Invio della transazione non riuscito: {error}',
    'no_token_selected_for_transfer':
        'Nessun token selezionato per questo trasferimento.',
    'enter_destination_address_first':
        'Inserisci prima un indirizzo di destinazione.',
    'destination_address_invalid':
        'Il formato dell indirizzo di destinazione non e valido.',
    'enter_token_amount_first': 'Inserisci prima un importo di token.',
    'token_amount_positive_integer':
        'L importo del token deve essere un intero positivo.',
    'token_transfer_sent_successfully':
        'Trasferimento token inviato con successo.',
    'token_transfer_rejected': 'Trasferimento token rifiutato: {message}',
    'unlock_browser_wallet': 'Sblocca Browser Wallet',
    'unlock_with_passkey': 'Sblocca con passkey',
    'six_digit_wallet_pin': 'PIN Wallet a 6 cifre',
    'unlock_with_pin': 'Sblocca con PIN',
    'hosted_wallet': 'Wallet ospitato',
    'installable_pwa': 'PWA installabile',
    'mainnet_profile': 'Profilo mainnet',
    'testnet_profile': 'Profilo testnet',
    'launch_count': 'Avvio #{count}',
    'send_token': 'Invia {token}',
    'amount_token': 'Importo ({token})',
    'this_account': 'questo account',
    'token_balances_for': 'Saldi token per {account}',
    'pwa_shell': 'Shell PWA',
    'confirm_mnemonic_backup': 'Conferma backup mnemonic',
    'word_number': 'Parola #{position}',
    'back_up_before_saving': 'Fai il backup prima di salvare',
    'generated_seed': 'Seed generato',
    'generated_mnemonic': 'Mnemonic generata',
    'copy_seed': 'Copia Seed',
    'copy_mnemonic': 'Copia Mnemonic',
    'import_24_word_mnemonic': 'Importa mnemonic da 24 parole',
    'scan_import_qr': 'Scansiona QR di importazione',
    'no_recent_transactions_loaded':
        'Nessuna transazione recente caricata finora.',
    'transaction_detail_unavailable':
        'Il dettaglio della transazione non e disponibile.',
    'last_submission': 'Ultimo invio',
    'submission_error': 'Errore di invio',
    'matched_history_item': 'Elemento cronologia corrispondente',
    'mnemonic_qr_scanned_loaded':
        'QR mnemonic scansionato e caricato per importazione.',
    'could_not_parse_payment_qr':
        'Impossibile analizzare il QR di pagamento: {error}',
    'twenty_four_word_mnemonic': 'Mnemonic di 24 parole',
  },
  'ru': <String, String>{
    'settings': 'Настройки',
    'network': 'Сеть',
    'custom_websocket_api_endpoint': 'Пользовательский Websocket API Endpoint',
    'preferences': 'Параметры',
    'currency': 'Валюта',
    'language': 'Язык',
    'theme': 'Тема',
    'auto': 'Авто',
    'mybismuth_non_custodial_wallet': 'myBismuth некастодиальный Wallet',
    'security': 'Безопасность',
    'wallet_lock': 'Блокировка Wallet',
    'protected': 'Защищено',
    'legacy_local_storage': 'Устаревшее локальное хранилище',
    'pin_unlock': 'Разблокировка PIN',
    'pin_attempts': 'Попытки PIN',
    'enabled': 'Включено',
    'disabled': 'Отключено',
    'passkey_unlock': 'Разблокировка Passkey',
    'available': 'Доступно',
    'unsupported': 'Не поддерживается',
    'manage': 'Управление',
    'reset_browser_wallet': 'Сбросить Browser Wallet',
    'connect': 'Подключить',
    'enable_passkey_unlock': 'Включить разблокировку Passkey',
    'lock_wallet_now': 'Заблокировать Wallet',
    'set_wallet_password': 'Установить PIN Wallet',
    'auth_method': 'Способ аутентификации',
    'backup_seed_phrase': 'Сохранить seed-фразу',
    'close': 'Закрыть',
    'cancel': 'Отмена',
    'continue': 'Продолжить',
    'confirm': 'Подтвердить',
    'save': 'Сохранить',
    'back_to': 'Назад к',
    'wallet': 'Wallet',
    'popup': 'Popup',
    'send': 'Отправить',
    'receive': 'Получить',
    'tokens': 'Токены',
    'transactions': 'Транзакции',
    'back_to_wallets': 'Назад к Wallets',
    'back_to_tokens': 'Назад к токенам',
    'account_label': 'Имя Wallet',
    'rename_account': 'Переименовать аккаунт',
    'show_more_transactions': 'Показать больше транзакций',
    'show_less': 'Показать меньше',
    'api_connection_established': 'Подключение к API установлено',
    'no_api_connection_established': 'Подключение к API не установлено',
    'refresh_live_data': 'Обновить данные',
    'waiting_for_first_network_sync': 'Ожидание первой синхронизации с сетью',
    'copy_address': 'Скопировать адрес',
    'wallet_locked': 'Wallet заблокирован.',
    'account_address_copied': 'Адрес аккаунта скопирован в буфер обмена.',
    'account_label_updated': 'Имя аккаунта обновлено.',
    'websocket_connected': 'Подключено к Websocket endpoint.',
    'current_status': 'Текущий статус',
    'browser_wallet_storage': 'Хранилище Browser Wallet',
    'active': 'Активно',
    'not_initialized': 'Не инициализировано',
    'migration_notice': 'Уведомление о миграции',
    'acknowledged': 'Подтверждено',
    'visible': 'Видимо',
    'next_actions': 'Следующие действия',
    'manage_browser_wallet': 'Управление Browser Wallet',
    'open_wallet_setup': 'Открыть настройку Wallet',
    'jump_to_browser_wallet_section':
        'Перейти к разделу Browser Wallet на этой странице.',
    'open_wallet_manager_browser_wallet_section':
        'Открыть менеджер Wallet и перейти к разделу Browser Wallet.',
    'use_wallet_setup_view':
        'Используйте настройку Wallet, чтобы импортировать существующую mnemonic или изменить настройки Wallet.',
    'language_preference_saved': 'Языковые настройки сохранены.',
    'auth_preference_saved':
        'Настройки аутентификации сохранены. Полная локализация browser shell еще не подключена.',
    'theme_preference_saved': 'Настройки темы сохранены.',
    'copy': 'Копировать',
    'clear': 'Очистить',
    'wallets': 'Wallets',
    'add_new': 'Добавить',
    'account': 'Аккаунт',
    'message': 'Сообщение',
    'optional': 'Необязательно',
    'optional_message': 'Необязательное сообщение',
    'optional_payload': 'Необязательная нагрузка',
    'no_browser_wallet_yet': 'Browser Wallet еще не создан',
    'create_browser_wallet': 'Создать Browser Wallet',
    'ready': 'Готово',
    'back': 'Назад',
    'confirm_and_save': 'Подтвердить и сохранить',
    'discard': 'Отменить',
    'save_browser_wallet': 'Сохранить Browser Wallet',
    'create_wallet': 'Создать Wallet',
    'import_wallet': 'Импортировать Wallet',
    'loading_browser_wallet': 'Загрузка Browser Wallet...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': 'История транзакций',
    'status': 'Статус',
    'destination': 'Получатель',
    'address_hint': 'Введите адрес',
    'scan_qr': 'Сканировать QR-код',
    'amount': 'Сумма',
    'enter_amount': 'Введите сумму',
    'fees': 'Комиссии',
    'operation': 'Операция',
    'transaction_detail': 'Детали транзакции',
    'back_to_transactions': 'Назад к транзакциям',
    'sender': 'Отправитель',
    'recipient': 'Получатель',
    'timestamp': 'Время',
    'block': 'Блок',
    'block_hash': 'Хеш блока',
    'transaction_id': 'ID транзакции',
    'transaction_ref': 'Ссылка транзакции',
    'signature': 'Подпись',
    'openfield': 'Openfield',
    'pending': 'В ожидании',
    'balance_title': '{name} Wallet',
    'dark': 'Темная',
    'light': 'Светлая',
    'wallet_unlocked_with_pin': 'Wallet разблокирован с помощью PIN.',
    'pin_unlock_failed': 'Не удалось разблокировать PIN: {error}',
    'wallet_unlocked_with_passkey': 'Wallet разблокирован с помощью passkey.',
    'passkey_unlock_failed': 'Не удалось разблокировать через passkey: {error}',
    'failed_create_new_account': 'Не удалось создать новый аккаунт: {error}',
    'enter_valid_websocket_endpoint': 'Введите корректный websocket endpoint.',
    'wallet_setup_failed': 'Не удалось настроить Wallet: {error}',
    'copied_to_clipboard': '{label} скопировано в буфер обмена.',
    'unsaved_generated_wallet_discarded':
        'Несохраненный созданный Wallet удален.',
    'set_wallet_pin_title': 'Установить PIN Wallet',
    'six_digit_pin': '6-значный PIN',
    'confirm_pin': 'Подтвердите PIN',
    'wallet_pin_must_be_6_digits':
        'PIN Wallet должен состоять ровно из 6 цифр.',
    'pin_confirmation_no_match': 'Подтверждение PIN не совпадает.',
    'backup_seed_phrase_title': 'Сохранить Seed Phrase',
    'seed_phrase_copied': 'Seed phrase скопирована в буфер обмена.',
    'current_wallet_pin': 'Текущий PIN Wallet',
    'passkey_enrollment_failed': 'Не удалось зарегистрировать passkey: {error}',
    'confirm_transaction': 'Подтвердить транзакцию',
    'send_amount_to': 'Отправить {amount} BIS на:',
    'estimated_fee_label': 'Оценочная комиссия: {fee} BIS',
    'operation_value': 'Операция: {value}',
    'transaction_rejected': 'Транзакция отклонена: {message}',
    'transaction_submission_failed': 'Не удалось отправить транзакцию: {error}',
    'no_token_selected_for_transfer': 'Для этого перевода не выбран токен.',
    'enter_destination_address_first': 'Сначала введите адрес получателя.',
    'destination_address_invalid': 'Неверный формат адреса получателя.',
    'enter_token_amount_first': 'Сначала введите количество токенов.',
    'token_amount_positive_integer':
        'Количество токенов должно быть положительным целым числом.',
    'token_transfer_sent_successfully': 'Перевод токена успешно отправлен.',
    'token_transfer_rejected': 'Перевод токена отклонен: {message}',
    'unlock_browser_wallet': 'Разблокировать Browser Wallet',
    'unlock_with_passkey': 'Разблокировать с помощью passkey',
    'six_digit_wallet_pin': '6-значный PIN Wallet',
    'unlock_with_pin': 'Разблокировать с помощью PIN',
    'hosted_wallet': 'Hosted Wallet',
    'installable_pwa': 'Устанавливаемое PWA',
    'mainnet_profile': 'Профиль mainnet',
    'testnet_profile': 'Профиль testnet',
    'launch_count': 'Запуск #{count}',
    'send_token': 'Отправить {token}',
    'amount_token': 'Количество ({token})',
    'this_account': 'этот аккаунт',
    'token_balances_for': 'Балансы токенов для {account}',
    'pwa_shell': 'Оболочка PWA',
    'confirm_mnemonic_backup': 'Подтвердить резервную копию mnemonic',
    'word_number': 'Слово #{position}',
    'back_up_before_saving': 'Сделайте резервную копию перед сохранением',
    'generated_seed': 'Созданный seed',
    'generated_mnemonic': 'Созданная mnemonic',
    'copy_seed': 'Копировать Seed',
    'copy_mnemonic': 'Копировать Mnemonic',
    'import_24_word_mnemonic': 'Импортировать mnemonic из 24 слов',
    'scan_import_qr': 'Сканировать QR импорта',
    'no_recent_transactions_loaded': 'Пока не загружено недавних транзакций.',
    'transaction_detail_unavailable': 'Детали транзакции недоступны.',
    'last_submission': 'Последняя отправка',
    'submission_error': 'Ошибка отправки',
    'matched_history_item': 'Совпадающий элемент истории',
    'mnemonic_qr_scanned_loaded':
        'QR с mnemonic отсканирован и загружен для импорта.',
    'could_not_parse_payment_qr': 'Не удалось разобрать платежный QR: {error}',
    'twenty_four_word_mnemonic': 'Mnemonic из 24 слов',
    'tx_count': '{count} транзакций',
    'token_tx_count_on_account': '{count} транзакций {token}',
  },
  'pl': <String, String>{
    'settings': 'Ustawienia',
    'network': 'Sieć',
    'custom_websocket_api_endpoint': 'Niestandardowy Websocket API Endpoint',
    'preferences': 'Preferencje',
    'currency': 'Waluta',
    'language': 'Język',
    'theme': 'Motyw',
    'auto': 'Auto',
    'dark': 'Ciemny',
    'light': 'Jasny',
    'mybismuth_non_custodial_wallet': 'Portfel bezpowierniczy myBismuth',
    'security': 'Bezpieczeństwo',
    'wallet_lock': 'Blokada Wallet',
    'protected': 'Chronione',
    'legacy_local_storage': 'Starsza pamięć lokalna',
    'pin_unlock': 'Odblokowanie PIN',
    'pin_attempts': 'Próby PIN',
    'enabled': 'Włączone',
    'disabled': 'Wyłączone',
    'passkey_unlock': 'Odblokowanie Passkey',
    'available': 'Dostępne',
    'unsupported': 'Nieobsługiwane',
    'manage': 'Zarządzanie',
    'reset_browser_wallet': 'Resetuj Browser Wallet',
    'connect': 'Połącz',
    'enable_passkey_unlock': 'Włącz odblokowanie Passkey',
    'lock_wallet_now': 'Zablokuj Wallet',
    'set_wallet_password': 'Ustaw PIN Wallet',
    'auth_method': 'Metoda uwierzytelniania',
    'backup_seed_phrase': 'Utwórz kopię seed phrase',
    'close': 'Zamknij',
    'cancel': 'Anuluj',
    'continue': 'Kontynuuj',
    'confirm': 'Potwierdź',
    'save': 'Zapisz',
    'back_to': 'Powrót do',
    'wallet': 'Wallet',
    'popup': 'Popup',
    'send': 'Wyślij',
    'receive': 'Odbierz',
    'tokens': 'Tokeny',
    'transactions': 'Transakcje',
    'back_to_wallets': 'Powrót do Wallets',
    'back_to_tokens': 'Powrót do tokenów',
    'account_label': 'Nazwa Wallet',
    'rename_account': 'Zmień nazwę konta',
    'show_more_transactions': 'Pokaż więcej transakcji',
    'show_less': 'Pokaż mniej',
    'api_connection_established': 'Połączenie z API ustanowione',
    'no_api_connection_established': 'Brak połączenia z API',
    'refresh_live_data': 'Odśwież dane',
    'waiting_for_first_network_sync':
        'Oczekiwanie na pierwszą synchronizację sieci',
    'copy_address': 'Kopiuj adres',
    'wallet_locked': 'Wallet zablokowany.',
    'account_address_copied': 'Adres konta skopiowano do schowka.',
    'account_label_updated': 'Nazwa konta została zaktualizowana.',
    'websocket_connected': 'Połączono z Websocket endpoint.',
    'current_status': 'Aktualny status',
    'browser_wallet_storage': 'Pamięć Browser Wallet',
    'active': 'Aktywne',
    'not_initialized': 'Nie zainicjalizowano',
    'migration_notice': 'Informacja o migracji',
    'acknowledged': 'Potwierdzone',
    'visible': 'Widoczne',
    'next_actions': 'Następne działania',
    'manage_browser_wallet': 'Zarządzaj Browser Wallet',
    'open_wallet_setup': 'Otwórz konfigurację Wallet',
    'jump_to_browser_wallet_section':
        'Przejdź do sekcji Browser Wallet na tej stronie.',
    'open_wallet_manager_browser_wallet_section':
        'Otwórz menedżer Wallet i przejdź do sekcji Browser Wallet.',
    'use_wallet_setup_view':
        'Użyj widoku konfiguracji Wallet, aby zaimportować istniejącą mnemonic lub zmienić ustawienia Wallet.',
    'language_preference_saved': 'Preferencje języka zapisane.',
    'auth_preference_saved':
        'Preferencje uwierzytelniania zapisane. Pełna lokalizacja browser shell nie jest jeszcze w pełni podłączona.',
    'theme_preference_saved': 'Preferencje motywu zapisane.',
    'copy': 'Kopiuj',
    'clear': 'Wyczyść',
    'wallets': 'Wallets',
    'add_new': 'Dodaj',
    'account': 'Konto',
    'message': 'Wiadomość',
    'optional': 'Opcjonalne',
    'optional_message': 'Opcjonalna wiadomość',
    'optional_payload': 'Opcjonalny ładunek',
    'no_browser_wallet_yet': 'Brak Browser Wallet',
    'create_browser_wallet': 'Utwórz Browser Wallet',
    'ready': 'Gotowe',
    'back': 'Wstecz',
    'confirm_and_save': 'Potwierdź i zapisz',
    'discard': 'Odrzuć',
    'save_browser_wallet': 'Zapisz Browser Wallet',
    'create_wallet': 'Utwórz Wallet',
    'import_wallet': 'Importuj Wallet',
    'loading_browser_wallet': 'Ładowanie Browser Wallet...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': 'Historia transakcji',
    'status': 'Status',
    'destination': 'Odbiorca',
    'tx_count': '{count} tx',
    'token_tx_count_on_account': '{count} transakcji {token}',
    'address_hint': 'Wpisz adres',
    'scan_qr': 'Skanuj kod QR',
    'amount': 'Kwota',
    'enter_amount': 'Wpisz kwotę',
    'fees': 'Opłaty',
    'operation': 'Operacja',
    'transaction_detail': 'Szczegóły transakcji',
    'back_to_transactions': 'Powrót do transakcji',
    'sender': 'Nadawca',
    'recipient': 'Odbiorca',
    'timestamp': 'Znacznik czasu',
    'block': 'Blok',
    'block_hash': 'Hash bloku',
    'transaction_id': 'ID transakcji',
    'transaction_ref': 'Odniesienie transakcji',
    'signature': 'Podpis',
    'openfield': 'Openfield',
    'pending': 'Oczekujące',
    'balance_title': '{name} Wallet',
    'wallet_unlocked_with_pin': 'Wallet odblokowany przy uzyciu PIN-u.',
    'pin_unlock_failed': 'Odblokowanie PIN-em nie powiodlo sie: {error}',
    'wallet_unlocked_with_passkey': 'Wallet odblokowany przy uzyciu passkey.',
    'passkey_unlock_failed': 'Odblokowanie passkey nie powiodlo sie: {error}',
    'failed_create_new_account': 'Nie udalo sie utworzyc nowego konta: {error}',
    'enter_valid_websocket_endpoint': 'Wpisz prawidlowy websocket endpoint.',
    'wallet_setup_failed': 'Konfiguracja Wallet nie powiodla sie: {error}',
    'copied_to_clipboard': '{label} skopiowano do schowka.',
    'unsaved_generated_wallet_discarded':
        'Niezapisany utworzony Wallet zostal odrzucony.',
    'set_wallet_pin_title': 'Ustaw PIN Wallet',
    'six_digit_pin': '6-cyfrowy PIN',
    'confirm_pin': 'Potwierdz PIN',
    'wallet_pin_must_be_6_digits': 'PIN Wallet musi miec dokladnie 6 cyfr.',
    'pin_confirmation_no_match': 'Potwierdzenie PIN-u nie zgadza sie.',
    'backup_seed_phrase_title': 'Utworz kopie Seed Phrase',
    'seed_phrase_copied': 'Seed phrase skopiowano do schowka.',
    'current_wallet_pin': 'Biezacy PIN Wallet',
    'passkey_enrollment_failed':
        'Rejestracja passkey nie powiodla sie: {error}',
    'confirm_transaction': 'Potwierdz transakcje',
    'send_amount_to': 'Wyslij {amount} BIS do:',
    'estimated_fee_label': 'Szacowana oplata: {fee} BIS',
    'operation_value': 'Operacja: {value}',
    'transaction_rejected': 'Transakcja odrzucona: {message}',
    'transaction_submission_failed':
        'Wyslanie transakcji nie powiodlo sie: {error}',
    'no_token_selected_for_transfer': 'Nie wybrano tokena dla tego transferu.',
    'enter_destination_address_first': 'Najpierw wpisz adres odbiorcy.',
    'destination_address_invalid': 'Format adresu odbiorcy jest nieprawidlowy.',
    'enter_token_amount_first': 'Najpierw wpisz ilosc tokena.',
    'token_amount_positive_integer':
        'Ilosc tokena musi byc dodatnia liczba calkowita.',
    'token_transfer_sent_successfully':
        'Transfer tokena zostal pomyslnie wyslany.',
    'token_transfer_rejected': 'Transfer tokena odrzucony: {message}',
    'unlock_browser_wallet': 'Odblokuj Browser Wallet',
    'unlock_with_passkey': 'Odblokuj przy uzyciu passkey',
    'six_digit_wallet_pin': '6-cyfrowy PIN Wallet',
    'unlock_with_pin': 'Odblokuj przy uzyciu PIN-u',
    'hosted_wallet': 'Hosted Wallet',
    'installable_pwa': 'Instalowalne PWA',
    'mainnet_profile': 'Profil mainnet',
    'testnet_profile': 'Profil testnet',
    'launch_count': 'Uruchomienie #{count}',
    'send_token': 'Wyslij {token}',
    'amount_token': 'Kwota ({token})',
    'this_account': 'to konto',
    'token_balances_for': 'Salda tokenow dla {account}',
    'pwa_shell': 'Powłoka PWA',
    'confirm_mnemonic_backup': 'Potwierdz kopie mnemonic',
    'word_number': 'Slowo #{position}',
    'back_up_before_saving': 'Wykonaj kopie przed zapisaniem',
    'generated_seed': 'Wygenerowany seed',
    'generated_mnemonic': 'Wygenerowana mnemonic',
    'copy_seed': 'Kopiuj Seed',
    'copy_mnemonic': 'Kopiuj Mnemonic',
    'import_24_word_mnemonic': 'Importuj 24-wyrazowa mnemonic',
    'scan_import_qr': 'Skanuj QR importu',
    'no_recent_transactions_loaded':
        'Nie zaladowano jeszcze ostatnich transakcji.',
    'transaction_detail_unavailable': 'Szczegoly transakcji sa niedostepne.',
    'last_submission': 'Ostatnie wyslanie',
    'submission_error': 'Blad wysylki',
    'matched_history_item': 'Pasujacy element historii',
    'mnemonic_qr_scanned_loaded':
        'QR mnemonic zeskanowano i zaladowano do importu.',
    'could_not_parse_payment_qr': 'Nie mozna przetworzyc QR platnosci: {error}',
    'twenty_four_word_mnemonic': '24-wyrazowa mnemonic',
  },
  'zh': <String, String>{
    'settings': '设置',
    'network': '网络',
    'custom_websocket_api_endpoint': '自定义 Websocket API 端点',
    'preferences': '偏好',
    'currency': '货币',
    'language': '语言',
    'theme': '主题',
    'auto': '自动',
    'dark': '深色',
    'light': '浅色',
    'mybismuth_non_custodial_wallet': 'myBismuth 非托管钱包',
    'security': '安全',
    'wallet_lock': 'Wallet 锁定',
    'protected': '已保护',
    'legacy_local_storage': '旧版本地存储',
    'pin_unlock': 'PIN 解锁',
    'pin_attempts': 'PIN 尝试次数',
    'enabled': '已启用',
    'disabled': '已禁用',
    'passkey_unlock': 'Passkey 解锁',
    'available': '可用',
    'unsupported': '不支持',
    'manage': '管理',
    'reset_browser_wallet': '重置 Browser Wallet',
    'connect': '连接',
    'enable_passkey_unlock': '启用 Passkey 解锁',
    'lock_wallet_now': '立即锁定 Wallet',
    'set_wallet_password': '设置 Wallet PIN',
    'auth_method': '认证方式',
    'backup_seed_phrase': '备份 Seed Phrase',
    'close': '关闭',
    'cancel': '取消',
    'continue': '继续',
    'confirm': '确认',
    'save': '保存',
    'back_to': '返回',
    'wallet': 'Wallet',
    'send': '发送',
    'receive': '接收',
    'tokens': '代币',
    'transactions': '交易',
    'back_to_wallets': '返回 Wallets',
    'back_to_tokens': '返回代币',
    'account_label': 'Wallet 名称',
    'rename_account': '重命名账户',
    'show_more_transactions': '显示更多交易',
    'show_less': '显示更少',
    'current_status': '当前状态',
    'browser_wallet_storage': 'Browser Wallet 存储',
    'active': '活动',
    'not_initialized': '未初始化',
    'migration_notice': '迁移说明',
    'next_actions': '下一步操作',
    'manage_browser_wallet': '管理 Browser Wallet',
    'open_wallet_setup': '打开 Wallet 设置',
    'copy': '复制',
    'clear': '清除',
    'wallets': 'Wallets',
    'add_new': '新增',
    'account': '账户',
    'message': '消息',
    'optional': '可选',
    'optional_message': '可选消息',
    'optional_payload': '可选载荷',
    'no_browser_wallet_yet': '尚无 Browser Wallet',
    'create_browser_wallet': '创建 Browser Wallet',
    'ready': '就绪',
    'back': '返回',
    'confirm_and_save': '确认并保存',
    'discard': '放弃',
    'save_browser_wallet': '保存 Browser Wallet',
    'create_wallet': '创建 Wallet',
    'import_wallet': '导入 Wallet',
    'loading_browser_wallet': '正在加载 Browser Wallet...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': '交易历史',
    'status': '状态',
    'destination': '目标',
    'address_hint': '输入地址',
    'scan_qr': '扫描二维码',
    'amount': '金额',
    'enter_amount': '输入金额',
    'fees': '费用',
    'operation': '操作',
    'transaction_detail': '交易详情',
    'back_to_transactions': '返回交易',
    'sender': '发送方',
    'recipient': '接收方',
    'timestamp': '时间戳',
    'block': '区块',
    'block_hash': '区块哈希',
    'transaction_id': '交易 ID',
    'transaction_ref': '交易引用',
    'signature': '签名',
    'openfield': 'Openfield',
    'pending': '待处理',
    'balance_title': '{name} Wallet',
    'tx_count': '{count} 笔交易',
    'token_tx_count_on_account': '{count} 笔 {token} 交易',
    'popup': '弹窗',
    'api_connection_established': 'API 连接已建立',
    'no_api_connection_established': 'API 连接未建立',
    'refresh_live_data': '刷新实时数据',
    'waiting_for_first_network_sync': '等待首次网络同步',
    'copy_address': '复制地址',
    'wallet_locked': 'Wallet 已锁定。',
    'account_address_copied': '账户地址已复制到剪贴板。',
    'account_label_updated': '账户名称已更新。',
    'websocket_connected': '已连接到 websocket 端点。',
    'acknowledged': '已确认',
    'visible': '可见',
    'language_preference_saved': '语言偏好已保存。',
    'theme_preference_saved': '主题偏好已保存。',
    'wallet_unlocked_with_pin': '已使用 PIN 解锁 Wallet。',
    'pin_unlock_failed': 'PIN 解锁失败：{error}',
    'wallet_unlocked_with_passkey': '已使用 passkey 解锁 Wallet。',
    'passkey_unlock_failed': 'Passkey 解锁失败：{error}',
    'failed_create_new_account': '创建新账户失败：{error}',
    'enter_valid_websocket_endpoint': '请输入有效的 websocket 端点。',
    'wallet_setup_failed': 'Wallet 设置失败：{error}',
    'copied_to_clipboard': '{label} 已复制到剪贴板。',
    'unsaved_generated_wallet_discarded': '未保存的已生成 Wallet 已丢弃。',
    'set_wallet_pin_title': '设置 Wallet PIN',
    'six_digit_pin': '6 位 PIN',
    'confirm_pin': '确认 PIN',
    'wallet_pin_must_be_6_digits': 'Wallet PIN 必须正好为 6 位。',
    'pin_confirmation_no_match': 'PIN 确认不匹配。',
    'backup_seed_phrase_title': '备份 Seed Phrase',
    'seed_phrase_copied': 'Seed Phrase 已复制到剪贴板。',
    'current_wallet_pin': '当前 Wallet PIN',
    'passkey_enrollment_failed': 'Passkey 注册失败：{error}',
    'confirm_transaction': '确认交易',
    'send_amount_to': '发送 {amount} BIS 至：',
    'estimated_fee_label': '预估费用：{fee} BIS',
    'operation_value': '操作：{value}',
    'transaction_rejected': '交易被拒绝：{message}',
    'transaction_submission_failed': '交易提交失败：{error}',
    'no_token_selected_for_transfer': '此转账未选择代币。',
    'enter_destination_address_first': '请先输入目标地址。',
    'destination_address_invalid': '目标地址格式无效。',
    'enter_token_amount_first': '请先输入代币数量。',
    'token_amount_positive_integer': '代币数量必须为正整数。',
    'token_transfer_sent_successfully': '代币转账已成功发送。',
    'token_transfer_rejected': '代币转账被拒绝：{message}',
    'unlock_browser_wallet': '解锁 Browser Wallet',
    'unlock_with_passkey': '使用 Passkey 解锁',
    'six_digit_wallet_pin': '6 位 Wallet PIN',
    'unlock_with_pin': '使用 PIN 解锁',
    'hosted_wallet': '托管 Wallet',
    'installable_pwa': '可安装 PWA',
    'mainnet_profile': 'Mainnet 配置',
    'testnet_profile': 'Testnet 配置',
    'launch_count': '启动 #{count}',
    'send_token': '发送 {token}',
    'amount_token': '数量 ({token})',
    'this_account': '此账户',
    'token_balances_for': '{account} 的代币余额',
    'pwa_shell': 'PWA 外壳',
    'confirm_mnemonic_backup': '确认 Mnemonic 备份',
    'word_number': '单词 #{position}',
    'back_up_before_saving': '保存前先备份',
    'generated_seed': '生成的 Seed',
    'generated_mnemonic': '生成的 Mnemonic',
    'copy_seed': '复制 Seed',
    'copy_mnemonic': '复制 Mnemonic',
    'import_24_word_mnemonic': '导入 24 个单词的 Mnemonic',
    'scan_import_qr': '扫描导入二维码',
    'no_recent_transactions_loaded': '尚未加载最近交易。',
    'transaction_detail_unavailable': '交易详情不可用。',
    'last_submission': '最近提交',
    'submission_error': '提交错误',
    'matched_history_item': '匹配的历史记录项',
    'mnemonic_qr_scanned_loaded': '已扫描 Mnemonic 二维码并载入导入。',
    'could_not_parse_payment_qr': '无法解析支付二维码：{error}',
    'twenty_four_word_mnemonic': '24 个单词的 Mnemonic',
  },
  'ja': <String, String>{
    'settings': '設定',
    'network': 'ネットワーク',
    'custom_websocket_api_endpoint': 'カスタム Websocket API エンドポイント',
    'preferences': '設定',
    'currency': '通貨',
    'language': '言語',
    'theme': 'テーマ',
    'auto': '自動',
    'dark': 'ダーク',
    'light': 'ライト',
    'mybismuth_non_custodial_wallet': 'myBismuth ノンカストディアルウォレット',
    'security': 'セキュリティ',
    'wallet_lock': 'Wallet ロック',
    'protected': '保護済み',
    'legacy_local_storage': '旧ローカルストレージ',
    'pin_unlock': 'PIN 解除',
    'pin_attempts': 'PIN 試行回数',
    'enabled': '有効',
    'disabled': '無効',
    'passkey_unlock': 'Passkey 解除',
    'available': '利用可能',
    'unsupported': '未対応',
    'manage': '管理',
    'reset_browser_wallet': 'Browser Wallet をリセット',
    'connect': '接続',
    'enable_passkey_unlock': 'Passkey 解除を有効化',
    'lock_wallet_now': '今すぐ Wallet をロック',
    'set_wallet_password': 'Wallet PIN を設定',
    'auth_method': '認証方法',
    'backup_seed_phrase': 'Seed Phrase をバックアップ',
    'close': '閉じる',
    'cancel': 'キャンセル',
    'continue': '続行',
    'confirm': '確認',
    'save': '保存',
    'back_to': '戻る',
    'wallet': 'Wallet',
    'send': '送信',
    'receive': '受信',
    'tokens': 'トークン',
    'transactions': '取引',
    'back_to_wallets': 'Wallets に戻る',
    'back_to_tokens': 'トークンに戻る',
    'account_label': 'Wallet 名',
    'rename_account': 'アカウント名を変更',
    'show_more_transactions': 'さらに取引を表示',
    'show_less': '表示を減らす',
    'current_status': '現在の状態',
    'browser_wallet_storage': 'Browser Wallet ストレージ',
    'active': '有効',
    'not_initialized': '未初期化',
    'migration_notice': '移行通知',
    'next_actions': '次の操作',
    'manage_browser_wallet': 'Browser Wallet を管理',
    'open_wallet_setup': 'Wallet 設定を開く',
    'copy': 'コピー',
    'clear': 'クリア',
    'wallets': 'Wallets',
    'add_new': '追加',
    'account': 'アカウント',
    'message': 'メッセージ',
    'optional': '任意',
    'optional_message': '任意のメッセージ',
    'optional_payload': '任意のペイロード',
    'no_browser_wallet_yet': 'Browser Wallet はまだありません',
    'create_browser_wallet': 'Browser Wallet を作成',
    'ready': '準備完了',
    'back': '戻る',
    'confirm_and_save': '確認して保存',
    'discard': '破棄',
    'save_browser_wallet': 'Browser Wallet を保存',
    'create_wallet': 'Wallet を作成',
    'import_wallet': 'Wallet をインポート',
    'loading_browser_wallet': 'Browser Wallet を読み込み中...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': '取引履歴',
    'status': '状態',
    'destination': '送信先',
    'address_hint': 'アドレスを入力',
    'scan_qr': 'QR コードをスキャン',
    'amount': '金額',
    'enter_amount': '金額を入力',
    'fees': '手数料',
    'operation': '操作',
    'transaction_detail': '取引詳細',
    'back_to_transactions': '取引に戻る',
    'sender': '送信者',
    'recipient': '受信者',
    'timestamp': 'タイムスタンプ',
    'block': 'ブロック',
    'block_hash': 'ブロックハッシュ',
    'transaction_id': '取引 ID',
    'transaction_ref': '取引参照',
    'signature': '署名',
    'openfield': 'Openfield',
    'pending': '保留中',
    'balance_title': '{name} Wallet',
    'tx_count': '{count} 件の取引',
    'token_tx_count_on_account': '{token} の取引 {count} 件',
    'popup': 'ポップアップ',
    'api_connection_established': 'API 接続が確立されました',
    'no_api_connection_established': 'API 接続が確立されていません',
    'refresh_live_data': 'ライブデータを更新',
    'waiting_for_first_network_sync': '最初のネットワーク同期を待機中',
    'copy_address': 'アドレスをコピー',
    'wallet_locked': 'Wallet はロックされています。',
    'account_address_copied': 'アカウントアドレスをクリップボードにコピーしました。',
    'account_label_updated': 'アカウント名を更新しました。',
    'websocket_connected': 'Websocket エンドポイントに接続しました。',
    'acknowledged': '確認済み',
    'visible': '表示中',
    'language_preference_saved': '言語設定を保存しました。',
    'theme_preference_saved': 'テーマ設定を保存しました。',
    'wallet_unlocked_with_pin': 'PIN で Wallet を解除しました。',
    'pin_unlock_failed': 'PIN 解除に失敗しました: {error}',
    'wallet_unlocked_with_passkey': 'Passkey で Wallet を解除しました。',
    'passkey_unlock_failed': 'Passkey 解除に失敗しました: {error}',
    'failed_create_new_account': '新しいアカウントの作成に失敗しました: {error}',
    'enter_valid_websocket_endpoint': '有効な websocket エンドポイントを入力してください。',
    'wallet_setup_failed': 'Wallet 設定に失敗しました: {error}',
    'copied_to_clipboard': '{label} をクリップボードにコピーしました。',
    'unsaved_generated_wallet_discarded': '未保存の生成済み Wallet を破棄しました。',
    'set_wallet_pin_title': 'Wallet PIN を設定',
    'six_digit_pin': '6 桁の PIN',
    'confirm_pin': 'PIN を確認',
    'wallet_pin_must_be_6_digits': 'Wallet PIN はちょうど 6 桁である必要があります。',
    'pin_confirmation_no_match': 'PIN 確認が一致しません。',
    'backup_seed_phrase_title': 'Seed Phrase をバックアップ',
    'seed_phrase_copied': 'Seed Phrase をクリップボードにコピーしました。',
    'current_wallet_pin': '現在の Wallet PIN',
    'passkey_enrollment_failed': 'Passkey 登録に失敗しました: {error}',
    'confirm_transaction': '取引を確認',
    'send_amount_to': '{amount} BIS を次へ送信:',
    'estimated_fee_label': '推定手数料: {fee} BIS',
    'operation_value': '操作: {value}',
    'transaction_rejected': '取引が拒否されました: {message}',
    'transaction_submission_failed': '取引送信に失敗しました: {error}',
    'no_token_selected_for_transfer': 'この送金にはトークンが選択されていません。',
    'enter_destination_address_first': '最初に送信先アドレスを入力してください。',
    'destination_address_invalid': '送信先アドレスの形式が無効です。',
    'enter_token_amount_first': '最初にトークン数量を入力してください。',
    'token_amount_positive_integer': 'トークン数量は正の整数である必要があります。',
    'token_transfer_sent_successfully': 'トークン送金が正常に送信されました。',
    'token_transfer_rejected': 'トークン送金が拒否されました: {message}',
    'unlock_browser_wallet': 'Browser Wallet を解除',
    'unlock_with_passkey': 'Passkey で解除',
    'six_digit_wallet_pin': '6 桁の Wallet PIN',
    'unlock_with_pin': 'PIN で解除',
    'hosted_wallet': 'Hosted Wallet',
    'installable_pwa': 'インストール可能な PWA',
    'mainnet_profile': 'Mainnet プロファイル',
    'testnet_profile': 'Testnet プロファイル',
    'launch_count': '起動 #{count}',
    'send_token': '{token} を送信',
    'amount_token': '数量 ({token})',
    'this_account': 'このアカウント',
    'token_balances_for': '{account} のトークン残高',
    'pwa_shell': 'PWA シェル',
    'confirm_mnemonic_backup': 'Mnemonic バックアップを確認',
    'word_number': '単語 #{position}',
    'back_up_before_saving': '保存前にバックアップ',
    'generated_seed': '生成された Seed',
    'generated_mnemonic': '生成された Mnemonic',
    'copy_seed': 'Seed をコピー',
    'copy_mnemonic': 'Mnemonic をコピー',
    'import_24_word_mnemonic': '24 単語の Mnemonic をインポート',
    'scan_import_qr': 'インポート QR をスキャン',
    'no_recent_transactions_loaded': 'まだ最近の取引は読み込まれていません。',
    'transaction_detail_unavailable': '取引詳細は利用できません。',
    'last_submission': '最後の送信',
    'submission_error': '送信エラー',
    'matched_history_item': '一致した履歴項目',
    'mnemonic_qr_scanned_loaded': 'Mnemonic QR をスキャンしてインポート用に読み込みました。',
    'could_not_parse_payment_qr': '支払い QR を解析できませんでした: {error}',
    'twenty_four_word_mnemonic': '24 単語の Mnemonic',
  },
  'ko': <String, String>{
    'settings': '설정',
    'network': '네트워크',
    'custom_websocket_api_endpoint': '사용자 지정 Websocket API 엔드포인트',
    'preferences': '환경설정',
    'currency': '통화',
    'language': '언어',
    'theme': '테마',
    'auto': '자동',
    'dark': '다크',
    'light': '라이트',
    'mybismuth_non_custodial_wallet': 'myBismuth 논커스터디얼 월렛',
    'security': '보안',
    'wallet_lock': 'Wallet 잠금',
    'protected': '보호됨',
    'legacy_local_storage': '레거시 로컬 저장소',
    'pin_unlock': 'PIN 잠금 해제',
    'pin_attempts': 'PIN 시도 횟수',
    'enabled': '사용함',
    'disabled': '사용 안 함',
    'passkey_unlock': 'Passkey 잠금 해제',
    'available': '사용 가능',
    'unsupported': '지원되지 않음',
    'manage': '관리',
    'reset_browser_wallet': 'Browser Wallet 재설정',
    'connect': '연결',
    'enable_passkey_unlock': 'Passkey 잠금 해제 활성화',
    'lock_wallet_now': '지금 Wallet 잠그기',
    'set_wallet_password': 'Wallet PIN 설정',
    'auth_method': '인증 방식',
    'backup_seed_phrase': 'Seed Phrase 백업',
    'close': '닫기',
    'cancel': '취소',
    'continue': '계속',
    'confirm': '확인',
    'save': '저장',
    'back_to': '돌아가기',
    'wallet': 'Wallet',
    'send': '보내기',
    'receive': '받기',
    'tokens': '토큰',
    'transactions': '거래',
    'back_to_wallets': 'Wallets로 돌아가기',
    'back_to_tokens': '토큰으로 돌아가기',
    'account_label': 'Wallet 이름',
    'rename_account': '계정 이름 변경',
    'show_more_transactions': '거래 더 보기',
    'show_less': '적게 보기',
    'current_status': '현재 상태',
    'browser_wallet_storage': 'Browser Wallet 저장소',
    'active': '활성',
    'not_initialized': '초기화되지 않음',
    'migration_notice': '마이그레이션 안내',
    'next_actions': '다음 작업',
    'manage_browser_wallet': 'Browser Wallet 관리',
    'open_wallet_setup': 'Wallet 설정 열기',
    'copy': '복사',
    'clear': '지우기',
    'wallets': 'Wallets',
    'add_new': '추가',
    'account': '계정',
    'message': '메시지',
    'optional': '선택 사항',
    'optional_message': '선택 메시지',
    'optional_payload': '선택 페이로드',
    'no_browser_wallet_yet': '아직 Browser Wallet이 없습니다',
    'create_browser_wallet': 'Browser Wallet 생성',
    'ready': '준비됨',
    'back': '뒤로',
    'confirm_and_save': '확인 후 저장',
    'discard': '버리기',
    'save_browser_wallet': 'Browser Wallet 저장',
    'create_wallet': 'Wallet 생성',
    'import_wallet': 'Wallet 가져오기',
    'loading_browser_wallet': 'Browser Wallet 불러오는 중...',
    'browser_wallet': 'Browser Wallet',
    'transaction_history': '거래 내역',
    'status': '상태',
    'destination': '대상',
    'address_hint': '주소 입력',
    'scan_qr': 'QR 코드 스캔',
    'amount': '금액',
    'enter_amount': '금액 입력',
    'fees': '수수료',
    'operation': '작업',
    'transaction_detail': '거래 상세',
    'back_to_transactions': '거래로 돌아가기',
    'sender': '보낸 사람',
    'recipient': '받는 사람',
    'timestamp': '타임스탬프',
    'block': '블록',
    'block_hash': '블록 해시',
    'transaction_id': '거래 ID',
    'transaction_ref': '거래 참조',
    'signature': '서명',
    'openfield': 'Openfield',
    'pending': '대기 중',
    'balance_title': '{name} Wallet',
    'tx_count': '{count}건 거래',
    'token_tx_count_on_account': '{token} 거래 {count}건',
    'popup': '팝업',
    'api_connection_established': 'API 연결이 설정되었습니다',
    'no_api_connection_established': 'API 연결이 설정되지 않았습니다',
    'refresh_live_data': '실시간 데이터 새로고침',
    'waiting_for_first_network_sync': '첫 네트워크 동기화를 기다리는 중',
    'copy_address': '주소 복사',
    'wallet_locked': 'Wallet이 잠겼습니다.',
    'account_address_copied': '계정 주소가 클립보드에 복사되었습니다.',
    'account_label_updated': '계정 이름이 업데이트되었습니다.',
    'websocket_connected': 'Websocket 엔드포인트에 연결되었습니다.',
    'acknowledged': '확인됨',
    'visible': '표시됨',
    'language_preference_saved': '언어 설정이 저장되었습니다.',
    'theme_preference_saved': '테마 설정이 저장되었습니다.',
    'wallet_unlocked_with_pin': 'PIN으로 Wallet 잠금이 해제되었습니다.',
    'pin_unlock_failed': 'PIN 잠금 해제 실패: {error}',
    'wallet_unlocked_with_passkey': 'Passkey로 Wallet 잠금이 해제되었습니다.',
    'passkey_unlock_failed': 'Passkey 잠금 해제 실패: {error}',
    'failed_create_new_account': '새 계정을 만들지 못했습니다: {error}',
    'enter_valid_websocket_endpoint': '유효한 websocket 엔드포인트를 입력하세요.',
    'wallet_setup_failed': 'Wallet 설정 실패: {error}',
    'copied_to_clipboard': '{label}이(가) 클립보드에 복사되었습니다.',
    'unsaved_generated_wallet_discarded': '저장되지 않은 생성 Wallet이 삭제되었습니다.',
    'set_wallet_pin_title': 'Wallet PIN 설정',
    'six_digit_pin': '6자리 PIN',
    'confirm_pin': 'PIN 확인',
    'wallet_pin_must_be_6_digits': 'Wallet PIN은 정확히 6자리여야 합니다.',
    'pin_confirmation_no_match': 'PIN 확인이 일치하지 않습니다.',
    'backup_seed_phrase_title': 'Seed Phrase 백업',
    'seed_phrase_copied': 'Seed Phrase가 클립보드에 복사되었습니다.',
    'current_wallet_pin': '현재 Wallet PIN',
    'passkey_enrollment_failed': 'Passkey 등록 실패: {error}',
    'confirm_transaction': '거래 확인',
    'send_amount_to': '{amount} BIS 보내기:',
    'estimated_fee_label': '예상 수수료: {fee} BIS',
    'operation_value': '작업: {value}',
    'transaction_rejected': '거래가 거부되었습니다: {message}',
    'transaction_submission_failed': '거래 제출 실패: {error}',
    'no_token_selected_for_transfer': '이 전송에 선택된 토큰이 없습니다.',
    'enter_destination_address_first': '먼저 대상 주소를 입력하세요.',
    'destination_address_invalid': '대상 주소 형식이 올바르지 않습니다.',
    'enter_token_amount_first': '먼저 토큰 수량을 입력하세요.',
    'token_amount_positive_integer': '토큰 수량은 양의 정수여야 합니다.',
    'token_transfer_sent_successfully': '토큰 전송이 성공적으로 전송되었습니다.',
    'token_transfer_rejected': '토큰 전송이 거부되었습니다: {message}',
    'unlock_browser_wallet': 'Browser Wallet 잠금 해제',
    'unlock_with_passkey': 'Passkey로 잠금 해제',
    'six_digit_wallet_pin': '6자리 Wallet PIN',
    'unlock_with_pin': 'PIN으로 잠금 해제',
    'hosted_wallet': 'Hosted Wallet',
    'installable_pwa': '설치 가능한 PWA',
    'mainnet_profile': 'Mainnet 프로필',
    'testnet_profile': 'Testnet 프로필',
    'launch_count': '실행 #{count}',
    'send_token': '{token} 보내기',
    'amount_token': '수량 ({token})',
    'this_account': '이 계정',
    'token_balances_for': '{account}의 토큰 잔액',
    'pwa_shell': 'PWA 셸',
    'confirm_mnemonic_backup': 'Mnemonic 백업 확인',
    'word_number': '단어 #{position}',
    'back_up_before_saving': '저장 전에 백업',
    'generated_seed': '생성된 Seed',
    'generated_mnemonic': '생성된 Mnemonic',
    'copy_seed': 'Seed 복사',
    'copy_mnemonic': 'Mnemonic 복사',
    'import_24_word_mnemonic': '24단어 Mnemonic 가져오기',
    'scan_import_qr': '가져오기 QR 스캔',
    'no_recent_transactions_loaded': '아직 최근 거래가 로드되지 않았습니다.',
    'transaction_detail_unavailable': '거래 상세를 사용할 수 없습니다.',
    'last_submission': '마지막 제출',
    'submission_error': '제출 오류',
    'matched_history_item': '일치하는 기록 항목',
    'mnemonic_qr_scanned_loaded': 'Mnemonic QR이 스캔되어 가져오기에 로드되었습니다.',
    'could_not_parse_payment_qr': '결제 QR을 해석할 수 없습니다: {error}',
    'twenty_four_word_mnemonic': '24단어 Mnemonic',
  },
};

String _tr(BuildContext context, String key) {
  final String languageCode = Localizations.localeOf(context).languageCode;
  return _webStrings[languageCode]?[key] ?? _webStrings['en']![key] ?? key;
}

String _trf(
  BuildContext context,
  String key, [
  Map<String, String> replacements = const <String, String>{},
]) {
  String value = _tr(context, key);
  replacements.forEach((String placeholder, String replacement) {
    value = value.replaceAll('{$placeholder}', replacement);
  });
  return value;
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

class MyBismuthWalletWebApp extends StatefulWidget {
  final SharedPreferences preferences;

  const MyBismuthWalletWebApp({super.key, required this.preferences});

  @override
  State<MyBismuthWalletWebApp> createState() => _MyBismuthWalletWebAppState();
}

class _MyBismuthWalletWebAppState extends State<MyBismuthWalletWebApp> {
  static const String _themeModeKey = 'extension_theme_mode';

  late String _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.preferences.getString(_themeModeKey) ?? 'auto';
  }

  Future<void> _setThemeMode(String value) async {
    await widget.preferences.setString(_themeModeKey, value);
    if (!mounted) {
      return;
    }
    setState(() {
      _themeMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness platformBrightness =
        MediaQuery.platformBrightnessOf(context);
    final bool isDark = _themeMode == 'dark' ||
        (_themeMode == 'auto' && platformBrightness == Brightness.dark);
    final _Palette palette = isDark
        ? const _Palette(
            background: Color(0xFF081018),
            surface: Color(0xFF0F1A27),
            surfaceAlt: Color(0xFF122033),
            primary: Color(0xFF2EE6A6),
            secondary: Color(0xFF77C8FF),
            text: Color(0xFFF4F7FB),
            muted: Color(0xFF9EB0C5),
            outline: Color(0x1AFFFFFF),
          )
        : const _Palette(
            background: Color(0xFFF5F8FC),
            surface: Color(0xFFFFFFFF),
            surfaceAlt: Color(0xFFEFF4FA),
            primary: Color(0xFF14B87A),
            secondary: Color(0xFF4E8FD8),
            text: Color(0xFF122033),
            muted: Color(0xFF5F7186),
            outline: Color(0xFFD4DEEA),
          );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'myBismuth.com',
      locale: _localeForLanguageCode(
        widget.preferences.getString('extension_language') ?? 'en',
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
        Locale('ru'),
        Locale('pl'),
        Locale('zh'),
        Locale('ja'),
        Locale('ko'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: palette.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: palette.primary,
          brightness: isDark ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: palette.primary,
          secondary: palette.secondary,
          surface: palette.surface,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? const Color(0xFF18263A) : const Color(0xFFFFFFFF),
          hoverColor:
              isDark ? const Color(0xFF21324B) : const Color(0xFFF7FBFF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? const Color(0xFF304763) : const Color(0xFFD4DEEA),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark ? const Color(0xFF304763) : const Color(0xFFD4DEEA),
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
        textTheme:
            (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
                  bodyColor: palette.text,
                  displayColor: palette.text,
                ),
      ),
      home: _ExtensionShell(
        preferences: widget.preferences,
        palette: palette,
        themeMode: _themeMode,
        onThemeModeChanged: _setThemeMode,
      ),
    );
  }
}

class _ExtensionShell extends StatefulWidget {
  final SharedPreferences preferences;
  final _Palette palette;
  final String themeMode;
  final Future<void> Function(String value) onThemeModeChanged;

  const _ExtensionShell({
    required this.preferences,
    required this.palette,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<_ExtensionShell> createState() => _ExtensionShellState();
}

class _ExtensionShellState extends State<_ExtensionShell> {
  static const String _nameKey = 'extension_profile_name';
  static const String _networkKey = 'extension_network';
  static const String _currencyKey = 'extension_currency';
  static const String _priceCachePrefix = 'extension_price_cache_';
  static const String _walletPresenceKey = 'browser_wallet_present';
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
  String _settingsBackLabelKey = 'wallet';
  bool _walletServerConnecting = false;
  int _assetTabIndex = 0;
  bool _showAccountDetails = false;
  int _accountDetailViewIndex = 0;
  String? _selectedTokenName;
  int _visibleBisTransactions = _transactionBatchSize;
  int _visibleTokenTransactions = _transactionBatchSize;
  BrowserWalletTransactionDetail? _selectedTransactionDetail;
  bool _transactionDetailLoading = false;
  String? _transactionDetailError;
  bool _transactionDetailReturnToTokenTransactions = false;
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
  bool get _knownWalletExists =>
      widget.preferences.getBool(_walletPresenceKey) ?? false;
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
    'fr': 'Français',
    'de': 'Deutsch',
    'id': 'Bahasa Indonesia',
    'nl': 'Nederlands',
    'es': 'Español',
    'it': 'Italiano',
    'ru': 'Русский',
    'pl': 'Polski',
    'zh': '中文',
    'ja': '日本語',
    'ko': '한국어',
  };

  static const Map<String, String> _supportedAuthMethods = <String, String>{
    'biometrics': 'Biometrics',
    'fingerprint': 'Fingerprint',
    'face_id': 'Face ID',
  };

  static const Map<String, String> _supportedThemeModes = <String, String>{
    'auto': 'Auto',
    'dark': 'Dark',
    'light': 'Light',
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

  void _startBackgroundNetworkRefresh({bool showActivity = false}) {
    unawaited(_refreshNetworkData(showActivity: showActivity));
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
        await widget.preferences.setBool(_walletPresenceKey, true);
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
        await widget.preferences.setBool(_walletPresenceKey, false);
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

      await widget.preferences.setBool(_walletPresenceKey, true);
      await _applyUnlockedSeed(seed, protectionStatus: protectionStatus);
      _startBackgroundNetworkRefresh(showActivity: false);
    } catch (error) {
      setState(() {
        _loading = false;
        _errorMessage = _trf(
          context,
          'failed_load_browser_wallet_data',
          <String, String>{'error': '$error'},
        );
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
        _errorMessage = _tr(context, 'enter_wallet_pin_to_unlock');
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
        _statusMessage = _tr(context, 'wallet_unlocked_with_pin');
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _errorMessage = _trf(
          context,
          'pin_unlock_failed',
          <String, String>{'error': '$error'},
        );
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
        _statusMessage = _tr(context, 'wallet_unlocked_with_passkey');
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _errorMessage = _trf(
          context,
          'passkey_unlock_failed',
          <String, String>{'error': '$error'},
        );
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
      _statusMessage = _tr(context, 'wallet_locked');
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
      _statusMessage = _tr(context, 'language_preference_saved');
    });
  }

  Future<void> _setAuthMethod(String value) async {
    await widget.preferences.setString(_authMethodKey, value);
    if (!mounted) {
      return;
    }
    setState(() {
      _authMethod = value;
      _statusMessage = _tr(context, 'auth_preference_saved');
    });
  }

  Future<void> _setThemeMode(String value) async {
    await widget.onThemeModeChanged(value);
    if (!mounted) {
      return;
    }
    setState(() {
      _statusMessage = _tr(context, 'theme_preference_saved');
    });
  }

  Future<void> _addDerivedAccount() async {
    final String seed = _seed ?? await _vault.getSeed();
    if (seed.isEmpty) {
      setState(() {
        _errorMessage = _tr(context, 'seed_unavailable_browser_vault');
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
        _statusMessage = _tr(context, 'new_deterministic_account_created');
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _errorMessage = _trf(
          context,
          'failed_create_new_account',
          <String, String>{'error': '$error'},
        );
      });
    }
  }

  Future<void> _selectAccount(Account account,
      {bool openDetails = true}) async {
    final String seed = _seed ?? await _vault.getSeed();
    if (seed.isEmpty) {
      return;
    }

    final Account? currentAccount = _selectedAccount;
    if (currentAccount?.index == account.index) {
      if (!mounted) {
        return;
      }

      setState(() {
        _showAccountDetails = openDetails;
        _accountDetailViewIndex = 0;
        _selectedTokenName = null;
        _sendStatusMessage = null;
        _sendErrorMessage = null;
        _lastSubmitResult = null;
        _visibleBisTransactions = _transactionBatchSize;
        _visibleTokenTransactions = _transactionBatchSize;
      });
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
      if (index != 5) {
        _selectedTransactionDetail = null;
        _transactionDetailLoading = false;
        _transactionDetailError = null;
        _transactionDetailReturnToTokenTransactions = false;
      }
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
      _selectedTransactionDetail = null;
      _transactionDetailLoading = false;
      _transactionDetailError = null;
      _transactionDetailReturnToTokenTransactions = false;
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
      _transactionDetailLoading = false;
      _transactionDetailError = null;
      _transactionDetailReturnToTokenTransactions = false;
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
      _selectedTransactionDetail = null;
      _transactionDetailLoading = false;
      _transactionDetailError = null;
      _transactionDetailReturnToTokenTransactions = false;
    });
  }

  Future<void> _openTransactionDetail(
    AddressTxsResponseResult transaction,
  ) async {
    setState(() {
      _accountDetailViewIndex = 5;
      _transactionDetailLoading = true;
      _transactionDetailError = null;
      _selectedTransactionDetail = null;
      _transactionDetailReturnToTokenTransactions = false;
    });

    try {
      final BrowserWalletTransactionDetail detail =
          _decorateTransactionDetailForTokenTransfer(
        transaction: transaction,
        detail: await _networkService.loadTransactionDetail(transaction),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedTransactionDetail = detail;
        _transactionDetailLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedTransactionDetail = _decorateTransactionDetailForTokenTransfer(
          transaction: transaction,
          detail: _networkService.loadTransactionDetailFallback(transaction),
        );
        _transactionDetailLoading = false;
        _transactionDetailError =
            _tr(context, 'live_transaction_detail_lookup_failed');
      });
    }
  }

  BrowserWalletTransactionDetail _decorateTransactionDetailForTokenTransfer({
    required AddressTxsResponseResult transaction,
    required BrowserWalletTransactionDetail detail,
  }) {
    final BisToken? token = transaction.getBisToken();
    if (!transaction.isTokenTransfer() || token == null) {
      return detail;
    }

    final String tokenAmount =
        token.tokensQuantity?.toString() ?? transaction.amount ?? '0';
    return BrowserWalletTransactionDetail(
      amount: detail.amount,
      displayAmountLabel: '$tokenAmount ${token.tokenName}',
      isReceive: detail.isReceive,
      sender: detail.sender,
      recipient: detail.recipient,
      fee: detail.fee,
      reward: detail.reward,
      timestamp: detail.timestamp,
      blockHeight: detail.blockHeight,
      blockHash: detail.blockHash,
      transactionId: detail.transactionId,
      transactionRef: detail.transactionRef,
      operation: detail.operation,
      openfield: detail.openfield,
      signature: detail.signature,
      isPending: detail.isPending,
    );
  }

  Future<void> _openTokenTransactionDetail(
    BrowserWalletTokenTransaction transaction,
  ) async {
    final String accountAddress = _selectedAccount?.address ?? '';
    setState(() {
      _accountDetailViewIndex = 5;
      _selectedTransactionDetail = null;
      _transactionDetailLoading = true;
      _transactionDetailError = null;
      _transactionDetailReturnToTokenTransactions = true;
    });

    try {
      final BrowserWalletTransactionDetail detail =
          await _networkService.loadTransactionDetailFromTokenTransaction(
        transaction: transaction,
        accountAddress: accountAddress,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedTransactionDetail = detail;
        _transactionDetailLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedTransactionDetail =
            _networkService.loadTransactionDetailFallbackFromTokenTransaction(
          transaction: transaction,
          accountAddress: accountAddress,
        );
        _transactionDetailLoading = false;
        _transactionDetailError =
            _tr(context, 'live_transaction_detail_lookup_failed');
      });
    }
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
      _statusMessage = _tr(context, 'account_address_copied');
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
            title: Text(_tr(context, 'rename_account')),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: _tr(context, 'account_label'),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(_tr(context, 'cancel')),
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
                    _statusMessage = _tr(context, 'account_label_updated');
                    _errorMessage = null;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(_tr(context, 'save')),
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

  void _openSettingsView({String fromLabelKey = 'wallet'}) {
    setState(() {
      _showSettingsView = true;
      _settingsBackLabelKey = fromLabelKey;
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
        _errorMessage = _tr(context, 'enter_valid_websocket_endpoint');
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
        _statusMessage = _tr(context, 'websocket_connected');
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
        _errorMessage = _trf(
          context,
          'failed_connect_wallet_server',
          <String, String>{'error': '$error'},
        );
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
        _statusMessage = _tr(context, 'wallet_generated_locally');
      });
      if (!_isOptionsView) {
        _openOptionsPage();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = _trf(
          context,
          'wallet_setup_failed',
          <String, String>{'error': '$error'},
        );
      });
    }
  }

  Future<void> _confirmPendingWallet() async {
    final String? seed = _pendingSeed;
    if (seed == null || seed.isEmpty) {
      setState(() {
        _errorMessage = _tr(context, 'generate_wallet_before_saving');
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
        _errorMessage = _tr(context, 'generate_wallet_before_saving');
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
        _errorMessage = _tr(context, 'mnemonic_verification_not_prepared');
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
        _mnemonicVerificationError = _tr(context, 'answer_each_prompt');
      });
      return;
    }

    final bool matches = _mnemonicVerificationPrompts.every(
      (_MnemonicCheckPrompt prompt) =>
          _mnemonicVerificationAnswers[prompt.position] == prompt.correctWord,
    );
    if (!matches) {
      setState(() {
        _mnemonicVerificationError = _tr(context, 'mnemonic_answers_incorrect');
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
      _statusMessage = _trf(
        context,
        'copied_to_clipboard',
        <String, String>{'label': label},
      );
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
      _statusMessage = _tr(context, 'unsaved_generated_wallet_discarded');
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
            title: Text(_tr(context, 'set_wallet_pin_title')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_tr(context, 'set_wallet_pin_description')),
                const SizedBox(height: 12),
                _PinEntryField(
                  controller: pinController,
                  label: _tr(context, 'six_digit_pin'),
                ),
                const SizedBox(height: 12),
                _PinEntryField(
                  controller: confirmController,
                  label: _tr(context, 'confirm_pin'),
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
                child: Text(_tr(context, 'cancel')),
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
                          _tr(context, 'unlock_or_create_wallet_before_pin');
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
                      _errorMessage =
                          _tr(context, 'wallet_pin_must_be_6_digits');
                    });
                    return;
                  }
                  if (pin != confirm) {
                    if (!mounted) {
                      return;
                    }
                    setState(() {
                      _errorMessage = _tr(context, 'pin_confirmation_no_match');
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
                    _statusMessage = _tr(context, 'wallet_pin_enabled');
                    _errorMessage = null;
                  });
                  Navigator.of(context).pop();
                },
                child: Text(_tr(context, 'save')),
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
        _errorMessage = _tr(context, 'no_seed_phrase_available');
      });
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_tr(context, 'backup_seed_phrase_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_tr(context, 'backup_seed_phrase_description')),
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
              child: Text(_tr(context, 'close')),
            ),
            FilledButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: mnemonic));
                if (!mounted) {
                  return;
                }
                setState(() {
                  _statusMessage = _tr(context, 'seed_phrase_copied');
                });
                Navigator.of(context).pop();
              },
              child: Text(_tr(context, 'copy')),
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
        _errorMessage = _tr(context, 'unlock_wallet_before_passkey');
      });
      return;
    }
    if (!_protectionStatus.hasPinProtection) {
      setState(() {
        _errorMessage = _tr(context, 'set_pin_before_passkey');
      });
      return;
    }

    final TextEditingController pinController = TextEditingController();
    try {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(_tr(context, 'enable_passkey_unlock')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(_tr(context, 'confirm_current_pin_for_passkey')),
                const SizedBox(height: 12),
                _PinEntryField(
                  controller: pinController,
                  label: _tr(context, 'current_wallet_pin'),
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
                child: Text(_tr(context, 'cancel')),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(_tr(context, 'continue')),
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
          _errorMessage = _tr(context, 'enter_pin_before_adding_passkey');
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
        _statusMessage = _tr(context, 'passkey_unlock_enabled');
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
          _errorMessage = _tr(context, 'passkey_prf_unavailable');
        } else {
          _errorMessage = _trf(
            context,
            'passkey_enrollment_failed',
            <String, String>{'error': '$error'},
          );
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
        _statusMessage = _tr(context, 'mnemonic_qr_scanned_loaded');
      });
      return;
    }

    setState(() {
      _errorMessage = _tr(context, 'qr_invalid_mnemonic_or_seed');
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
            _tr(context, 'qr_payment_request_invalid_address'),
          );
        }

        setState(() {
          _destinationController.text = destination;
          _amountController.text = bisUrl.amount?.trim() ?? '';
          _operationController.text = bisUrl.operation?.trim() ?? '';
          _openfieldController.text = bisUrl.openfield?.trim() ?? '';
          _sendErrorMessage = null;
          _sendStatusMessage = _tr(context, 'payment_qr_scanned_prefilled');
        });
        return;
      }

      if (Address(normalized).isValid()) {
        setState(() {
          _destinationController.text = normalized;
          _sendErrorMessage = null;
          _sendStatusMessage = _tr(context, 'address_qr_scanned_prefilled');
        });
        return;
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sendErrorMessage = _trf(
          context,
          'could_not_parse_payment_qr',
          <String, String>{'error': '$error'},
        );
      });
      return;
    }

    setState(() {
      _sendErrorMessage = _tr(context, 'qr_invalid_bismuth_request');
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
          ? _tr(context, 'scanning_deterministic_accounts')
          : null;
    });

    try {
      await _ensureBrowserSecrets();
      await _db.dropAccounts();
      final String primaryAddress =
          await AddressDerivation.seedToAddress(seed, 0);
      final Account primaryAccount = Account(
        index: 0,
        name: profileName,
        lastAccess: 1,
        selected: true,
        address: primaryAddress,
        balance: '0',
        dragginatorDna: '',
        dragginatorStatus: '',
      );
      final List<Account> accounts = discoverExistingAccounts
          ? <Account>[primaryAccount]
          : <Account>[primaryAccount];

      for (final Account account in accounts) {
        await _db.saveAccount(account);
      }
      await _vault.setSeed(seed);
      await widget.preferences.setBool(_walletPresenceKey, true);
      await _applyUnlockedSeed(seed);
      _startBackgroundNetworkRefresh(showActivity: false);
      if (discoverExistingAccounts) {
        _startBackgroundImportedAccountDiscovery(
          seed: seed,
          profileName: profileName,
        );
      }

      _mnemonicController.clear();

      if (!mounted) {
        return;
      }
      setState(() {
        _working = false;
        _statusMessage = discoverExistingAccounts
            ? _trf(
                context,
                'opening_account_and_recovering',
                <String, String>{'status': statusMessage},
              )
            : statusMessage;
      });
    } catch (error) {
      setState(() {
        _working = false;
        _errorMessage = _trf(
          context,
          'wallet_setup_failed',
          <String, String>{'error': '$error'},
        );
      });
    }
  }

  Future<List<Account>> _discoverAccountsForSeed(
    String seed, {
    required String profileName,
    int gapLimit = 2,
    int maxScan = 50,
    int batchSize = 4,
  }) async {
    final List<Account> discoveredAccounts = <Account>[];
    int consecutiveUnused = 0;

    final int effectiveBatchSize = batchSize < 1 ? 1 : batchSize;

    for (int startIndex = 0;
        startIndex < maxScan && consecutiveUnused < gapLimit;
        startIndex += effectiveBatchSize) {
      final int endIndex = min(startIndex + effectiveBatchSize, maxScan);
      final List<_DiscoveredAccountProbe> probes =
          await Future.wait<_DiscoveredAccountProbe>(
        List<Future<_DiscoveredAccountProbe>>.generate(
          endIndex - startIndex,
          (int offset) async {
            final int index = startIndex + offset;
            final String address =
                await AddressDerivation.seedToAddress(seed, index);
            bool hasUsage = false;
            try {
              hasUsage = await _networkService.addressHasUsage(address);
            } catch (_) {
              hasUsage = false;
            }
            return _DiscoveredAccountProbe(
              index: index,
              address: address,
              hasUsage: hasUsage,
            );
          },
        ),
      );

      for (final _DiscoveredAccountProbe probe in probes) {
        if (probe.hasUsage) {
          consecutiveUnused = 0;
          discoveredAccounts.add(
            Account(
              index: probe.index,
              name:
                  probe.index == 0 ? profileName : 'Account ${probe.index + 1}',
              lastAccess: discoveredAccounts.isEmpty ? 1 : 0,
              selected: discoveredAccounts.isEmpty,
              address: probe.address,
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

  void _startBackgroundImportedAccountDiscovery({
    required String seed,
    required String profileName,
  }) {
    unawaited(() async {
      final List<Account> discoveredAccounts = await _discoverAccountsForSeed(
        seed,
        profileName: profileName,
        gapLimit: 2,
      );

      if (discoveredAccounts.length <= 1) {
        return;
      }

      final String activeSeed = _seed ?? await _vault.getSeed();
      if (activeSeed != seed) {
        return;
      }

      for (final Account account in discoveredAccounts) {
        final bool isSelected = account.index == (_selectedAccount?.index ?? 0);
        account.selected = isSelected;
        account.lastAccess = isSelected ? 1 : 0;
        await _db.saveAccount(account);
      }

      if (!mounted) {
        return;
      }

      final List<Account> refreshedAccounts = await _db.getAccounts(seed);
      final int selectedIndex = _selectedAccount?.index ?? 0;
      final Account? updatedSelected = refreshedAccounts
          .where((Account item) => item.index == selectedIndex)
          .cast<Account?>()
          .firstWhere(
            (Account? item) => item != null,
            orElse: () =>
                refreshedAccounts.isEmpty ? null : refreshedAccounts.first,
          );

      if (!mounted) {
        return;
      }

      setState(() {
        _accounts = refreshedAccounts;
        _selectedAccount = updatedSelected;
        _statusMessage = _trf(
          context,
          'recovered_accounts_from_seed',
          <String, String>{'count': '${refreshedAccounts.length}'},
        );
      });
    }());
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
      await widget.preferences.setBool(_walletPresenceKey, false);
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
        _errorMessage = _trf(
          context,
          'failed_reset_browser_wallet_data',
          <String, String>{'error': '$error'},
        );
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
      final BrowserWalletSnapshot liveSnapshot =
          await _networkService.loadSnapshot(
        address: account.address!,
        currencyCode: _currencyCode,
      );
      final BrowserWalletSnapshot snapshot =
          await _mergeSnapshotWithCachedPrice(liveSnapshot);

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
      _scheduleAccountBalanceRefresh(accounts);
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

  Future<BrowserWalletSnapshot> _mergeSnapshotWithCachedPrice(
    BrowserWalletSnapshot snapshot,
  ) async {
    final String currencyCode = snapshot.currencyCode.toUpperCase();
    final double cachedLocalPrice = widget.preferences
            .getDouble('${_priceCachePrefix}${currencyCode}_local') ??
        0;
    final double cachedBtcPrice = widget.preferences
            .getDouble('${_priceCachePrefix}${currencyCode}_btc') ??
        0;

    double resolvedLocalPrice = snapshot.localCurrencyPrice;
    double resolvedBtcPrice = snapshot.btcPrice;

    if (resolvedLocalPrice > 0) {
      await widget.preferences.setDouble(
        '${_priceCachePrefix}${currencyCode}_local',
        resolvedLocalPrice,
      );
    } else if (cachedLocalPrice > 0) {
      resolvedLocalPrice = cachedLocalPrice;
    }

    if (resolvedBtcPrice > 0) {
      await widget.preferences.setDouble(
        '${_priceCachePrefix}${currencyCode}_btc',
        resolvedBtcPrice,
      );
    } else if (cachedBtcPrice > 0) {
      resolvedBtcPrice = cachedBtcPrice;
    }

    if (resolvedLocalPrice == snapshot.localCurrencyPrice &&
        resolvedBtcPrice == snapshot.btcPrice) {
      return snapshot;
    }

    return BrowserWalletSnapshot(
      balance: snapshot.balance,
      transactions: snapshot.transactions,
      tokens: snapshot.tokens,
      tokenTransactions: snapshot.tokenTransactions,
      btcPrice: resolvedBtcPrice,
      localCurrencyPrice: resolvedLocalPrice,
      currencyCode: snapshot.currencyCode,
    );
  }

  String _describeNetworkError(Object error) {
    final String raw = error.toString();
    if (raw.contains('XMLHttpRequest error')) {
      return 'Live network sync failed: browser CORS blocked the hosted web app from calling the remote HTTP APIs. The Chrome extension can use those endpoints via host permissions, but the PWA needs the APIs to send CORS headers or be exposed through a same-origin reverse proxy.';
    }
    if (raw.toLowerCase().contains('status 503')) {
      return 'Live network sync failed: the transaction history service is temporarily unavailable (503).';
    }
    return 'Live network sync failed: $raw';
  }

  void _scheduleAccountBalanceRefresh(List<Account> accounts) {
    if (accounts.isEmpty) {
      return;
    }

    final List<Account> refreshTargets = List<Account>.from(accounts);
    unawaited(() async {
      await _refreshAllAccountBalances(refreshTargets);
      if (!mounted) {
        return;
      }

      final String seed = _seed ?? '';
      final List<Account> refreshedAccounts =
          seed.isEmpty ? refreshTargets : await _db.getAccounts(seed);
      final int? selectedIndex = _selectedAccount?.index;
      final Account? updatedSelected = refreshedAccounts
          .where((Account item) => item.index == selectedIndex)
          .cast<Account?>()
          .firstWhere((Account? item) => item != null,
              orElse: () => _selectedAccount);

      if (!mounted) {
        return;
      }

      setState(() {
        _accounts = refreshedAccounts;
        _selectedAccount = updatedSelected;
      });
    }());
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
    final String amount = _normalizeDecimalInput(_amountController.text);
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
    if (_exceedsAvailableBalance(
      amount: amount,
      estimatedFee: estimatedFee,
      balance: _snapshot?.balance.balance ?? '0',
    )) {
      setState(() {
        _sendErrorMessage = _tr(context, 'amount_plus_fee_exceeds_balance');
      });
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_tr(context, 'confirm_transaction')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_trf(
                context,
                'send_amount_to',
                <String, String>{'amount': amount},
              )),
              const SizedBox(height: 8),
              SelectableText(
                destination,
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(_trf(
                context,
                'estimated_fee_label',
                <String, String>{'fee': estimatedFee.toStringAsFixed(6)},
              )),
              if (operation.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  _trf(
                    context,
                    'operation_value',
                    <String, String>{'value': operation},
                  ),
                ),
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
              child: Text(_tr(context, 'cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(_tr(context, 'confirm')),
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
        throw StateError(_tr(context, 'seed_unavailable_browser_vault'));
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
              _tr(context, 'transaction_submitted_successfully');
          _lastSubmitResult = result;
        });
      } else {
        setState(() {
          _working = false;
          _sendErrorMessage = _trf(
            context,
            'transaction_rejected',
            <String, String>{'message': result.message},
          );
          _lastSubmitResult = result;
        });
      }
    } catch (error) {
      setState(() {
        _working = false;
        _sendErrorMessage = _trf(
          context,
          'transaction_submission_failed',
          <String, String>{'error': '$error'},
        );
      });
    }
  }

  String _normalizeDecimalInput(String rawValue) {
    final String trimmed = rawValue.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return trimmed.replaceAll(',', '.');
  }

  Future<void> _submitTokenSendTransaction() async {
    final Account? account = _selectedAccount;
    final String tokenName = _selectedTokenName ?? '';
    final String destination = _destinationController.text.trim();
    final String tokenAmount = _tokenAmountController.text.trim();
    final String message = _tokenMessageController.text.trim();

    if (account?.address == null || account!.address!.isEmpty) {
      setState(() {
        _sendErrorMessage = _tr(context, 'no_active_browser_wallet_account');
      });
      return;
    }
    if (tokenName.isEmpty) {
      setState(() {
        _sendErrorMessage = _tr(context, 'no_token_selected_for_transfer');
      });
      return;
    }
    if (destination.isEmpty) {
      setState(() {
        _sendErrorMessage = _tr(context, 'enter_destination_address_first');
      });
      return;
    }
    if (!Address(destination).isValid()) {
      setState(() {
        _sendErrorMessage = _tr(context, 'destination_address_invalid');
      });
      return;
    }
    if (tokenAmount.isEmpty) {
      setState(() {
        _sendErrorMessage = _tr(context, 'enter_token_amount_first');
      });
      return;
    }

    final int requestedAmount = int.tryParse(tokenAmount) ?? -1;
    if (requestedAmount <= 0) {
      setState(() {
        _sendErrorMessage = _tr(context, 'token_amount_positive_integer');
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
        _sendErrorMessage = _tr(context, 'token_amount_exceeds_balance');
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
        throw StateError(_tr(context, 'seed_unavailable_browser_vault'));
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
          _sendStatusMessage = _tr(context, 'token_transfer_sent_successfully');
          _lastSubmitResult = result;
          _lastSubmitAmountLabel = '$tokenAmount $tokenName';
        });
      } else {
        setState(() {
          _working = false;
          _sendErrorMessage = _trf(
            context,
            'token_transfer_rejected',
            <String, String>{'message': result.message},
          );
          _lastSubmitResult = result;
        });
      }
    } catch (error) {
      setState(() {
        _working = false;
        _sendErrorMessage = _trf(
          context,
          'token_transfer_submission_failed',
          <String, String>{'error': '$error'},
        );
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

  bool _exceedsAvailableBalance({
    required String amount,
    required double estimatedFee,
    required String balance,
  }) {
    final Decimal amountValue = _parseBisDecimal(amount);
    final Decimal feeValue =
        _parseBisDecimal(estimatedFee.toStringAsFixed(8));
    final Decimal balanceValue = _parseBisDecimal(balance);
    return amountValue + feeValue > balanceValue;
  }

  Decimal _parseBisDecimal(String value) {
    final String normalized = _normalizeDecimalInput(value);
    if (normalized.isEmpty) {
      return Decimal.zero;
    }

    try {
      return Decimal.parse(normalized);
    } catch (_) {
      return Decimal.zero;
    }
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

class _DiscoveredAccountProbe {
  final int index;
  final String address;
  final bool hasUsage;

  const _DiscoveredAccountProbe({
    required this.index,
    required this.address,
    required this.hasUsage,
  });
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
          colors: <Color>[
            palette.background,
            Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0D1622)
                : const Color(0xFFE7EEF7),
          ],
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
                              shell._openSettingsView(fromLabelKey: 'popup'),
                          icon: const Icon(Icons.settings_outlined),
                          tooltip: _tr(context, 'settings'),
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
                      _tr(context, 'hosted_wallet_runtime_notice'),
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
    final bool showFirstOpenLayout =
        !shell._hasWallet && !shell._knownWalletExists;

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
              title: _tr(context, 'mybismuth_non_custodial_wallet'),
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
                      border: Border.all(color: palette.outline),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          _tr(context, 'import_24_word_mnemonic'),
                          style: TextStyle(
                            color: palette.muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tr(context, 'mnemonic_storage_note'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: palette.muted.withValues(alpha: 0.82),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: shell._mnemonicController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'bright future ability ...',
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
                          onPressed: shell._working || shell._loading
                              ? null
                              : shell._createWallet,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(_tr(context, 'create_wallet')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: shell._working || shell._loading
                              ? null
                              : shell._importWallet,
                          icon: const Icon(Icons.download_outlined),
                          label: Text(_tr(context, 'import_wallet')),
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
                              _tr(context, 'generated_seed'),
                            ),
                            onCopyMnemonic: () =>
                                shell._copyPendingWalletSecret(
                              shell._pendingMnemonic!,
                              _tr(context, 'generated_mnemonic'),
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
                      onPressed: shell._working || shell._loading
                          ? null
                          : shell._scanQrForImport,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(_tr(context, 'scan_import_qr')),
                    ),
                  ),
                  if (shell._loading) ...<Widget>[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: palette.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _tr(context, 'loading_browser_wallet'),
                          style: TextStyle(
                            color: palette.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
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
              _ViewBackLink(
                label:
                    '${_tr(context, 'back_to')} ${_tr(context, shell._settingsBackLabelKey)}',
                onPressed: shell._closeSettingsView,
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
            title: _tr(context, 'network'),
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
                  decoration: InputDecoration(
                    labelText: _tr(context, 'custom_websocket_api_endpoint'),
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
                  child: Text(_tr(context, 'connect')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            palette: palette,
            title: _tr(context, 'preferences'),
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
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: _tr(context, 'theme'),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  child: SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: _ExtensionShellState._supportedThemeModes.entries
                        .map(
                          (MapEntry<String, String> mode) =>
                              ButtonSegment<String>(
                            value: mode.key,
                            label: Text(_tr(context, mode.key)),
                          ),
                        )
                        .toList(),
                    selected: <String>{shell.widget.themeMode},
                    onSelectionChanged: (Set<String> values) {
                      if (values.isNotEmpty) {
                        shell._setThemeMode(values.first);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            palette: palette,
            title: _tr(context, 'security'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _StatusRow(
                  label: _tr(context, 'wallet_lock'),
                  value: shell._protectionStatus.hasProtectedWallet
                      ? _tr(context, 'protected')
                      : _tr(context, 'legacy_local_storage'),
                  valueColor: shell._protectionStatus.hasProtectedWallet
                      ? palette.primary
                      : const Color(0xFFF8C15D),
                ),
                const SizedBox(height: 12),
                _StatusRow(
                  label: _tr(context, 'pin_unlock'),
                  value: shell._protectionStatus.hasPinProtection
                      ? _tr(context, 'enabled')
                      : _tr(context, 'disabled'),
                  valueColor: shell._protectionStatus.hasPinProtection
                      ? palette.secondary
                      : palette.muted,
                ),
                const SizedBox(height: 12),
                if (shell._protectionStatus.hasPinProtection) ...<Widget>[
                  _StatusRow(
                    label: _tr(context, 'pin_attempts'),
                    value: shell._protectionStatus.failedPinAttempts.toString(),
                    valueColor: shell._protectionStatus.isPinLocked
                        ? const Color(0xFFFF8A80)
                        : palette.muted,
                  ),
                  const SizedBox(height: 12),
                ],
                if (shell._protectionStatus.isPinLocked) ...<Widget>[
                  Text(
                    _tr(context, 'pin_unlock_temporarily_locked'),
                    style: TextStyle(
                      color: palette.muted,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                _StatusRow(
                  label: _tr(context, 'passkey_unlock'),
                  value: shell._protectionStatus.hasPasskeyProtection
                      ? _tr(context, 'enabled')
                      : shell._protectionStatus.canEnrollPasskey
                          ? _tr(context, 'available')
                          : _tr(context, 'unsupported'),
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
                    _tr(context, 'passkey_support_without_prf'),
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
                      label: Text(_tr(context, 'enable_passkey_unlock')),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                if (shell._protectionStatus.hasProtectedWallet &&
                    !shell._walletLocked)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: shell._working ? null : shell._lockWallet,
                      icon: const Icon(Icons.lock_clock_outlined),
                      label: Text(_tr(context, 'lock_wallet_now')),
                    ),
                  ),
                if (shell._protectionStatus.hasProtectedWallet &&
                    !shell._walletLocked)
                  const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: shell._authMethod,
                  items: _ExtensionShellState._supportedAuthMethods.entries
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
          const SizedBox(height: 18),
          _SectionCard(
            palette: palette,
            title: _tr(context, 'manage'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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
                    label: Text(_tr(context, 'reset_browser_wallet')),
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
            title: _tr(context, 'unlock_browser_wallet'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  shell._protectionStatus.hasPasskeyProtection
                      ? _tr(context, 'locked_wallet_description_with_passkey')
                      : _tr(context, 'locked_wallet_description_pin_only'),
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
                      label: Text(_tr(context, 'unlock_with_passkey')),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (shell._protectionStatus.hasPinProtection) ...<Widget>[
                  _PinEntryField(
                    controller: shell._unlockPasswordController,
                    label: _tr(context, 'six_digit_wallet_pin'),
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
                      label: Text(_tr(context, 'unlock_with_pin')),
                    ),
                  ),
                ],
                if (shell._protectionStatus.isPinLocked) ...<Widget>[
                  const SizedBox(height: 14),
                  _BannerCard(
                    palette: palette,
                    color: const Color(0xFFF8C15D),
                    message: _tr(context, 'pin_unlock_rate_limited'),
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
                  _tr(context, 'recovery_depends_on_seed_phrase'),
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
                label: _tr(context, 'clear'),
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
      title: _tr(context, 'hosted_wallet'),
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
                      'myBismuth Wallet',
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
                label: _tr(context, 'installable_pwa'),
                color: palette.primary,
              ),
              _ChipLabel(
                palette: palette,
                label: network == 'mainnet'
                    ? _tr(context, 'mainnet_profile')
                    : _tr(context, 'testnet_profile'),
                color: palette.secondary,
                onTap: onOpenOptions,
              ),
              _ChipLabel(
                palette: palette,
                label: _trf(
                  context,
                  'launch_count',
                  <String, String>{'count': '$launchCount'},
                ),
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
        Row(
          children: <Widget>[
            const Spacer(),
            IconButton(
              onPressed: () => shell._openSettingsView(fromLabelKey: 'wallet'),
              icon: const Icon(Icons.settings_outlined),
              tooltip: _tr(context, 'settings'),
              style: IconButton.styleFrom(
                backgroundColor: palette.surfaceAlt,
                foregroundColor: palette.text,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _SectionCard(
          palette: palette,
          title: 'myBismuth Wallet',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: compact ? 0.94 : 0.58,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: selectedAccount == null
                          ? null
                          : () => shell._selectAccount(selectedAccount),
                      borderRadius: BorderRadius.circular(16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: compact ? 124 : 108,
                          padding: EdgeInsets.all(compact ? 5 : 9),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
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
                                        fontSize: compact ? 15 : 16,
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
                    label: _tr(context, 'wallets'),
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
                  if (shell._assetTabIndex == 0)
                    TextButton(
                      onPressed:
                          shell._working ? null : shell._addDerivedAccount,
                      child: Text(_tr(context, 'add_new')),
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
        title: _tr(context, 'browser_wallet'),
        child: Text(
          _tr(context, 'no_browser_wallet_account_selected'),
          style: TextStyle(
            color: palette.muted,
            fontSize: 13,
            height: 1.45,
          ),
        ),
      );
    }

    final bool wrapReceiveWithOutsideLinks = shell._accountDetailViewIndex == 2;
    final bool wrapTokenListWithOutsideLinks =
        shell._accountDetailViewIndex == 3 && shell._selectedTokenName == null;

    final Widget detailContent = _showsStandaloneTransactionCard(
      shell._accountDetailViewIndex,
      selectedTokenName: shell._selectedTokenName,
    )
        ? _DetailContentSwitch(
            palette: palette,
            shell: shell,
            account: account,
          )
        : _SectionCard(
            palette: palette,
            title: _detailSectionTitle(
              context,
              shell._accountDetailViewIndex,
              selectedTokenName: shell._selectedTokenName,
            ),
            child: _DetailContentSwitch(
              palette: palette,
              shell: shell,
              account: account,
            ),
          );

    final Widget panelContent =
        wrapReceiveWithOutsideLinks || wrapTokenListWithOutsideLinks
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _BackToTransactionsLink(
                    onPressed: shell._returnToAccountTransactions,
                  ),
                  const SizedBox(height: 8),
                  detailContent,
                  const SizedBox(height: 12),
                  _BackToTransactionsLink(
                    onPressed: shell._returnToAccountTransactions,
                  ),
                ],
              )
            : detailContent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _ViewBackLink(
              label: _tr(context, 'back_to_wallets'),
              onPressed: shell._showOverviewHome,
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
                        ? _tr(context, 'api_connection_established')
                        : _tr(context, 'no_api_connection_established'),
                  ),
                ),
                IconButton(
                  onPressed: () => shell._openSettingsView(
                    fromLabelKey: 'wallet',
                  ),
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: _tr(context, 'settings'),
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
          onOpenSettings: () => shell._openSettingsView(
            fromLabelKey: 'wallet',
          ),
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
              label: _tr(context, 'send'),
              selected: shell._accountDetailViewIndex == 1 ||
                  shell._accountDetailViewIndex == 4,
              onTap: shell._selectedTokenName != null
                  ? shell._setTokenSendView
                  : () => shell._setAccountDetailView(1),
            ),
            _OverviewTabButton(
              palette: palette,
              label: _tr(context, 'receive'),
              selected: shell._accountDetailViewIndex == 2,
              onTap: () => shell._setAccountDetailView(2),
            ),
            _OverviewTabButton(
              palette: palette,
              label: _tr(context, 'tokens'),
              selected: shell._accountDetailViewIndex == 3 &&
                  shell._selectedTokenName == null,
              onTap: shell._selectedTokenName != null
                  ? shell._showTokenBalances
                  : () => shell._setAccountDetailView(3),
            ),
          ],
        ),
        const SizedBox(height: 18),
        panelContent,
      ],
    );
  }

  bool _showsStandaloneTransactionCard(int index, {String? selectedTokenName}) {
    if (index == 0 || index == 1 || index == 4 || index == 5) {
      return true;
    }
    return index == 3 && selectedTokenName != null;
  }

  String _detailSectionTitle(
    BuildContext context,
    int index, {
    String? selectedTokenName,
  }) {
    switch (index) {
      case 1:
        return _tr(context, 'send');
      case 4:
        return _tr(context, 'send');
      case 2:
        return _tr(context, 'receive');
      case 3:
        return selectedTokenName == null
            ? _tr(context, 'tokens')
            : _tr(context, 'transaction_history');
      case 5:
        return _tr(context, 'transaction_detail');
      case 0:
      default:
        return _tr(context, 'transaction_history');
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
    final String heroTitle = _trf(
      context,
      'balance_title',
      <String, String>{'name': selectedTokenName ?? 'Bismuth'},
    );
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
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            heroTitle,
                            style: const TextStyle(
                              color: Color(0xFF081018),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          _AccountMetaChip(
                            label: _tr(context, 'account_label'),
                            value: account.name ?? 'Account',
                            onTap: onRenameAccount,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        heroAmount,
                        style: const TextStyle(
                          color: Color(0xFF081018),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                      tooltip: _tr(context, 'refresh_live_data'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  snapshot == null
                      ? _tr(context, 'waiting_for_first_network_sync')
                      : selectedToken == null
                          ? '≈ ${localValue.toStringAsFixed(6)} $currencyCode • ${_trf(context, 'tx_count', <String, String>{
                                  'count': '$transactionCount'
                                })}'
                          : _trf(
                              context,
                              'token_tx_count_on_account',
                              <String, String>{
                                'count': '$tokenTransactionCount',
                                'token': selectedTokenName ?? '',
                              },
                            ),
                  style: TextStyle(
                    color: const Color(0xFF081018).withValues(alpha: 0.72),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
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
                        tooltip: _tr(context, 'copy_address'),
                      ),
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
            _BackToTransactionsLink(
              onPressed: shell._returnToAccountTransactions,
            ),
            const SizedBox(height: 8),
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
            ],
            const SizedBox(height: 12),
            _BackToTransactionsLink(
              onPressed: shell._returnToAccountTransactions,
            ),
          ],
        );
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (shell._selectedTokenName != null) ...<Widget>[
              _ViewBackLink(
                label: _tr(context, 'back_to_tokens'),
                onPressed: shell._returnToSelectedTokenTransactions,
              ),
              const SizedBox(height: 8),
            ],
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
                _ViewBackLink(
                  label: _tr(context, 'back_to_tokens'),
                  onPressed: shell._returnToSelectedTokenTransactions,
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
                onOpenTransactionDetail: shell._openTokenTransactionDetail,
              );
      case 5:
        return _TransactionDetailCard(
          palette: palette,
          detail: shell._selectedTransactionDetail,
          loading: shell._transactionDetailLoading,
          errorMessage: shell._transactionDetailError,
          onBack: shell._transactionDetailReturnToTokenTransactions
              ? shell._returnToSelectedTokenTransactions
              : shell._returnToAccountTransactions,
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
          onOpenTransactionDetail: shell._openTransactionDetail,
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
            border: Border.all(color: palette.outline),
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
                tooltip: _tr(context, 'copy_address'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BackToTransactionsLink extends StatelessWidget {
  final VoidCallback onPressed;

  const _BackToTransactionsLink({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _ViewBackLink(
      label: _tr(context, 'back_to_transactions'),
      onPressed: onPressed,
    );
  }
}

class _ViewBackLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _ViewBackLink({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.arrow_back),
          tooltip: label,
        ),
        TextButton(
          onPressed: onPressed,
          child: Text(label),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
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
    final Color backgroundColor = palette.isLight
        ? Colors.white
        : selected
            ? palette.primary.withValues(alpha: 0.18)
            : palette.surfaceAlt;
    final BorderSide borderSide = BorderSide(
      color: selected
          ? palette.primary.withValues(alpha: 0.5)
          : palette.outline,
    );

    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? palette.primary : palette.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
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
        _tr(context, 'no_deterministic_accounts'),
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
                  : palette.outline,
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
                          ? account.name ?? _tr(context, 'account')
                          : _shortAddress(account.address!),
                      style: TextStyle(
                        color: palette.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${account.name ?? _tr(context, 'account')} • $balance BIS',
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
        color: palette.sendFormColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _trf(context, 'send_token', <String, String>{'token': tokenName}),
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
              labelText: _trf(context, 'amount_token',
                  <String, String>{'token': tokenName}),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: messageController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: _tr(context, 'message'),
              hintText: _tr(context, 'optional_message'),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _tr(context, 'token_transfer_operation_note'),
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
              label: Text(_tr(context, 'send')),
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

  const _WalletTokensList({
    super.key,
    required this.palette,
    required this.account,
    required this.snapshot,
    this.onSelectToken,
  });

  @override
  Widget build(BuildContext context) {
    final List<BisToken> tokens = snapshot?.tokens ?? const <BisToken>[];
    if (snapshot == null) {
      return Text(
        _tr(context, 'loading_token_balances'),
        style: TextStyle(
          color: palette.muted,
          fontSize: 13,
          height: 1.45,
        ),
      );
    }

    if (tokens.isEmpty) {
      return Text(
        _trf(
          context,
          'no_token_balances_found',
          <String, String>{
            'account': _shortAddress(
              account?.address ?? _tr(context, 'this_account'),
            ),
          },
        ),
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
        Text(
          _trf(
            context,
            'token_balances_for',
            <String, String>{'account': _shortAddress(account?.address ?? '')},
          ),
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
              : _tr(context, 'tokens');
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
                    border: Border.all(color: palette.outline),
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
  final Future<void> Function(BrowserWalletTokenTransaction transaction)
      onOpenTransactionDetail;

  const _TokenTransactionsCard({
    required this.palette,
    required this.account,
    required this.tokenName,
    required this.transactions,
    required this.visibleCount,
    required this.onBackToTokens,
    required this.onShowMore,
    required this.onShowLess,
    required this.onOpenTransactionDetail,
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
        _ViewBackLink(
          label: _tr(context, 'back_to_tokens'),
          onPressed: onBackToTokens,
        ),
        const SizedBox(height: 16),
        if (filtered.isEmpty)
          Text(
            _trf(
              context,
              'no_token_transactions_found',
              <String, String>{'token': tokenName},
            ),
            style: TextStyle(
              color: palette.muted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        if (filtered.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.transactionPanelColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.transactionBorderColor),
              boxShadow: palette.panelShadows,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _tr(context, 'transactions'),
                  style: TextStyle(
                    color: palette.text,
                    fontSize: 16,
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
                    onTap: () => onOpenTransactionDetail(transaction),
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
                          child: Text(_tr(context, 'show_more_transactions')),
                        ),
                      if (visible.length > 5)
                        TextButton(
                          onPressed: onShowLess,
                          child: Text(_tr(context, 'show_less')),
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
  final VoidCallback onTap;

  const _TokenTransactionRow({
    required this.palette,
    required this.accountAddress,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReceive = transaction.recipient == accountAddress;
    final bool isPending = transaction.isPending;
    final Color accent =
        isReceive ? const Color(0xFF2EE6A6) : const Color(0xFFF8C15D);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.transactionItemColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: palette.transactionBorderColor,
        ),
        boxShadow: palette.itemShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
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
                            '${_tr(context, isReceive ? 'receive' : 'send')} ${transaction.amount} ${transaction.tokenName}',
                            style: TextStyle(
                              color: palette.text,
                              fontSize: 16,
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
                                color: const Color(0xFFFF9F43)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFFF9F43)
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              child: Text(
                                _tr(context, 'pending'),
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
                          fontSize: 16,
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
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      title: _tr(context, 'no_browser_wallet_yet'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _tr(context, 'no_browser_wallet_yet_description'),
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
              label: Text(_tr(context, 'create_browser_wallet')),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenOptions,
              icon: const Icon(Icons.open_in_new),
              label: Text(_tr(context, 'open_wallet_setup')),
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
      title: _tr(context, 'current_status'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _StatusRow(
            label: _tr(context, 'pwa_shell'),
            value: _tr(context, 'ready'),
            valueColor: palette.primary,
          ),
          const SizedBox(height: 10),
          _StatusRow(
            label: _tr(context, 'browser_wallet_storage'),
            value: hasWallet
                ? _tr(context, 'active')
                : _tr(context, 'not_initialized'),
            valueColor: hasWallet ? palette.secondary : const Color(0xFFF8C15D),
          ),
          const SizedBox(height: 10),
          _StatusRow(
            label: _tr(context, 'migration_notice'),
            value: noticeAcknowledged
                ? _tr(context, 'acknowledged')
                : _tr(context, 'visible'),
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
      title: _tr(context, 'next_actions'),
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
                    ? _tr(context, 'manage_browser_wallet')
                    : _tr(context, 'open_wallet_setup'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isOptionsView
                ? _tr(context, 'jump_to_browser_wallet_section')
                : hasWallet
                    ? _tr(context, 'open_wallet_manager_browser_wallet_section')
                    : _tr(context, 'use_wallet_setup_view'),
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
            label: Text(_tr(context, 'back')),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: palette.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _tr(context, 'confirm_mnemonic_backup'),
            style: TextStyle(
              color: palette.text,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tr(context, 'confirm_mnemonic_backup_description'),
            style: TextStyle(
              color: palette.muted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          for (final _MnemonicCheckPrompt prompt in prompts) ...<Widget>[
            Text(
              _trf(
                context,
                'word_number',
                <String, String>{'position': '${prompt.position}'},
              ),
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
                  child: Text(_tr(context, 'back')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: working || !allAnswered ? null : onConfirm,
                  child: Text(_tr(context, 'confirm_and_save')),
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
            _tr(context, 'back_up_before_saving'),
            style: TextStyle(
              color: palette.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _tr(context, 'back_up_before_saving_description'),
            style: TextStyle(
              color: palette.muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: _tr(context, 'generated_seed'),
            value: seed,
            multiLine: true,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: working ? null : onCopySeed,
              icon: const Icon(Icons.copy_all_outlined),
              label: Text(_tr(context, 'copy_seed')),
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
              label: Text(_tr(context, 'copy_mnemonic')),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: working ? null : onDiscard,
                  child: Text(_tr(context, 'discard')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: working ? null : onConfirm,
                  child: Text(_tr(context, 'save_browser_wallet')),
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
        color: palette.sendFormColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.outline),
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
              hintText: _tr(context, 'optional'),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: openfieldController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: _tr(context, 'openfield'),
              hintText: _tr(context, 'optional_payload'),
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
  final ValueChanged<AddressTxsResponseResult> onOpenTransactionDetail;

  const _RecentTransactionsCard({
    required this.palette,
    required this.transactions,
    required this.visibleCount,
    required this.onShowMore,
    required this.onShowLess,
    required this.onOpenTransactionDetail,
  });

  @override
  Widget build(BuildContext context) {
    final List<AddressTxsResponseResult> visible =
        transactions.take(visibleCount).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.transactionPanelColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.transactionBorderColor),
        boxShadow: palette.panelShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _tr(context, 'transactions'),
            style: TextStyle(
              color: palette.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            Text(
              _tr(context, 'no_recent_transactions_loaded'),
              style: TextStyle(
                color: palette.muted,
                fontSize: 16,
              ),
            ),
          for (final AddressTxsResponseResult tx in visible) ...<Widget>[
            _RecentTxRow(
              palette: palette,
              transaction: tx,
              onTap: () => onOpenTransactionDetail(tx),
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
                    child: Text(_tr(context, 'show_more_transactions')),
                  ),
                if (visible.length > 5)
                  TextButton(
                    onPressed: onShowLess,
                    child: Text(_tr(context, 'show_less')),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionDetailCard extends StatelessWidget {
  final _Palette palette;
  final BrowserWalletTransactionDetail? detail;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onBack;

  const _TransactionDetailCard({
    required this.palette,
    required this.detail,
    required this.loading,
    required this.errorMessage,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.transactionPanelColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.transactionBorderColor),
          boxShadow: palette.panelShadows,
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 28),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final BrowserWalletTransactionDetail? detail = this.detail;
    if (detail == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.transactionPanelColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.transactionBorderColor),
          boxShadow: palette.panelShadows,
        ),
        child: Text(
          _tr(context, 'transaction_detail_unavailable'),
          style: TextStyle(
            color: palette.muted,
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
          label: Text(_tr(context, 'back_to_transactions')),
        ),
        const SizedBox(height: 8),
        Text(
          _tr(context, 'transaction_detail'),
          style: TextStyle(
            color: palette.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 12),
          _BannerCard(
            palette: palette,
            color: const Color(0xFFF8C15D),
            message: errorMessage!,
          ),
        ],
        const SizedBox(height: 14),
        _TransactionDetailSection(
          palette: palette,
          children: <Widget>[
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'amount'),
              valueChild: _TransactionDetailAmountValue(
                palette: palette,
                isReceive: detail.isReceive,
                amountLabel:
                    detail.displayAmountLabel ?? '${detail.amount} BIS',
              ),
            ),
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'sender'),
              value: detail.sender,
              selectable: true,
            ),
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'recipient'),
              value: detail.recipient,
              selectable: true,
            ),
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'fees'),
              value: '${detail.fee} BIS',
            ),
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'timestamp'),
              value: _formatTransactionDetailTimestamp(detail.timestamp),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _TransactionDetailSection(
          palette: palette,
          children: <Widget>[
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'block'),
              value: detail.isPending
                  ? _tr(context, 'pending')
                  : (detail.blockHeight?.toString() ?? ''),
            ),
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'block_hash'),
              value: detail.blockHash,
              selectable: true,
            ),
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'transaction_id'),
              value: detail.transactionId,
              selectable: true,
            ),
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'transaction_ref'),
              value: detail.transactionRef,
              selectable: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _TransactionDetailSection(
          palette: palette,
          children: <Widget>[
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'operation'),
              value: detail.operation,
            ),
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'openfield'),
              value: detail.openfield,
              selectable: true,
              multiLine: true,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _TransactionDetailSection(
          palette: palette,
          children: <Widget>[
            _TransactionDetailField(
              palette: palette,
              label: _tr(context, 'signature'),
              value: detail.signature,
              selectable: true,
              multiLine: true,
            ),
          ],
        ),
      ],
    );
  }

  String _formatTransactionDetailTimestamp(DateTime? value) {
    if (value == null) {
      return '';
    }

    final String day = value.day.toString().padLeft(2, '0');
    final String month = value.month.toString().padLeft(2, '0');
    final String year = value.year.toString();
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');
    final String second = value.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second, $day/$month/$year';
  }
}

class _TransactionDetailSection extends StatelessWidget {
  final _Palette palette;
  final List<Widget> children;

  const _TransactionDetailSection({
    required this.palette,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.transactionPanelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.transactionBorderColor),
        boxShadow: palette.panelShadows,
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _TransactionDetailAmountValue extends StatelessWidget {
  final _Palette palette;
  final bool isReceive;
  final String amountLabel;

  const _TransactionDetailAmountValue({
    required this.palette,
    required this.isReceive,
    required this.amountLabel,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent =
        isReceive ? const Color(0xFF2EE6A6) : const Color(0xFFF8C15D);
    final String directionLabel = _tr(context, isReceive ? 'receive' : 'send');

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            '$directionLabel $amountLabel',
            style: TextStyle(
              color: palette.text,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransactionDetailField extends StatelessWidget {
  final _Palette palette;
  final String label;
  final String value;
  final Widget? valueChild;
  final bool selectable;
  final bool multiLine;

  const _TransactionDetailField({
    required this.palette,
    required this.label,
    this.value = '',
    this.valueChild,
    this.selectable = false,
    this.multiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget valueWidget = valueChild ??
        (selectable
            ? SelectableText(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              )
            : Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  color: palette.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: palette.muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          if (multiLine)
            SizedBox(
              width: double.infinity,
              child: valueWidget,
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: valueWidget,
            ),
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
            result.success
                ? _tr(context, 'last_submission')
                : _tr(context, 'submission_error'),
            style: TextStyle(
              color: palette.text,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: _tr(context, 'status'),
            value: result.message,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: _tr(context, 'amount'),
            value: amountLabel ?? '${result.amount} BIS',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: _tr(context, 'destination'),
            value: result.destination,
            multiLine: true,
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: _tr(context, 'signature'),
            value: _shorten(result.signature),
          ),
          if (matchedTransaction != null) ...<Widget>[
            const SizedBox(height: 8),
            _InfoRow(
              label: _tr(context, 'matched_history_item'),
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
  final VoidCallback onTap;

  const _RecentTxRow({
    required this.palette,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isReceive = transaction.type == BlockTypes.RECEIVE;
    final bool isPending = transaction.isPending;
    final BisToken? token = transaction.getBisToken();
    final bool isTokenTransfer = transaction.isTokenTransfer() && token != null;
    final Color accent =
        isReceive ? const Color(0xFF2EE6A6) : const Color(0xFFF8C15D);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.transactionItemColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: palette.transactionBorderColor,
        ),
        boxShadow: palette.itemShadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
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
                              fontSize: 16,
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
                                color: const Color(0xFFFF9F43)
                                    .withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: const Color(0xFFFF9F43)
                                      .withValues(alpha: 0.45),
                                ),
                              ),
                              child: Text(
                                _tr(context, 'pending'),
                                style: const TextStyle(
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
                          fontSize: 16,
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
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.outline),
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
        Text(
          _tr(context, 'twenty_four_word_mnemonic'),
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
  final Color outline;

  const _Palette({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.secondary,
    required this.text,
    required this.muted,
    required this.outline,
  });

  bool get isLight => background.computeLuminance() > 0.5;

  Color get transactionPanelColor => isLight ? surface : surfaceAlt;

  Color get transactionItemColor => isLight ? Colors.white : Colors.transparent;

  Color get transactionBorderColor => isLight ? const Color(0xFFE1E9F2) : outline;

  Color get sendFormColor => isLight ? const Color(0xFFFAFCFE) : surfaceAlt;

  List<BoxShadow> get panelShadows => isLight
      ? const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A5D6C84),
            blurRadius: 30,
            offset: Offset(0, 16),
          ),
          BoxShadow(
            color: Color(0x0F5D6C84),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ]
      : const <BoxShadow>[];

  List<BoxShadow> get itemShadows => isLight
      ? const <BoxShadow>[
          BoxShadow(
            color: Color(0x0D5D6C84),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ]
      : const <BoxShadow>[];
}
