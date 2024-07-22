import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/stats/stats_page.dart';

class HomePage extends StatefulWidget {
  final int? indexFromPrevious;

  const HomePage({super.key, this.indexFromPrevious});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ValueNotifier<int> _currentTabIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _currentTabIndex.value = widget.indexFromPrevious ?? 0;
  }

  void onTabTapped(int index) {
    setState(() {
      _currentTabIndex.value = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [
      const StatsPage(),
      const Center(child: Text('Join Page')),
      const Center(child: Text('Settings Page')),
    ];
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          AwesomeDialog(
            dismissOnTouchOutside: true,
            context: context,
            keyboardAware: true,
            dismissOnBackKeyPress: false,
            dialogType: DialogType.question,
            animType: AnimType.scale,
            transitionAnimationDuration: const Duration(milliseconds: 200),
            title: 'Exit App',
            desc: 'Are you sure you want to exit the app?',
            btnOkText: 'Yes',
            btnOkColor: Theme.of(context).primaryColor,
            btnCancelText: 'Cancel',
            btnOkOnPress: () async {
              await FlutterExitApp.exitApp();
            },
            btnCancelOnPress: () {
              DismissType.btnCancel;
            },
          ).show();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 0,
            title: Center(
              child: Text(
                _currentTabIndex.value == 0
                    ? 'Statistics'
                    : _currentTabIndex.value == 1
                        ? 'Join'
                        : 'Settings',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            leading: IconButton(
                icon: SvgPicture.asset('assets/logo/logo_with_bg.svg'),
                onPressed: () {
                  setState(() => _currentTabIndex.value = 0);
                }),
            actions: [
              Builder(
                builder: (BuildContext context) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null && user.photoURL != null) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _currentTabIndex.value = 2),
                      child: ClipOval(
                        child: FadeInImage.assetNetwork(
                          image: user.photoURL!,
                          placeholder: 'assets/images/placeholder_loading.gif',
                          fit: BoxFit.cover,
                          width: 45,
                          height: 45,
                        ),
                      ),
                    );
                  } else {
                    return Icon(Icons.account_circle,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white);
                  }
                },
              ),
            ],
          ),
          bottomNavigationBar: ValueListenableBuilder<int>(
            valueListenable: _currentTabIndex,
            builder: (context, value, child) {
              return ConvexAppBar(
                elevation: 0,
                cornerRadius: 25,
                key: ValueKey(value),
                backgroundColor: Theme.of(context).primaryColor,
                style: TabStyle.fixedCircle,
                items: const [
                  TabItem(
                      icon: Icons.bar_chart,
                      title: 'Statistics',
                      activeIcon: Icons.bar_chart_rounded),
                  TabItem(
                    icon: Icons.add_circle,
                    title: 'Join',
                    activeIcon: Icons.add_circle_rounded,
                  ),
                  TabItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      activeIcon: Icons.settings_rounded),
                ],
                initialActiveIndex: value,
                onTap: (index) {
                  setState(() {
                    _currentTabIndex.value = index;
                  });
                },
              );
            },
          ),
          body: children[_currentTabIndex.value]),
    );
  }
}
