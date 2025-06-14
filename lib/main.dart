// 🎯 TASKMASTURE - FINAL PRODUCTION BUILD
// Complete, optimized, production-ready code
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart' show TitleBarStyle;
import 'package:system_tray/system_tray.dart' as system_tray;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:async';
import 'package:confetti/confetti.dart';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:window_size/window_size.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('TaskMasture');
    setWindowMinSize(const Size(393, 900));
    setWindowMaxSize(const Size(393, 900));

    doWhenWindowReady(() {
      appWindow.title = 'TaskMasture';
      //appWindow.titleBarStyle = 0; // 0 = hidden, 1 = normal
      appWindow.minSize = const Size(393, 900);
      appWindow.maxSize = const Size(393, 900);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  runApp(TaskMastureApp());
}

class TaskMastureApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMasture',
      theme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'SF Pro Display',
            ),
        primaryTextTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'SF Pro Display',
            ),
      ),
      home: TaskMasture(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TaskMasture extends StatefulWidget {
  @override
  _TaskMastureHomeState createState() => _TaskMastureHomeState();
}

enum TaskPriority { SSS, SS, S, A, B }

enum XPTitle {
  ROOKIE,
  DISCIPLINED,
  FOCUSED,
  DEDICATED,
  WARRIOR,
  MASTER,
  LEGEND
}

class ArchivedTask {
  String name;
  String description;
  DateTime completedDate;
  TaskPriority priority;
  int xpEarned;

  ArchivedTask({
    required this.name,
    required this.description,
    required this.completedDate,
    required this.priority,
    this.xpEarned = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'completedDate': completedDate.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'xpEarned': xpEarned,
    };
  }

  factory ArchivedTask.fromJson(Map<String, dynamic> json) {
    return ArchivedTask(
      name: json['name'],
      description: json['description'],
      completedDate: DateTime.parse(json['completedDate']),
      priority: _stringToPriority(json['priority'] ?? 'B'),
      xpEarned: json['xpEarned'] ?? 0,
    );
  }

  static TaskPriority _stringToPriority(String priorityString) {
    switch (priorityString) {
      case 'SSS':
        return TaskPriority.SSS;
      case 'SS':
        return TaskPriority.SS;
      case 'S':
        return TaskPriority.S;
      case 'A':
        return TaskPriority.A;
      case 'B':
      default:
        return TaskPriority.B;
    }
  }
}

class Task {
  String name;
  String description;
  int goal;
  bool oneTime;
  List<bool> days;
  int done;
  DateTime dateAdded;
  TaskPriority priority;
  DateTime? completedAt;
  // Smart features
  int currentStreak;
  int bestStreak;
  int totalCompletions;
  int totalSkips;
  DateTime lastCompleted;
  DateTime lastInteraction;
  List<String> failurePattern;
  bool smartSuggestionShown;

  Task({
    required this.name,
    required this.description,
    required this.goal,
    required this.oneTime,
    required this.days,
    this.done = 0,
    DateTime? dateAdded,
    this.priority = TaskPriority.B,
    this.completedAt,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.totalCompletions = 0,
    this.totalSkips = 0,
    DateTime? lastCompleted,
    DateTime? lastInteraction,
    List<String>? failurePattern,
    this.smartSuggestionShown = false,
  })  : dateAdded = dateAdded ?? DateTime.now(),
        lastCompleted = lastCompleted ?? DateTime.now(),
        lastInteraction = lastInteraction ?? DateTime.now(),
        failurePattern = failurePattern ?? [];
  bool get shouldBeArchived {
    if (!oneTime || completedAt == null) return false;
    final now = DateTime.now();
    final hoursSinceCompletion = now.difference(completedAt!).inHours;
    return hoursSinceCompletion >= 24;
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.SSS:
        return Color(0xFFFF0000);
      case TaskPriority.SS:
        return Color(0xFFFF6600);
      case TaskPriority.S:
        return Color(0xFFFFCC00);
      case TaskPriority.A:
        return Color(0xFF00CC00);
      case TaskPriority.B:
        return Color(0xFF0099FF);
    }
  }

  String get priorityText {
    return priority.toString().split('.').last;
  }

  int get priorityOrder {
    switch (priority) {
      case TaskPriority.SSS:
        return 0;
      case TaskPriority.SS:
        return 1;
      case TaskPriority.S:
        return 2;
      case TaskPriority.A:
        return 3;
      case TaskPriority.B:
        return 4;
    }
  }

  int get xpValue {
    int baseXP = switch (priority) {
      TaskPriority.SSS => 50,
      TaskPriority.SS => 40,
      TaskPriority.S => 30,
      TaskPriority.A => 20,
      TaskPriority.B => 10,
    };
    return baseXP + (currentStreak * 5);
  }

  bool get needsSmartSuggestion {
    if (smartSuggestionShown) return false;
    if (totalSkips >= 3 && totalCompletions == 0) return true;
    if (totalCompletions >= 7 && currentStreak >= 3) return true;
    final daysDiff = DateTime.now().difference(lastInteraction).inDays;
    return daysDiff >= 7;
  }

  String get smartSuggestionMessage {
    final totalAttempts = totalCompletions + totalSkips;

    if (totalAttempts == 0) {
      final newTaskMessages = [
        "Ready to conquer this new challenge?\n• Start small and build momentum\n• Set a realistic goal\n• Make it part of your routine",
        "New task detected!\n• Break it into smaller steps\n• Choose the perfect time\n• Visualize your success",
        "Time to make it happen!\n• Plan your approach\n• Set up your environment\n• Take the first step today",
        "Fresh start incoming!\n• Define your why\n• Remove barriers\n• Focus on consistency over perfection"
      ];
      return newTaskMessages[Random().nextInt(newTaskMessages.length)];
    }

    if (totalSkips >= 3 && totalCompletions == 0) {
      final strugglingMessages = [
        "Every expert was once a beginner!\n• Lower the goal temporarily\n• Change the schedule\n• Find an accountability partner",
        "Struggling? That's normal!\n• Try a different approach\n• Reduce the difficulty\n• Celebrate small wins",
        "Growth happens in small steps\n• Make it easier to start\n• Link it to an existing habit\n• Focus on showing up",
        "Time to pivot strategy!\n• Reassess your goal\n• Change the timing\n• Break it down further"
      ];
      return strugglingMessages[Random().nextInt(strugglingMessages.length)];
    }

    if (totalCompletions >= 7 && currentStreak >= 3) {
      final crushingMessages = [
        "You're absolutely crushing it!\n• Consider increasing the challenge\n• Add related tasks\n• Share your success story",
        "Consistency champion!\n• Level up the difficulty\n• Mentor someone else\n• Set a bigger goal",
        "Unstoppable momentum!\n• Expand your routine\n• Try advanced variations\n• Inspire others",
        "Diamond-level performance!\n• Scale up the challenge\n• Document your journey\n• Celebrate this achievement"
      ];
      return crushingMessages[Random().nextInt(crushingMessages.length)];
    }

    final daysDiff = DateTime.now().difference(lastInteraction).inDays;
    if (daysDiff >= 7) {
      final comebackMessages = [
        "Ready for a comeback?\n• Start where you left off\n• Adjust if needed\n• Remember your why",
        "Time to reconnect!\n• Ease back into it\n• Update your approach\n• One step at a time",
        "Fresh perspective time!\n• Review your progress\n• Modify if necessary\n• Begin again with confidence",
        "Let's get back on track!\n• Reassess your goals\n• Plan your return\n• Focus on the next action"
      ];
      return comebackMessages[Random().nextInt(comebackMessages.length)];
    }

    return "Keep building that momentum!";
  }

  void updateStreak(bool completed) {
    lastInteraction = DateTime.now();
    if (completed) {
      currentStreak++;
      totalCompletions++;
      lastCompleted = DateTime.now();
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    } else {
      totalSkips++;
      currentStreak = 0;
      failurePattern.add(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      if (failurePattern.length > 10) {
        failurePattern.removeAt(0);
      }
    }
  }
}

class _TaskMastureHomeState extends State<TaskMasture>
    with TickerProviderStateMixin {
  List<Task> tasks = [];
  Map<String, dynamic> dailyLogs = <String, dynamic>{};
  DateTime? _lastResetDate;
  Map<String, dynamic> draftTask = {};
  List<ArchivedTask> archivedTasks = [];
  int totalXP = 0;
  DateTime lastCleanupCheck = DateTime.now();
  bool showSmartSuggestion = false;
  Task? suggestionTask;

  // System tray variables
  final SystemTray _systemTray = SystemTray();
  bool _isAppVisible = true;

  // Add these new variables after the existing ones
  Map<String, dynamic> userProfile = {};
  bool isFirstLaunch = true;
  int totalDaysCompleted = 0; // This is our "Total Days" instead of "lifetime"

  int dailyStreak = 0; // Daily visit/attempt streak
  DateTime? lastDailyActivity; // Track last day user attempted any task
  Uint8List? profileImageData; // Store profile picture data
  final _imagePicker = ImagePicker();

  // Add these missing variables
  Color profileColor = Colors.blue;
  final List<Color> profileColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
  ];
  // Profile picture helper
  String get profileInitials {
    if (userProfile.isEmpty || userProfile['name'] == null) return 'U';
    final names = userProfile['name'].toString().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  late String quoteText;
  late AnimationController _animationController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    quoteText = getQuoteFromFile();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    // Initialize system tray first
    _initSystemTray();

    // Load data
    loadData().then((_) {
      // Check first launch after data is loaded
      if (mounted && isFirstLaunch && userProfile.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showProfileSetupDialog();
        });
      }
    });
    _checkFirstLaunch();

    // Setup timers for auto-reset and maintenance
    Timer.periodic(Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (_lastResetDate == null ||
          now.day != _lastResetDate!.day ||
          now.month != _lastResetDate!.month ||
          now.year != _lastResetDate!.year) {
        _autoResetDailyTasks();
        _lastResetDate = now;
      }
      _checkForAutoArchiving();
    });

    Timer.periodic(Duration(minutes: 5), (timer) {
      _checkSmartSuggestions();
    });

    Timer.periodic(Duration(hours: 24), (timer) {
      _checkCleanupNeeded();
    });
  }

  @override
  void dispose() {
    try {
      _systemTray.destroy();
    } catch (e) {
      print('Error destroying system tray: $e');
    }
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // 🔥 COMPLETELY FIXED SYSTEM TRAY IMPLEMENTATION
  Future<void> _initSystemTray() async {
    if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
      print('⚠️ System tray not supported on this platform');
      return;
    }

    try {
      print('🔧 Starting system tray initialization...');

      // Step 1: Initialize the system tray with proper icon path
      String iconPath = _getSystemTrayIconPath();
      print('📁 Using icon path: $iconPath');

      await _systemTray.initSystemTray(
        title: "TaskMasture",
        iconPath: iconPath,
        toolTip: "TaskMasture - Click to toggle visibility",
      );

      print('✅ System tray initialized successfully');

      // Step 2: Wait a moment for the system tray to be ready
      await Future.delayed(Duration(milliseconds: 200));

      // Step 3: Set up the context menu BEFORE registering event handlers
      await _setupSystemTrayMenu();

      // Step 4: Register event handlers
      _systemTray.registerSystemTrayEventHandler((eventName) {
        print('🖱️ System tray event received: $eventName');
        _handleSystemTrayEvent(eventName);
      });

      // Step 5: Update the tooltip with current app status
      await _updateSystemTrayStatus();

      print('✅ System tray fully configured and operational');
    } catch (e, stackTrace) {
      print('❌ System tray initialization error: $e');
      print('📋 Stack trace: $stackTrace');
      // Don't rethrow - let app continue without system tray
    }
  }

  String _getSystemTrayIconPath() {
    // Try different icon formats based on platform
    if (Platform.isWindows) {
      // Try multiple possible locations for Windows
      const possiblePaths = [
        'assets/app_icon.ico',
        'assets/icon.ico',
        'assets/images/app_icon.ico',
        'data/flutter_assets/assets/app_icon.ico',
        'app_icon.ico'
      ];

      for (String path in possiblePaths) {
        if (File(path).existsSync()) {
          print('📍 Found Windows icon at: $path');
          return path;
        }
      }

      // If no icon file found, return empty string (will use default)
      print('⚠️ No Windows icon file found, using system default');
      return '';
    } else if (Platform.isMacOS) {
      const possiblePaths = [
        'assets/app_icon.icns',
        'assets/icon.icns',
        'assets/images/app_icon.icns',
        'app_icon.icns'
      ];

      for (String path in possiblePaths) {
        if (File(path).existsSync()) {
          print('📍 Found macOS icon at: $path');
          return path;
        }
      }

      print('⚠️ No macOS icon file found, using system default');
      return '';
    } else {
      // Linux
      const possiblePaths = [
        'assets/app_icon.png',
        'assets/icon.png',
        'assets/images/app_icon.png',
        'app_icon.png'
      ];

      for (String path in possiblePaths) {
        if (File(path).existsSync()) {
          print('📍 Found Linux icon at: $path');
          return path;
        }
      }

      print('⚠️ No Linux icon file found, using system default');
      return '';
    }
  }

  Future<void> _setupSystemTrayMenu() async {
    try {
      print('📋 Setting up system tray context menu...');

      final menu = system_tray.Menu();
      await menu.buildFrom([
        MenuItemLabel(
          label: '📱 Show TaskMasture',
          onClicked: (menuItem) {
            print('📱 Menu clicked: Show TaskMasture');
            _showApp();
          },
        ),
        MenuItemLabel(
          label: '🫥 Hide TaskMasture',
          onClicked: (menuItem) {
            print('🫥 Menu clicked: Hide TaskMasture');
            _hideApp();
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: '📊 Quick Stats',
          onClicked: (menuItem) {
            print('📊 Menu clicked: Quick Stats');
            _showQuickStats();
          },
        ),
        MenuItemLabel(
          label: '📈 Super Stats',
          onClicked: (menuItem) {
            print('📈 Menu clicked: Super Stats');
            _showExportOptions();
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: '➕ Add New Task',
          onClicked: (menuItem) {
            print('➕ Menu clicked: Add New Task');
            _showApp();
            Future.delayed(Duration(milliseconds: 300), () {
              _showAddTaskDialog();
            });
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: '🔄 Reset All Data',
          onClicked: (menuItem) {
            print('🔄 Menu clicked: Reset All Data');
            _showResetConfirmation();
          },
        ),
        MenuSeparator(),
        MenuItemLabel(
          label: '❌ Exit TaskMasture',
          onClicked: (menuItem) {
            print('❌ Menu clicked: Exit Application');
            _exitApp();
          },
        ),
      ]);

      await _systemTray.setContextMenu(menu);
      print('✅ System tray context menu configured successfully');
    } catch (e) {
      print('❌ Error setting up system tray menu: $e');
    }
  }

  void _handleSystemTrayEvent(String eventName) {
    try {
      // Normalize the event name to handle different formats
      String normalizedEvent =
          eventName.toLowerCase().replaceAll('_', '').replaceAll('-', '');

      print('🔄 Processing normalized event: $normalizedEvent');

      switch (normalizedEvent) {
        case 'click':
        case 'leftclick':
        case 'leftmouseup':
        case 'leftmousedown':
          print('👆 Left click detected - toggling app visibility');
          _toggleAppVisibility();
          break;

        case 'rightclick':
        case 'rightmouseup':
        case 'rightmousedown':
          print('👆 Right click detected - context menu should appear');
          // Context menu appears automatically - no action needed
          break;

        case 'doubleclick':
        case 'dblclick':
          print('👆 Double click detected - showing app');
          _showApp();
          break;

        case 'middleclick':
        case 'middlemouseup':
          print('👆 Middle click detected - showing quick stats');
          _showQuickStats();
          break;

        default:
          print('🤷 Unhandled system tray event: $eventName');
      }
    } catch (e) {
      print('❌ Error handling system tray event: $e');
    }
  }

  void _showApp() {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        print('📱 Showing app window...');
        appWindow.show();
        appWindow.restore(); // In case it was minimized

        setState(() => _isAppVisible = true);

        // Update system tray tooltip
        _updateSystemTrayStatus();

        print('✅ App window shown and focused');
      }
    } catch (e) {
      print('❌ Error showing app: $e');
    }
  }

  void _hideApp() {
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        print('🫥 Hiding app window...');
        appWindow.hide();

        setState(() => _isAppVisible = false);

        // Update system tray tooltip
        _updateSystemTrayStatus();

        print('✅ App window hidden');
      }
    } catch (e) {
      print('❌ Error hiding app: $e');
    }
  }

  void _toggleAppVisibility() {
    print(
        '🔄 Toggling app visibility. Current state: ${_isAppVisible ? "visible" : "hidden"}');

    if (_isAppVisible) {
      _hideApp();
    } else {
      _showApp();
    }
  }

  Future<void> _updateSystemTrayStatus() async {
    try {
      final completionPercent = (this.completionPercent * 100).round();
      final activeTasksCount =
          tasks.where((task) => !task.oneTime && task.done < task.goal).length;
      final completedToday =
          tasks.where((task) => task.done >= task.goal).length;

      String statusText =
          _isAppVisible ? "TaskMasture (Visible)" : "TaskMasture (Hidden)";
      String detailsText =
          "$completionPercent% complete today • $completedToday/${tasks.length} tasks done";

      await _systemTray.setSystemTrayInfo(
        title: statusText,
        toolTip:
            "$statusText\n$detailsText\n\nLeft-click: Toggle visibility\nRight-click: Menu",
      );

      print('📊 System tray status updated: $detailsText');
    } catch (e) {
      print('❌ Error updating system tray status: $e');
    }
  }

  void _showQuickStats() {
    _showApp();
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        final completionPercent = (this.completionPercent * 100).round();
        final completedToday =
            tasks.where((task) => task.done >= task.goal).length;
        void _pickProfileColor() {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Color(0xFF1A1A1A),
              title: Text('Choose Profile Color',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'SF Pro Display')),
              content: Wrap(
                children: profileColors
                    .map(
                      (color) => GestureDetector(
                        onTap: () {
                          setState(() {
                            profileColor = color;
                          });
                          saveData();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Profile color updated!',
                                  style:
                                      TextStyle(fontFamily: 'SF Pro Display')),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: profileColor == color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child:
                      Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Today\'s Quick Stats',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'SF Pro Display'),
                ),
                SizedBox(height: 4),
                Text(
                  '✅ Completion: $completionPercent% ($completedToday/${tasks.length} tasks)',
                  style: TextStyle(fontFamily: 'SF Pro Display'),
                ),
                Text(
                  '🔥 Active Streaks: $activeStreaksCount',
                  style: TextStyle(fontFamily: 'SF Pro Display'),
                ),
                Text(
                  '⭐ Total XP: $totalXP',
                  style: TextStyle(fontFamily: 'SF Pro Display'),
                ),
              ],
            ),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'FULL STATS',
              textColor: Colors.white,
              onPressed: () => _showSuperStatsDialog(),
            ),
          ),
        );
      }
    });
  }

  void _showExportOptions() {
    _showApp();
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        _showSuperStatsDialog();
      }
    });
  }

  void _showResetConfirmation() {
    _showApp();
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Color(0xFF1A1A1A),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text('⚠️ RESET ALL DATA',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('This will permanently delete:',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
                SizedBox(height: 8),
                ...[
                  'All ${tasks.length} active tasks',
                  'All ${archivedTasks.length} archived tasks',
                  'All $totalXP XP and progress',
                  'All statistics and logs'
                ]
                    .map((text) => Text('• $text',
                        style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'SF Pro Display')))
                    .toList(),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Color(0xFFBB8FCE).withOpacity(0.4)),
                  ),
                  child: Text('🚨 THIS CANNOT BE UNDONE! 🚨',
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro Display'),
                      textAlign: TextAlign.center),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: TextStyle(
                        color: Colors.white70, fontFamily: 'SF Pro Display')),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetAllData();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('🔥 RESET EVERYTHING',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> _resetAllData() async {
    try {
      print('🔄 Resetting all application data...');

      setState(() {
        tasks.clear();
        archivedTasks.clear();
        dailyLogs.clear();
        draftTask.clear();
        totalXP = 0;
        lastCleanupCheck = DateTime.now();
      });

      final file = File('task_data.json');
      if (file.existsSync()) {
        await file.delete();
        print('🗑️ Data file deleted');
      }

      // Update system tray status
      await _updateSystemTrayStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🔥 All data has been reset! Starting fresh...',
                style: TextStyle(fontFamily: 'SF Pro Display')),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      print('✅ Data reset completed successfully');
    } catch (e) {
      print('❌ Error resetting data: $e');
    }
  }

  void _exitApp() {
    try {
      print('🚪 Exiting TaskMasture application...');

      // Clean up system tray
      _systemTray.destroy();
      print('🗑️ System tray destroyed');

      // Close window
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        appWindow.close();
      }

      // Exit the application
      exit(0);
    } catch (e) {
      print('❌ Error during app exit: $e');
      // Force exit if there's an error
      exit(1);
    }
  }

  // Add this method to update system tray when tasks change
  Future<void> _refreshSystemTray() async {
    await _updateSystemTrayStatus();
  }

  XPTitle get currentXPTitle {
    if (totalXP >= 4000) return XPTitle.LEGEND;
    if (totalXP >= 2000) return XPTitle.MASTER;
    if (totalXP >= 1000) return XPTitle.WARRIOR;
    if (totalXP >= 600) return XPTitle.DEDICATED;
    if (totalXP >= 300) return XPTitle.FOCUSED;
    if (totalXP >= 100) return XPTitle.DISCIPLINED;
    return XPTitle.ROOKIE;
  }

  String get xpTitleText {
    return currentXPTitle.toString().split('.').last;
  }

  Color get xpTitleColor {
    switch (currentXPTitle) {
      case XPTitle.LEGEND:
        return Color(0xFFFFD700);
      case XPTitle.MASTER:
        return Color(0xFFFF6B35);
      case XPTitle.WARRIOR:
        return Color(0xFFE63946);
      case XPTitle.DEDICATED:
        return Color(0xFF9D4EDD);
      case XPTitle.FOCUSED:
        return Color(0xFF277DA1);
      case XPTitle.DISCIPLINED:
        return Color(0xFF43AA8B);
      case XPTitle.ROOKIE:
        return Color(0xFF6C757D);
    }
  }

  void _autoResetDailyTasks() {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    for (var task in tasks) {
      final logKey = '${todayKey}_${task.name}';
      final scheduledToday = _isTaskScheduledOn(task, now);
      final alreadyLogged = dailyLogs.containsKey(logKey);

      if (scheduledToday && !alreadyLogged) {
        dailyLogs[logKey] = {'done': task.done, 'skipped': true};
        task.updateStreak(false);
      }

      if (scheduledToday) {
        task.done = 0;
      }
    }

    saveData();
    setState(() {});
  }

  void _checkSmartSuggestions() {
    for (var task in tasks) {
      if (task.needsSmartSuggestion) {
        setState(() {
          showSmartSuggestion = true;
          suggestionTask = task;
        });
        break;
      }
    }
  }

  void _checkCleanupNeeded() {
    final now = DateTime.now();
    final oldTasks = tasks.where((task) {
      final daysDiff = now.difference(task.lastInteraction).inDays;
      return daysDiff >= 14;
    }).toList();

    if (oldTasks.isNotEmpty) {
      _showCleanupWizard(oldTasks);
    }
  }

  bool _isTaskScheduledOn(Task task, DateTime date) {
    if (task.oneTime) {
      return DateFormat('yyyy-MM-dd').format(task.dateAdded) ==
          DateFormat('yyyy-MM-dd').format(date);
    }

    int weekday = date.weekday - 1;
    if (weekday < 0 || weekday >= task.days.length) return false;
    return task.days[weekday];
  }

  TaskPriority _stringToPriority(String priorityString) {
    switch (priorityString) {
      case 'SSS':
        return TaskPriority.SSS;
      case 'SS':
        return TaskPriority.SS;
      case 'S':
        return TaskPriority.S;
      case 'A':
        return TaskPriority.A;
      case 'B':
      default:
        return TaskPriority.B;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.SSS:
        return Color(0xFFFF0000);
      case TaskPriority.SS:
        return Color(0xFFFF6600);
      case TaskPriority.S:
        return Color(0xFFFFCC00);
      case TaskPriority.A:
        return Color(0xFF00CC00);
      case TaskPriority.B:
        return Color(0xFF0099FF);
    }
  }

  void saveDraftTask(Map<String, dynamic> draft) {
    draftTask = draft;
    saveData();
  }

  void clearDraftTask() {
    draftTask = {};
    saveData();
  }

  void _archiveTask(Task task) {
    final archived = ArchivedTask(
      name: task.name,
      description: task.description,
      completedDate: DateTime.now(),
      priority: task.priority,
      xpEarned: task.xpValue,
    );

    setState(() {
      archivedTasks.add(archived);
      totalXP += task.xpValue;
      tasks.removeWhere((t) => t.name == task.name);
      dailyLogs.removeWhere((key, _) => key.endsWith('_${task.name}'));
    });

    saveData();
    _showXPGainedDialog(task.xpValue, archived.name);
  }

  void _checkForAutoArchiving() {
    final tasksToArchive =
        tasks.where((task) => task.shouldBeArchived).toList();

    for (var task in tasksToArchive) {
      _archiveTask(task);
    }
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final file = File('task_data.json');
      if (file.existsSync()) {
        final content = await file.readAsString();
        final data = jsonDecode(content);

        if (data['userProfile'] != null && data['userProfile'].isNotEmpty) {
          setState(() {
            userProfile = Map<String, dynamic>.from(data['userProfile']);
            isFirstLaunch = false;
            totalDaysCompleted = data['totalDaysCompleted'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('Error checking first launch: $e');
    }
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 80,
      );

      if (image != null) {
        final Uint8List imageData = await image.readAsBytes();
        setState(() {
          profileImageData = imageData;
        });
        saveData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile picture updated!',
                style: TextStyle(fontFamily: 'SF Pro Display')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void _exportToPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile data exported! (PDF feature coming soon)',
            style: TextStyle(fontFamily: 'SF Pro Display')),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color.fromARGB(255, 255, 0, 85), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning,
                      color: const Color.fromARGB(255, 228, 89, 158), size: 50),
                  SizedBox(height: 16),
                  Text('LOGOUT WARNING',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 65, 1, 184),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro Display')),
                  SizedBox(height: 16),
                  Text(
                    'Logging out will delete all your data!\n\nDo you want to export your data first?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'SF Pro Display'),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _exportToPDF();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 141, 4, 4),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Yes, Export First',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 111, 5, 143),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('No, Just Delete',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'SF Pro Display')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    setState(() {
      tasks.clear();
      archivedTasks.clear();
      dailyLogs.clear();
      draftTask.clear();
      userProfile.clear();
      profileImageData = null;
      totalXP = 0;
      dailyStreak = 0;
      totalDaysCompleted = 0;
      lastDailyActivity = null;
      isFirstLaunch = true;
    });

    // Delete data file
    final file = File('task_data.json');
    if (file.existsSync()) {
      file.deleteSync();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logged out successfully!',
            style: TextStyle(fontFamily: 'SF Pro Display')),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateDailyStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDailyActivity == null) {
      // First time user
      dailyStreak = 1;
      lastDailyActivity = today;
      totalDaysCompleted = 1;
    } else {
      final lastActivityDay = DateTime(lastDailyActivity!.year,
          lastDailyActivity!.month, lastDailyActivity!.day);

      final daysDifference = today.difference(lastActivityDay).inDays;

      if (daysDifference == 0) {
        // Same day - no change
        return;
      } else if (daysDifference == 1) {
        // Next day - increment streak
        dailyStreak++;
        lastDailyActivity = today;
        totalDaysCompleted++;
      } else {
        // Missed days - reset streak
        dailyStreak = 1;
        lastDailyActivity = today;
        totalDaysCompleted++;
      }
    }
    saveData();
  }

  void _showProfileSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProfileSetupDialog(
        onProfileCreated: (profile) {
          setState(() {
            userProfile = profile;
            isFirstLaunch = false;
          });
          saveData();
        },
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Picture
                  // Profile Picture (Clickable to Upload)
                  GestureDetector(
                    onTap: _pickProfileImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(60),
                        border: Border.all(color: Colors.white, width: 4),
                        image: profileImageData != null
                            ? DecorationImage(
                                image: MemoryImage(profileImageData!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: profileImageData == null
                          ? Center(
                              child: Text(
                                profileInitials,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display',
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('Tap to upload picture',
                      style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          fontFamily: 'SF Pro Display')),
                  SizedBox(height: 16),

                  // Name
                  Text(userProfile['name'] ?? 'Unknown User',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro Display')),

                  SizedBox(height: 20),

                  // Stats
                  Column(
                    children: [
                      _buildStatRow(
                          'Current Streak', '$longestCurrentStreak days'),
                      _buildStatRow('Daily Streak', '$dailyStreak days'),
                      _buildStatRow('Total Days', '$totalDaysCompleted days'),
                      _buildStatRow('Total XP', '$totalXP XP'),
                      _buildStatRow('Title', xpTitleText),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Close'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _exportToPDF();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 174, 0, 255),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Export'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showLogoutDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 76, 0, 255),
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontFamily: 'SF Pro Display')),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF Pro Display')),
        ],
      ),
    );
  }

  Future<void> saveData() async {
    try {
      final file = File('task_data.json');
      tasks.sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));

      final taskList = tasks
          .map((t) => {
                'name': t.name,
                'description': t.description,
                'goal': t.goal,
                'oneTime': t.oneTime,
                'days': t.days,
                'done': t.done,
                'dateAdded': t.dateAdded.toIso8601String(),
                'priority': t.priority.toString().split('.').last,
                'completedAt': t.completedAt?.toIso8601String(),
                'currentStreak': t.currentStreak,
                'bestStreak': t.bestStreak,
                'totalCompletions': t.totalCompletions,
                'totalSkips': t.totalSkips,
                'lastCompleted': t.lastCompleted.toIso8601String(),
                'lastInteraction': t.lastInteraction.toIso8601String(),
                'failurePattern': t.failurePattern,
                'smartSuggestionShown': t.smartSuggestionShown,
              })
          .toList();

      final archivedList = archivedTasks.map((t) => t.toJson()).toList();
      final logList = dailyLogs.map((k, v) => MapEntry(k, v));
      final fullData = {
        'tasks': taskList,
        'logs': logList,
        'draft': draftTask,
        'archivedTasks': archivedList,
        'totalXP': totalXP,
        'lastCleanupCheck': lastCleanupCheck.toIso8601String(),
        // ADD THESE TWO LINES:
        // ADD THESE TWO LINES:
        'userProfile': userProfile,
        'totalDaysCompleted': totalDaysCompleted,
        'dailyStreak': dailyStreak,
        'lastDailyActivity': lastDailyActivity?.toIso8601String(),
        'profileImageData': profileImageData?.toList(),
        'profileColor': profileColor.value,
        'isFirstLaunch': false,
      };

      // Debug print
      print(
          '🔍 DEBUG: Saving data - isFirstLaunch: false, userProfile: $userProfile');

      await file.writeAsString(jsonEncode(fullData));
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<void> loadData() async {
    try {
      final file = File('task_data.json');
      if (!file.existsSync()) return;

      final content = await file.readAsString();
      final data = jsonDecode(content);

      final loadedTasks = (data['tasks'] as List? ?? [])
          .map((t) => Task(
                name: t['name'],
                description: t['description'],
                goal: t['goal'],
                oneTime: t['oneTime'],
                days: List<bool>.from(t['days']),
                done: t['done'] ?? 0,
                dateAdded: DateTime.parse(t['dateAdded']),
                priority: _stringToPriority(t['priority'] ?? 'B'),
                completedAt: t['completedAt'] != null
                    ? DateTime.parse(t['completedAt'])
                    : null,
                currentStreak: t['currentStreak'] ?? 0,
                bestStreak: t['bestStreak'] ?? 0,
                totalCompletions: t['totalCompletions'] ?? 0,
                totalSkips: t['totalSkips'] ?? 0,
                lastCompleted: t['lastCompleted'] != null
                    ? DateTime.parse(t['lastCompleted'])
                    : DateTime.now(),
                lastInteraction: t['lastInteraction'] != null
                    ? DateTime.parse(t['lastInteraction'])
                    : DateTime.now(),
                failurePattern: t['failurePattern'] != null
                    ? List<String>.from(t['failurePattern'])
                    : [],
                smartSuggestionShown: t['smartSuggestionShown'] ?? false,
              ))
          .toList();

      final loadedLogs = Map<String, dynamic>.from(data['logs'] ?? {});
      final loadedDraft = Map<String, dynamic>.from(data['draft'] ?? {});
      final loadedArchived = (data['archivedTasks'] as List? ?? [])
          .map((t) => ArchivedTask.fromJson(t))
          .toList();

      // Clean up orphaned logs
      final taskNames = loadedTasks.map((t) => t.name).toSet();
      loadedLogs.removeWhere((key, _) {
        final namePart = key.split('_').skip(1).join('_');
        return !taskNames.contains(namePart);
      });

      setState(() {
        tasks = loadedTasks;
        dailyLogs = loadedLogs;
        draftTask = loadedDraft;
        archivedTasks = loadedArchived;
        totalXP = data['totalXP'] ?? 0;
        lastCleanupCheck = data['lastCleanupCheck'] != null
            ? DateTime.parse(data['lastCleanupCheck'])
            : DateTime.now();
        // ADD THESE LINES:
        userProfile = Map<String, dynamic>.from(data['userProfile'] ?? {});
        totalDaysCompleted = data['totalDaysCompleted'] ?? 0;
        dailyStreak = data['dailyStreak'] ?? 0;
        lastDailyActivity = data['lastDailyActivity'] != null
            ? DateTime.parse(data['lastDailyActivity'])
            : null;
        profileImageData = data['profileImageData'] != null
            ? Uint8List.fromList(List<int>.from(data['profileImageData']))
            : null;
        profileColor = data['profileColor'] != null
            ? Color(data['profileColor'])
            : Colors.blue;
        isFirstLaunch = data['isFirstLaunch'] ?? userProfile.isEmpty;
        tasks.sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));

        // Debug prints
        print('🔍 DEBUG: Loaded data - isFirstLaunch: $isFirstLaunch');
        print('🔍 DEBUG: userProfile: $userProfile');
        print('🔍 DEBUG: userProfile.isEmpty: ${userProfile.isEmpty}');
      });

      _lastResetDate = DateTime.now();
      _animationController.forward(from: 1.0);
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  List<double> getWeeklyProgress() {
    final today = DateTime.now();
    List<double> progressList = [];

    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      int total = 0;
      int completed = 0;

      for (var task in tasks) {
        if (_isTaskScheduledOn(task, day)) {
          final key = '${day.year}-${day.month}-${day.day}_${task.name}';
          if (dailyLogs.containsKey(key)) {
            total++;
            if ((dailyLogs[key]['done'] ?? 0) >= task.goal) {
              completed++;
            }
          }
        }
      }

      final dayPercent = total == 0 ? 0 : completed / total;
      progressList.add(dayPercent.toDouble());
    }

    return progressList;
  }

  double get completionPercent {
    if (tasks.isEmpty) return 0.0;

    final today = (DateTime.now().weekday % 7);
    final activeTasks = tasks.where((t) {
      if (t.oneTime) return true;
      return t.days[today];
    }).toList();

    if (activeTasks.isEmpty) return 0.0;

    double sum = 0;
    for (var t in activeTasks) {
      sum += (t.done / t.goal).clamp(0, 1);
    }
    return (sum / activeTasks.length);
  }

  Map<String, int> get priorityStats {
    Map<String, int> stats = {'SSS': 0, 'SS': 0, 'S': 0, 'A': 0, 'B': 0};
    for (var task in tasks) {
      stats[task.priorityText] = (stats[task.priorityText] ?? 0) + 1;
    }
    return stats;
  }

  Map<String, dynamic> get superStats {
    final now = DateTime.now();
    final last30Days =
        List.generate(30, (i) => now.subtract(Duration(days: i)));

    double productivityScore = 0;
    int totalScheduledTasks = 0;
    int totalCompletedTasks = 0;

    for (var day in last30Days) {
      for (var task in tasks) {
        if (_isTaskScheduledOn(task, day)) {
          totalScheduledTasks++;
          final key = '${day.year}-${day.month}-${day.day}_${task.name}';
          if (dailyLogs.containsKey(key) &&
              (dailyLogs[key]['done'] ?? 0) >= task.goal) {
            totalCompletedTasks++;
          }
        }
      }
    }

    productivityScore = totalScheduledTasks > 0
        ? (totalCompletedTasks / totalScheduledTasks) * 100
        : 0;

    Map<int, int> dayPerformance = {};
    for (int i = 0; i < 7; i++) {
      dayPerformance[i] = 0;
    }

    for (var task in tasks) {
      for (int i = 0; i < task.days.length; i++) {
        if (task.days[i]) {
          dayPerformance[i] = (dayPerformance[i] ?? 0) + task.totalCompletions;
        }
      }
    }

    int bestDay = dayPerformance.entries.isNotEmpty
        ? dayPerformance.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 0;

    int totalStreaks = tasks.fold(0, (sum, task) => sum + task.currentStreak);
    int bestOverallStreak = tasks.fold(
        0, (max, task) => task.bestStreak > max ? task.bestStreak : max);
    int totalSkips = tasks.fold(0, (sum, task) => sum + task.totalSkips);

    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return {
      'productivityScore': productivityScore.round(),
      'bestDay': dayNames[bestDay],
      'bestDayIndex': bestDay,
      'totalStreaks': totalStreaks,
      'bestOverallStreak': bestOverallStreak,
      'totalSkips': totalSkips,
      'totalScheduled': totalScheduledTasks,
      'totalCompleted': totalCompletedTasks,
      'averageCompletion': productivityScore,
    };
  }

  int get totalTasksCompleted {
    return tasks.where((task) => task.done >= task.goal).length;
  }

  int get activeStreaksCount {
    return tasks.where((task) => task.currentStreak > 0).length;
  }

  int get longestCurrentStreak {
    return tasks.fold(
        0, (max, task) => task.currentStreak > max ? task.currentStreak : max);
  }

  Map<String, String> _getImageAndQuote() {
    final percent = (completionPercent * 100).round();

    if (percent == 0) return {'image': '1.png', 'quote': 'HOLY\nFKN\nAIRBALL'};
    if (percent <= 10) return {'image': '2.png', 'quote': 'TRY\nHARDER\nNOW'};
    if (percent <= 20) return {'image': '3.png', 'quote': 'DONT\nGIVE\nUP'};
    if (percent <= 30) return {'image': '4.png', 'quote': 'PUSH\nURSELF\nMORE'};
    if (percent <= 40) return {'image': '5.png', 'quote': 'YOURE\nWARMING\nUP'};
    if (percent <= 60) return {'image': '6.png', 'quote': 'NOT\nBAD\nAT ALL'};
    if (percent <= 70)
      return {'image': '7.png', 'quote': 'GETTING\nCLOSER\nNOW'};
    if (percent <= 80) return {'image': '8.png', 'quote': 'ALMOST\nTHERE\n'};
    if (percent <= 90) return {'image': '9.png', 'quote': 'EXCELLENT\nWORK'};
    if (percent <= 100) return {'image': '10.png', 'quote': 'YOU\nA LEGEND'};
    return {'image': '1.png', 'quote': 'HOLY\nFKN\nAIRBALL'};
  }

  void _showXPGainedDialog(int xpGained, String taskName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 50),
                SizedBox(height: 16),
                Text('+$xpGained XP',
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
                SizedBox(height: 8),
                Text('Task Completed!',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
                SizedBox(height: 4),
                Text(taskName,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'SF Pro Display'),
                    textAlign: TextAlign.center),
                SizedBox(height: 16),
                Text('Total XP: $totalXP',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontFamily: 'SF Pro Display')),
                Text('Title: $xpTitleText',
                    style: TextStyle(
                        color: xpTitleColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black),
                  child: Text('AWESOME!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro Display')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSmartSuggestionDialog() {
    if (suggestionTask == null) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lightbulb, color: Colors.blue, size: 40),
                SizedBox(height: 16),
                Text('Smart Suggestion',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
                SizedBox(height: 16),
                Text(suggestionTask!.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display'),
                    textAlign: TextAlign.center),
                SizedBox(height: 12),
                Text(suggestionTask!.smartSuggestionMessage,
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'SF Pro Display'),
                    textAlign: TextAlign.center),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _dismissSmartSuggestion();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white),
                        child: Text('Maybe Later',
                            style: TextStyle(fontFamily: 'SF Pro Display')),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _actOnSmartSuggestion();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white),
                        child: Text('Edit Task',
                            style: TextStyle(fontFamily: 'SF Pro Display')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _dismissSmartSuggestion() {
    if (suggestionTask != null) {
      suggestionTask!.smartSuggestionShown = true;
      saveData();
    }
    setState(() {
      showSmartSuggestion = false;
      suggestionTask = null;
    });
  }

  void _actOnSmartSuggestion() {
    if (suggestionTask != null) {
      final taskIndex = tasks.indexOf(suggestionTask!);
      if (taskIndex != -1) {
        _showTaskDetailsDialog(suggestionTask!, taskIndex);
      }
    }
    _dismissSmartSuggestion();
  }

  void _showCleanupWizard(List<Task> oldTasks) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cleaning_services, color: Colors.orange, size: 40),
                SizedBox(height: 16),
                Text('Cleanup Wizard',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
                SizedBox(height: 16),
                Text('Found ${oldTasks.length} tasks untouched for 14+ days',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'SF Pro Display'),
                    textAlign: TextAlign.center),
                SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: oldTasks.length,
                    itemBuilder: (context, index) {
                      final task = oldTasks[index];
                      final daysSince = DateTime.now()
                          .difference(task.lastInteraction)
                          .inDays;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'SF Pro Display')),
                            Text('Last interaction: $daysSince days ago',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontFamily: 'SF Pro Display')),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white),
                        child: Text('Keep All',
                            style: TextStyle(fontFamily: 'SF Pro Display')),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteOldTasks(oldTasks);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white),
                        child: Text('Clean Up',
                            style: TextStyle(fontFamily: 'SF Pro Display')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteOldTasks(List<Task> oldTasks) {
    setState(() {
      for (var task in oldTasks) {
        tasks.removeWhere((t) => t.name == task.name);
        dailyLogs.removeWhere((key, _) => key.endsWith('_${task.name}'));
      }
    });

    saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cleaned up ${oldTasks.length} old tasks',
            style: TextStyle(fontFamily: 'SF Pro Display')),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return TaskDialog(
          draftData: draftTask,
          onTaskAdded: (task) {
            setState(() {
              tasks.add(task);
              tasks.sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
            });
            clearDraftTask();
          },
          onDraftSaved: saveDraftTask,
        );
      },
    );
  }

  void _showTaskDetailsDialog(Task task, int index) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return TaskDetailsDialog(
          task: task,
          onTaskUpdated: (updatedTask) {
            setState(() {
              tasks[index] = updatedTask;
              tasks.sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
            });
          },
          onTaskDeleted: () {
            setState(() {
              final taskName = tasks[index].name;
              dailyLogs.removeWhere((key, _) => key.endsWith('_$taskName'));
              tasks.removeAt(index);
              saveData();
            });
          },
        );
      },
    );
  }

  Widget buildWeeklyGraph({bool isMini = false}) {
    final weeklyData = getWeeklyProgress();
    final spots = weeklyData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    return Container(
      height: isMini ? 60 : 150,
      padding: EdgeInsets.all(isMini ? 8 : 16),
      decoration: BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color.fromARGB(255, 241, 158, 209).withOpacity(0.3)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: !isMini,
            drawVerticalLine: true,
            drawHorizontalLine: true,
            horizontalInterval: 0.25,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.white.withOpacity(0.1), strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: !isMini,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return Text(days[value.toInt() % 7],
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: isMini ? 10 : 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'SF Pro Display'));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: !isMini,
                getTitlesWidget: (value, meta) {
                  return Text('${(value * 100).toInt()}%',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontFamily: 'SF Pro Display'));
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.redAccent,
              barWidth: isMini ? 2 : 4,
              dotData: FlDotData(
                show: !isMini,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                      radius: 4,
                      color: Color.fromARGB(255, 113, 7, 155),
                      strokeWidth: 2,
                      strokeColor: Colors.white);
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFA569BD).withOpacity(0.4),
                    Color(0xFFA569BD).withOpacity(0.1)
                  ],
                ),
              ),
            ),
          ],
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 1,
        ),
      ),
    );
  }

  Widget buildArchivedTasksDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.amber, width: 2),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.archive, color: Colors.amber, size: 24),
                SizedBox(width: 8),
                Text('ARCHIVED CONQUESTS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
              ],
            ),
            SizedBox(height: 16),
            Text('${archivedTasks.length} completed tasks',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: 'SF Pro Display')),
            SizedBox(height: 16),
            Expanded(
              child: archivedTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, color: Colors.white30, size: 64),
                          SizedBox(height: 16),
                          Text('No archived tasks yet',
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 16,
                                  fontFamily: 'SF Pro Display')),
                          SizedBox(height: 8),
                          Text('Complete some one-time tasks to see them here!',
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontSize: 12,
                                  fontFamily: 'SF Pro Display'),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: archivedTasks.length,
                      itemBuilder: (context, index) {
                        final archived = archivedTasks.reversed.toList()[index];
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF2E2E2E),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _getPriorityColor(archived.priority)
                                    .withOpacity(0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(archived.priority),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                    archived.priority
                                        .toString()
                                        .split('.')
                                        .last,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'SF Pro Display')),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(archived.name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'SF Pro Display')),
                                    SizedBox(height: 4),
                                    Text(archived.description,
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontFamily: 'SF Pro Display')),
                                    SizedBox(height: 4),
                                    Text(
                                        'Completed: ${DateFormat('dd MMM yyyy').format(archived.completedDate)}',
                                        style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 10,
                                            fontFamily: 'SF Pro Display')),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('+${archived.xpEarned} XP',
                                        style: TextStyle(
                                            color: Colors.amber,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'SF Pro Display')),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, foregroundColor: Colors.black),
              child: Text('CLOSE',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SF Pro Display')),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuperStatsDialog() {
    final stats = superStats;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFF8E44AD), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2)
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.analytics, color: Colors.purple, size: 24),
                          SizedBox(width: 8),
                          Text('SUPER STATS MODE',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // XP & Title Section
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: xpTitleColor.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total XP:',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontFamily: 'SF Pro Display')),
                              Text('$totalXP',
                                  style: TextStyle(
                                      color: Colors.amber,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SF Pro Display')),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Current Title:',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontFamily: 'SF Pro Display')),
                              Text(xpTitleText,
                                  style: TextStyle(
                                      color: xpTitleColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SF Pro Display')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16), // Productivity Score
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Productivity Score (Last 30 Days)',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${stats['productivityScore']}%',
                                  style: TextStyle(
                                    color: stats['productivityScore'] >= 80
                                        ? Colors.green
                                        : stats['productivityScore'] >= 60
                                            ? Colors.orange
                                            : Colors.red,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'SF Pro Display',
                                  )),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      '${stats['totalCompleted']}/${stats['totalScheduled']}',
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'SF Pro Display')),
                                  Text('Tasks Completed',
                                      style: TextStyle(
                                          color: Colors.white60,
                                          fontSize: 12,
                                          fontFamily: 'SF Pro Display')),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: stats['productivityScore'] / 100,
                            color: stats['productivityScore'] >= 80
                                ? Colors.green
                                : stats['productivityScore'] >= 60
                                    ? Colors.orange
                                    : Colors.red,
                            backgroundColor: Colors.grey[800],
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // Best Performance Day
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Best Performance Day:',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontFamily: 'SF Pro Display')),
                          Text(stats['bestDay'],
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                    Text('Weekly Progress:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SF Pro Display')),
                    SizedBox(height: 8),
                    buildWeeklyGraph(isMini: false),

                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF8E44AD),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: Text('CLOSE',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'SF Pro Display')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('dd MMM yyyy').format(DateTime.now()).toUpperCase();

    return WindowBorder(
      color: Colors.transparent,
      width: 0,
      child: WillPopScope(
        onWillPop: () async {
          _hideApp();
          return false;
        },
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 0, 0, 0),
          body: Stack(
            children: [
              Column(
                children: [
                  // ENHANCED HEADER with XP Display
                  Container(
                    height: 80,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Color(0xFF5B2C6F),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(14),
                        bottomRight: Radius.circular(14),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(formattedDate,
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white60,
                                fontFamily: 'SF Pro Display')),
                        Text('TASKMASTURE',
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SF Pro Display')),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),

                  // ENHANCED STREAKS BAR
                  // ENHANCED STREAKS BAR WITH PROFILE PICTURE
                  // ENHANCED STREAKS BAR WITH PROFILE PICTURE
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 35,
                        width: double.infinity,
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        padding: EdgeInsets.only(left: 50, right: 16),
                        decoration: BoxDecoration(
                          color: Color(0xFF8E44AD),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Spacer(),

                            // Current Streak
                            Row(
                              children: [
                                Icon(Icons.local_fire_department,
                                    color: const Color.fromARGB(
                                        255, 207, 187, 255),
                                    size: 18),
                                SizedBox(width: 4),
                                Text('Current: $longestCurrentStreak',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 207, 187, 255),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'SF Pro Display')),
                              ],
                            ),

                            const Spacer(),

                            // Daily Streak
                            Row(
                              children: [
                                Icon(Icons.local_fire_department,
                                    color: Color.fromARGB(255, 207, 187, 255),
                                    size: 16),
                                SizedBox(width: 4),
                                Text('Daily: $dailyStreak',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 207, 187, 255),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'SF Pro Display')),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Profile Picture positioned outside the bar
                      // Profile Picture positioned outside the bar
                      Positioned(
                        left: 16,
                        top: 6,
                        child: GestureDetector(
                          onTap: _showProfileDialog,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: profileColor,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white, width: 3),
                              image: profileImageData != null
                                  ? DecorationImage(
                                      image: MemoryImage(profileImageData!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profileImageData == null
                                ? Center(
                                    child: Text(
                                      profileInitials,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'SF Pro Display',
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 350,
                    height: 100,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Container(
                            padding: EdgeInsets.only(
                                left: 140, right: 20, top: 25, bottom: 25),
                            decoration: BoxDecoration(
                              color: Color(0xFF2C1A47),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                quoteText,
                                textAlign: TextAlign.right,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily:
                                      'SFUIText-Regular', // Keep original for quotes
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -30,
                          left: -30,
                          child: Container(
                            width: 160,
                            height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: AnimatedBuilder(
                                    animation: _animationController,
                                    builder: (context, child) {
                                      return CircularProgressIndicator(
                                        value: completionPercent *
                                            _animationController.value,
                                        strokeWidth: 20,
                                        strokeCap: StrokeCap.round,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Color(0xFFA569BD)),
                                        backgroundColor: Colors.grey.shade800,
                                      );
                                    },
                                  ),
                                ),
                                Text('${(completionPercent * 100).round()}%',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'SF Pro Display')),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ENHANCED TASK LIST with SF Fonts
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF121212),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final isDone = task.done >= task.goal;
                          final progressPercent =
                              (task.done / task.goal).clamp(0.0, 1.0);

                          final today = DateTime.now();
                          final todayWeekday = today.weekday - 1;
                          final isOffDay = !task.oneTime &&
                              (todayWeekday < 0 ||
                                  todayWeekday >= task.days.length ||
                                  !task.days[todayWeekday]);

                          return GestureDetector(
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              _showTaskDetailsDialog(task, index);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDone
                                      ? task.priorityColor.withOpacity(0.8)
                                      : task.priorityColor.withOpacity(0.3),
                                  width: isDone ? 2.5 : 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  children: [
                                    // Base background
                                    Container(
                                      width: double.infinity,
                                      height: 90,
                                      color: isOffDay
                                          ? Color(0xFF424242)
                                          : isDone
                                              ? task.priorityColor
                                                  .withOpacity(0.3)
                                              : Color(0xFF2E2E2E),
                                    ),

                                    // Progress fill
                                    if (!isDone && !isOffDay && task.goal > 1)
                                      Positioned.fill(
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: progressPercent,
                                          child: Container(
                                              color: task.priorityColor
                                                  .withOpacity(0.4)),
                                        ),
                                      ), // Content
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          // Priority badge
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: task.priorityColor,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: task.priorityColor
                                                        .withOpacity(0.4),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2))
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(task.priorityText,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'SF Pro Display')),
                                            ),
                                          ),

                                          SizedBox(width: 12),

                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (isOffDay) ...[
                                                  Text('NOT TODAY BOSS',
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'SF Pro Display')),
                                                  SizedBox(height: 2),
                                                  Text(task.name,
                                                      style: TextStyle(
                                                          color: Colors.white54,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'SF Pro Display')),
                                                ] else if (isDone) ...[
                                                  Text(
                                                      task.oneTime
                                                          ? 'TASK COMPLETE'
                                                          : 'DONE FOR THE DAY',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                          fontFamily:
                                                              'SF Pro Display')),
                                                  SizedBox(height: 4),
                                                  Text(task.name,
                                                      style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontFamily:
                                                              'SF Pro Display')),
                                                  if (task.oneTime &&
                                                      task.completedAt ==
                                                          null) ...[
                                                    SizedBox(height: 4),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.amber
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: Text(
                                                          '+${task.xpValue} XP',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.amber,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'SF Pro Display')),
                                                    ),
                                                  ],
                                                ] else ...[
                                                  Text(task.name,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 22,
                                                          fontFamily:
                                                              'SF Pro Display')),
                                                  SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      if (task.goal > 1 &&
                                                          task.done > 0) ...[
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: task
                                                                .priorityColor
                                                                .withOpacity(
                                                                    0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Text(
                                                              '${task.done}/${task.goal}',
                                                              style: TextStyle(
                                                                  color: task
                                                                      .priorityColor,
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'SF Pro Display')),
                                                        ),
                                                        SizedBox(width: 8),
                                                      ],
                                                      if (task.currentStreak >
                                                          0) ...[
                                                        Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.orange
                                                                .withOpacity(
                                                                    0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .local_fire_department,
                                                                  color: Colors
                                                                      .orange,
                                                                  size: 12),
                                                              SizedBox(
                                                                  width: 2),
                                                              Text(
                                                                  '${task.currentStreak}',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .orange,
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          'SF Pro Display')),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(width: 8),
                                                      ],
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 6,
                                                                vertical: 2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.amber
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Text(
                                                            '+${task.xpValue} XP',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .amber,
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    'SF Pro Display')),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ), // Action Button
                                          if (!isOffDay && !isDone)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  task.done++;
                                                  task.updateStreak(true);

                                                  // Update daily streak when user attempts any task
                                                  _updateDailyStreak();

                                                  if (task.done >= task.goal) {
                                                    _confettiController.play();
                                                    totalXP += task.xpValue;

                                                    if (task.oneTime) {
                                                      task.completedAt =
                                                          DateTime.now();
                                                    }
                                                  }

                                                  saveData();
                                                  _animationController
                                                      .forward();

                                                  final today = DateTime.now();
                                                  final logKey =
                                                      '${today.year}-${today.month}-${today.day}_${task.name}';
                                                  dailyLogs[logKey] = {
                                                    'done': task.done,
                                                    'skipped': false
                                                  };
                                                });
                                              },
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: task.priorityColor
                                                          .withOpacity(0.8),
                                                      width: 2),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.add,
                                                    color: task.priorityColor,
                                                    size: 20),
                                              ),
                                            ),

                                          if (!isOffDay && isDone)
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: task.priorityColor,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(Icons.check,
                                                  color: Colors.white,
                                                  size: 20),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ), // ADD TASK BUTTON
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: _showAddTaskDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 212, 18, 99),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                      ),
                      child: Text('ADD TASK',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SF Pro Display')),
                    ),
                  ),

                  // ENHANCED BOTTOM BOXES with SF Fonts
                  SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        // First Row: Quote box and Stats box
                        Row(
                          children: [
                            // Quote box
                            Expanded(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    height: 75,
                                    padding:
                                        EdgeInsets.only(left: 50, right: 12),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF121212),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        _getImageAndQuote()['quote']!,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                          height: 1.2,
                                          fontFamily: 'SF Pro Display',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: -8,
                                    top: -5,
                                    bottom: -5,
                                    child: Image.asset(
                                      'assets/images/${_getImageAndQuote()['image']!}',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),

                            // Stats box
                            Expanded(
                              child: GestureDetector(
                                onTap: _showSuperStatsDialog,
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF121212),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.purple.withOpacity(0.3)),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Opacity(
                                            opacity: 0.3,
                                            child:
                                                buildWeeklyGraph(isMini: true),
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('SUPER STATS',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        'SF Pro Display')),
                                            Text(
                                                '${(completionPercent * 100).round()}%',
                                                style: TextStyle(
                                                    color: Colors.purple,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    fontFamily:
                                                        'SF Pro Display')),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                            height:
                                10), // Second Row: Archive box and Streaks box
                        Row(
                          children: [
                            // Archive box
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) =>
                                          buildArchivedTasksDialog());
                                },
                                child: Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF121212),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.archive,
                                            color: Colors.amber, size: 18),
                                        SizedBox(height: 3),
                                        Text('ARCHIVES',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                                fontFamily: 'SF Pro Display')),
                                        Text('${archivedTasks.length} done',
                                            style: TextStyle(
                                                color: Colors.amber,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'SF Pro Display')),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),

                            // Streaks box
                            Expanded(
                              child: Container(
                                height: 70,
                                decoration: BoxDecoration(
                                  color: Color(0xFF121212),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.local_fire_department,
                                              color: Colors.orange, size: 18),
                                          SizedBox(width: 3),
                                          Text('${longestCurrentStreak}',
                                              style: TextStyle(
                                                  color: Colors.orange,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily:
                                                      'SF Pro Display')),
                                        ],
                                      ),
                                      SizedBox(height: 1),
                                      Text('BEST STREAK',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 9,
                                              fontFamily: 'SF Pro Display')),
                                      Text('${activeStreaksCount} active',
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 9,
                                              fontFamily: 'SF Pro Display')),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ), // CONFETTI EFFECT
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  emissionFrequency: 0.05,
                  numberOfParticles: 20,
                  maxBlastForce: 20,
                  minBlastForce: 8,
                  gravity: 0.3,
                ),
              ),

              // Enhanced Smart Suggestion Overlay
              if (showSmartSuggestion)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: GestureDetector(
                        onTap: _showSmartSuggestionDialog,
                        child: Container(
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lightbulb,
                                  color: Colors.white, size: 24),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Smart suggestion available!\nTap to view...',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SF Pro Display'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLogsDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        String searchQuery = '';

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text('TASK LOGS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display')),
                SizedBox(height: 16),
                TextField(
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'SF Pro Display'),
                  decoration: InputDecoration(
                    hintText: 'Search by task name or date...',
                    hintStyle: TextStyle(
                        color: Colors.white60, fontFamily: 'SF Pro Display'),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    prefixIcon: Icon(Icons.search, color: Colors.white60),
                  ),
                  onChanged: (value) =>
                      setDialogState(() => searchQuery = value.toLowerCase()),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: dailyLogs.length,
                    itemBuilder: (context, index) {
                      final entryList = dailyLogs.entries.toList();
                      final entry = entryList[index];
                      final parts = entry.key.split('_');
                      final datePart = parts[0];
                      final taskName = parts.length > 1 ? parts[1] : 'Unknown';

                      if (searchQuery.isNotEmpty &&
                          !taskName.toLowerCase().contains(searchQuery) &&
                          !datePart.toLowerCase().contains(searchQuery)) {
                        return SizedBox.shrink();
                      }

                      final log = entry.value;
                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFF2E2E2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(taskName,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'SF Pro Display')),
                                  Text(datePart,
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontFamily: 'SF Pro Display')),
                                ],
                              ),
                            ),
                            Text(
                              log['skipped'] == true
                                  ? 'SKIPPED'
                                  : '${log['done']} DONE',
                              style: TextStyle(
                                color: log['skipped'] == true
                                    ? Colors.orange
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SF Pro Display',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA569BD),
                  ), // ← Added this closing parenthesis
                  child: Text(
                    'CLOSE',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display'),
                  ),
                ), // ← Added this closing parenthesis and comma
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProfileSetupDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onProfileCreated;

  const ProfileSetupDialog({Key? key, required this.onProfileCreated})
      : super(key: key);

  @override
  _ProfileSetupDialogState createState() => _ProfileSetupDialogState();
}

