import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:yamble_yap_to_gamble_ai_game/components/stat_container.dart';
import 'package:yamble_yap_to_gamble_ai_game/pages/leaderboard/leaderboard_page.dart';
import 'package:yamble_yap_to_gamble_ai_game/utils/hex_color.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      return await _firestore.collection('leaderboard').doc(user.uid).get();
    }
    return null;
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

  List<Map<String, String>> getRankDetails() {
    return [
      {
        'title': 'Newcomer',
        'details': 'Registered (1 Arrow)',
        'asset': 'assets/ranks/0_newcomer.svg'
      },
      {
        'title': 'Novice',
        'details': 'Win At Least One Game (2 Arrows)',
        'asset': 'assets/ranks/1_novice.svg'
      },
      {
        'title': 'Apprentice',
        'details': 'Win 5 Total Games (3 Arrows)',
        'asset': 'assets/ranks/2_apprentice.svg'
      },
      {
        'title': 'Adept',
        'details': 'Win 10 Hard/Medium Games & Win 20 Total Games (1 Star)',
        'asset': 'assets/ranks/3_adept.svg'
      },
      {
        'title': 'Expert',
        'details': 'Win 15 Hard Games & Win 30 Total Games (2 Stars)',
        'asset': 'assets/ranks/4_expert.svg'
      },
      {
        'title': 'The Elder',
        'details': 'Win 25 Hard Games & Win 50 Total Games (3 Stars)',
        'asset': 'assets/ranks/5_the-elder.svg'
      },
      {
        'title': 'Developer',
        'details': 'Your Highness, Developer (Diamond 1)',
        'asset': 'assets/ranks/6_developer.svg'
      },
    ];
  }

  void _showRankDialog(BuildContext context, int rank) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Rank Details',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 15),
                CircleAvatar(
                  backgroundColor: HexColor('#E5DEFF'),
                  radius: 50,
                  child: SvgPicture.asset(
                    getRankAsset(rank),
                  ),
                ),
                Text(
                  getRankTitle(rank),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                Text('Your Rank',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  child: Column(
                    children: getRankDetails().asMap().entries.map((entry) {
                      int idx = entry.key;
                      var step = entry.value;
                      return Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: rank >= idx
                                    ? HexColor('#E5DEFF')
                                    : Colors.lightBlue,
                                child: SvgPicture.asset(step['asset']!,
                                    height: 50),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      step['title']!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: rank >= idx
                                            ? Theme.of(context).primaryColor
                                            : Colors.blueGrey,
                                      ),
                                    ),
                                    Text(
                                      step['details']!,
                                      style: TextStyle(
                                        color: rank >= idx
                                            ? Theme.of(context).primaryColor
                                            : Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot?>(
      future: _fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(
              child: Text('No data found.'),
            ),
          );
        }

        final userDoc = snapshot.data!;
        final String name = userDoc['name'];
        final String userName = userDoc['userName'];
        final int rank = userDoc['rank'];
        final int totalGames = userDoc['totalGames'];
        final int totalLost = userDoc['totalLost'];
        final int totalWin = userDoc['totalWin'];
        final int easyWin = userDoc['easyWin'];
        final int mediumWin = userDoc['mediumWin'];
        final int hardWin = userDoc['hardWin'];
        final double winRate = totalGames > 0 ? totalWin / totalGames : 0;

        final List<ChartData> chartData = [
          ChartData('Easy Wins', easyWin.toDouble()),
          ChartData('Medium Wins', mediumWin.toDouble()),
          ChartData('Hard Wins', hardWin.toDouble()),
        ];

        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'Hello, ',
                        style: Theme.of(context).textTheme.titleLarge,
                        children: <TextSpan>[
                          TextSpan(
                            text: name,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    color: Theme.of(context).primaryColor),
                          ),
                          TextSpan(
                            text: '!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32.0),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: HexColor('#E5DEFF'),
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            userName,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => _showRankDialog(context, rank),
                            borderRadius: BorderRadius.circular(32.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: HexColor('#E5DEFF'),
                                  child: SvgPicture.asset(getRankAsset(rank),
                                      height: 50),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  getRankTitle(rank),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.leaderboard),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaderboardPage(),
                          ),
                        );
                      },
                      label: const Text('Leaderboard'),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32.0),
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              StatContainer(
                                title: 'TOTAL GAMES',
                                value: totalGames.toString(),
                                color: Colors.blue,
                              ),
                              StatContainer(
                                title: 'TOTAL WINS',
                                value: totalWin.toString(),
                                color: Colors.green,
                              ),
                              StatContainer(
                                title: 'TOTAL LOST',
                                value: totalLost.toString(),
                                color: Colors.red,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          StatContainer(
                            title: 'WIN RATE',
                            value: winRate.toStringAsFixed(2),
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32.0),
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: SingleChildScrollView(
                      child: SfCircularChart(
                        title: ChartTitle(
                          text: 'Winning Statistics',
                          textStyle: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                        legend: const Legend(isVisible: true),
                        series: <CircularSeries>[
                          PieSeries<ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.category,
                            yValueMapper: (ChartData data, _) => data.value,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ChartData {
  ChartData(this.category, this.value);
  final String category;
  final double value;
}
