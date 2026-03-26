# bs58check

A straight forward implementation of base58check extending upon bs58 for Flutter writing in Dart.

Inspired by [bitcoinjs](https://github.com/bitcoinjs/bs58check)

## Example

```dart
import 'package:bs58check/bs58check.dart' as bs58check;

Uint8List decoded = bs58check.decode('5Kd3NBUAdUnhyzenEwVLy9pBKxSwXvE9FMPyR4UKZvpe6E3AgLr');

print(decoded);
// => [128, 237, 219, 220, 17, 104, 241, 218, 234, 219, 211, 228, 76, 30, 63, 143, 90, 40, 76, 32, 41, 247, 138, 210, 106, 249, 133, 131, 164, 153, 222, 91, 25]

print(HEX.encode(decoded));
// => 80eddbdc1168f1daeadbd3e44c1e3f8f5a284c2029f78ad26af98583a499de5b19

print(bs58check.encode(decoded));
// => 5Kd3NBUAdUnhyzenEwVLy9pBKxSwXvE9FMPyR4UKZvpe6E3AgLr


// for fun
print(bs58check.getAddress('AnDoan'));
// => 1AnDoannV16NE8AQ74obrTNf6i2jbahYadr
```