class _ProfileSetupDialogState extends State<ProfileSetupDialog> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  // Form data
  final TextEditingController nameController = TextEditingController();
  DateTime? selectedBirthdate;
  String selectedPersonality = '';
  String selectedReason = '';
  final reasons = [
    {
      'key': 'track',
      'title': 'Track Tasks',
      'desc': 'Stay organized with my work'
    },
    {
      'key': 'discipline',
      'title': 'Add Discipline',
      'desc': 'Build better habits'
    },
    {
      'key': 'motivation',
      'title': 'Get Motivated',
      'desc': 'Finish everything I start'
    },
  ];
  final personalities = [
    {
      'key': 'lazy',
      'title': 'Lazy/Procrastinator',
      'desc': 'I struggle with motivation'
    },
    {
      'key': 'productive',
      'title': 'Productive/Fast',
      'desc': 'I get things done quickly'
    },
    {
      'key': 'enthusiastic',
      'title': 'Enthusiastic',
      'desc': 'I love taking on challenges'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(20),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          children: [
            Text('Welcome to TaskMasture!',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display')),
            SizedBox(height: 20),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => currentPage = page),
                children: [
                  _buildNamePage(),
                  _buildBirthdatePage(),
                  _buildPersonalityPage(),
                  _buildReasonPage(),
                  _buildWelcomePage(),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentPage > 0)
                  TextButton(
                    onPressed: () => _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                    child:
                        Text('Back', style: TextStyle(color: Colors.white70)),
                  )
                else
                  SizedBox(),
                ElevatedButton(
                  onPressed: _handleNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                      currentPage == 4 ? 'Start Using TaskMasture!' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person, color: Colors.blue, size: 64),
        SizedBox(height: 24),
        Text('What\'s your name?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        TextField(
          controller: nameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: TextStyle(color: Colors.white60),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthdatePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cake, color: Colors.blue, size: 64),
        SizedBox(height: 24),
        Text('When were you born?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                  selectedBirthdate != null
                      ? DateFormat('MMMM dd, yyyy').format(selectedBirthdate!)
                      : 'Select your birthdate',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate:
                        DateTime.now().subtract(Duration(days: 365 * 25)),
                    firstDate:
                        DateTime.now().subtract(Duration(days: 365 * 100)),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => selectedBirthdate = date);
                },
                child: Text('Select Date'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.psychology, color: Colors.blue, size: 64),
        SizedBox(height: 24),
        Text('What kind of person are you?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        ...personalities.map(
          (personality) => Container(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              tileColor: selectedPersonality == personality['key']
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.grey[800],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text(personality['title']!,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(personality['desc']!,
                  style: TextStyle(color: Colors.white70)),
              onTap: () =>
                  setState(() => selectedPersonality = personality['key']!),
              leading: Radio<String>(
                value: personality['key']!,
                groupValue: selectedPersonality,
                onChanged: (value) =>
                    setState(() => selectedPersonality = value!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReasonPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.track_changes, color: Colors.blue, size: 64),
        SizedBox(height: 24),
        Text('Why are you using TaskMasture?',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        ...reasons.map(
          (reason) => Container(
            margin: EdgeInsets.only(bottom: 12),
            child: ListTile(
              tileColor: selectedReason == reason['key']
                  ? Colors.blue.withOpacity(0.3)
                  : Colors.grey[800],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              title: Text(reason['title']!,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text(reason['desc']!,
                  style: TextStyle(color: Colors.white70)),
              onTap: () => setState(() => selectedReason = reason['key']!),
              leading: Radio<String>(
                value: reason['key']!,
                groupValue: selectedReason,
                onChanged: (value) => setState(() => selectedReason = value!),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomePage() {
    String personalizedMessage = _getPersonalizedMessage();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.celebration, color: Colors.amber, size: 64),
        SizedBox(height: 24),
        Text('Perfect!',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Text(personalizedMessage,
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              textAlign: TextAlign.center),
        ),
      ],
    );
  }

  String _getPersonalizedMessage() {
    String personalityMsg = '';
    String reasonMsg = '';

    switch (selectedPersonality) {
      case 'lazy':
        personalityMsg =
            "I understand - we all struggle with motivation sometimes. This app is designed just for you!";
        break;
      case 'productive':
        personalityMsg =
            "Awesome! You're already productive - this will make you unstoppable!";
        break;
      case 'enthusiastic':
        personalityMsg =
            "I love your energy! You're going to absolutely crush it with TaskMasture!";
        break;
    }

    switch (selectedReason) {
      case 'track':
        reasonMsg =
            "TaskMasture will keep you organized and on track with all your tasks.";
        break;
      case 'discipline':
        reasonMsg =
            "Perfect! Building discipline is what TaskMasture does best.";
        break;
      case 'motivation':
        reasonMsg =
            "You'll definitely finish everything with our motivation system!";
        break;
    }

    return "$personalityMsg\n\n$reasonMsg\n\nLet's get started on your productivity journey!";
  }

  bool _canProceedToNext() {
    switch (currentPage) {
      case 0:
        return nameController.text.trim().isNotEmpty;
      case 1:
        return selectedBirthdate != null;
      case 2:
        return selectedPersonality.isNotEmpty;
      case 3:
        return selectedReason.isNotEmpty;
      case 4:
        return true;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (currentPage < 4) {
      _pageController.nextPage(
          duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      // Create profile and finish setup
      final profile = {
        'name': nameController.text.trim(),
        'birthdate': selectedBirthdate!.toIso8601String(),
        'personality': selectedPersonality,
        'reason': selectedReason,
        'createdAt': DateTime.now().toIso8601String(),
      };
      widget.onProfileCreated(profile);
      Navigator.of(context).pop();
    }
  }
}

class TaskDetailsDialog extends StatelessWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final Function() onTaskDeleted;

  const TaskDetailsDialog({
    Key? key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskDeleted,
  }) : super(key: key);

  String _getTaskTypeText() {
    if (task.oneTime) return 'One-Time Task';
    if (task.days.every((day) => day)) return 'Daily';
    return 'Custom';
  }

  String _getCustomDaysText() {
    if (task.oneTime || task.days.every((day) => day)) return '';
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final selectedDays = <String>[];
    for (int i = 0; i < task.days.length; i++) {
      if (task.days[i]) selectedDays.add(dayNames[i]);
    }
    return selectedDays.join(', ');
  }

  void _editTask(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
            TaskDialog(
              task: task,
              onTaskAdded: (updatedTask) {
                onTaskUpdated(updatedTask);
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          title: Text('Delete Task',
              style:
                  TextStyle(color: Colors.white, fontFamily: 'SF Pro Display')),
          content: Text('Are you sure you want to delete "${task.name}"?',
              style: TextStyle(
                  color: Colors.white70, fontFamily: 'SF Pro Display')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.white70, fontFamily: 'SF Pro Display')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                onTaskDeleted();
              },
              child: Text('Delete',
                  style: TextStyle(
                      color: Colors.redAccent, fontFamily: 'SF Pro Display')),
            ),
          ],
        );
      },
    );
  }

  String _getSmartInsight() {
    final totalAttempts = task.totalCompletions + task.totalSkips;
    if (totalAttempts == 0)
      return 'No performance data yet - time to start building your streak!';

    final successRate = (task.totalCompletions / totalAttempts * 100).round();

    if (successRate >= 80) {
      return 'Excellent performance! You\'re crushing this task with ${successRate}% success rate.';
    } else if (successRate >= 60) {
      return 'Good consistency with ${successRate}% success rate. Keep it up!';
    } else if (successRate >= 40) {
      return 'Room for improvement. ${successRate}% success rate - consider adjusting the goal or schedule.';
    } else {
      return 'This task seems challenging with ${successRate}% success rate. Consider breaking it down or changing the approach.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text('TASK DETAILS',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'SF Pro Display')),
                  ),
                  SizedBox(height: 20),
                  _buildDetailRow('Title:', task.name),
                  _buildDetailRow('Description:', task.description),
                  _buildDetailRow('Goal Count:', task.goal.toString()),
                  _buildDetailRow('Type:', _getTaskTypeText()),

                  // Priority display
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text('Priority:',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SF Pro Display')),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: task.priorityColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(task.priorityText,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SF Pro Display')),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Enhanced Stats Display
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Performance Stats:',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SF Pro Display')),
                        SizedBox(height: 8),
                        _buildStatRow(
                            'Current Streak:', '🔥 ${task.currentStreak} days'),
                        _buildStatRow(
                            'Best Streak:', '⭐ ${task.bestStreak} days'),
                        _buildStatRow(
                            'Total Completions:', '✅ ${task.totalCompletions}'),
                        _buildStatRow('Total Skips:', '❌ ${task.totalSkips}'),
                        _buildStatRow('XP Value:', '💫 ${task.xpValue} XP'),
                        _buildStatRow('Last Completed:',
                            '📅 ${DateFormat('dd MMM yyyy').format(task.lastCompleted)}'),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),
                  if (_getCustomDaysText().isNotEmpty)
                    _buildDetailRow('Days:', _getCustomDaysText()),
                  _buildDetailRow('Date Added:',
                      DateFormat('dd MMM yyyy').format(task.dateAdded)),
                  _buildDetailRow('Progress:', '${task.done}/${task.goal}'),

                  // Smart Insights
                  if (task.totalCompletions > 0 || task.totalSkips > 0) ...[
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFF2E2E2E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology,
                                  color: Colors.blue, size: 16),
                              SizedBox(width: 6),
                              Text('Smart Insights:',
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'SF Pro Display')),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(_getSmartInsight(),
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontFamily: 'SF Pro Display')),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('OK',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _editTask(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Edit',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _deleteTask(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Delete',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'SF Pro Display')),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'SF Pro Display')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'SF Pro Display')),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SF Pro Display')),
        ],
      ),
    );
  }
}

