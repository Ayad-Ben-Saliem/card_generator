import 'package:card_generator/models/user.dart';
import 'package:card_generator/services/users_service.dart';

abstract class AuthService {
  static Future<User?> login(String email, String password) async {
    return UsersService.authenticate(email, password);
  }

  static void sendOTP(String email) {
    throw UnimplementedError();
  }

  static Future<bool> verifyOTP(String email, String otp) async {
    throw UnimplementedError();
  }
}
