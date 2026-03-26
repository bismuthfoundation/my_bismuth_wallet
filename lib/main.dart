import 'package:my_bismuth_wallet/mobile_app.dart'
    if (dart.library.html) 'package:my_bismuth_wallet/web_app.dart' as app;

Future<void> main() => app.main();
