import 'package:flutter/material.dart';

class CricketScoreScreen extends StatefulWidget {
  const CricketScoreScreen({super.key});

  @override
  State<CricketScoreScreen> createState() => _CricketScoreScreenState();
}

class _CricketScoreScreenState extends State<CricketScoreScreen> with SingleTickerProviderStateMixin {
  // Match state
  int _totalRuns = 0;
  int _wickets = 0;
  int _balls = 0;
  int _extras = 0;
  bool _isFreeHit = false;
  final List<int> _runHistory = [];
  final List<int> _ballHistory = [];
  final List<String> _eventHistory = [];

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

  // Animation
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateButton() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _addRuns(int runs, {bool isExtra = false, String? event}) {
    _animateButton();
    setState(() {
      _totalRuns += runs;
      if (!isExtra) {
        _balls++;

        // Update striker's stats
        final striker = _batsmen.firstWhere((b) => b['striker'] == true);
        striker['runs'] += runs;
        striker['balls']++;

        // Rotate strike for odd runs
        if (runs % 2 != 0) {
          _rotateStrike();
        }
      } else {
        _extras += runs;
      }

      _runHistory.add(runs);
      _ballHistory.add(_balls);
      if (event != null) {
        _eventHistory.add(event);
      }

      // Update current bowler
      if (_bowlers.isNotEmpty) {
        _bowlers[0]['runs'] += runs;
        if (isExtra) {
          _bowlers[0]['extras'] += runs;
        }
      }

      // Reset free hit if it was used
      if (_isFreeHit && event != 'Free Hit') {
        _isFreeHit = false;
      }
    });
  }

  void _addNoBall(int runs) {
    _addRuns(runs + 1, isExtra: true, event: 'No Ball +$runs');
    setState(() {
      _isFreeHit = true;
    });
  }

  void _addWideBall(int runs) {
    _addRuns(runs + 1, isExtra: true, event: 'Wide +$runs');
  }

  void _addFreeHit(int runs) {
    if (_isFreeHit) {
      _addRuns(runs, event: 'Free Hit +$runs');
    }
  }

  void _addDeclaredRuns(int runs) {
    _addRuns(runs, event: 'Declared +$runs');
  }

  void _rotateStrike() {
    setState(() {
      final first = _batsmen.firstWhere((b) => b['striker'] == true);
      final next = _batsmen.firstWhere((b) => b['out'] == false && b['striker'] == false);

      first['striker'] = false;
      next['striker'] = true;
    });
  }

  void _addWicket() {
    if (_isFreeHit) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cannot get out on a free hit!")));
      return;
    }

