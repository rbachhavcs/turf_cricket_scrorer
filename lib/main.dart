import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: CricketFieldScreen()));
}

class CricketFieldScreen extends StatefulWidget {
  @override
  State<CricketFieldScreen> createState() => _CricketFieldScreenState();
}

class _CricketFieldScreenState extends State<CricketFieldScreen> {
  String striker = "Rohit";
  String nonStriker = "Virat";
  String bowler = "Bumrah";

  double strikerTop = 10;
  double nonStrikerBottom = 10;

  final List<String> fielders = List.generate(6, (index) => "F${index + 1}");

  late double moveDistance;
  bool isRun = false;
  double strikerPosition = 10; // top coordinate
  double nonStrikerPosition = 300; // top coordinate (opposite end of pitch)
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double boxSize = min(screenWidth, screenHeight);
    moveDistance = boxSize * 0.68; // distance along pitch
  }

  bool is1Run = false;
  Future<void> runRuns(int runs) async {
    if (runs == 1) {
      if (is1Run == false) {
        // Move to opposite end
        setState(() {
          is1Run = true;
          strikerTop = moveDistance;
          nonStrikerBottom = moveDistance - 50;
        });
        await Future.delayed(const Duration(milliseconds: 600));
      } else {
        // Return to start
        setState(() {
          is1Run = false;
          strikerTop = 50;
          nonStrikerBottom = 50;
        });
        await Future.delayed(const Duration(milliseconds: 600));
      }
    } else {
      for (int i = 1; i < runs; i++) {
        // Move to opposite end
        setState(() {
          strikerTop = moveDistance;
          nonStrikerBottom = moveDistance - 50;
        });
        await Future.delayed(const Duration(milliseconds: 600));

        // Return to start
        setState(() {
          strikerTop = 10;
          nonStrikerBottom = 10;
        });
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }
  }

  bool isOneRun = true;
  bool isTwoRun = true;
  bool isThreeRun = true;

  run1(pitchHeight) {
    isOneRun;
    strikerTop = isOneRun ? pitchHeight : 10;
    nonStrikerBottom = isOneRun ? pitchHeight : 10;

    isOneRun = !isOneRun;
    isOneRun;
    setState(() {});
  }

  Future<void> run(int runs, double pitchHeight) async {
    for (int i = 0; i < runs; i++) {
      // Swap logical positions
      double temp = strikerPosition;
      strikerPosition = nonStrikerPosition;
      nonStrikerPosition = temp;

      setState(() {});
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  Future<void> run2(double pitchHeight) async {
    // Determine the target position based on current toggle
    double target = isTwoRun ? pitchHeight : 10;

    // Move striker and non-striker to target
    strikerTop = target;
    nonStrikerBottom = target;
    setState(() {});

    // Wait for animation/delay
    await Future.delayed(const Duration(seconds: 1));

    // Move back to the original position
    strikerTop = (target == pitchHeight) ? 10 : pitchHeight;
    nonStrikerBottom = (target == pitchHeight) ? 10 : pitchHeight;

    // Toggle run state
    isTwoRun = !isTwoRun;
    setState(() {});
  }

  Future<void> run3(double pitchHeight) async {
    // Determine initial and alternate positions based on isThreeRun
    double startPos = isThreeRun ? 10 : pitchHeight;
    double endPos = isThreeRun ? pitchHeight : 10;

    // Step 1
    strikerTop = endPos;
    nonStrikerBottom = endPos;
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));

    // Step 2
    strikerTop = startPos;
    nonStrikerBottom = startPos;
    setState(() {});
    await Future.delayed(const Duration(seconds: 1));

    // Step 3
    strikerTop = endPos;
    nonStrikerBottom = endPos;
    setState(() {});

    // Toggle for next run
    isThreeRun = !isThreeRun;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double boxSize = min(screenWidth, screenHeight);
    final double pitchWidth = boxSize * 0.20;
    final double pitchHeight = boxSize * 0.75;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          strikerTop = 10;
          strikerTop = pitchHeight;
          nonStrikerBottom = 10;
          nonStrikerBottom = pitchHeight;
          setState(() {});
        },
      ),
      appBar: AppBar(title: const Text("Cricket Field")),
      body: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(color: Colors.green[600], border: Border.all(color: Colors.white, width: 2)),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ..._buildFielders(boxSize / 2, fielders.length),
                    // Pitch
                    Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 30, right: 30, bottom: 30, top: 20),
                          width: pitchWidth,
                          height: pitchHeight,
                          decoration: BoxDecoration(color: Colors.brown[400], borderRadius: BorderRadius.circular(4)),
                        ),
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 20,
                          right: 0,
                          child: TextButton.icon(
                            onPressed: () {
                              run(1, pitchHeight);
                            },
                            icon: Icon(Icons.swap_vert_circle_rounded, color: Colors.white, size: 30),
                            label: Text("Change Strik",style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => Container(width: 2, height: 20, margin: const EdgeInsets.symmetric(horizontal: 2), color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => Container(width: 2, height: 20, margin: const EdgeInsets.symmetric(horizontal: 2), color: Colors.white),
                            ),
                          ),
                        ),
                        // Striker
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 600),
                          top: strikerPosition,
                          right: 10,
                          child: PlayerWithName(name: striker, color: Colors.orange.shade700),
                        ),

                        // Non-striker
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 600),
                          top: nonStrikerPosition,
                          right: 10,
                          child: PlayerWithName(name: nonStriker, color: Colors.orange),
                        ),
                        const Positioned(left: 10, bottom: 10, child: PlayerWithName(name: "Bumrah\n(Bowler)", color: Colors.red)),
                      ],
                    ),

                    // Bowler

                    // Stumps at non-striker end
                    // Positioned(
                    //   top: 46,
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: List.generate(
                    //       3,
                    //       (i) => Container(width: 2, height: 20, margin: const EdgeInsets.symmetric(horizontal: 2), color: Colors.white),
                    //     ),
                    //   ),
                    // ),

                    // Fielders
                    // ..._buildFielders(boxSize / 2, fielders.length),
                  ],
                ),
              ),
            ),
          ),

          // Run button
          ElevatedButton(onPressed: () => run(1, pitchHeight), child: const Text("1 Run")),
          ElevatedButton(onPressed: () => run(2, pitchHeight), child: const Text("2 Runs")),
          ElevatedButton(onPressed: () => run(3, pitchHeight), child: const Text("3 Runs")),
          SizedBox(height: 100),
        ],
      ),
    );
  }

  List<Widget> _buildFielders(double radius, int count) {
    final center = radius;
    List<Widget> widgets = [];
    for (int i = 0; i < count; i++) {
      final angle = (2 * pi / count) * i - pi / 2;
      final x = center + radius * 0.85 * cos(angle);
      final y = center + radius * 0.85 * sin(angle);

      widgets.add(Positioned(left: x - 5, top: y - 5, child: const CircleAvatar(radius: 5, backgroundColor: Colors.red)));
    }
    return widgets;
  }
}

class PlayerWithName extends StatelessWidget {
  final String name;
  final Color color;

  const PlayerWithName({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(radius: 12, backgroundColor: color, child: const Icon(Icons.person, size: 14, color: Colors.white)),
        const SizedBox(height: 4),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
