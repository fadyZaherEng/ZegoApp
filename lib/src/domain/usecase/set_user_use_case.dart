import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego/src/domain/entities/user_model.dart';

class SetUserUseCase {
  final SharedPreferences sharedPreferences;

  SetUserUseCase(this.sharedPreferences);

  Future<bool> call(UserModel userModel) async {
    return await sharedPreferences.setString(
        "user", jsonEncode(userModel.toJson()));
  }
}
