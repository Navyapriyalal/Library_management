import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ImageKitService {
  static Future<String?> uploadImage(File imageFile) async {
    const String uploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';
    final publicKey = dotenv.env['IMAGEKIT_PUBLIC_KEY'];
    final privateApiKey = dotenv.env['IMAGEKIT_PRIVATE_KEY'];

    final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

    // Attach file
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    // Add other required fields
    request.fields['fileName'] = imageFile.path.split('/').last;

    // Use basic auth with your private key
    request.headers['Authorization'] = 'Basic ' + base64Encode(utf8.encode('$privateApiKey:'));

    final response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = jsonDecode(res.body);
      return data['url'];
    } else {
      print('Upload failed with status: ${response.statusCode}');
      final error = await http.Response.fromStream(response);
      print('Error: ${error.body}');
      return null;
    }
  }
}
