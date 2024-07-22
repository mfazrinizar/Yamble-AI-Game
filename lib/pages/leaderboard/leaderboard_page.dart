import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/hex_color.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User _currentUser = FirebaseAuth.instance.currentUser!;

  Future<List<DocumentSnapshot>> _fetchLeaderboardData() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('leaderboard')
        .orderBy('totalWin', descending: true)
        .limit(100)
        .get();
    return querySnapshot.docs;
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

  @override
  Widget build(BuildContext context) {
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
          'Leaderboard',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontSize: 24,
              ),
        ),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _fetchLeaderboardData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No data found.'),
            );
          }

          List<DocumentSnapshot> leaderboardData = snapshot.data!;

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
            child: Column(
              children: [
                const SizedBox(
                  height: 15,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: leaderboardData.length,
                      itemBuilder: (context, index) {
                        var userDoc = leaderboardData[index];

                        var name = userDoc['name'];
                        var wins = userDoc['totalWin'];
                        var rank = userDoc['rank'];
                        var uid = userDoc['uid'];

                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.grey.withOpacity(0.5),
                            //     spreadRadius: 2,
                            //     blurRadius: 5,
                            //     offset: const Offset(0, 3),
                            //   ),
                            // ],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  child: Text(
                                    (index + 1).toString(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   name + (_currentUser.uid == uid) ? ' (You)' : '',
                                    //   style: Theme.of(context)
                                    //       .textTheme
                                    //       .titleLarge,
                                    // ),
                                    RichText(
                                      text: TextSpan(
                                        text: name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                        children: [
                                          TextSpan(
                                            text: (_currentUser.uid == uid)
                                                ? ' (You)'
                                                : '',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '$wins Wins',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 2,
                                  height: 40,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: HexColor('#E5DEFF'),
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
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
