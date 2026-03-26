import '../lib/bs58check.dart' as bs58check;
import 'dart:typed_data';
import 'package:hex/hex.dart';
main() {
  Uint8List decoded = bs58check.decode('5Kd3NBUAdUnhyzenEwVLy9pBKxSwXvE9FMPyR4UKZvpe6E3AgLr');
  print(decoded);
  print(HEX.encode(decoded));
  print(bs58check.encode(decoded));
  print(bs58check.getAddress('AnDoan'));
}
