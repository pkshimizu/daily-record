import 'package:daily_record/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

/// アプリケーションのメインエントリーポイント
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP');
  runApp(const MyApp());
}

/// メインアプリケーション
class MyApp extends StatelessWidget {
  /// コンストラクタ
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Daily Record',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const MyHomePage(title: 'Daily Record'),
  );
}

/// ホームページ
class MyHomePage extends StatefulWidget {
  /// コンストラクタ
  const MyHomePage({required this.title, super.key});

  /// ページタイトル
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// ホームページの状態
class _MyHomePageState extends State<MyHomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(widget.title),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed:
              () => Navigator.push(
                context,
                MaterialPageRoute<SettingsPage>(
                  builder: (context) => const SettingsPage(),
                ),
              ),
        ),
      ],
    ),
    body: TableCalendar<Event>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      eventLoader: _getEventsForDay,
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddEventDialog,
      child: const Icon(Icons.add),
    ),
  );

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  List<Event> _getEventsForDay(DateTime day) => <Event>[];

  void _showAddEventDialog() {
    showDialog<void>(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: const Text('Add Event'),
            content: const TextField(
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}

/// イベントクラス
class Event {
  /// コンストラクタ
  const Event(this.title);

  /// イベントタイトル
  final String title;
}
