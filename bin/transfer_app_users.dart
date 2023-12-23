import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

void main(List<String> arguments) {
  final jwt = JWT(
    {
      "iss": "74M3NX9948",
      "iat": 1703322052,
      "exp": 1719099052,
      "aud": "https://appleid.apple.com",
      "sub": "com.jctop.WingGos"
    },
    header: {
      "alg": "ES256",
      "kid": "LM3K7H9U62",
    },
  );

  final pem = File('./assets/AuthKey_LM3K7H9U62.p8').readAsStringSync();
  final key = ECPrivateKey(pem);

  final token = jwt.sign(key, algorithm: JWTAlgorithm.ES256);

  print('Signed token: $token\n');
}
