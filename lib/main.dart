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

  final List<String> fielders = List.generate(10, (index) => "F${index + 1}");

  late double moveDistance;
  bool isRun = false;
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
          strikerTop = 110;
          nonStrikerBottom = 110;
        });
        await Future.delayed(const Duration(milliseconds: 600));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double boxSize = min(screenWidth, screenHeight);
    final double pitchWidth = boxSize * 0.20;
    final double pitchHeight = boxSize * 0.68;

    return Scaffold(
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
                    // Pitch
                    Container(
                      margin: const EdgeInsets.all(30),
                      width: pitchWidth,
                      height: pitchHeight,
                      decoration: BoxDecoration(color: Colors.brown[400], borderRadius: BorderRadius.circular(4)),
                    ),

                    // Striker
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 600),
                      top: strikerTop,
                      // right: 10,
                      child: PlayerWithName(name: striker, color: Colors.orange.shade700),
                    ),

                    // Non-striker
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 600),
                      bottom: nonStrikerBottom,
                      // right: 10,
                      child: PlayerWithName(name: nonStriker, color: Colors.orange),
                    ),

                    // Bowler
                    const Positioned(left: 10, bottom: 10, child: PlayerWithName(name: "Bumrah", color: Colors.red)),

                    // Stumps at non-striker end
                    Positioned(
                      top: 46,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          3,
                          (i) => Container(width: 2, height: 20, margin: const EdgeInsets.symmetric(horizontal: 2), color: Colors.white),
                        ),
                      ),
                    ),

                    // Fielders
                    ..._buildFielders(boxSize / 2, fielders.length),
                  ],
                ),
              ),
            ),
          ),

          // Run button
          ElevatedButton(onPressed: () => runRuns(1), child: const Text("1 Run")),
          ElevatedButton(onPressed: () => runRuns(2), child: const Text("2 Runs")),
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

// import 'package:flutter/material.dart';
// import 'dart:math';
//
// void main() {
//   runApp(MaterialApp(home: CricketFieldScreen(), debugShowCheckedModeBanner: false));
// }
//
// class CricketFieldScreen extends StatefulWidget {
//   @override
//   State<CricketFieldScreen> createState() => _CricketFieldScreenState();
// }
//
// class _CricketFieldScreenState extends State<CricketFieldScreen> {
//   String striker = "Rohit";
//   String nonStriker = "Virat";
//
//   double strikerTop = 10;
//   double nonStrikerBottom = 10;
//
//   final List<String> fielders = List.generate(10, (index) => "F${index + 1}");
//   late double moveDistance;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final double boxSize = min(screenWidth, screenHeight);
//     moveDistance = (boxSize * 0.68) - 50; // based on pitch height
//   }
//
//   // Future<void> runBetweenWickets(int runs) async {
//   //   for (int i = 0; i < runs; i++) {
//   //     // Move towards each other
//   //     setState(() {
//   //       strikerTop = moveDistance;
//   //       nonStrikerBottom = moveDistance;
//   //     });
//   //
//   //     // Wait for animation to complete
//   //     await Future.delayed(const Duration(seconds: 1));
//   //
//   //     // If it's not the last run, reset positions back to start for next run
//   //     if (i < runs - 1) {
//   //       setState(() {
//   //         strikerTop = 10;
//   //         nonStrikerBottom = 10;
//   //       });
//   //
//   //       // Wait for them to run back before the next run
//   //       await Future.delayed(const Duration(milliseconds: 500));
//   //     }
//   //
//   //     // Swap names after they reach the opposite ends
//   //     setState(() {
//   //       final temp = striker;
//   //       striker = nonStriker;
//   //       nonStriker = temp;
//   //     });
//   //   }
//   // }
//
//   Future<void> runBetweenWickets(int runs) async {
//     for (int i = 0; i < runs; i++) {
//       // Move to opposite ends (complete the run)
//       setState(() {
//         strikerTop = moveDistance;
//         nonStrikerBottom = moveDistance;
//       });
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       // Swap names after completing the run
//       setState(() {
//         final temp = striker;
//         striker = nonStriker;
//         nonStriker = temp;
//       });
//
//       // If more runs needed, return to original positions before next run
//       if (i < runs - 1) {
//         setState(() {
//           strikerTop = 10;
//           nonStrikerBottom = 10;
//         });
//         await Future.delayed(const Duration(milliseconds: 500));
//       }
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final double boxSize = min(screenWidth, screenHeight);
//     final double pitchWidth = boxSize * 0.20;
//     final double pitchHeight = boxSize * 0.68;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Cricket Field")),
//       body: Column(
//         children: [
//           Expanded(
//             child: Align(
//               alignment: Alignment.topCenter,
//               child: Container(
//                 width: boxSize,
//                 height: boxSize,
//                 decoration: BoxDecoration(
//                   color: Colors.green[600],
//                   border: Border.all(color: Colors.white, width: 2),
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Pitch
//                     Stack(
//                       children: [
//                         Container(
//                           margin: const EdgeInsets.all(30),
//                           width: pitchWidth,
//                           height: pitchHeight,
//                           decoration: BoxDecoration(
//                             color: Colors.brown[400],
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         ),
//                         // Striker (moving from top down)
//                         AnimatedPositioned(
//                           duration: const Duration(milliseconds: 400),
//                           top: strikerTop, // animate this
//                           right: 10,
//                           child: PlayerWithName(
//                             name: striker,
//                             color: Colors.orange.shade700,
//                           ),
//                         ),
//
// // Non-striker (moving from bottom up)
//                         AnimatedPositioned(
//                           duration: const Duration(milliseconds: 400),
//                           bottom: nonStrikerBottom, // animate this
//                           right: 10,
//                           child: PlayerWithName(
//                             name: nonStriker,
//                             color: Colors.orange,
//                           ),
//                         ),
//
//                         // Bowler
//                         const Positioned(
//                           left: 10,
//                           bottom: 10,
//                           child: PlayerWithName(name: "Bumrah", color: Colors.red),
//                         ),
//                       ],
//                     ),
//                     Positioned(
//                       top: 46,
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: List.generate(3, (i) => Container(
//                           width: 2,
//                           height: 20,
//                           margin: const EdgeInsets.symmetric(horizontal: 2),
//                           color: Colors.white,
//                         )),
//                       ),
//                     ),
//                     ..._buildFielders(boxSize / 2, fielders.length),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           // Run buttons
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 for (int i in [1, 2, 3])
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     child: ElevatedButton(
//                       onPressed: () => runBetweenWickets(i),
//                       child: Text("$i Run${i > 1 ? 's' : ''}"),
//                     ),
//                   ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   List<Widget> _buildFielders(double radius, int count) {
//     final center = radius;
//     List<Widget> widgets = [];
//     for (int i = 0; i < count; i++) {
//       final angle = (2 * pi / count) * i - pi / 2;
//       final x = center + radius * 0.85 * cos(angle);
//       final y = center + radius * 0.85 * sin(angle);
//
//       widgets.add(Positioned(
//         left: x - 5,
//         top: y - 5,
//         child: const CircleAvatar(radius: 5, backgroundColor: Colors.red),
//       ));
//     }
//     return widgets;
//   }
// }
//
// class PlayerWithName extends StatelessWidget {
//   final String name;
//   final Color color;
//
//   const PlayerWithName({super.key, required this.name, required this.color});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         CircleAvatar(
//           radius: 12,
//           backgroundColor: color,
//           child: const Icon(Icons.person, size: 14, color: Colors.white),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           name,
//           style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
//         ),
//       ],
//     );
//   }
// }
//
//
//
