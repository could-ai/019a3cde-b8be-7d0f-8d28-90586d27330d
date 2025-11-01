import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int gridSize = 20;
  static const int squareSize = 20;
  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  String direction = 'down';
  bool isPlaying = false;
  int score = 0;
  Timer? timer;

  void startGame() {
    setState(() {
      snake = [const Point(10, 10)];
      direction = 'down';
      score = 0;
      generateFood();
      isPlaying = true;
    });
    timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      moveSnake();
      checkCollision();
    });
  }

  void generateFood() {
    setState(() {
      food = Point(Random().nextInt(gridSize), Random().nextInt(gridSize));
    });
  }

  void moveSnake() {
    setState(() {
      Point<int> head = snake.first;
      Point<int> newHead;
      switch (direction) {
        case 'up':
          newHead = Point(head.x, head.y - 1);
          break;
        case 'down':
          newHead = Point(head.x, head.y + 1);
          break;
        case 'left':
          newHead = Point(head.x - 1, head.y);
          break;
        case 'right':
          newHead = Point(head.x + 1, head.y);
          break;
        default:
          newHead = head;
      }
      snake.insert(0, newHead);
      if (newHead != food) {
        snake.removeLast();
      } else {
        score++;
        generateFood();
      }
    });
  }

  void checkCollision() {
    Point<int> head = snake.first;
    if (head.x < 0 ||
        head.x >= gridSize ||
        head.y < 0 ||
        head.y >= gridSize) {
      gameOver();
    }
    for (var i = 1; i < snake.length; i++) {
      if (head == snake[i]) {
        gameOver();
      }
    }
  }

  void gameOver() {
    timer?.cancel();
    setState(() {
      isPlaying = false;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text('Your score: $score'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onVerticalDragUpdate: (details) {
                if (direction != 'up' && details.delta.dy > 0) {
                  direction = 'down';
                } else if (direction != 'down' && details.delta.dy < 0) {
                  direction = 'up';
                }
              },
              onHorizontalDragUpdate: (details) {
                if (direction != 'left' && details.delta.dx > 0) {
                  direction = 'right';
                } else if (direction != 'right' && details.delta.dx < 0) {
                  direction = 'left';
                }
              },
              child: AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: gridSize,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    var x = index % gridSize;
                    var y = index ~/ gridSize;
                    var point = Point(x, y);
                    if (snake.contains(point)) {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    } else if (food == point) {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }
                  },
                  itemCount: gridSize * gridSize,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Score: $score',
                  style: const TextStyle(fontSize: 24),
                ),
                ElevatedButton(
                  onPressed: isPlaying ? null : startGame,
                  child: Text(isPlaying ? 'Playing' : 'Start Game'),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_upward),
                onPressed: () => setState(() {
                  if (direction != 'down') direction = 'up';
                }),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  if (direction != 'right') direction = 'left';
                }),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => setState(() {
                  if (direction != 'left') direction = 'right';
                }),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_downward),
                onPressed: () => setState(() {
                  if (direction != 'up') direction = 'down';
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
