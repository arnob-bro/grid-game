import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Grid Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Score: ${gameProvider.score} | Highest Possible Score: ${gameProvider.highestPossibleScore}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              gameProvider.timeRemaining > 0
                  ? 'Time Remaining: ${gameProvider.timeRemaining} seconds'
                  : 'Game Over! Restarting...',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: gameProvider.timeRemaining > 0 ? Colors.red : Colors.blue),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gameProvider.grid.length,
              ),
              itemCount: gameProvider.grid.length * gameProvider.grid.length,
              itemBuilder: (context, index) {
                int rowIndex = index ~/ gameProvider.grid.length;
                int columnIndex = index % gameProvider.grid.length;
                final gridItem = gameProvider.grid[rowIndex][columnIndex];

                return GestureDetector(
                  onTap: () => gameProvider.selectItem(rowIndex, columnIndex),
                  child: Container(
                    margin: EdgeInsets.all(2),
                    color: gridItem.isHighlighted
                        ? Colors.red
                        : (gridItem.isSelected ? Colors.blue : Colors.grey),
                    child: Center(
                      child: Text('${gridItem.points}'),
                    ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: gameProvider.isNextLevelEnabled
                    ? gameProvider.nextLevel
                    : null,
                child: Text('Next Level'),
              ),
              ElevatedButton(
                onPressed: gameProvider.resetGame,
                child: Text('Reset'),
              ),
              ElevatedButton(
                onPressed: gameProvider.highlightCorrectBoxes,
                child: Text('Show Correct Path'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
