

import 'package:zego/src/di/data_layer_injector.dart';
import 'package:zego/src/domain/usecase/get_user_use_case.dart';
import 'package:zego/src/domain/usecase/set_user_use_case.dart';

Future<void> initializeUseCaseDependencies() async {

  injector.registerFactory<SetUserUseCase>(() => SetUserUseCase(injector()));
  injector.registerFactory<GetUserUseCase>(() => GetUserUseCase(injector()));
}
