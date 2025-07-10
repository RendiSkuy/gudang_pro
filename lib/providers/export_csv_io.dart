import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<String?> exportCsv(String csv) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        "${directory.path}/gudang_pro_export_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csv);
    OpenFile.open(path);
    return null;
  } catch (e) {
    return "Gagal menyimpan file: $e";
  }
}