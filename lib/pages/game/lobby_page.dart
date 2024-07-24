import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LobbyPage extends StatefulWidget {
  final String joinCode;

  const LobbyPage({super.key, required this.joinCode});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List players = [];

  bool _isHost = false;

  @override
  void initState() {
    super.initState();
    _checkHostStatus();
  }

  Future<void> _checkHostStatus() async {
    User? currentUser = _auth.currentUser;

    if (currentUser != null) {
      DocumentSnapshot gameSnapshot =
          await _firestore.collection('games').doc(widget.joinCode).get();

      if (gameSnapshot.exists) {
        Map<String, dynamic> gameData =
            gameSnapshot.data() as Map<String, dynamic>;
        players = gameData['players'];

        setState(() {
          _isHost = players.first['uid'] == currentUser.uid;
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
    if (_isHost) {
      await _firestore.collection('games').doc(widget.joinCode).update({
        'gameActive': true,
      });
      // Navigate to the game screen or other actions to start the game
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
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
                'assets/images/waiting.svg',
              ),
            ),
          ),
          StreamBuilder<DocumentSnapshot>(
            stream:
                _firestore.collection('games').doc(widget.joinCode).snapshots(),
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
              List players = gameData['players'];

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
                        const SliverToBoxAdapter(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: CircleAvatar(
                                  child: Icon(Icons.people),
                                ),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                            ],
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              var player = players[index];
                              var name = player['name'];
                              var uid = player['uid'];
                              var rank = player['rank'];
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
                                      CircleAvatar(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        child: Icon(
                                          isHost ? Icons.star : Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ConstrainedBox(
                                            constraints: BoxConstraints(
                                              maxWidth: width * 0.4,
                                            ),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: RichText(
                                                text: TextSpan(
                                                  text: name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge,
                                                  children: [
                                                    TextSpan(
                                                      text: (_auth.currentUser!
                                                                  .uid ==
                                                              uid)
                                                          ? ' (You)'
                                                          : '',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
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
                                            getRankTitle(rank),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ),
                                        ],
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
                                          CircleAvatar(
                                            backgroundColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.1),
                                            child: SvgPicture.asset(
                                              getRankAsset(rank),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            getRankTitle(rank),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                    color: Theme.of(context)
                                                        .primaryColor),
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
                      ],
                    ),
                  );
                },
              );
            },
          ),
          if (_isHost)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: players.length >= 2 ? _startGame : null,
                  child: const Text('Start Game'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
