import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_service.dart';

class AuthService {
  final PocketBase pb = PocketBaseService.pb;

  Future<RecordAuth> login(String email, String password) async {
    final result = await pb.collection('users').authWithPassword(email, password);
    return result;
  }

  Future<void> signup(String email, String password, String name, String gender, String address, String mobile) async {
    final body = {
      "email": email,
      "password": password,
      "passwordConfirm": password,
      "name": name,
      "role": 'member',
      "emailVisibility": true,
      "gender": gender,
      "address": address,
      "mobile": mobile,
    };

    final record = await pb.collection('users').create(body: body);
  }

  void logout() {
    pb.authStore.clear();
  }

  bool isLoggedIn() => pb.authStore.isValid;

  /// Logged-in user data
  RecordModel? get currentUser => pb.authStore.model;

  /// Role helpers
  bool get isAdmin => currentUser?.data['role'] == 'admin';
  bool get isLibrarian => currentUser?.data['role'] == 'librarian';
  bool get isMember => currentUser?.data['role'] == 'member';

  /// Field access
  String? getProfileField(String field) => currentUser?.data[field];
}
