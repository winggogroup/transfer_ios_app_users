// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:transfer_app_users/transfer_app_users.dart';

void main(List<String> arguments) async {
  final csvFile = File('./assets/eb_user.csv').readAsStringSync();

  List<List<dynamic>> rows = const CsvToListConverter(
    // fieldDelimiter: ', ',
    eol: "\n",
  ).convert(csvFile);
  // rows = rows.sublist(0, 10);
  // print(rows);

  List<String> old_apple_user_ids = [];
  for (int i = 1; i < rows.length; i++) {
    final row = rows[i];
    final old_apple_uesr_id = row[1];
    print(old_apple_uesr_id);
    old_apple_user_ids.add(old_apple_uesr_id);
  }

  // print(old_apple_user_ids);
  // old_apple_user_ids = ['000086.35a49c9d30894c16b5dd1cc5402afb16.1229'];
  final transfer_user_ids = await createTransferId(old_apple_user_ids);
  print('${transfer_user_ids.length} vs ${old_apple_user_ids.length}');

  rows[0].add('new_apple_user_id');
  for (int i = 1; i < rows.length; i++) {
    final row = rows[i];
    row.add(transfer_user_ids[i - 1]);
  }

  final newCsvFile = const ListToCsvConverter().convert(rows);
  File('./assets/eb_user_new.csv').writeAsStringSync(newCsvFile);
}
