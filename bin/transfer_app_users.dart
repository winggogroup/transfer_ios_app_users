// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:transfer_app_users/transfer_app_users.dart';

void main(List<String> arguments) async {
  final csvFile = File('./assets/eb_user.csv').readAsStringSync();

  List<List<dynamic>> csvRows =
      const CsvToListConverter(eol: "\n").convert(csvFile);

  List<String> old_apple_user_ids = [];
  for (int i = 1; i < csvRows.length; i++) {
    final row = csvRows[i];
    final old_apple_uesr_id = row[1];
    print(old_apple_uesr_id);
    old_apple_user_ids.add(old_apple_uesr_id);
  }

  // rows = rows.sublist(0, 10);
  // print(old_apple_user_ids);
  // old_apple_user_ids = ['000086.35a49c9d30894c16b5dd1cc5402afb16.1229'];
  final new_user_ids = await createUserIds(old_apple_user_ids);
  print('${new_user_ids.length} vs ${old_apple_user_ids.length}');

  csvRows[0].add('new_apple_user_id');
  for (int i = 1; i < csvRows.length; i++) {
    final row = csvRows[i];
    row.add(new_user_ids[i - 1]);
  }

  final newCsvFile = const ListToCsvConverter().convert(csvRows);
  File('./assets/eb_user_new.csv').writeAsStringSync(newCsvFile);
}
