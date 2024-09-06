import 'dart:async';  // Import this for Timer
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/grid_item.dart';

class GameProvider with ChangeNotifier {
  List<List<GridItem>> grid = [];
  int score = 0;
  int penalty = 0;
  int previousColumnIndex = -1;
  int currentLevel = 1;
  final int maxLevel = 3;
  int highestPossibleScore = 0;
  bool isNextLevelEnabled = false;
  int timeRemaining = 60;  // Set the initial time in seconds
  Timer? _timer;

  final Random _random = Random();

  GameProvider() {
    _initializeGrid();
    _startTimer();  // Start the timer when the game initializes
  }

  void _initializeGrid() {
    int gridSize = _getGridSizeForLevel(currentLevel);
    grid = List.generate(gridSize, (row) {
      return List.generate(gridSize, (col) => GridItem(points: _randomPointValue()));
    });
    calculateMaxScore();
    notifyListeners();
  }

  int _getGridSizeForLevel(int level) {
    return 5 + (level - 1);
  }

  int _randomPointValue() {
    return _random.nextInt(9) + 1;
  }

  void selectItem(int rowIndex, int columnIndex) {
    if (grid[rowIndex][columnIndex].isSelected) return;

    for (int i = 0; i < grid[rowIndex].length; i++) {
      if (grid[rowIndex][i].isSelected) {
        score -= grid[rowIndex][i].points;
        grid[rowIndex][i].isSelected = false;
      }
    }

    if (previousColumnIndex != -1) {
      penalty += (columnIndex - previousColumnIndex).abs() * 5 * currentLevel;
    }

    grid[rowIndex][columnIndex].isSelected = true;
    score += grid[rowIndex][columnIndex].points;

    // Apply penalty
    score -= penalty;
    penalty = 0; // Reset penalty after applying

    previousColumnIndex = columnIndex;

    checkIfNextLevelEnabled();
    notifyListeners();
  }

  void calculateMaxScore() {
    int rows = grid.length;
    int cols = grid[0].length;

    List<List<int>> dp = List.generate(rows, (i) => List.filled(cols, 0));
    List<List<int>> track = List.generate(rows, (i) => List.filled(cols, -1));

    for (int j = 0; j < cols; j++) {
      dp[0][j] = grid[0][j].points;
    }

    for (int i = 1; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        int maxPrevious = dp[i - 1][j];
        track[i][j] = j;

        if (j > 0 && dp[i - 1][j - 1] - (5 * currentLevel) > maxPrevious) {
          maxPrevious = dp[i - 1][j - 1] - (5 * currentLevel);
          track[i][j] = j - 1;
        }
        if (j < cols - 1 && dp[i - 1][j + 1] - (5 * currentLevel) > maxPrevious) {
          maxPrevious = dp[i - 1][j + 1] - (5 * currentLevel);
          track[i][j] = j + 1;
        }

        dp[i][j] = grid[i][j].points + maxPrevious;
      }
    }

    highestPossibleScore = dp[rows - 1].reduce(max);

    checkIfNextLevelEnabled();
    notifyListeners();
  }

  void highlightCorrectBoxes() {
    int rows = grid.length;
    int cols = grid[0].length;

    List<List<int>> dp = List.generate(rows, (i) => List.filled(cols, 0));
    List<List<int>> track = List.generate(rows, (i) => List.filled(cols, -1));

    for (int j = 0; j < cols; j++) {
      dp[0][j] = grid[0][j].points;
    }

    for (int i = 1; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        int maxPrevious = dp[i - 1][j];
        track[i][j] = j;

        if (j > 0 && dp[i - 1][j - 1] - (5 * currentLevel) > maxPrevious) {
          maxPrevious = dp[i - 1][j - 1] - (5 * currentLevel);
          track[i][j] = j - 1;
        }
        if (j < cols - 1 && dp[i - 1][j + 1] - (5 * currentLevel) > maxPrevious) {
          maxPrevious = dp[i - 1][j + 1] - (5 * currentLevel);
          track[i][j] = j + 1;
        }

        dp[i][j] = grid[i][j].points + maxPrevious;
      }
    }

    int maxColumnIndex = dp[rows - 1].indexWhere((element) => element == highestPossibleScore);

    for (var row in grid) {
      for (var item in row) {
        item.isHighlighted = false;
      }
    }

    int currentColumn = maxColumnIndex;
    for (int i = rows - 1; i >= 0; i--) {
      grid[i][currentColumn].isHighlighted = true;
      currentColumn = track[i][currentColumn];
    }

    notifyListeners();
  }

  void resetGame() {
    score = 0;
    penalty = 0;
    previousColumnIndex = -1;
    currentLevel = 1;  // Reset to level 1 when restarting
    isNextLevelEnabled = false;
    _initializeGrid();
    _startTimer();  // Reset the timer
  }

  void nextLevel() {
    if (currentLevel < maxLevel && isNextLevelEnabled) {
      currentLevel++;
      resetLevel();
    }
  }

  void resetLevel() {
    score = 0;
    penalty = 0;
    previousColumnIndex = -1;
    isNextLevelEnabled = false;
    _initializeGrid();
    _startTimer();  // Reset the timer
  }

  void checkIfNextLevelEnabled() {
    if (score >= highestPossibleScore) {
      isNextLevelEnabled = true;
    }
  }

  void _startTimer() {
    _timer?.cancel();  // Cancel any previous timer
    timeRemaining = 60;  // Set the timer to 60 seconds
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        timeRemaining--;
        notifyListeners();
      } else {
        timer.cancel();
        _showGameOverMessage();  // Show game over message and reset after delay
      }
    });
  }

  void _showGameOverMessage() {
    timeRemaining = 0;  // Ensure timeRemaining is zero
    notifyListeners();

    Future.delayed(Duration(seconds: 2), () {
      resetGame();  // Reset the game after a short delay
    });
  }

  @override
  void dispose() {
    _timer?.cancel();  // Clean up the timer when the provider is disposed
    super.dispose();
  }
}