    _animateButton();
    setState(() {
      _wickets++;
      _balls++;

      // Mark current striker as out
      final striker = _batsmen.firstWhere((b) => b['striker'] == true);
      striker['out'] = true;
      striker['striker'] = false;

      // Update bowler's wickets
      if (_bowlers.isNotEmpty) {
        _bowlers[0]['wickets']++;
      }

      // Bring in new batsman if available
      if (_batsmen.any((b) => b['out'] == false && b['striker'] == false)) {
        final next = _batsmen.firstWhere((b) => b['out'] == false && b['striker'] == false);
        next['striker'] = true;
      }
    });
  }

  void _undo() {
    if (_runHistory.isNotEmpty) {
      setState(() {
        final lastRun = _runHistory.removeLast();
        _totalRuns -= lastRun;
        _balls = _ballHistory.removeLast();

        if (_eventHistory.isNotEmpty && _eventHistory.last.startsWith('No Ball')) {
          _isFreeHit = false;
        }

        // Update striker's stats if it was a regular run
        if (!_eventHistory.isNotEmpty ||
            (!_eventHistory.last.startsWith('No Ball') &&
                !_eventHistory.last.startsWith('Wide') &&
                !_eventHistory.last.startsWith('Free Hit'))) {
          final striker = _batsmen.firstWhere((b) => b['striker'] == true);
          striker['runs'] -= lastRun;
          striker['balls']--;
        }

        if (_eventHistory.isNotEmpty) {
          _eventHistory.removeLast();
        }
      });
    }
  }

  String _formatOvers() {
    final overs = _balls ~/ 6;
    final balls = _balls % 6;
    return '$overs.${balls}';
  }

  double _calculateRunRate() => _balls > 0 ? (_totalRuns / (_balls / 6)) : 0;

  Widget _buildRunButton(int runs, Color color, {VoidCallback? onPressed, String? label}) {
    return ScaleTransition(
      scale: _buttonScaleAnimation,
      child: ElevatedButton(
        onPressed: onPressed ?? () => _addRuns(runs),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(20),
          backgroundColor: color,
          foregroundColor: Colors.white,
          shadowColor: Colors.black26,
          elevation: 4,
        ),
        child: Text(
          label ?? "$runs",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showExtrasMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
                _buildRunButton(1, Colors.orange, onPressed: () => _addNoBall(0), label: "NB"),
                _buildRunButton(1, Colors.orange, onPressed: () => _addWideBall(0), label: "WD"),
                _buildRunButton(1, Colors.orange, onPressed: () => _addNoBall(1), label: "NB+1"),
                _buildRunButton(2, Colors.orange, onPressed: () => _addNoBall(2), label: "NB+2"),
                _buildRunButton(3, Colors.orange, onPressed: () => _addNoBall(3), label: "NB+3"),
                _buildRunButton(1, Colors.orange, onPressed: () => _addWideBall(1), label: "WD+1"),
                _buildRunButton(2, Colors.orange, onPressed: () => _addWideBall(2), label: "WD+2"),
                _buildRunButton(3, Colors.orange, onPressed: () => _addWideBall(3), label: "WD+3"),
                if (_isFreeHit) _buildRunButton(1, Colors.green, onPressed: () => _addFreeHit(1), label: "FH+1"),
                if (_isFreeHit) _buildRunButton(2, Colors.green, onPressed: () => _addFreeHit(2), label: "FH+2"),
                if (_isFreeHit) _buildRunButton(3, Colors.green, onPressed: () => _addFreeHit(3), label: "FH+3"),
                if (_isFreeHit) _buildRunButton(4, Colors.green, onPressed: () => _addFreeHit(4), label: "FH+4"),
                if (_isFreeHit) _buildRunButton(6, Colors.green, onPressed: () => _addFreeHit(6), label: "FH+6"),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeclaredRunsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
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
                _buildRunButton(1, Colors.purple, onPressed: () => _addDeclaredRuns(1), label: "D+1"),
                _buildRunButton(2, Colors.purple, onPressed: () => _addDeclaredRuns(2), label: "D+2"),
                _buildRunButton(3, Colors.purple, onPressed: () => _addDeclaredRuns(3), label: "D+3"),
                _buildRunButton(4, Colors.purple, onPressed: () => _addDeclaredRuns(4), label: "D+4"),
                _buildRunButton(5, Colors.purple, onPressed: () => _addDeclaredRuns(5), label: "D+5"),
                _buildRunButton(6, Colors.purple, onPressed: () => _addDeclaredRuns(6), label: "D+6"),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text("Cricket Score Tracker"),
            centerTitle: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top,),
                    Text("djdjdjdj"),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Event History"),
                      content: SizedBox(
                        width: double.maxFinite,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _eventHistory.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(_eventHistory.reversed.toList()[index]),
                            );
                          },
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Scoreboard
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("$_totalRuns", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                              Text("/$_wickets", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _formatOvers(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "RR: ${_calculateRunRate().toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_extras > 0) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Extras: $_extras",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                              if (_isFreeHit) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    "Free Hit",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Run Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildRunButton(1, colorScheme.primary),
                      _buildRunButton(2, colorScheme.primary),
                      _buildRunButton(3, colorScheme.primary),
                      _buildRunButton(4, colorScheme.primary),
                      _buildRunButton(6, colorScheme.primary),
                      _buildRunButton(0, colorScheme.secondary),
                      ElevatedButton(
                        onPressed: _addWicket,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: colorScheme.tertiary,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.black26,
                          elevation: 4,
                        ),
                        child: const Icon(Icons.person_remove_alt_1),
                      ),
                      ElevatedButton(
                        onPressed: () => _showExtrasMenu(context),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.black26,
                          elevation: 4,
                        ),
                        child: const Text("EX", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () => _showDeclaredRunsMenu(context),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.black26,
                          elevation: 4,
                        ),
                        child: const Text("D", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ball Controls
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: _balls > 0 ? _undo : null,
                          icon: const Icon(Icons.undo),
                          color: colorScheme.primary,
                          iconSize: 32,
                        ),
                        const VerticalDivider(),
                        IconButton(
                          onPressed: () => setState(() => _balls--),
                          icon: const Icon(Icons.remove),
                          color: colorScheme.secondary,
                          iconSize: 32,
                        ),
                        Text(
                          "Balls: $_balls",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _balls++),
                          icon: const Icon(Icons.add),
                          color: colorScheme.secondary,
                          iconSize: 32,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Batting Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                          child: Row(
                            children: [
                              Icon(Icons.sports_cricket, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text("Batting", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const Spacer(),
                              Chip(
                                label: Text("${_batsmen.where((b) => b['out'] == false).length} wickets left"),
                                backgroundColor: colorScheme.primary.withOpacity(0.1),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        ..._batsmen.map(
                              (batsman) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primaryContainer,
                              child: Text(
                                batsman['name'].toString().split(' ').map((e) => e[0]).join(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              batsman['name'],
                              style: TextStyle(
                                fontWeight: batsman['striker'] ? FontWeight.bold : FontWeight.normal,
                                color: batsman['striker'] ? colorScheme.primary : null,
                              ),
                            ),
                            subtitle: Text('${batsman['runs']} (${batsman['balls']})'),
                            trailing: Chip(
                              label: Text(
                                batsman['out'] ? 'Out' : 'Not Out',
                                style: TextStyle(color: batsman['out'] ? Colors.red : Colors.green),
                              ),
                              backgroundColor: batsman['out'] ? Colors.red[50] : Colors.green[50],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bowling Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                          child: Row(
                            children: [
                              Icon(Icons.sports_baseball, color: colorScheme.secondary),
                              const SizedBox(width: 8),
                              const Text("Bowling", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const Divider(),
                        ..._bowlers.map(
                              (bowler) => ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.secondaryContainer,
                              child: Text(
                                bowler['name'].toString().split(' ').map((e) => e[0]).join(),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(bowler['name']),
                            subtitle: Text('${bowler['overs']} overs • ${bowler['maidens']} maidens'),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${bowler['runs']} runs • ${bowler['wickets']} wkts',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('ER: ${(bowler['runs'] / bowler['overs']).toStringAsFixed(2)}'),
                                if (bowler['extras'] > 0) Text(
                                  'Extras: ${bowler['extras']}',
                                  style: const TextStyle(color: Colors.orange),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FilledButton.icon(
              onPressed: () {
                // Show batting report
              },
              icon: const Icon(Icons.sports_cricket),
              label: const Text("Batting"),
              style: FilledButton.styleFrom(backgroundColor: colorScheme.primary),
            ),
            FilledButton.icon(
              onPressed: () {
                // Show bowling report
              },
              icon: const Icon(Icons.sports_baseball),
              label: const Text("Bowling"),
              style: FilledButton.styleFrom(backgroundColor: colorScheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}