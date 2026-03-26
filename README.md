# My Bismuth Wallet

![Thumbnail](https://raw.githubusercontent.com/bismuthfoundation/MEDIA-KIT/master/Screenshots/MyBismuthWallet/my_bis_wallet.png "Thumbnail")

Bismuth wallet app based on Flutter.

## Hosted PWA

The `web/` target is the hosted Progressive Web App version of the wallet:

- `web/manifest.json` is the active web app manifest with standalone display mode and install icons.
- `web/flutter_bootstrap.js` loads the generated Flutter service worker so the site behaves like a real installable PWA when it is served over HTTPS.
- `scripts/build_pwa.sh` builds the deployable site bundle into `build/web`.

To build the hosted PWA:

1. Run `./scripts/build_pwa.sh`
2. Deploy the contents of `build/web` to a static web host over HTTPS
3. If you host below a subpath, rebuild with the matching Flutter base href for that deployment path

For hosted PWA network access, note that the Chrome extension and the web app do not have the same privileges:

- The extension can call remote APIs because its manifest grants host permissions.
- The PWA runs as a normal web page, so browser CORS rules apply.
- The current Bismuth explorer HTTP endpoints do not return `Access-Control-Allow-Origin`, so direct browser requests from the hosted PWA can fail with `XMLHttpRequest error` even when the same endpoint works in the extension.

For production hosting, the practical fix is to serve the HTTP APIs through a same-origin reverse proxy and build with matching `dart-define` values, for example:

```bash
./scripts/build_pwa.sh \
  --dart-define=BROWSER_WALLET_EXPLORER_API_BASE=/api/ \
  --dart-define=BROWSER_WALLET_TOKEN_BALANCE_API=/api/token/balances/ \
  --dart-define=BROWSER_WALLET_TOKEN_TRANSACTIONS_API=/api/token/transactions/ \
  --dart-define=BROWSER_WALLET_WEBSOCKET_URL=wss://bismuth.world/api/web-socket/
```

If your site proxies `/api/*` to `https://bismuth.im/api/*`, the browser sees same-origin requests and the hosted PWA can sync normally.

## Chrome extension basis

There is also a Chrome extension packaging path for the same browser wallet code:

- `chrome_extension/manifest.json` defines a Manifest V3 popup extension and a full-page options surface, both backed by the Flutter web app.
- `scripts/build_chrome_extension.sh` builds the web app with CSP-compatible settings, injects the app version into the extension manifest, and assembles a loadable unpacked extension bundle in `build/chrome_extension`.
- The browser extension UI can now create or import a 24-word mnemonic, persist the seed in browser-safe encrypted storage, and derive the first Bismuth account/address locally.
- The browser extension UI now also fetches live network data for that account: balance, recent transactions, token balances, and market price data.
- The browser extension UI now includes a browser-safe send form that derives keys locally, signs transactions in Dart, and submits them to the Bismuth mempool over the legacy wallet protocol.

To load the extension in Chrome:

1. Run `./scripts/build_chrome_extension.sh`
2. Open `chrome://extensions`
3. Enable Developer mode
4. Click `Load unpacked`
5. Select the `build/chrome_extension` directory

## Current blocker

The browser shell, browser wallet storage, live network sync, and basic transaction submission now build, but the original wallet implementation is still mid-migration from an older pre-null-safety Flutter codebase.

There are also mobile-oriented integrations in the app codebase, such as direct `dart:io` imports and scanner/auth packages, that will need web-safe shims or replacements before the wallet can run as a full PWA.

All infos here: https://hypernodes.bismuth.live/?p=2574
