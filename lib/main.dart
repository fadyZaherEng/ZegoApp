import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zego/src/di/injector.dart';
import 'package:zego/src/presentations/blocs/chats/chats_bloc.dart';
import 'package:zego/src/presentations/screens/sign_up/sign_up_screen.dart';
// import 'package:zego_zimkit/zego_zimkit.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDependencies();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await ZIMKit().init(
  //   appID: 332255309,
  //   appSign: "695d51aa7bbe13d50a1d6a3225bbf1a7be887f32ed0af34ca67015227b5c47f5",
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatsBloc()),
      ],
      child: MaterialApp(
        title: 'ZEGO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SignUpScreen(),
      ),
    );
  }
}
