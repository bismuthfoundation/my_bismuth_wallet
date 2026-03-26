import 'package:flutter/material.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';

class _WebRouteScaffold extends StatelessWidget {
  final String title;
  final String body;

  const _WebRouteScaffold({
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B101A),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFFB5C0D0),
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppHomePage extends StatelessWidget {
  final PriceConversion? priceConversion;

  const AppHomePage({super.key, this.priceConversion});

  @override
  Widget build(BuildContext context) {
    return const _WebRouteScaffold(
      title: 'My Bismuth Wallet',
      body:
          'The hosted web wallet is active. The native wallet screens are being migrated to Dart 3 and browser-safe APIs.',
    );
  }
}

class BeforeScanScreen extends StatelessWidget {
  const BeforeScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WebRouteScaffold(
      title: 'QR Scanning Unavailable',
      body:
          'Camera-based QR scanning is not available in the hosted web build yet.',
    );
  }
}

class IntroWelcomePage extends StatelessWidget {
  const IntroWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppHomePage();
  }
}

class IntroPasswordOnLaunch extends StatelessWidget {
  final String? seed;

  const IntroPasswordOnLaunch({super.key, this.seed});

  @override
  Widget build(BuildContext context) {
    return const AppHomePage();
  }
}

class IntroPassword extends StatelessWidget {
  final String? seed;

  const IntroPassword({super.key, this.seed});

  @override
  Widget build(BuildContext context) {
    return const AppHomePage();
  }
}

class IntroBackupSeedPage extends StatelessWidget {
  final String? encryptedSeed;

  const IntroBackupSeedPage({super.key, this.encryptedSeed});

  @override
  Widget build(BuildContext context) {
    return const AppHomePage();
  }
}

class IntroBackupSafetyPage extends StatelessWidget {
  const IntroBackupSafetyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppHomePage();
  }
}

class IntroBackupConfirm extends StatelessWidget {
  const IntroBackupConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppHomePage();
  }
}

class IntroImportSeedPage extends StatelessWidget {
  const IntroImportSeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppHomePage();
  }
}

class AppLockScreen extends StatelessWidget {
  const AppLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppHomePage();
  }
}

class AppPasswordLockScreen extends StatelessWidget {
  const AppPasswordLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppHomePage();
  }
}
