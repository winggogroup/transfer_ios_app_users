// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dio/dio.dart';

/// https://developer.apple.com/documentation/accountorganizationaldatasharing/creating-a-client-secret
String createTransferringClientJWTToken(String client_id) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final jwt = JWT(
    {
      "iss": "74M3NX9948",
      "iat": now,
      "exp": now + 15777000,
      "aud": "https://appleid.apple.com",
      "sub": client_id,
    },
    header: {
      "alg": "ES256",
      "kid": "LM3K7H9U62",
    },
  );

  final pem = File('./assets/AuthKey_LM3K7H9U62.p8').readAsStringSync();
  final key = ECPrivateKey(pem);

  final token = jwt.sign(key, algorithm: JWTAlgorithm.ES256);
  return token;
}

/// https://developer.apple.com/documentation/accountorganizationaldatasharing/creating-a-client-secret
String createRecipientClientJWTToken(String client_id) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final jwt = JWT(
    {
      "iss": "MS2AV673HV",
      "iat": now,
      "exp": now + 15777000,
      "aud": "https://appleid.apple.com",
      "sub": client_id,
    },
    header: {
      "alg": "ES256",
      "kid": "723WRK6TM8",
    },
  );

  final pem = File('./assets/AuthKey_723WRK6TM8.p8').readAsStringSync();
  final key = ECPrivateKey(pem);

  final token = jwt.sign(key, algorithm: JWTAlgorithm.ES256);
  return token;
}

/// https://developer.apple.com/documentation/sign_in_with_apple/transferring_your_apps_and_users_to_another_team
/// https://developer.apple.com/documentation/sign_in_with_apple/bringing_new_apps_and_users_into_your_team
Future<List<String>> createUserIds(List<String> old_user_ids) async {
  const client_id = 'com.jctop.WingGos';
  final transferring_client_secret =
      createTransferringClientJWTToken(client_id);
  final recipient_client_secret = createRecipientClientJWTToken(client_id);

  final dio = Dio(BaseOptions(baseUrl: 'https://appleid.apple.com'));
  dio.options.contentType = Headers.formUrlEncodedContentType;

  final accessTokenRes = await dio.post(
    '/auth/token',
    data: {
      'grant_type': 'client_credentials',
      'scope': 'user.migration',
      'client_id': client_id,
      'client_secret': transferring_client_secret,
    },
  );

  final access_token = (accessTokenRes.data as Map)['access_token'];
  print('User access token is $access_token');

  final accessTokenRes2 = await dio.post(
    '/auth/token',
    data: {
      'grant_type': 'client_credentials',
      'scope': 'user.migration',
      'client_id': client_id,
      'client_secret': transferring_client_secret,
    },
  );

  final access_token2 = (accessTokenRes2.data as Map)['access_token'];
  print('User access token is $access_token2');

  List<String> transfer_user_ids = [];
  for (final old_user_id in old_user_ids) {
    if (old_user_id.contains("cancel") || old_user_id.contains('"')) {
      transfer_user_ids.add("");

      continue;
    } else {
      try {
        final transferIdentifierRes = await dio.post(
          '/auth/usermigrationinfo',
          data: {
            'sub': old_user_id,
            'target': 'MS2AV673HV',
            'client_id': client_id,
            'client_secret': transferring_client_secret,
          },
          options: Options(headers: {
            ...dio.options.headers,
            'Authorization': 'Bearer $access_token',
          }),
        );
        print(transferIdentifierRes);

        final exchangeIdentifierRes = await dio.post(
          '/auth/usermigrationinfo',
          data: {
            'transfer_sub': transferIdentifierRes.data['transfer_sub'],
            'client_id': client_id,
            'client_secret': recipient_client_secret,
          },
          options: Options(headers: {
            ...dio.options.headers,
            'Authorization': 'Bearer $access_token2',
          }),
        );
        print(exchangeIdentifierRes);
        transfer_user_ids.add(exchangeIdentifierRes.data['sub']);
      } catch (_) {
        print('error user id is $old_user_id');
        transfer_user_ids.add("");
      }
    }
  }

  return transfer_user_ids;
}
