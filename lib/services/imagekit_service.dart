import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ImageKitService {
  static Future<String?> uploadImage(File imageFile) async {
    const String uploadUrl = 'https://upload.imagekit.io/api/v1/files/upload';
    const String publicKey = 'your_public_api_key'; // 🔁 Replace with your ImageKit public key
    const String uploadPreset = ''; // Optional

    var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
    request.fields['fileName'] = imageFile.path.split('/').last;
    request.fields['publicKey'] = publicKey;
    request.fields['file'] = base64Encode(imageFile.readAsBytesSync());

    var response = await request.send();
    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = jsonDecode(res.body);
      return data['url']; // 🎯 URL of the uploaded image
    } else {
      print('Upload failed: ${response.statusCode}');
      return null;
    }
  }
}
