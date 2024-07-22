import 'user_type.dart';

class Stats {
  UserYamble user;
  int rank;
  int totalWin;
  int hardWin;
  int mediumWin;
  int easyWin;
  int totalLost;
  int totalGames;

  Stats({
    required this.user,
    required this.rank,
    required this.totalWin,
    required this.hardWin,
    required this.mediumWin,
    required this.easyWin,
    required this.totalLost,
    required this.totalGames,
  });
}
