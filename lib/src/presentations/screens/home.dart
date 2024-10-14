// Dart imports:

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:zego/src/presentations/screens/convernce_video_page.dart';

class HomePage extends StatefulWidget {
  final String userId;
  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Users who use the same conferenceID can in the same conference.
  var conferenceDTextCtrl = TextEditingController(text: 'video_conference_id');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // endDrawer: const SettingsDrawer(),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: conferenceDTextCtrl,
                        decoration: const InputDecoration(
                            labelText: 'join a conference by id'),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return VideoConferencePage(
                                conferenceID: conferenceDTextCtrl.text.trim(),
                                userID: widget.userId,
                              );
                            }),
                          );
                        },
                        child: const Text('join'))
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openEndDrawer();
                },
                icon: Icon(Icons.settings),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// class SettingsDrawer extends StatefulWidget {
//   const SettingsDrawer({Key? key}) : super(key: key);
//
//   @override
//   State<SettingsDrawer> createState() {
//     return _SettingsDrawerState();
//   }
// }
//
// class _SettingsDrawerState extends State<SettingsDrawer> {
//   RadioGroupController roleController = RadioGroupController();
//
//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.sizeOf(context).width / 5.0 * 4;
//
//     return SafeArea(
//       child: Drawer(
//         width: width,
//         child: Container(
//           color: Colors.white.withOpacity(0.2),
//           margin: const EdgeInsets.all(10),
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: <Widget>[
//               group('Role', [role()]),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget role() {
//     return RadioGroup(
//       controller: roleController,
//       values: const ['Host', 'audience'],
//       indexOfDefault: settingsValue.role.index,
//       decoration: const RadioGroupDecoration(
//         spacing: 10.0,
//         labelStyle: TextStyle(
//           color: Colors.blue,
//         ),
//         activeColor: Colors.amber,
//       ),
//       onChanged: (dynamic data) {
//         final role = data as String? ?? '';
//         if (role.isEmpty) {
//           return;
//         }
//
//         settingsValue.role = 'Host' == role ? Role.Host : Role.Audience;
//       },
//     );
//   }
//
//   Widget group(String title, List<Widget> children) {
//     return Column(
//       children: [
//         Align(
//           alignment: Alignment.centerLeft,
//           child: Text(title),
//         ),
//         Container(
//           margin: EdgeInsets.all(10),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10.0),
//             color: Colors.white,
//           ),
//           child: Column(
//             children: children,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget line() {
//     return Container(
//       color: Colors.black.withOpacity(0.2),
//       height: 1,
//       margin: EdgeInsets.all(20),
//     );
//   }
// }