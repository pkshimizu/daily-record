import 'package:daily_record/data/datasources/github_api_datasource.dart';
import 'package:daily_record/data/datasources/settings_local_datasource.dart';
import 'package:daily_record/data/repositories/github_repository_impl.dart';
import 'package:daily_record/data/repositories/settings_repository_impl.dart';
import 'package:daily_record/day_detail_page.dart';
import 'package:daily_record/domain/repositories/github_repository.dart';
import 'package:daily_record/domain/repositories/settings_repository.dart';
import 'package:daily_record/presentation/providers/github_provider.dart';
import 'package:daily_record/presentation/providers/settings_provider.dart';
import 'package:daily_record/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
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
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      // Data sources
      Provider<SettingsLocalDataSource>(
        create: (_) => SettingsLocalDataSource(),
      ),
      Provider<GitHubApiDataSource>(create: (_) => GitHubApiDataSource()),
      // Repositories
      Provider<SettingsRepository>(
        create:
            (context) =>
                SettingsRepositoryImpl(context.read<SettingsLocalDataSource>()),
      ),
      Provider<GitHubRepository>(
        create:
            (context) => GitHubRepositoryImpl(
              context.read<SettingsLocalDataSource>(),
              context.read<GitHubApiDataSource>(),
            ),
      ),
      // Providers
      ChangeNotifierProvider<SettingsProvider>(
        create:
            (context) => SettingsProvider(context.read<SettingsRepository>()),
      ),
      ChangeNotifierProvider<GitHubProvider>(
        create: (context) => GitHubProvider(context.read<GitHubRepository>()),
      ),
    ],
    child: Consumer<SettingsProvider>(
      builder:
          (context, settingsProvider, child) => MaterialApp(
            title: 'Daily Record',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            themeMode:
                settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MyHomePage(title: 'Daily Record'),
          ),
    ),
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
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

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
      availableCalendarFormats: const {CalendarFormat.month: 'Month'},
      onDaySelected: _onDaySelected,
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddEventDialog,
      child: const Icon(Icons.add),
    ),
  );

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });

    // 日付詳細ページに遷移
    Navigator.push(
      context,
      MaterialPageRoute<DayDetailPage>(
        builder: (context) => DayDetailPage(selectedDate: selectedDay),
      ),
    );
  }

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
