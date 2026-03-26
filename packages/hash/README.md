# Cryptographic hashing functions for Dart
A set of cryptographic hashing functions implemented in pure Dart

The following hashing algorithms are supported:
* MD5
* RIPEMD-160
* SHA-1
* SHA-224
* SHA-256
* SHA-384
* SHA-512
* HMAC

# Depend on it
Add this to your package's pubspec.yaml file:
```yaml
dependencies:
  hash: ^1.0.1
```


### MD5

```dart
import 'package:hash/hash.dart';

void main() {
  var hash = [96, 191, 108, 70, 168, 246, 217, 160, 43, 181, 160, 241, 248, 105, 30, 176, 215, 208, 207, 100, 148, 36, 244, 211, 133, 189, 243, 31, 194, 97, 180, 190];
  print("MD5 digest as bytes: ${MD5().update(hash).digest()}");
  /// => MD5 digest as bytes: [157, 161, 39, 157, 129, 83, 38, 177, 20, 176, 28, 102, 71, 59, 161, 99]
}
```

### RIPEMD-160

```dart
import 'package:hash/hash.dart';

void main() {
  var hash = [96, 191, 108, 70, 168, 246, 217, 160, 43, 181, 160, 241, 248, 105, 30, 176, 215, 208, 207, 100, 148, 36, 244, 211, 133, 189, 243, 31, 194, 97, 180, 190];
  print("RIPEMD160 digest as bytes: ${RIPEMD().update(hash).digest()}");
  /// => RIPEMD160 digest as bytes: [106, 0, 130, 179, 127, 111, 174, 128, 101, 46, 44, 174, 206, 48, 221, 6, 84, 178, 249, 54]
}
```

### SHA-1

```dart
import 'package:hash/hash.dart';

void main() {
  var hash = [96, 191, 108, 70, 168, 246, 217, 160, 43, 181, 160, 241, 248, 105, 30, 176, 215, 208, 207, 100, 148, 36, 244, 211, 133, 189, 243, 31, 194, 97, 180, 190];
  print("SHA1 digest as bytes: ${SHA1().update(hash).digest()}");
  /// => SHA1 digest as bytes: [89, 77, 139, 19, 242, 92, 237, 227, 192, 203, 65, 46, 162, 206, 69, 86, 38, 40, 133, 129]
}
```


### SHA-224

```dart
import 'package:hash/hash.dart';

void main() {
  var hash = [96, 191, 108, 70, 168, 246, 217, 160, 43, 181, 160, 241, 248, 105, 30, 176, 215, 208, 207, 100, 148, 36, 244, 211, 133, 189, 243, 31, 194, 97, 180, 190];
  print("SHA224 digest as bytes: ${SHA224().update(hash).digest()}");
  /// => SHA224 digest as bytes: [65, 21, 152, 248, 205, 84, 119, 117, 173, 117, 239, 216, 31, 240, 51, 11, 2, 74, 57, 0, 240, 120, 16, 202, 89, 114, 195, 156]
}
```


### SHA-256

```dart
import 'package:hash/hash.dart';

void main() {
  var hash = [96, 191, 108, 70, 168, 246, 217, 160, 43, 181, 160, 241, 248, 105, 30, 176, 215, 208, 207, 100, 148, 36, 244, 211, 133, 189, 243, 31, 194, 97, 180, 190];
  print("SHA256 digest as bytes: ${SHA256().update(hash).digest()}");
  /// => SHA256 digest as bytes: [190, 194, 99, 8, 250, 99, 204, 92, 152, 27, 174, 217, 152, 110, 5, 15, 12, 18, 30, 166, 70, 222, 186, 8, 65, 188, 127, 150, 3, 103, 191, 161]
}
```


### SHA-384

```dart
import 'package:hash/hash.dart';

void main() {
  var hash = [96, 191, 108, 70, 168, 246, 217, 160, 43, 181, 160, 241, 248, 105, 30, 176, 215, 208, 207, 100, 148, 36, 244, 211, 133, 189, 243, 31, 194, 97, 180, 190];
  print("SHA384 digest as bytes: ${SHA384().update(hash).digest()}");
  /// => SHA384 digest as bytes: [255, 109, 245, 134, 18, 229, 151, 64, 118, 141, 233, 133, 118, 18, 79, 238, 244, 54, 40, 231, 169, 89, 34, 186, 138, 82, 38, 3, 66, 242, 245, 157, 34, 29, 82, 79, 157, 0, 79, 1, 29, 128, 141, 105, 7, 123, 41, 240]
}
```


### SHA-512

```dart
import 'package:hash/hash.dart';

void main() {
  var hash = [96, 191, 108, 70, 168, 246, 217, 160, 43, 181, 160, 241, 248, 105, 30, 176, 215, 208, 207, 100, 148, 36, 244, 211, 133, 189, 243, 31, 194, 97, 180, 190];
  print("SHA512 digest as bytes: ${SHA512().update(hash).digest()}");
  /// => SHA512 digest as bytes: [68, 17, 163, 18, 60, 62, 59, 176, 168, 3, 74, 33, 193, 202, 168, 157, 140, 188, 220, 213, 245, 97, 162, 84, 13, 178, 152, 188, 176, 243, 238, 209, 194, 238, 44, 11, 59, 100, 228, 19, 43, 181, 140, 127, 165, 69, 11, 206, 146, 129, 254, 203, 135, 91, 186, 104, 175, 145, 8, 155, 7, 184, 56, 56]
}
```


### HMAC

```dart
import 'package:hash/hash.dart';

void main() {
  var hash = [96, 191, 108, 70, 168, 246, 217, 160, 43, 181, 160, 241, 248, 105, 30, 176, 215, 208, 207, 100, 148, 36, 244, 211, 133, 189, 243, 31, 194, 97, 180, 190];
  print("HMAC digest as bytes: ${Hmac(SHA256(), hash).update(hash).digest()}");
  /// => HMAC digest as bytes: [13, 122, 158, 40, 212, 24, 185, 91, 221, 252, 165, 239, 33, 137, 147, 40, 112, 91, 216, 241, 221, 170, 60, 149, 60, 154, 67, 144, 6, 158, 65, 91]
}
```