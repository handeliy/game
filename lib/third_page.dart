import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class TrashSortingGame extends StatefulWidget {
  @override
  _TrashSortingGameState createState() => _TrashSortingGameState();
}

class _TrashSortingGameState extends State<TrashSortingGame> {
  final Random random = Random();
  final List<String> trashItems = ['paper', 'plastic', 'food'];
  final List<String> trashAssets = [
    'assets/paper.jpg',
    'assets/plastic.jpg',
    'assets/food.jpg'
  ];
  String currentTrash = '';
  int score = 0;
  bool gameOver = false;
  Timer? gameTimer;
  double trashPositionY = 0.0;
  double paperBinX = 0.0;
  double plasticBinX = 0.0;
  double foodBinX = 0.0;
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  Timer? trashTimer;
  int timeLeft = 30;
  double trashDropSpeed = 8.0; // Initial speed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      screenWidth = MediaQuery.of(context).size.width;
      screenHeight = MediaQuery.of(context).size.height;
      paperBinX = screenWidth * 0.1; // Place bins initially
      plasticBinX = screenWidth * 0.4;
      foodBinX = screenWidth * 0.7;
      _generateNewTrash();
      showTrashAlert();
    });
  }

  void startGame() {
    if (!mounted) return;
    setState(() {
      gameOver = false;
      score = 0;
      timeLeft = 30;
      trashDropSpeed = 8.0;
    });
    dropTrash();
    startTimer();
    increaseDifficulty();
  }

  void startTimer() {
    if (!mounted) return;
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          gameOver = true;
          timer.cancel();
          _showGameOverDialog();
        }
      });
    });
  }

  void increaseDifficulty() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (gameOver || !mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        trashDropSpeed += 2.0; // Increase speed every 5 seconds
      });
    });
  }

  void dropTrash() {
    trashPositionY = 0.0;

    trashTimer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      if (gameOver || !mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        trashPositionY += trashDropSpeed;
        if (_checkTrashCollision()) {
          collectTrash(currentTrash);
          _generateNewTrash();
          trashPositionY = 0.0;
        }
        if (trashPositionY > screenHeight) {
          _generateNewTrash();
          trashPositionY = 0.0;
        }
      });
    });
  }

  void _generateNewTrash() {
    if (!mounted) return;
    setState(() {
      currentTrash = trashItems[random.nextInt(trashItems.length)];
    });
  }

  bool _checkTrashCollision() {
    // Check if the correct bin is hit
    if (currentTrash == 'paper') {
      return trashPositionY + 100 >= screenHeight - 150 &&
          paperBinX < screenWidth * 0.5 + 50 &&
          paperBinX + 100 > screenWidth * 0.5 - 50;
    } else if (currentTrash == 'plastic') {
      return trashPositionY + 100 >= screenHeight - 150 &&
          plasticBinX < screenWidth * 0.5 + 50 &&
          plasticBinX + 100 > screenWidth * 0.5 - 50;
    } else if (currentTrash == 'food') {
      return trashPositionY + 100 >= screenHeight - 150 &&
          foodBinX < screenWidth * 0.5 + 50 &&
          foodBinX + 100 > screenWidth * 0.5 - 50;
    }
    return false;
  }

  void showTrashAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Dikkat!'),
          content: Text('Toplamanız gereken çöp türü: $currentTrash'),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
          ],
        );
      },
    );
  }

  void collectTrash(String collectedTrash) {
    if (gameOver || !mounted) return;

    if (collectedTrash == 'paper' ||
        collectedTrash == 'plastic' ||
        collectedTrash == 'food') {
      setState(() {
        score += 10; // Increase score for correct items
      });
    } else {
      setState(() {
        gameOver = true;
        _showGameOverDialog();
      });
    }
  }

  void _showGameOverDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oyun Bitti!'),
          content: Text('Toplam Puan: $score'),
          actions: [
            TextButton(
              child: Text('Yeniden Başla'),
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
              },
            ),
            TextButton(
              child: Text('Çıkış'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    trashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trash Sorting Game'),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/game.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Score and Timer Display
          Positioned(
            top: 20,
            left: 20,
            child: Column(
              children: [
                Text('Score: $score',
                    style: TextStyle(fontSize: 24, color: Colors.white)),
                const SizedBox(height: 10),
                Text('Time Left: $timeLeft seconds',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ],
            ),
          ),
          // Falling trash item
          Positioned(
            top: trashPositionY,
            left: MediaQuery.of(context).size.width * 0.5 - 50,
            child: Builder(
              builder: (context) {
                int trashIndex = trashItems.indexOf(currentTrash);
                if (trashIndex == -1) {
                  trashIndex = 0;
                }
                return Image.asset(trashAssets[trashIndex],
                    width: 100, height: 100);
              },
            ),
          ),
          // Paper Bin
          Positioned(
            bottom: 50,
            left: paperBinX,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  paperBinX += details.delta.dx;
                  if (paperBinX < 0) paperBinX = 0;
                  if (paperBinX > screenWidth - 100) {
                    paperBinX = screenWidth - 100;
                  }
                });
              },
              child: Image.asset('assets/paper_bin.png',
                  width: 100, height: 100),
            ),
          ),
          // Plastic Bin
          Positioned(
            bottom: 50,
            left: plasticBinX,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  plasticBinX += details.delta.dx;
                  if (plasticBinX < 0) plasticBinX = 0;
                  if (plasticBinX > screenWidth - 100) {
                    plasticBinX = screenWidth - 100;
                  }
                });
              },
              child: Image.asset('assets/plastic_bin.png',
                  width: 100, height: 100),
            ),
          ),
          // Food Bin
          Positioned(
            bottom: 50,
            left: foodBinX,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  foodBinX += details.delta.dx;
                  if (foodBinX < 0) foodBinX = 0;
                  if (foodBinX > screenWidth - 100) {
                    foodBinX = screenWidth - 100;
                  }
                });
              },
              child: Image.asset('assets/food_bin.png',
                  width: 100, height: 100),
            ),
          ),
          if (gameOver)
            Center(
              child: Text('Oyun Bitti!',
                  style: TextStyle(fontSize: 32, color: Colors.red)),
            ),
        ],
      ),
    );
  }
}
