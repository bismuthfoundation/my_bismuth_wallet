// @dart=2.9

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:my_bismuth_wallet/model/db/appdb.dart';
import 'package:my_bismuth_wallet/model/vault.dart';
import 'package:my_bismuth_wallet/service/app_service.dart';
import 'package:my_bismuth_wallet/service/dragginator_service.dart';
import 'package:my_bismuth_wallet/service/http_service.dart';
import 'package:my_bismuth_wallet/util/biometrics.dart';
import 'package:my_bismuth_wallet/util/hapticutil.dart';
import 'package:my_bismuth_wallet/util/sharedprefsutil.dart';

GetIt sl = GetIt.instance;

void setupServiceLocator() {
  if (sl.isRegistered<SharedPrefsUtil>()) {
    sl.unregister<SharedPrefsUtil>();
  }
  sl.registerLazySingleton<SharedPrefsUtil>(() => SharedPrefsUtil());

  if (sl.isRegistered<AppService>()) {
    sl.unregister<AppService>();
  }
  sl.registerLazySingleton<AppService>(() => AppService());

  if (sl.isRegistered<HttpService>()) {
    sl.unregister<HttpService>();
  }
  sl.registerLazySingleton<HttpService>(() => HttpService());

  if (sl.isRegistered<DragginatorService>()) {
    sl.unregister<DragginatorService>();
  }
  sl.registerLazySingleton<DragginatorService>(() => DragginatorService());

  if (sl.isRegistered<DBHelper>()) {
    sl.unregister<DBHelper>();
  }
  sl.registerLazySingleton<DBHelper>(() => DBHelper());

  if (sl.isRegistered<HapticUtil>()) {
    sl.unregister<HapticUtil>();
  }
  sl.registerLazySingleton<HapticUtil>(() => HapticUtil());

  if (sl.isRegistered<BiometricUtil>()) {
    sl.unregister<BiometricUtil>();
  }
  sl.registerLazySingleton<BiometricUtil>(() => BiometricUtil());

  if (sl.isRegistered<Vault>()) {
    sl.unregister<Vault>();
  }
  sl.registerLazySingleton<Vault>(() => Vault());

  if (sl.isRegistered<Logger>()) {
    sl.unregister<Logger>();
  }
  sl.registerLazySingleton<Logger>(() => Logger(printer: PrettyPrinter()));
}
