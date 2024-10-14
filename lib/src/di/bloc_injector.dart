
import 'package:zego/src/di/data_layer_injector.dart';
import 'package:zego/src/presentations/blocs/chats/chats_bloc.dart';

Future<void> initializeBlocDependencies() async {

  injector.registerFactory<ChatsBloc>(() => ChatsBloc());
}
