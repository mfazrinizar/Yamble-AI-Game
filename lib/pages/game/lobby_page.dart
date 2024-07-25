import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yamble_yap_to_gamble_ai_game/db/game/game_api.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/game/game_page.dart';

class LobbyPage extends StatefulWidget {
  final String joinCode;

  const LobbyPage({super.key, required this.joinCode});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List players = [];

  bool _isHost = false;
  DocumentSnapshot? _gameSnapshot;

  @override
  void initState() {
    super.initState();
    _checkHostStatus();
  }

  Future<void> _checkHostStatus() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      final gameApi = GameApi();
      DocumentSnapshot? gameSnapshot =
          await gameApi.fetchGameByJoinCode(widget.joinCode);

      if (gameSnapshot != null) {
        Map<String, dynamic> gameData =
            gameSnapshot.data() as Map<String, dynamic>;
        players = gameData['players'];

        setState(() {
          _isHost = players.first['uid'] == currentUser.uid;
          _gameSnapshot = gameSnapshot;
        });
      }
    }
  }

  String getRankAsset(int rank) {
    switch (rank) {
      case 6:
        return 'assets/ranks/6_developer.svg';
      case 5:
        return 'assets/ranks/5_the-elder.svg';
      case 4:
        return 'assets/ranks/4_expert.svg';
      case 3:
        return 'assets/ranks/3_adept.svg';
      case 2:
        return 'assets/ranks/2_apprentice.svg';
      case 1:
        return 'assets/ranks/1_novice.svg';
      case 0:
      default:
        return 'assets/ranks/0_newcomer.svg';
    }
  }

  String getRankTitle(int rank) {
    switch (rank) {
      case 6:
        return 'Developer';
      case 5:
        return 'The Elder';
      case 4:
        return 'Expert';
      case 3:
        return 'Adept';
      case 2:
        return 'Apprentice';
      case 1:
        return 'Novice';
      case 0:
      default:
        return 'Newcomer';
    }
  }

  Future<void> _startGame() async {
    if (_isHost && _gameSnapshot != null) {
      final gameApi = GameApi();

      SmartDialog.showLoading(
        msg: 'Starting game...',
        maskColor: Theme.of(context).primaryColor.withOpacity(0.5),
      );
      final gameIsStarted = await gameApi.startRound(widget.joinCode);

      SmartDialog.dismiss();

      if (gameIsStarted) {
        SmartDialog.showNotify(
            msg: 'Game Started!', notifyType: NotifyType.success);
      } else {
        SmartDialog.showNotify(
            msg: 'Failed to start the game.', notifyType: NotifyType.error);
      }
      SmartDialog.dismiss();
      // Navigate to the game screen or other actions to start the game
    }
  }

  Future<void> _cancelGame(BuildContext context) async {
    final gameApi = GameApi();

    SmartDialog.showLoading(
      msg: 'Cancelling game...',
      maskColor: Theme.of(context).primaryColor.withOpacity(0.5),
    );

    final cancelSuccess = await gameApi.cancelGame(widget.joinCode);

    SmartDialog.dismiss();

    if (cancelSuccess) {
      if (context.mounted) {
        Navigator.pop(context);
        SmartDialog.showNotify(
            msg: 'The game (${widget.joinCode}) is cancelled.',
            notifyType: NotifyType.success);
      }
    } else {
      SmartDialog.showNotify(
          msg: 'Failed to leave the game.', notifyType: NotifyType.error);
    }
  }

  Future<void> _leaveGame(BuildContext context) async {
    final gameApi = GameApi();

    SmartDialog.showLoading(
      msg: 'Leaving game...',
      maskColor: Theme.of(context).primaryColor.withOpacity(0.5),
    );

    final leaveSuccess = await gameApi.leaveGame(widget.joinCode);

    SmartDialog.dismiss();

    if (leaveSuccess) {
      if (context.mounted) {
        Navigator.pop(context);
        SmartDialog.showNotify(
            msg: 'You have left the game (${widget.joinCode}).',
            notifyType: NotifyType.success);
      }
    } else {
      SmartDialog.showNotify(
          msg: 'Failed to leave the game.', notifyType: NotifyType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            if (Navigator.canPop(context)) {
              AwesomeDialog(
                dismissOnTouchOutside: true,
                context: context,
                keyboardAware: true,
                dismissOnBackKeyPress: false,
                dialogType: DialogType.question,
                animType: AnimType.scale,
                transitionAnimationDuration: const Duration(milliseconds: 200),
                title: 'Exit Lobby',
                desc:
                    'Are you sure you want to exit the lobby?${_isHost ? '\nYou are host, the game will be cancelled.' : ''}',
                btnOkText: 'Yes',
                btnOkColor: Theme.of(context).primaryColor,
                btnCancelText: 'Cancel',
                btnOkOnPress: () async => _isHost
                    ? await _cancelGame(context)
                    : await _leaveGame(context),
                btnCancelOnPress: () {
                  DismissType.btnCancel;
                },
              ).show();
            }
          },
        ),
        centerTitle: true,
        title: Text(
          'Lobby',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: 24,
              ),
        ),
      ),
      body: PopScope(
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
              title: 'Exit Lobby',
              desc:
                  'Are you sure you want to exit the lobby?${_isHost ? '\nYou are host, the game will be cancelled.' : ''}',
              btnOkText: 'Yes',
              btnOkColor: Theme.of(context).primaryColor,
              btnCancelText: 'Cancel',
              btnOkOnPress: () async => _isHost
                  ? await _cancelGame(context)
                  : await _leaveGame(context),
              btnCancelOnPress: () {
                DismissType.btnCancel;
              },
            ).show();
          }
        },
        child: Stack(
          children: [
            // Background SVG image
            Positioned(
              top: -top + 10,
              left: 0,
              width: width,
              height: height * 0.4,
              child: SizedBox(
                child: SvgPicture.asset(
                  'assets/images/waiting.svg',
                ),
              ),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: _gameSnapshot != null
                  ? _gameSnapshot!.reference.snapshots()
                  : const Stream<DocumentSnapshot>.empty(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text('Game not found'),
                  );
                }

                Map<String, dynamic> gameData =
                    snapshot.data!.data() as Map<String, dynamic>;

                bool gameActive = gameData['gameActive'];
                if (!gameActive) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context);
                    SmartDialog.showNotify(
                        msg: 'The Host ended the game.',
                        notifyType: NotifyType.alert);
                  });
                }

                bool gameStarted = gameData['rounds'].length > 0;
                if (gameStarted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    SmartDialog.showNotify(
                        msg: 'The game has started.',
                        notifyType: NotifyType.alert);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GamePage(
                          joinCode: widget.joinCode,
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  });
                }

                players = gameData['players'];

                return DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.6,
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
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 10),
                              const CircleAvatar(
                                child: Icon(Icons.people),
                              ),
                              const SizedBox(height: 5),
                              TextButton.icon(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                          ClipboardData(text: widget.joinCode))
                                      .then((_) {
                                    SmartDialog.showToast(
                                        'Join Code copied to clipboard!');
                                  });
                                },
                                label: Text(widget.joinCode),
                              ),
                            ],
                          )),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                var player = players[index];
                                var name = player['name'];
                                var userName = player['userName'];
                                var uid = player['uid'];
                                var rank = player['rank'];
                                var profilePictureUrl =
                                    player['profilePictureUrl'];
                                var isHost =
                                    (index == 0); // Host is the first player

                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.2),
                                    ),
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 27,
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              child: ClipOval(
                                                child: FadeInImage.assetNetwork(
                                                  image: profilePictureUrl,
                                                  placeholder:
                                                      'assets/images/placeholder_loading.gif',
                                                  fit: BoxFit.cover,
                                                  width: 50,
                                                  height: 50,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: CircleAvatar(
                                                radius: 12.5,
                                                backgroundColor: Colors.white,
                                                child: Icon(
                                                  isHost
                                                      ? Icons.star
                                                      : Icons.person,
                                                  size:
                                                      25, // Adjust the size as needed
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 10),
                                        SizedBox(
                                          width: width * 0.4,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth: width * 0.4,
                                                ),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: RichText(
                                                    text: TextSpan(
                                                      text: name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge,
                                                      children: [
                                                        TextSpan(
                                                          text:
                                                              (_auth.currentUser!
                                                                          .uid ==
                                                                      uid)
                                                                  ? ' (You)'
                                                                  : '',
                                                          style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                userName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Container(
                                          width: 2,
                                          height: 40,
                                          color: Colors.white,
                                        ),
                                        const Spacer(),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: width * 0.22,
                                              ),
                                              child: SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Text(
                                                  getRankTitle(rank),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .primaryColor),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.1),
                                              child: SvgPicture.asset(
                                                getRankAsset(rank),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: players.length,
                            ),
                          ),
                          if (_isHost)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FilledButton(
                                  onPressed:
                                      // ignore: prefer_is_empty
                                      players.length >= 1 ? _startGame : null,
                                  child: const Text(
                                    'Start Game',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
