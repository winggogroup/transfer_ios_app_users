// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'package:transfer_app_users/transfer_app_users.dart';

void main(List<String> arguments) async {
  const old_user_id = '000086.35a49c9d30894c16b5dd1cc5402afb16.1229';
  final transfer_user_ids = await createTransferId([old_user_id]);
  print(transfer_user_ids);
}
