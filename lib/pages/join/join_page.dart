import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yamble_yap_to_gamble_ai_game/db/game/game_api.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/game/lobby_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/form_validator.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  State<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController joinCodeController = TextEditingController();

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
                'assets/images/game.svg',
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
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32.0),
                    topRight: Radius.circular(32.0),
                  ),
                  color: Colors.white,
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
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Center(
                            child: CircleAvatar(
                              radius: 40,
                              child: Icon(
                                Icons.videogame_asset,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: joinCodeController,
                            validator: FormValidator.validateJoin,
                            maxLength: 6,
                            decoration: const InputDecoration(
                              labelText: 'Enter 6-character Join Code',
                              prefixIcon: Icon(Icons.code),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          FilledButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final joinCode = joinCodeController.text;

                                SmartDialog.showLoading(
                                  msg: 'Joining Game...',
                                  maskColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.5),
                                );
                                final gameApi = GameApi();
                                final joinStatus =
                                    await gameApi.joinGame(joinCode);
                                SmartDialog.dismiss();

                                if (joinStatus == 'SUCCESS') {
                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LobbyPage(
                                          joinCode: joinCode,
                                        ),
                                      ),
                                    );
                                  }
                                } else if (joinStatus == 'NOT-LOGGED-IN') {
                                  SmartDialog.showNotify(
                                      msg:
                                          'You are not logged in, please logout first.',
                                      notifyType: NotifyType.error);
                                } else if (joinStatus == 'GAME-NOT-FOUND') {
                                  SmartDialog.showNotify(
                                      msg:
                                          'Game with code $joinCode not found.',
                                      notifyType: NotifyType.failure);
                                } else if (joinStatus == 'GAME-FULL') {
                                  SmartDialog.showNotify(
                                      msg: 'Game with code $joinCode is full.',
                                      notifyType: NotifyType.warning);
                                } else {
                                  SmartDialog.showNotify(
                                      msg:
                                          'Failed to join game. Please try again.',
                                      notifyType: NotifyType.error);
                                }
                              }
                            },
                            child: const Text(
                              'Join Game',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          OutlinedButton(
                            onPressed: () {
                              // Handle Create a Game action
                            },
                            child: const Text(
                              'Create a Game',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
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
}
