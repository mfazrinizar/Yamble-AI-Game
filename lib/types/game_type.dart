import 'package:cloud_firestore/cloud_firestore.dart';

class GameType {
  final String joinCode;
  final bool gameActive;
  final String difficulty;
  final Timestamp createdAt;
  final List<Player> players;
  final List<Round> rounds;

  GameType({
    required this.joinCode,
    required this.gameActive,
    required this.difficulty,
    required this.createdAt,
    required this.players,
    required this.rounds,
  });

  factory GameType.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<Player> players = (data['players'] as List)
        .map((playerData) => Player.fromMap(playerData))
        .toList();

    List<Round> rounds = (data['rounds'] as List)
        .map((roundData) => Round.fromMap(roundData))
        .toList();

    return GameType(
      joinCode: data['joinCode'],
      gameActive: data['gameActive'],
      difficulty: data['difficulty'],
      createdAt: data['createdAt'],
      players: players,
      rounds: rounds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'joinCode': joinCode,
      'gameActive': gameActive,
      'difficulty': difficulty,
      'createdAt': createdAt,
      'players': players.map((player) => player.toMap()).toList(),
      'rounds': rounds.map((round) => round.toMap()).toList(),
    };
  }
}

class Player {
  final String uid;
  final String name;
  final String userName;
  final String? profilePictureUrl;
  final int rank;

  Player({
    required this.uid,
    required this.name,
    required this.userName,
    this.profilePictureUrl,
    required this.rank,
  });

  factory Player.fromMap(Map<String, dynamic> data) {
    return Player(
      uid: data['uid'],
      name: data['name'],
      userName: data['userName'],
      profilePictureUrl: data['profilePictureUrl'],
      rank: data['rank'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'userName': userName,
      'profilePictureUrl': profilePictureUrl,
      'rank': rank,
    };
  }
}

class Round {
  final String scenario;
  final List<Solution> solutions;
  final Timestamp startedAt;
  final Timestamp? endedAt;

  Round({
    required this.scenario,
    required this.solutions,
    required this.startedAt,
    this.endedAt,
  });

  factory Round.fromMap(Map<String, dynamic> data) {
    List<Solution> solutions = (data['solutions'] as List)
        .map((solutionData) => Solution.fromMap(solutionData))
        .toList();

    return Round(
      scenario: data['scenario'],
      solutions: solutions,
      startedAt: data['startedAt'],
      endedAt: data['endedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scenario': scenario,
      'solutions': solutions.map((solution) => solution.toMap()).toList(),
      'startedAt': startedAt,
      'endedAt': endedAt,
    };
  }
}

class Solution {
  final String uid;
  final String solution;
  final String evaluation;
  final bool isSuccess;
  final Timestamp submittedAt;

  Solution({
    required this.uid,
    required this.solution,
    required this.evaluation,
    required this.isSuccess,
    required this.submittedAt,
  });

  factory Solution.fromMap(Map<String, dynamic> data) {
    return Solution(
      uid: data['uid'],
      solution: data['solution'],
      evaluation: data['evaluation'],
      isSuccess: data['isSuccess'],
      submittedAt: data['submittedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'solution': solution,
      'evaluation': evaluation,
      'isSuccess': isSuccess,
      'submittedAt': submittedAt,
    };
  }
}
