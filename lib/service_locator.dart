import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import 'package:my_idena_wallet/model/db/appdb.dart';
import 'package:my_idena_wallet/model/vault.dart';
import 'package:my_idena_wallet/util/hapticutil.dart';
import 'package:my_idena_wallet/util/biometrics.dart';
import 'package:my_idena_wallet/util/sharedprefsutil.dart';

GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<DBHelper>(() => DBHelper());
  sl.registerLazySingleton<HapticUtil>(() => HapticUtil());
  sl.registerLazySingleton<BiometricUtil>(() => BiometricUtil());
  sl.registerLazySingleton<Vault>(() => Vault());
  sl.registerLazySingleton<SharedPrefsUtil>(() => SharedPrefsUtil());
  sl.registerLazySingleton<Logger>(() => Logger(printer: PrettyPrinter()));
}