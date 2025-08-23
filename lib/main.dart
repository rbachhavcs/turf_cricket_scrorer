import 'package:flutter/material.dart';
import 'dart:math';

import 'CricketScoreScreen.dart';

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
  bool _isFreeHit = false;
  late double moveDistance;
  bool isRun = false;
  double strikerPosition = 10; // top coordinate
  double nonStrikerPosition = 300; // top coordinate (opposite end of pitch)
  // Players
  final List<Map<String, dynamic>> _batsmen = [
    {'name': 'Virat Kohli', 'runs': 0, 'balls': 0, 'out': false, 'striker': true},
    {'name': 'Rohit Sharma', 'runs': 0, 'balls': 0, 'out': false, 'striker': false},
    {'name': 'Suryakumar', 'runs': 0, 'balls': 0, 'out': false, 'striker': false},
  ];
  final List<Map<String, dynamic>> _bowlers = [
    {'name': 'Jasprit Bumrah', 'overs': 0.0, 'maidens': 0, 'runs': 0, 'wickets': 0, 'extras': 0},
    {'name': 'Mohammed Shami', 'overs': 0.0, 'maidens': 0, 'runs': 0, 'wickets': 0, 'extras': 0},
  ];

  bool isMoving = false;
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

  Future<void> run(int runs, double pitchHeight) async {
    if (isMoving == true) return;
    isMoving = true;
    for (int i = 0; i < runs; i++) {
      // Swap logical positions
      double temp = strikerPosition;
      strikerPosition = nonStrikerPosition;
      nonStrikerPosition = temp;

      setState(() {});
      // await Future.delayed(const Duration(seconds: 1));
      await Future.delayed(const Duration(milliseconds: 1500));
    }
  }
  // run1(pitchHeight) {
  //   isOneRun;
  //   strikerTop = isOneRun ? pitchHeight : 10;
  //   nonStrikerBottom = isOneRun ? pitchHeight : 10;
  //
  //   isOneRun = !isOneRun;
  //   isOneRun;
  //   setState(() {});
  // }
  // Future<void> run2(double pitchHeight) async {
  //   // Determine the target position based on current toggle
  //   double target = isTwoRun ? pitchHeight : 10;
  //
  //   // Move striker and non-striker to target
  //   strikerTop = target;
  //   nonStrikerBottom = target;
  //   setState(() {});
  //
  //   // Wait for animation/delay
  //   await Future.delayed(const Duration(seconds: 1));
  //
  //   // Move back to the original position
  //   strikerTop = (target == pitchHeight) ? 10 : pitchHeight;
  //   nonStrikerBottom = (target == pitchHeight) ? 10 : pitchHeight;
  //
  //   // Toggle run state
  //   isTwoRun = !isTwoRun;
  //   setState(() {});
  // }
  //
  // Future<void> run3(double pitchHeight) async {
  //   // Determine initial and alternate positions based on isThreeRun
  //   double startPos = isThreeRun ? 10 : pitchHeight;
  //   double endPos = isThreeRun ? pitchHeight : 10;
  //
  //   // Step 1
  //   strikerTop = endPos;
  //   nonStrikerBottom = endPos;
  //   setState(() {});
  //   await Future.delayed(const Duration(seconds: 1));
  //
  //   // Step 2
  //   strikerTop = startPos;
  //   nonStrikerBottom = startPos;
  //   setState(() {});
  //   await Future.delayed(const Duration(seconds: 1));
  //
  //   // Step 3
  //   strikerTop = endPos;
  //   nonStrikerBottom = endPos;
  //   setState(() {});
  //
  //   // Toggle for next run
  //   isThreeRun = !isThreeRun;
  // }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double boxSize = min(screenWidth, screenHeight);
    final double pitchWidth = boxSize * 0.22;
    final double pitchHeight = boxSize * 0.75;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    int _balls = 0;
    var _undo;
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // strikerTop = 10;
      //     // strikerTop = pitchHeight;
      //     // nonStrikerBottom = 10;
      //     // nonStrikerBottom = pitchHeight;
      //     // setState(() {});
      //     Navigator.push(context, MaterialPageRoute(builder: (context) => CricketScoreScreen()));
      //   },
      // ),
      drawer: Drawer(),
      appBar: AppBar(title:  const Text("Cricket Score Tracker"),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: boxSize,
                      height: boxSize,
                      decoration: BoxDecoration(color: Colors.green[600], border: Border.all(color: Colors.white, width: 2)),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // ..._buildFielders(boxSize / 2, fielders.length),
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
                                  label: Text("Change Strik", style: TextStyle(color: Colors.white)),
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
                                // duration: const Duration(milliseconds: 600),
                                duration: const Duration(milliseconds: 1500),
                                top: strikerPosition,
                                right: 10,
                                child: PlayerWithName(name: striker, color: Colors.orange.shade700),
                                onEnd: () {
                                  print("Striker animation finished!");
                                  isMoving = false;
                                  // You can also call a function here
                                },
                              ),

                              // Non-striker
                              AnimatedPositioned(
                                // duration: const Duration(milliseconds: 600),
                                duration: const Duration(milliseconds: 1500),
                                top: nonStrikerPosition,
                                right: 10,
                                child: PlayerWithName(name: nonStriker, color: Colors.orange),
                                onEnd: () {
                                  print("Non-striker animation finished!");
                                  isMoving = false;
                                },
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
                  SizedBox(
                    height: boxSize,
                    width: MediaQuery.of(context).size.width / 1.8,
                    child: Column(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 6,
                              color: Colors.blue.shade400,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(text: "334-9 ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.white)),
                                          TextSpan(text: "(91.1)", style: TextStyle(fontSize: 20, color: Colors.white70)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Chip(
                                      backgroundColor: Colors.red.shade50,
                                      label: Text("Extras: 10", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            alignment: Alignment.center,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  alignment: Alignment.center,
                                  height: 30,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(colors: [Colors.deepOrange, Colors.orangeAccent]),
                                  ),
                                  child: const Text(
                                    "Balls",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.2),
                                  ),
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: List.generate(
                                    6,
                                    (index) => CircleAvatar(
                                      radius: 18,
                                      backgroundColor: index < 3 ? Colors.orangeAccent : Colors.orangeAccent.withOpacity(0.25),
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(color: index < 3 ? Colors.white : Colors.black54, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            alignment: Alignment.center,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Header
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  alignment: Alignment.center,
                                  height: 30,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
                                  ),
                                  child: const Text(
                                    "Batsman",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.1),
                                  ),
                                ),

                                // Batsman list
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(Icons.sports_cricket, size: 16, color: Colors.green),
                                              SizedBox(width: 6),
                                              Text("Rohit", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                            ],
                                          ),
                                          const Text("45 (33)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(Icons.sports_cricket, size: 16, color: Colors.grey),
                                              SizedBox(width: 6),
                                              Text("Virat", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                                            ],
                                          ),
                                          const Text("20 (21)", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Run Buttons
            const SizedBox(height: 10),
            Wrap(
              spacing: 18,
              runSpacing: 4,
              alignment: WrapAlignment.start,
              children: [
                _buildRunButton(pitchHeight, 1, Colors.green),
                _buildRunButton(pitchHeight, 2, Colors.green.shade700),
                _buildRunButton(pitchHeight, 3, Colors.teal),
                _buildRunButton(pitchHeight, 4, Colors.blue, label: "Four"), // boundary
                _buildRunButton(pitchHeight, 6, Colors.deepPurple, label: "Six"), // sixer
                _buildRunButton(pitchHeight, 0, Colors.grey.shade600, label: " Dot Ball "), // dot ball
                _buildRunButton(
                  pitchHeight,
                  -1,
                  Colors.red.shade700,
                  label: "W", // wicket
                  onPressed: () {},
                ),
                _buildRunButton(pitchHeight, -2, Colors.orange, label: "EX", onPressed: () => _showExtrasMenu(context, pitchHeight)),
                _buildRunButton(pitchHeight, -3, Colors.purple, label: "D", onPressed: () => _showDeclaredRunsMenu(context, pitchHeight)),
              ],
            ),

            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6, offset: const Offset(0, 3))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Undo Button
                  IconButton(
                    onPressed: _balls > 0 ? _undo : null,
                    icon: const Icon(Icons.undo, size: 22),
                    color: colorScheme.primary,
                    tooltip: "Undo",
                  ),

                  const SizedBox(width: 8),

                  // - Button
                  Padding(
                    padding: const EdgeInsets.only(right: 18.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.secondary.withOpacity(0.1),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () => setState(() => _balls > 0 ? _balls-- : _balls),
                            color: colorScheme.secondary,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Balls Count
                        Text(
                          "Balls: $_balls",
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
                        ),

                        const SizedBox(width: 12),

                        // + Button
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colorScheme.secondary.withOpacity(0.1),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => setState(() => _balls++),
                            color: colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 36,
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2).copyWith(right: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Batting", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.1)),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white),
                            child: Text(
                              "${_batsmen.where((b) => !b['out']).length} wickets left",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Batsman List
                  Column(
                    children:
                        _batsmen
                            .map(
                              (batsman) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,
                                          child: Text(
                                            batsman['name'].toString().split(' ').map((e) => e[0]).join(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          batsman['name'],
                                          style: TextStyle(
                                            fontWeight: batsman['striker'] ? FontWeight.bold : FontWeight.w500,
                                            color: batsman['striker'] ? Colors.blue : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('${batsman['runs']} (${batsman['balls']})', style: const TextStyle(fontWeight: FontWeight.w600)),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                          decoration: BoxDecoration(
                                            color: batsman['out'] ? Colors.red.shade100 : Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            batsman['out'] ? 'Out' : 'Not Out',
                                            style: TextStyle(
                                              color: batsman['out'] ? Colors.red : Colors.green,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bowler Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    height: 36,
                    width: double.infinity,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(colors: [Colors.green, Colors.lightGreenAccent]),
                    ),
                    child: const Text(
                      "Bowling",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 1.1),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bowler List
                  Column(
                    children:
                        _bowlers
                            .map(
                              (bowler) => Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.green.shade100,
                                          child: Text(
                                            bowler['name'].toString().split(' ').map((e) => e[0]).join(),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(bowler['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${bowler['runs']} runs • ${bowler['wickets']} wkts',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text('Overs: ${bowler['overs']} • Maidens: ${bowler['maidens']}', style: const TextStyle(fontSize: 12)),
                                        if (bowler['extras'] > 0)
                                          Text(
                                            'Extras: ${bowler['extras']}',
                                            style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDeclaredRunsMenu(BuildContext context, pitchHeight) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add Declared Runs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildRunButton(pitchHeight, 1, Colors.purple, onPressed: () => _addDeclaredRuns(1), label: "D+1"),
                    _buildRunButton(pitchHeight, 2, Colors.purple, onPressed: () => _addDeclaredRuns(2), label: "D+2"),
                    _buildRunButton(pitchHeight, 3, Colors.purple, onPressed: () => _addDeclaredRuns(3), label: "D+3"),
                    _buildRunButton(pitchHeight, 4, Colors.purple, onPressed: () => _addDeclaredRuns(4), label: "D+4"),
                    _buildRunButton(pitchHeight, 5, Colors.purple, onPressed: () => _addDeclaredRuns(5), label: "D+5"),
                    _buildRunButton(pitchHeight, 6, Colors.purple, onPressed: () => _addDeclaredRuns(6), label: "D+6"),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
              ],
            ),
          ),
    );
  }

  void _addDeclaredRuns(int runs) {
    // _addRuns(runs, event: 'Declared +$runs');
  }
  List<Widget> _buildFielders(double radius, int count) {
    final center = radius;
    List<Widget> widgets = [];
    for (int i = 0; i < count; i++) {
      final angle = (2 * pi / count) * i - pi / 2;
      final x = center + radius * 0.85 * cos(angle);
      final y = center + radius * 0.85 * sin(angle);

      widgets.add(Positioned(left: x - 5, top: y - 5, child: const CircleAvatar(radius: 6, backgroundColor: Colors.red)));
    }
    return widgets;
  }

  Widget _buildRunButton(double pitchHeight, int runs, Color color, {VoidCallback? onPressed, String? label}) {
    return ElevatedButton(
      onPressed: onPressed ?? () => run(runs, pitchHeight),
      style: ElevatedButton.styleFrom(
        // shape: const CircleBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shadowColor: Colors.black45,
        elevation: 8,
      ).copyWith(
        overlayColor: WidgetStateProperty.all(Colors.white24), // ripple effect
      ),
      child: Text(
        label ?? "$runs",
        style: TextStyle(
          fontSize: (label != null && label.length > 2) ? 18 : 22,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.3,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(1, 1))],
        ),
      ),
    );
  }

  void _showExtrasMenu(BuildContext context, pitchHeight) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Add Extras", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildRunButton(pitchHeight, 1, Colors.orange, onPressed: () => _addNoBall(0), label: "NB"),
                    _buildRunButton(pitchHeight, 1, Colors.orange, onPressed: () => _addWideBall(0), label: "WD"),
                    _buildRunButton(pitchHeight, 1, Colors.orange, onPressed: () => _addNoBall(1), label: "NB+1"),
                    _buildRunButton(pitchHeight, 2, Colors.orange, onPressed: () => _addNoBall(2), label: "NB+2"),
                    _buildRunButton(pitchHeight, 3, Colors.orange, onPressed: () => _addNoBall(3), label: "NB+3"),
                    _buildRunButton(pitchHeight, 1, Colors.orange, onPressed: () => _addWideBall(1), label: "WD+1"),
                    _buildRunButton(pitchHeight, 2, Colors.orange, onPressed: () => _addWideBall(2), label: "WD+2"),
                    _buildRunButton(pitchHeight, 3, Colors.orange, onPressed: () => _addWideBall(3), label: "WD+3"),
                    if (_isFreeHit) _buildRunButton(pitchHeight, 1, Colors.green, onPressed: () => _addFreeHit(1), label: "FH+1"),
                    if (_isFreeHit) _buildRunButton(pitchHeight, 2, Colors.green, onPressed: () => _addFreeHit(2), label: "FH+2"),
                    if (_isFreeHit) _buildRunButton(pitchHeight, 3, Colors.green, onPressed: () => _addFreeHit(3), label: "FH+3"),
                    if (_isFreeHit) _buildRunButton(pitchHeight, 4, Colors.green, onPressed: () => _addFreeHit(4), label: "FH+4"),
                    if (_isFreeHit) _buildRunButton(pitchHeight, 6, Colors.green, onPressed: () => _addFreeHit(6), label: "FH+6"),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
              ],
            ),
          ),
    );
  }

  void _addFreeHit(int runs) {
    if (_isFreeHit) {
      // _addRuns(runs, event: 'Free Hit +$runs');
    }
  }

  void _addNoBall(int runs) {
    // _addRuns(runs + 1, isExtra: true, event: 'No Ball +$runs');
    // setState(() {
    //   _isFreeHit = true;
    // });
  }
  void _addWideBall(int runs) {
    // _addRuns(runs + 1, isExtra: true, event: 'Wide +$runs');
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
