import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zego/src/core/base/widget/base_stateful_widget.dart';
import 'package:zego/src/di/data_layer_injector.dart';
import 'package:zego/src/domain/entities/user_model.dart';
import 'package:zego/src/domain/usecase/get_user_use_case.dart';
import 'package:zego/src/presentations/blocs/chats/chats_bloc.dart';
import 'package:zego/src/presentations/screens/my_chats/widgets/my_last_massages_stream.dart';
import 'package:zego/src/presentations/screens/my_chats/widgets/search_stream_widget.dart';

class OnBoardChatScreen extends BaseStatefulWidget {
  const OnBoardChatScreen({super.key});

  @override
  BaseState<OnBoardChatScreen> baseCreateState() => _OnBoardChatScreenState();
}

class _OnBoardChatScreenState extends BaseState<OnBoardChatScreen> {
  ChatsBloc get _bloc => BlocProvider.of<ChatsBloc>(context);
  final _searchController = TextEditingController();
  UserModel currentUser = UserModel();

  @override
  void initState() {
    super.initState();
    _bloc.add(GetAllUsersEvent());
    currentUser = GetUserUseCase(injector())();
  }

  @override
  Widget baseBuild(BuildContext context) {
    return BlocConsumer<ChatsBloc, ChatsState>(
      listener: (context, state) {
        if (state is GetUserChatsSuccess) {
        } else if (state is GetUserChatsError) {}
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: CupertinoSearchTextField(
                    placeholder: "Search",
                    prefixIcon: const Icon(CupertinoIcons.search),
                    onTap: () {},
                    onChanged: (value) {
                      _searchController.text = value;
                      setState(() {});
                      //filter stream based on search
                    },
                    controller: _searchController,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _bloc.searchQuery.isEmpty
                      ? MyChatsStream(
                          myChatsStream: _bloc.getChatsLastMassagesStream(
                            userId: GetUserUseCase(injector())().uid,
                          ),
                        )
                      : SearchStreamWidget(uid: currentUser.uid),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