class TaskDialog extends StatefulWidget {
  final Function(Task) onTaskAdded;
  final Task? task;
  final Map<String, dynamic>? draftData;
  final Function(Map<String, dynamic>)? onDraftSaved;

  const TaskDialog({
    Key? key,
    required this.onTaskAdded,
    this.task,
    this.draftData,
    this.onDraftSaved,
  }) : super(key: key);

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  String selectedType = 'One-Time Task';
  final taskTypes = ['One-Time Task', 'Daily', 'Custom'];
  List<bool> customDays = List.filled(7, false);
  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  TaskPriority selectedPriority = TaskPriority.B;
  final priorityOptions = [
    TaskPriority.SSS,
    TaskPriority.SS,
    TaskPriority.S,
    TaskPriority.A,
    TaskPriority.B
  ];

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.SSS:
        return Color(0xFFFF0000);
      case TaskPriority.SS:
        return Color(0xFFFF6600);
      case TaskPriority.S:
        return Color(0xFFFFCC00);
      case TaskPriority.A:
        return Color(0xFF00CC00);
      case TaskPriority.B:
        return Color(0xFF0099FF);
    }
  }

  String _getPriorityDescription(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.SSS:
        return 'Ultra Critical - 50 base XP + streak bonus';
      case TaskPriority.SS:
        return 'Critical - 40 base XP + streak bonus';
      case TaskPriority.S:
        return 'Important - 30 base XP + streak bonus';
      case TaskPriority.A:
        return 'Medium - 20 base XP + streak bonus';
      case TaskPriority.B:
        return 'Low - 10 base XP + streak bonus';
    }
  }

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      nameController.text = widget.task!.name;
      descriptionController.text = widget.task!.description;
      goalController.text = widget.task!.goal.toString();
      selectedPriority = widget.task!.priority;

      if (widget.task!.oneTime) {
        selectedType = 'One-Time Task';
      } else if (widget.task!.days.every((day) => day)) {
        selectedType = 'Daily';
      } else {
        selectedType = 'Custom';
        customDays = List.from(widget.task!.days);
      }
    } else if (widget.draftData != null && widget.draftData!.isNotEmpty) {
      nameController.text = widget.draftData!['name'] ?? '';
      descriptionController.text = widget.draftData!['description'] ?? '';
      goalController.text = widget.draftData!['goal']?.toString() ?? '';
      selectedType = widget.draftData!['type'] ?? 'One-Time Task';

      if (widget.draftData!['priority'] != null) {
        selectedPriority = _stringToPriority(widget.draftData!['priority']);
      }

      if (widget.draftData!['customDays'] != null) {
        customDays = List<bool>.from(widget.draftData!['customDays']);
      }
    }

    //nameController.addListener(_saveDraft);
    // descriptionController.addListener(_saveDraft);
    //  goalController.addListener(_saveDraft);
  }

  void _saveDraft() {
    if (widget.onDraftSaved != null) {
      final draftData = {
        'name': nameController.text,
        'description': descriptionController.text,
        'goal': goalController.text,
        'type': selectedType,
        'priority': selectedPriority.toString().split('.').last,
        'customDays': customDays,
      };
      widget.onDraftSaved!(draftData);
    }
  }

  TaskPriority _stringToPriority(String priorityString) {
    switch (priorityString) {
      case 'SSS':
        return TaskPriority.SSS;
      case 'SS':
        return TaskPriority.SS;
      case 'S':
        return TaskPriority.S;
      case 'A':
        return TaskPriority.A;
      case 'B':
      default:
        return TaskPriority.B;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    goalController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    return nameController.text.trim().isNotEmpty &&
        descriptionController.text.trim().isNotEmpty;
  }

  int _getEstimatedXP() {
    int baseXP = switch (selectedPriority) {
      TaskPriority.SSS => 50,
      TaskPriority.SS => 40,
      TaskPriority.S => 30,
      TaskPriority.A => 20,
      TaskPriority.B => 10,
    };
    return baseXP;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(20),
          child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.task != null ? 'EDIT TASK' : 'ADD TASK',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'SF Pro Display'),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'SF Pro Display'),
                    decoration: InputDecoration(
                      hintText: 'Task Name',
                      hintStyle: TextStyle(
                          color: Colors.white60, fontFamily: 'SF Pro Display'),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.redAccent, width: 2)),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),

                  SizedBox(height: 15),
                  TextField(
                    controller: descriptionController,
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'SF Pro Display'),
                    decoration: InputDecoration(
                      hintText: 'Task Description',
                      hintStyle: TextStyle(
                          color: Colors.white60, fontFamily: 'SF Pro Display'),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.redAccent, width: 2)),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),

                  SizedBox(height: 15),
                  TextField(
                    controller: goalController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'SF Pro Display'),
                    decoration: InputDecoration(
                      hintText: 'Goal Count (default: 1)',
                      hintStyle: TextStyle(
                          color: Colors.white60, fontFamily: 'SF Pro Display'),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.redAccent, width: 2)),
                    ),
                  ),

                  SizedBox(height: 15), // Enhanced Priority Dropdown
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Priority Level:',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'SF Pro Display')),
                        SizedBox(height: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<TaskPriority>(
                            value: selectedPriority,
                            dropdownColor: Colors.grey[800],
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SF Pro Display'),
                            isExpanded: true,
                            items: priorityOptions.map((TaskPriority priority) {
                              return DropdownMenuItem<TaskPriority>(
                                value: priority,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: _getPriorityColor(priority),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                          'Priority ${priority.toString().split('.').last}',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'SF Pro Display')),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (TaskPriority? newValue) {
                              setState(() {
                                selectedPriority = newValue!;
                                _saveDraft();
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(selectedPriority)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _getPriorityColor(selectedPriority)
                                    .withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getPriorityDescription(selectedPriority),
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontFamily: 'SF Pro Display')),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber, size: 14),
                                  SizedBox(width: 4),
                                  Text('Base XP: ${_getEstimatedXP()}',
                                      style: TextStyle(
                                          color: Colors.amber,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'SF Pro Display')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedType,
                        dropdownColor: Colors.grey[800],
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'SF Pro Display'),
                        isExpanded: true,
                        items: taskTypes.map((String type) {
                          return DropdownMenuItem<String>(
                              value: type,
                              child: Text(type,
                                  style:
                                      TextStyle(fontFamily: 'SF Pro Display')));
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedType = newValue!;
                            if (selectedType == 'Custom') {
                              if (widget.task == null &&
                                  (widget.draftData == null ||
                                      widget.draftData!.isEmpty)) {
                                customDays = List.filled(7, false);
                              }
                            }
                            _saveDraft();
                          });
                        },
                      ),
                    ),
                  ),

                  if (selectedType == 'Custom') ...[
                    SizedBox(height: 15),
                    Text('Select Days:',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'SF Pro Display')),
                    SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: List.generate(7, (index) {
                        return FilterChip(
                          label: Text(dayNames[index],
                              style: TextStyle(
                                  color: customDays[index]
                                      ? Colors.white
                                      : Colors.white70,
                                  fontFamily: 'SF Pro Display')),
                          selected: customDays[index],
                          onSelected: (bool selected) {
                            setState(() {
                              customDays[index] = selected;
                              _saveDraft();
                            });
                          },
                          selectedColor: Colors.redAccent,
                          backgroundColor: Colors.grey[700],
                          checkmarkColor: Colors.white,
                        );
                      }),
                    ),
                  ],

                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('Cancel',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _canProceed()
                              ? () {
                                  List<bool> taskDays = List.filled(7, false);
                                  bool isOneTime =
                                      selectedType == 'One-Time Task';

                                  if (selectedType == 'Daily') {
                                    taskDays = List.filled(7, true);
                                  } else if (selectedType == 'Custom') {
                                    taskDays = List.from(customDays);
                                  }

                                  final task = Task(
                                    name: nameController.text.trim(),
                                    description:
                                        descriptionController.text.trim(),
                                    goal:
                                        int.tryParse(goalController.text) ?? 1,
                                    oneTime: isOneTime,
                                    days: taskDays,
                                    done: widget.task?.done ?? 0,
                                    dateAdded: widget.task?.dateAdded ??
                                        DateTime.now(),
                                    priority: selectedPriority,
                                    currentStreak:
                                        widget.task?.currentStreak ?? 0,
                                    bestStreak: widget.task?.bestStreak ?? 0,
                                    totalCompletions:
                                        widget.task?.totalCompletions ?? 0,
                                    totalSkips: widget.task?.totalSkips ?? 0,
                                    lastCompleted: widget.task?.lastCompleted,
                                    lastInteraction:
                                        widget.task?.lastInteraction,
                                    failurePattern: widget.task?.failurePattern,
                                    smartSuggestionShown:
                                        widget.task?.smartSuggestionShown ??
                                            false,
                                  );

                                  widget.onTaskAdded(task);
                                  Navigator.of(context).pop();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canProceed()
                                ? Colors.redAccent
                                : Colors.grey[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text('OK',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'SF Pro Display')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
} // Enhanced utility function for quotes

String getQuoteFromFile() {
  try {
    final file = File('assets/quotes/quotes.txt');
    if (!file.existsSync()) {
      // Enhanced fallback quotes for production
      final fallbackQuotes = [
        'Stay consistent.',
        'Build momentum.',
        'Progress over perfection.',
        'Small steps, big results.',
        'Consistency is key.',
        'Every day counts.',
        'You got this.',
        'Keep pushing forward.',
        'Excellence is a habit.',
        'Success is showing up.',
        'One task at a time.',
        'Discipline equals freedom.',
        'Action creates clarity.',
        'Commitment drives results.',
        'Focus on the process.',
        'Growth through challenge.',
        'Persistence pays off.',
        'Quality over quantity.',
        'Start where you are.',
        'Progress not perfection.'
      ];
      final random = Random();
      return fallbackQuotes[random.nextInt(fallbackQuotes.length)];
    }

    final lines = file.readAsLinesSync();
    if (lines.isEmpty) return 'Stay consistent.';
    final random = Random();
    return lines[random.nextInt(lines.length)];
  } catch (e) {
    print('Error reading quotes file: $e');
    return 'Keep pushing forward.';
  }
}

// Debug logging function for production
void logDebug(String message) {
  // Only log in debug mode
  assert(() {
    print('[TaskMasture Debug] $message');
    return true;
  }());
}

// Production-ready error handling
void handleError(String context, dynamic error) {
  print('Error in $context: $error');
  // In production, you might want to send this to a crash reporting service
}

// Performance monitoring
class PerformanceMonitor {
  static final Map<String, DateTime> _startTimes = {};

  static void startTimer(String operation) {
    _startTimes[operation] = DateTime.now();
  }

  static void endTimer(String operation) {
    final startTime = _startTimes[operation];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      logDebug('$operation took ${duration.inMilliseconds}ms');
      _startTimes.remove(operation);
    }
  }
}

// Analytics helper
class AnalyticsHelper {
  static Map<String, dynamic> getSessionStats(List<Task> tasks) {
    final completedToday = tasks.where((task) => task.done >= task.goal).length;
    final totalTasks = tasks.length;
    final activeStreaks = tasks.where((task) => task.currentStreak > 0).length;
    final totalXP = tasks.fold(0, (sum, task) => sum + task.xpValue);

    return {
      'completedToday': completedToday,
      'totalTasks': totalTasks,
      'completionRate': totalTasks > 0 ? (completedToday / totalTasks) : 0.0,
      'activeStreaks': activeStreaks,
      'totalPotentialXP': totalXP,
      'sessionStartTime': DateTime.now().toIso8601String(),
    };
  }

  static String generateSessionReport(Map<String, dynamic> stats) {
    final completionRate = (stats['completionRate'] * 100).round();
    return '''
=== TaskMasture Session Report ===
Tasks Completed: ${stats['completedToday']}/${stats['totalTasks']}
Completion Rate: $completionRate%
Active Streaks: ${stats['activeStreaks']}
Potential XP: ${stats['totalPotentialXP']}
Session Time: ${stats['sessionStartTime']}
==================================
''';
  }
}

// Production-ready constants
class AppConstants {
  static const String appName = 'TaskMasture';
  static const String version = '1.0.0';
  static const String dataFileName = 'task_data.json';
  static const String quotesFileName = 'assets/quotes/quotes.txt';
  static const String backupDirectory = 'backups';

  // XP Constants
  static const Map<TaskPriority, int> baseXPValues = {
    TaskPriority.SSS: 50,
    TaskPriority.SS: 40,
    TaskPriority.S: 30,
    TaskPriority.A: 20,
    TaskPriority.B: 10,
  };

  // Timing Constants
  static const int autoResetCheckMinutes = 1;
  static const int smartSuggestionCheckMinutes = 5;
  static const int cleanupCheckHours = 24;
  static const int archiveDelayHours = 24;
  static const int inactiveTaskDays = 14;

  // UI Constants
  static const double windowWidth = 393;
  static const double windowHeight = 852;
  static const int maxTaskListHeight = 500;

  // Performance Constants
  static const int maxFailurePatternEntries = 10;
  static const int maxDailyLogsEntries = 365; // Keep one year of logs
}

// Enhanced validation helper
class ValidationHelper {
  static bool isValidTaskName(String name) {
    return name.trim().isNotEmpty && name.length <= 100;
  }

  static bool isValidTaskDescription(String description) {
    return description.trim().isNotEmpty && description.length <= 500;
  }

  static bool isValidGoal(int goal) {
    return goal > 0 && goal <= 1000;
  }

  static String? validateTask(String name, String description, int goal) {
    if (!isValidTaskName(name)) {
      return 'Task name must be 1-100 characters';
    }
    if (!isValidTaskDescription(description)) {
      return 'Description must be 1-500 characters';
    }
    if (!isValidGoal(goal)) {
      return 'Goal must be between 1 and 1000';
    }
    return null;
  }
}
