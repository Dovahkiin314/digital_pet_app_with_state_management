import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(PetGameApp());
}

class PetGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Pet Game',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: PetNameScreen(), // Start at name screen
    );
  }
}

// ---------------------------
// Pet Name Setup Screen
// ---------------------------
class PetNameScreen extends StatefulWidget {
  @override
  _PetNameScreenState createState() => _PetNameScreenState();
}

class _PetNameScreenState extends State<PetNameScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _startGame() {
    String name = _nameController.text.trim();
    if (name.isEmpty) name = "Your Pet";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => PetGameHomePage(petName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Name Your Pet")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter your pet’s name:",
              style: TextStyle(fontSize: 18),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "e.g. Fluffy",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startGame,
              child: Text("Start Game"),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------
// Pet Game Screen
// ---------------------------
class PetGameHomePage extends StatefulWidget {
  final String petName;

  PetGameHomePage({required this.petName});

  @override
  _PetGameHomePageState createState() => _PetGameHomePageState();
}

class _PetGameHomePageState extends State<PetGameHomePage> {
  int happinessLevel = 50;
  int fullnessLevel = 50;
  int energyLevel = 50;
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _gameOver = false;
  bool _gameWon = false;

  @override
  void initState() {
    super.initState();
    _startGameLoop();
  }

  void _startGameLoop() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_gameOver || _gameWon) return;

      setState(() {
        // All three decrease over time
        happinessLevel -= 1;
        fullnessLevel -= 1;
        energyLevel -= 1;

        if (happinessLevel < 0) happinessLevel = 0;
        if (fullnessLevel < 0) fullnessLevel = 0;
        if (energyLevel < 0) energyLevel = 0;

        _elapsedSeconds++;
        _checkGameOver();
        _checkWinCondition();
      });
    });
  }

  void _playWithPet() {
    if (_isGameActive()) {
      setState(() {
        happinessLevel += 10;
        if (happinessLevel > 100) happinessLevel = 100;

        energyLevel -= 5;
        if (energyLevel < 0) energyLevel = 0;

        fullnessLevel -= 2;
        if (fullnessLevel < 0) fullnessLevel = 0;

        _checkWinCondition();
        _checkGameOver();
      });
    }
  }

  void _feedPet() {
    if (_isGameActive()) {
      setState(() {
        fullnessLevel += 10;
        if (fullnessLevel > 100) fullnessLevel = 100;

        energyLevel += 5;
        if (energyLevel > 100) energyLevel = 100;

        // Feeding does not affect happiness anymore
        _checkGameOver();
      });
    }
  }

  bool _isGameActive() {
    return !_gameOver && !_gameWon;
  }

  void _checkGameOver() {
    if (happinessLevel <= 0 || fullnessLevel <= 0 || energyLevel <= 0) {
      _gameOver = true;
      _timer?.cancel();
    }
  }

  void _checkWinCondition() {
    if (_elapsedSeconds >= 180 &&
        happinessLevel > 80 &&
        fullnessLevel > 80 &&
        energyLevel > 80) {
      _gameWon = true;
      _timer?.cancel();
    }
  }

  void _restartGame() {
    setState(() {
      happinessLevel = 50;
      fullnessLevel = 50;
      energyLevel = 50;
      _elapsedSeconds = 0;
      _gameOver = false;
      _gameWon = false;
      _startGameLoop();
    });
  }

  String _getMood() {
    if (happinessLevel > 70) return "😊 Happy";
    if (happinessLevel > 30) return "😐 Neutral";
    return "😢 Unhappy";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.petName}'s Game"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Instructions
            Text(
              "Take care of ${widget.petName}!\n"
              "- Playing increases happiness but reduces energy & fullness.\n"
              "- Feeding increases fullness & energy.\n"
              "- Happiness, fullness, and energy all decrease over time.\n"
              "- If any bar reaches 0 → Game Over.\n"
              "- Keep all bars high for 3 minutes to win!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),

            // Mood Indicator
            Text(
              "Mood: ${_getMood()}",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Status bars
            _buildStatusBar("Happiness", happinessLevel, Colors.pink),
            _buildStatusBar("Fullness", fullnessLevel, Colors.orange),
            _buildStatusBar("Energy", energyLevel, Colors.blue),
            SizedBox(height: 20),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _playWithPet,
                  child: Text("Play"),
                ),
                ElevatedButton(
                  onPressed: _feedPet,
                  child: Text("Feed"),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Timer
            Text(
              "Time Alive: $_elapsedSeconds seconds",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),

            // Game Over / Win Messages
            if (_gameOver)
              Column(
                children: [
                  Text(
                    "Game Over! 😢",
                    style: TextStyle(fontSize: 22, color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: _restartGame,
                    child: Text("Restart"),
                  ),
                ],
              ),
            if (_gameWon)
              Column(
                children: [
                  Text(
                    "You Win! 🎉 ${widget.petName} is happy and healthy!",
                    style: TextStyle(fontSize: 22, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  ElevatedButton(
                    onPressed: _restartGame,
                    child: Text("Play Again"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int value, Color color) {
    return Column(
      children: [
        Text("$label: $value"),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Colors.grey[300],
          color: color,
          minHeight: 10,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
