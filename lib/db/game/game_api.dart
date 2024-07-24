import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:yamble_yap_to_gamble_ai_game/encrypted/env.dart';

class GameApi {
  final env = Env.create();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> generateJoinCode() async {
    const length = 6;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();

    String joinCode;
    bool isDuplicate;

    do {
      joinCode = String.fromCharCodes(Iterable.generate(
          length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

      // Check for duplicate join code
      QuerySnapshot result = await _firestore
          .collection('games')
          .where('joinCode', isEqualTo: joinCode)
          .where('gameActive', isEqualTo: true)
          .get();

      isDuplicate = result.docs.isNotEmpty;
    } while (isDuplicate);

    return joinCode;
  }

  Future<Map<String, dynamic>> createGame(String difficulty) async {
    String joinCode = await generateJoinCode();
    User? currentUser = _auth.currentUser;
    difficulty = difficulty.toLowerCase();

    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint('No user is signed in');
      }
      return {
        'joinCode': '',
        'status': 'NOT-LOGGED-IN',
      };
    }

    // Fetch user details from the leaderboard
    DocumentSnapshot leaderboardSnapshot =
        await _firestore.collection('leaderboard').doc(currentUser.uid).get();
    if (!leaderboardSnapshot.exists) {
      if (kDebugMode) {
        debugPrint('User not found in leaderboard');
      }
      return {
        'joinCode': '',
        'status': 'USER-NOT-FOUND-LEADERBOARD',
      };
    }
    Map<String, dynamic> leaderboardData =
        leaderboardSnapshot.data() as Map<String, dynamic>;

    DocumentReference gameDocRef = await _firestore.collection('games').add({
      'joinCode': joinCode,
      'gameActive': true,
      'difficulty': difficulty,
      'createdAt': FieldValue.serverTimestamp(),
      'players': [
        {
          'uid': currentUser.uid,
          'name': currentUser.displayName,
          'userName': leaderboardData['userName'],
          'profilePictureUrl': currentUser.photoURL,
          'rank': leaderboardData['rank'],
        }
      ],
      'rounds': [],
      'gameId': '',
    });

    // Add the auto-generated document ID as a field in the document
    await gameDocRef.update({'gameId': gameDocRef.id});

    return {
      'joinCode': joinCode,
      'status': 'SUCCESS',
    };
  }

