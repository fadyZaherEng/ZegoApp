import 'package:get_it/get_it.dart';
import 'package:zego/src/di/bloc_injector.dart';
import 'package:zego/src/di/data_layer_injector.dart';
import 'package:zego/src/di/repository_injector.dart';
import 'package:zego/src/di/use_case_injector.dart';

final injector = GetIt.instance;

Future<void> initializeDependencies() async {
  await initializeDataDependencies();
  await initializeRepositoryDependencies();
  await initializeUseCaseDependencies();
  await initializeBlocDependencies();
}
