import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yamble_yap_to_gamble_ai_game/encrypted/secure_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? userName;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userName = await UserSecureStorage.getUserName();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Stack(
        children: [
          // Background SVG image
          Positioned(
            top: -top,
            left: 0,
            width: width,
            height: height * 0.4,
            child: SizedBox(
              child: SvgPicture.asset(
                'assets/images/settings.svg', // Replace with your SVG asset
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.5,
            maxChildSize: 1.0,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipOval(
                                child: Container(
                                  width: height * 0.15,
                                  height: height * 0.15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: user?.photoURL != null
                                      ? FadeInImage.assetNetwork(
                                          image: user!.photoURL!,
                                          placeholder:
                                              'assets/images/placeholder_loading.gif',
                                          fit: BoxFit.cover,
                                          width: height * 0.1,
                                          height: height * 0.1,
                                        )
                                      : CircleAvatar(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          radius: height * 0.1,
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 25),
                              Container(
                                width: 3,
                                height: height * 0.15,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 25),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.displayName ?? 'User Name',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 24,
                                        ),
                                  ),
                                  Text(
                                    userName ?? 'username',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.blueGrey,
                                          fontSize: 20,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSettingsTile(
                          context,
                          icon: Icons.lock,
                          title: 'Change Password',
                          onTap: () {
                            // Handle change password action
                          },
                        ),
                        _buildSettingsTile(
                          context,
                          icon: Icons.info,
                          title: 'About Developer',
                          onTap: () {
                            // Handle about developer action
                          },
                        ),
                        _buildSettingsTile(
                          context,
                          icon: Icons.logout,
                          title: 'Logout Account',
                          onTap: () async {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.question,
                              animType: AnimType.scale,
                              title: 'Logout',
                              desc: 'Are you sure you want to logout?',
                              btnCancelOnPress: () {},
                              btnOkColor: Theme.of(context).primaryColor,
                              btnOkOnPress: () async {
                                await UserSecureStorage.clearAll();
                                // Handle logout action
                              },
                            ).show();
                          },
                        ),
                        _buildSettingsTile(
                          context,
                          icon: Icons.exit_to_app,
                          title: 'Exit Game',
                          onTap: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.question,
                              animType: AnimType.scale,
                              title: 'Exiting...',
                              desc: 'Are you sure you want to exit the game?',
                              btnCancelOnPress: () {},
                              btnOkColor: Theme.of(context).primaryColor,
                              btnOkOnPress: () async {
                                await FlutterExitApp.exitApp();
                              },
                            ).show();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required IconData icon,
      required String title,
      required Function() onTap}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.white),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onTap: onTap,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
