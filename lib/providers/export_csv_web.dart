// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<String?> exportCsv(String csv) async {
  try {
    final bytes = html.Blob([csv]);
    final url = html.Url.createObjectUrlFromBlob(bytes);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download",
          "gudang_pro_export_${DateTime.now().millisecondsSinceEpoch}.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
    return "Download dimulai...";
  } catch (e) {
    return "Gagal membuat file download: $e";
  }
}
