import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TrashSortingGame extends StatefulWidget {
  @override
  _TrashSortingGameState createState() => _TrashSortingGameState();
}

class _TrashSortingGameState extends State<TrashSortingGame> {
  final Random random = Random();
  List<String> trashItems = ['paper', 'plastic', 'metal']; // Karışık çöpler
  String currentTrash = 'paper'; // Düşen çöp
  int score = 0; // Oyuncunun puanı
  bool gameOver = false; // Oyun bitti mi?
  Timer? gameTimer; // 30 saniyelik oyun süresi

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    gameOver = false;
    score = 0;
    currentTrash = 'paper'; // İlk çöp kağıt
    startTimer();
    dropTrash();
  }

  void startTimer() {
    gameTimer = Timer(Duration(seconds: 30), () {
      setState(() {
        gameOver = true;
      });
    });
  }

  // Çöplerin düşmesini sağlayan fonksiyon
  void dropTrash() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (gameOver) {
        timer.cancel(); // Oyun bittiğinde çöpler düşmeye devam etmesin
      } else {
        setState(() {
          currentTrash = trashItems[random.nextInt(trashItems.length)]; // Rastgele çöp üret
        });
      }
    });
  }

  // Oyuncu çöpleri topladığında kontrol edilir
  void collectTrash(String collectedTrash) {
    if (gameOver) return;

    if (collectedTrash == 'paper') {
      setState(() {
        score += 10; // Kağıt toplandığında puan kazan
      });
    } else {
      setState(() {
        gameOver = true; // Yanlış çöp toplandı, oyun bitti
      });
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel(); // Zamanlayıcıyı iptal et
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Paper Sorting Game'),
      ),
      body: Center(
        child: gameOver
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Game Over!', style: TextStyle(fontSize: 32, color: Colors.red)),
            Text('Score: $score', style: TextStyle(fontSize: 24)),
            ElevatedButton(
              onPressed: startGame,
              child: Text('Restart Game'),
            )
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Collect only paper!',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              'Current Trash: $currentTrash',
              style: TextStyle(fontSize: 30, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => collectTrash(currentTrash),
              child: Text('Collect $currentTrash'),
            ),
            const SizedBox(height: 20),
            Text('Score: $score', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text('Time Left: 30 seconds', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