  Future<String> joinGame(String joinCode) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint('No user is signed in');
      }
      return 'NOT-LOGGED-IN';
    }

    QuerySnapshot gameSnapshot = await _firestore
        .collection('games')
        .where('joinCode', isEqualTo: joinCode)
        .where('gameActive', isEqualTo: true)
        .get();

    if (gameSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('Game not found');
      }
      return 'GAME-NOT-FOUND';
    }

    DocumentSnapshot gameDoc = gameSnapshot.docs.first;
    Map<String, dynamic> gameData = gameDoc.data() as Map<String, dynamic>;
    List players = gameData['players'];

    if (players.length >= 3) {
      if (kDebugMode) {
        debugPrint('Game is full');
      }
      return 'GAME-FULL';
    }

    if (players.any((player) => player['uid'] == currentUser.uid)) {
      if (kDebugMode) {
        debugPrint('User already joined the game');
      }
      return 'SUCCESS';
    }

    // Fetch user details from the leaderboard
    DocumentSnapshot leaderboardSnapshot =
        await _firestore.collection('leaderboard').doc(currentUser.uid).get();
    if (!leaderboardSnapshot.exists) {
      if (kDebugMode) {
        debugPrint('User not found in leaderboard');
      }
      return 'USER-NOT-FOUND-LEADERBOARD';
    }
    Map<String, dynamic> leaderboardData =
        leaderboardSnapshot.data() as Map<String, dynamic>;

    players.add({
      'uid': currentUser.uid,
      'name': currentUser.displayName,
      'userName': leaderboardData['userName'],
      'profilePictureUrl': currentUser.photoURL,
      'rank': leaderboardData['rank'],
    });

    await gameDoc.reference.update({'players': players});

    return 'SUCCESS';
  }

  Future<String> generateScenario(String difficulty) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: env.generativeAiApiKey,
    );

    difficulty = difficulty.toLowerCase();

    final prompt =
        'The current game difficulty is $difficulty where there are easy, medium and hard difficulty. The harder the difficulty, the more complex the scenario MUST be. Generate a scenario for the game with maximum 150 characters, BE STRAIGHT FORWARD TO SCENARIO:';
    final response = await model.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        temperature: difficulty == 'easy'
            ? 0.5
            : difficulty == 'medium'
                ? 0.75
                : 1.0,
        maxOutputTokens: 150,
        responseMimeType: 'application/json',
      ),
    );

    return '{"response": "${response.text?.trim()}"}';
  }

  Future<bool> startRound(String joinCode) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint('No user is signed in');
      }
      return false;
    }

    // Check if current user is the host
    QuerySnapshot gameSnapshot = await _firestore
        .collection('games')
        .where('joinCode', isEqualTo: joinCode)
        .where('gameActive', isEqualTo: true)
        .get();

    if (gameSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('Game not found');
      }
      return false;
    }

    DocumentSnapshot gameDoc = gameSnapshot.docs.first;
    Map<String, dynamic> gameData = gameDoc.data() as Map<String, dynamic>;
    List players = gameData['players'];
    if (players.first['uid'] != currentUser.uid) {
      if (kDebugMode) {
        debugPrint('Only the host can start a new round');
      }
      return false;
    }

    // Generate a scenario
    final scenario = await generateScenario(gameData['difficulty']);

    // Start a new round with the scenario
    List rounds = gameData['rounds'];
    rounds.add({
      'scenario': scenario,
      'solutions': [],
      'startedAt': FieldValue.serverTimestamp(),
    });

    await gameDoc.reference.update({
      'rounds': rounds,
    });

    return true;
  }

  Future<Map<String, dynamic>> evaluateSolution(
      String solution, String scenario, String difficulty) async {
    final schema = Schema.object(properties: {
      'response':
          Schema.string(description: 'Evaluation response.', nullable: false),
      'isSuccess': Schema.boolean(
          description: 'Whether the solution is successful.', nullable: false)
    }, requiredProperties: [
      'response',
      'isSuccess'
    ]);

    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: env.generativeAiApiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );

    difficulty = difficulty.toLowerCase();

    final prompt = '''
    You are Yamble AI Game Evaluator developed by M. Fazri Nizar. You are tasked to evaluate the following solution based on the scenario provided:
    
    Scenario: $scenario
    
    Solution: $solution
    
    The difficulty of the current game is $difficulty, you must act accordingly.
    Return a JSON response with the evaluation and whether it is successful. The response MUST be in the format: {"response": string, "isSuccess": boolean}
  ''';

    final response = await model.generateContent(
      [Content.text(prompt)],
      generationConfig: GenerationConfig(
        temperature: difficulty == 'easy'
            ? 0.5
            : difficulty == 'medium'
                ? 0.75
                : 1.0,
        responseMimeType: 'application/json',
      ),
    );

    final responseData = jsonDecode(response.text?.trim() ?? '{}');
    final isSuccess = responseData['isSuccess'] ?? false;

    return {
      'response': responseData['response'],
      'isSuccess': isSuccess,
    };
  }

  Future<bool> submitSolution(String joinCode, String solution) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint('No user is signed in');
      }
      return false;
    }

    QuerySnapshot gameSnapshot = await _firestore
        .collection('games')
        .where('joinCode', isEqualTo: joinCode)
        .where('gameActive', isEqualTo: true)
        .get();

    if (gameSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('Game not found');
      }
      return false;
    }

    DocumentSnapshot gameDoc = gameSnapshot.docs.first;
    Map<String, dynamic> gameData = gameDoc.data() as Map<String, dynamic>;
    List rounds = gameData['rounds'];

    if (rounds.isEmpty) {
      if (kDebugMode) {
        debugPrint('No active round found');
      }
      return false;
    }

    Map<String, dynamic> currentRound = rounds.last;

    if (currentRound['scenario'] == null) {
      if (kDebugMode) {
        debugPrint('No scenario found for the current round');
      }
      return false;
    }

    // Evaluate the solution
    final evaluation = await evaluateSolution(
      solution,
      currentRound['scenario'],
      gameData['difficulty'],
    );

    // Append the solution and its evaluation to the current round
    List solutions = currentRound['solutions'];
    solutions.add({
      'uid': currentUser.uid,
      'solution': solution,
      'evaluation': evaluation['response'],
      'isSuccess': evaluation['isSuccess'],
    });

    currentRound['solutions'] = solutions;

    await gameDoc.reference.update({'rounds': rounds});

    return true;
  }

  Future<bool> endRound(String joinCode) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint('No user is signed in');
      }
      return false;
    }

    // Fetch the game document using the joinCode
    QuerySnapshot gameSnapshot = await _firestore
        .collection('games')
        .where('joinCode', isEqualTo: joinCode)
        .where('gameActive', isEqualTo: true)
        .get();

    if (gameSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('Game not found');
      }
      return false;
    }

    DocumentSnapshot gameDoc = gameSnapshot.docs.first;
    Map<String, dynamic> gameData = gameDoc.data() as Map<String, dynamic>;
    List players = gameData['players'];
    if (players.first['uid'] != currentUser.uid) {
      if (kDebugMode) {
        debugPrint('Only the host can end the round');
      }
      return false;
    }

    // Mark the current round as ended
    List rounds = gameData['rounds'];
    if (rounds.isEmpty) {
      throw Exception('No rounds available');
    }

    Map<String, dynamic> currentRound = rounds.last;
    currentRound['endedAt'] = FieldValue.serverTimestamp();

    await gameDoc.reference.update({
      'rounds': rounds,
    });

    return true;
  }

  Future<bool> endGame(String joinCode) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint('No user is signed in');
      }
      return false;
    }

    // Fetch the game document using the joinCode
    QuerySnapshot gameSnapshot = await _firestore
        .collection('games')
        .where('joinCode', isEqualTo: joinCode)
        .where('gameActive', isEqualTo: true)
        .get();

    if (gameSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('Game not found');
      }
      return false;
    }

    DocumentSnapshot gameDoc = gameSnapshot.docs.first;
    Map<String, dynamic> gameData = gameDoc.data() as Map<String, dynamic>;
    List players = gameData['players'];
    if (players.first['uid'] != currentUser.uid) {
      if (kDebugMode) {
        debugPrint('Only the host can end the game');
      }
      return false;
    }

    List rounds = gameData['rounds'];

    Map<String, int> scores = {};
    for (var player in players) {
      scores[player['uid']] = 0;
    }

    for (var round in rounds) {
      for (var solution in round['solutions']) {
        if (solution['isSuccess']) {
          scores[solution['uid']] = (scores[solution['uid']] ?? 0) + 1;
        }
      }
    }

    // Determine winner
    int maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    List<String> winners = scores.entries
        .where((entry) => entry.value == maxScore)
        .map((entry) => entry.key)
        .toList();

    for (var player in players) {
      String uid = player['uid'];
      bool isWinner = winners.contains(uid);

      await _firestore.collection('leaderboard').doc(uid).update({
        'totalGames': FieldValue.increment(1),
        if (isWinner) 'totalWin': FieldValue.increment(1),
        if (!isWinner && winners.length == 1)
          'totalLost': FieldValue.increment(1),
        if (gameData['difficulty'] == 'easy' && isWinner)
          'easyWin': FieldValue.increment(1),
        if (gameData['difficulty'] == 'medium' && isWinner)
          'mediumWin': FieldValue.increment(1),
        if (gameData['difficulty'] == 'hard' && isWinner)
          'hardWin': FieldValue.increment(1),
      });
    }

    await gameDoc.reference.update({
      'gameActive': false,
    });

    return true;
  }

  Future<bool> cancelGame(String joinCode) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint('No user is signed in');
      }
      return false;
    }

    // Fetch the game document using the joinCode
    QuerySnapshot gameSnapshot = await _firestore
        .collection('games')
        .where('joinCode', isEqualTo: joinCode)
        .where('gameActive', isEqualTo: true)
        .get();

    if (gameSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('Game not found');
      }
      return false;
    }

    DocumentSnapshot gameDoc = gameSnapshot.docs.first;
    Map<String, dynamic> gameData = gameDoc.data() as Map<String, dynamic>;
    List players = gameData['players'];
    if (players.first['uid'] != currentUser.uid) {
      if (kDebugMode) {
        debugPrint('Only the host can cancel the game');
      }
      return false;
    }

    // Set gameActive to false to cancel the game
    await gameDoc.reference.update({
      'gameActive': false,
    });

    if (kDebugMode) {
      debugPrint('Game cancelled successfully');
    }
    return true;
  }

  Future<bool> leaveGame(String joinCode) async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      if (kDebugMode) {
        debugPrint('No user is signed in');
      }
      return false;
    }

    // Fetch the game document using the joinCode
    QuerySnapshot gameSnapshot = await _firestore
        .collection('games')
        .where('joinCode', isEqualTo: joinCode)
        .where('gameActive', isEqualTo: true)
        .get();

    if (gameSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('Game not found');
      }
      return false;
    }

    DocumentSnapshot gameDoc = gameSnapshot.docs.first;
    Map<String, dynamic> gameData = gameDoc.data() as Map<String, dynamic>;
    List players = gameData['players'];

    // Remove the current user from the players list
    players.removeWhere((player) => player['uid'] == currentUser.uid);

    await gameDoc.reference.update({
      'players': players,
    });

    if (kDebugMode) {
      debugPrint('Player left the game successfully');
    }
    return true;
  }

  Future<DocumentSnapshot?> fetchGameByJoinCode(String joinCode) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('games')
        .where('joinCode', isEqualTo: joinCode)
        .where('gameActive', isEqualTo: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first;
    }

    return null;
  }
}
