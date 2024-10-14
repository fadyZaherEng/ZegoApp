import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego/src/domain/entities/user_model.dart';

class GetUserUseCase {
  final SharedPreferences sharedPreferences;

  GetUserUseCase(this.sharedPreferences);

  UserModel call() {
    return sharedPreferences.getString("user") == null
        ? UserModel()
        : UserModel.fromJson(
            jsonDecode(sharedPreferences.getString("user") ?? ""),
          );
  }
}
