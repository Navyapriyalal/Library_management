import 'package:pocketbase/pocketbase.dart';
import 'dart:io';

String getPocketBaseUrl() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8090';
  } else {
    return 'http://127.0.0.1:8090';
  }
}

class PocketBaseService {
  static final PocketBase pb = PocketBase(getPocketBaseUrl());
  //static final pb = PocketBase('https://pocketbase-1-a018.onrender.com');
}
