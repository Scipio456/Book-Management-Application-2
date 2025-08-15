import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> getDownloadUrl(String path) {
    return _storage.ref(path).getDownloadURL();
  }

  Future<Uint8List> downloadFile(String url) async {
    final response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }
}