import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:yamble_yap_to_gamble_ai_game/db/game/game_api.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/home_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/form_validator.dart';

class EvaluationPage extends StatefulWidget {
  final String joinCode;

  const EvaluationPage({super.key, required this.joinCode});

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class _EvaluationPageState extends State<EvaluationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _solutionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List players = [];
  bool _isHost = false;
  bool _currentRoundEnded = false;
  int _currentEvaluation = 0;
  int _amountOfRound = 0;
  String _currentEvaluationText = '';
  bool _currentEvaluationSuccess = false;
  String _titleOfSolutionOwner = 'Your Solution';
  bool _solutionTextFormDisabled = false;
  int _numberOfPlayers = 0;
  bool _allPlayerSolutionSubmitted = false;
  bool _lastRound = false;
  bool _gameActive = true;
  DocumentSnapshot? _gameSnapshot;
  String scenario = '';
  bool _isSubmitting = false;
  late int endTime;

  @override
  void initState() {
    super.initState();
    endTime =
        DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 1; // 1 minutes

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
        if (gameData['rounds'] != null && gameData['rounds'].isNotEmpty) {
          scenario = gameData['rounds'].last['scenario'];
        }

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

  // Future<void> _startGame() async {
  //   if (_isHost && _gameSnapshot != null) {
  //     final gameApi = GameApi();
  //     SmartDialog.showLoading(
  //       msg: 'Starting game...',
  //       maskColor: Theme.of(context).primaryColor.withOpacity(0.5),
  //     );
  //     final gameIsStarted = await gameApi.startRound(widget.joinCode);

  //     SmartDialog.dismiss();

  //     if (gameIsStarted) {
  //       SmartDialog.showNotify(
  //           msg: 'Game Started!', notifyType: NotifyType.success);
  //       _checkHostStatus();
  //     } else {
  //       SmartDialog.showNotify(
  //           msg: 'Failed to start the game.', notifyType: NotifyType.error);
  //     }
  //   }
  // }

  Future<void> _submitSolution() async {
    if (_isSubmitting || _solutionController.text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final gameApi = GameApi();
    SmartDialog.showLoading(
      msg: 'Submitting solution...',
      maskColor: Theme.of(context).primaryColor.withOpacity(0.5),
    );

    final success =
        await gameApi.submitSolution(widget.joinCode, _solutionController.text);

    SmartDialog.dismiss();

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      SmartDialog.showNotify(
          msg: 'Solution Submitted!', notifyType: NotifyType.success);
    } else {
      SmartDialog.showNotify(
          msg: 'Failed to submit the solution.', notifyType: NotifyType.error);
    }
    endTime = 0;
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (Route<dynamic> route) => false,
        );
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (Route<dynamic> route) => false,
        );
        SmartDialog.showNotify(
            msg: 'You have left the game (${widget.joinCode}).',
            notifyType: NotifyType.success);
      }
    } else {
      SmartDialog.showNotify(
          msg: 'Failed to leave the game.', notifyType: NotifyType.error);
    }
  }

  Future<void> _endRound() async {
    if (_isHost) {
      final gameApi = GameApi();
      SmartDialog.showLoading(
        msg: 'Ending round...',
        maskColor: Theme.of(context).primaryColor.withOpacity(0.5),
      );
      final success = await gameApi.endRound(widget.joinCode);
      SmartDialog.dismiss();

      if (success) {
        SmartDialog.showNotify(
            msg: 'Round Ended!', notifyType: NotifyType.success);
        _checkHostStatus();
      } else {
        SmartDialog.showNotify(
            msg: 'Failed to end the round.', notifyType: NotifyType.error);
      }
    }
  }

  Future<void> _finishGame() async {
    if (_isHost) {
      final gameApi = GameApi();
      SmartDialog.showLoading(
        msg: 'Finishing game...',
        maskColor: Theme.of(context).primaryColor.withOpacity(0.5),
      );
      final success = await gameApi.endGame(widget.joinCode);
      SmartDialog.dismiss();

      if (success) {
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
            (Route<dynamic> route) => false,
          );
        }
        SmartDialog.showNotify(
            msg: 'Game Finished!', notifyType: NotifyType.success);
      } else {
        SmartDialog.showNotify(
            msg: 'Failed to finish the game.', notifyType: NotifyType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: PopScope(
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
                title: 'Exit Game',
                desc:
                    'Are you sure you want to exit the game?${_isHost ? '\nYou are host, the game will be cancelled.' : ''}',
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: StreamBuilder<DocumentSnapshot>(
                stream: _gameSnapshot != null
                    ? _gameSnapshot!.reference.snapshots()
                    : const Stream<DocumentSnapshot>.empty(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _gameSnapshot = snapshot.data;
                    final gameData =
                        _gameSnapshot!.data() as Map<String, dynamic>;
                    players = gameData['players'];
                    _numberOfPlayers = players.length;
                    if (gameData['rounds'] != null &&
                        gameData['rounds'].isNotEmpty) {
                      scenario = gameData['rounds'].last['scenario'];
                      _amountOfRound = gameData['rounds'].length;
                      _currentRoundEnded = gameData['rounds'].last['ended'];
                      _allPlayerSolutionSubmitted = _numberOfPlayers ==
                          gameData['rounds'].last['solutions'].length;
                      _solutionTextFormDisabled = _allPlayerSolutionSubmitted;
                    }

                    if (gameData['rounds'] != null &&
                        gameData['rounds'].length == 3) {
                      _lastRound = true;
                    }

                    if (_currentRoundEnded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                        SmartDialog.showNotify(
                            msg: 'The Host ended the game.',
                            notifyType: NotifyType.alert);
                      });
                    }

                    // if (_allPlayerSolutionSubmitted) {
                    //   final solution = gameData['rounds']
                    //       .last['solutions']
                    //       .firstWhere((solution) =>
                    //           solution['uid'] == _auth.currentUser!.uid);
                    //   _solutionController.text = solution['solution'];
                    //   var player = gameData['players'].firstWhere(
                    //       (player) => player['uid'] == solution['uid']);
                    //   _titleOfSolutionOwner = player['name'];
                    // }

                    if (_allPlayerSolutionSubmitted) {
                      for (var solution
                          in gameData['rounds'].last['solutions']) {
                        _solutionController.text = solution['solution'];

                        // Find the player in the 'players' array whose 'uid' matches the current solution's 'uid'
                        var player = gameData['players'].firstWhere(
                            (player) => player['uid'] == solution['uid']);
                        _titleOfSolutionOwner = player['name'];
                        _currentEvaluationText = solution['evaluation'];
                        _currentEvaluationSuccess = solution['isSuccess'];

                        endTime =
                            DateTime.now().millisecondsSinceEpoch + 1000 * 15;

                        // Wait for 15 seconds before showing the next solution
                        Future.delayed(const Duration(seconds: 15));
                        _currentEvaluation++;
                      }
                    }
                    _gameActive = gameData['gameActive'];
                    if (!_gameActive) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                          (Route<dynamic> route) => false,
                        );
                        SmartDialog.showNotify(
                            msg: 'The Host ended the game.',
                            notifyType: NotifyType.alert);
                      });
                    }

                    return Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'Yap to Gamble!',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontFamily: 'PermanentMarker',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.joinCode,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold),
                          ),
                          Container(
                            height: 2.0,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Scenario',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .secondaryHeaderColor
                                  .withOpacity(0.2),
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Text(
                              scenario,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CountdownTimer(
                            endTime: endTime,
                            onEnd: () {
                              if (!_isSubmitting) {
                                _submitSolution();
                              }
                            },
                            widgetBuilder: (_, time) {
                              if (time == null) {
                                return Text(
                                  'Time\'s up!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: Colors.white),
                                );
                              }
                              return Text(
                                time.hours != null
                                    ? '${(time.hours ?? 0).toString().padLeft(2, '0')} : ${(time.min ?? 0).toString().padLeft(2, '0')} : ${(time.sec ?? 0).toString().padLeft(2, '0')}'
                                    : '${(time.min ?? 0).toString().padLeft(2, '0')} : ${(time.sec ?? 0).toString().padLeft(2, '0')}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(color: Colors.white),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _solutionController,
                            validator: FormValidator.validateText,
                            maxLines: 4,
                            maxLength: 150,
                            enabled: !_solutionTextFormDisabled,
                            decoration: InputDecoration(
                              labelText: _titleOfSolutionOwner,
                              labelStyle: const TextStyle(
                                  color: Colors.white, fontSize: 20),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              counterStyle:
                                  const TextStyle(color: Colors.white),
                              hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.7)),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Evaluation',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .secondaryHeaderColor
                                  .withOpacity(0.2),
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Text(
                              "$_currentEvaluationText\nSolution Yapping: ${_currentEvaluationSuccess ? "Success" : "Fail"}",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (_currentEvaluation == players.length &&
                              _currentRoundEnded &&
                              _isHost)
                            Column(
                              children: [
                                const SizedBox(
                                  height: 25,
                                ),
                                ElevatedButton(
                                  onPressed: _endRound,
                                  child: const Text(
                                    'Next Round',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          if (_isHost && _currentRoundEnded && _lastRound)
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: _finishGame,
                                  child: const Text(
                                    'Finish Game',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong.'));
                  } else if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text('Game not found.'));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: Colors.white,
                    ));
                  } else {
                    return const Center(child: Text('Something went wrong.'));
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
