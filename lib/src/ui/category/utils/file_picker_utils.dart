import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>?> uploadFileToServer(
    File file, String apiUrl) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody);
    } else {
      print('Failed to upload file: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('An error occurred during the upload: $e');
    return null;
  }
}
