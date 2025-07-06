import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'data/datasources/github_api_datasource.dart';
import 'data/datasources/settings_local_datasource.dart';
import 'data/repositories/github_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'day_detail_page.dart';
import 'domain/usecases/get_dark_mode_usecase.dart';
import 'domain/usecases/github_usecases.dart';
import 'domain/usecases/set_dark_mode_usecase.dart';
import 'presentation/providers/github_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja_JP', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Settings related providers
        Provider<SettingsLocalDataSource>(
          create: (_) => SettingsLocalDataSource(),
        ),
        Provider<SettingsRepositoryImpl>(
          create:
              (context) => SettingsRepositoryImpl(
                context.read<SettingsLocalDataSource>(),
              ),
        ),
        Provider<GetDarkModeUseCase>(
          create:
              (context) =>
                  GetDarkModeUseCase(context.read<SettingsRepositoryImpl>()),
        ),
        Provider<SetDarkModeUseCase>(
          create:
              (context) =>
                  SetDarkModeUseCase(context.read<SettingsRepositoryImpl>()),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create:
              (context) => SettingsProvider(
                context.read<GetDarkModeUseCase>(),
                context.read<SetDarkModeUseCase>(),
              ),
        ),

        // GitHub related providers
        Provider<GitHubApiDataSource>(create: (_) => GitHubApiDataSource()),
        Provider<GitHubRepositoryImpl>(
          create:
              (context) => GitHubRepositoryImpl(
                context.read<SettingsLocalDataSource>(),
                context.read<GitHubApiDataSource>(),
              ),
        ),
        Provider<GetGitHubSettingsUseCase>(
          create:
              (context) => GetGitHubSettingsUseCase(
                context.read<GitHubRepositoryImpl>(),
              ),
        ),
        Provider<SaveGitHubSettingsUseCase>(
          create:
              (context) => SaveGitHubSettingsUseCase(
                context.read<GitHubRepositoryImpl>(),
              ),
        ),
        Provider<UpdateGitHubEnabledUseCase>(
          create:
              (context) => UpdateGitHubEnabledUseCase(
                context.read<GitHubRepositoryImpl>(),
              ),
        ),
        Provider<ValidateGitHubTokenUseCase>(
          create:
              (context) => ValidateGitHubTokenUseCase(
                context.read<GitHubRepositoryImpl>(),
              ),
        ),
        Provider<GetGitHubUserInfoUseCase>(
          create:
              (context) => GetGitHubUserInfoUseCase(
                context.read<GitHubRepositoryImpl>(),
              ),
        ),

        ChangeNotifierProvider(
          create:
              (context) => GitHubProvider(
                getSettingsUseCase: GetGitHubSettingsUseCase(
                  GitHubRepositoryImpl(
                    SettingsLocalDataSource(),
                    GitHubApiDataSource(),
                  ),
                ),
                saveSettingsUseCase: SaveGitHubSettingsUseCase(
                  GitHubRepositoryImpl(
                    SettingsLocalDataSource(),
                    GitHubApiDataSource(),
                  ),
                ),
                updateEnabledUseCase: UpdateGitHubEnabledUseCase(
                  GitHubRepositoryImpl(
                    SettingsLocalDataSource(),
                    GitHubApiDataSource(),
                  ),
                ),
                validateTokenUseCase: ValidateGitHubTokenUseCase(
                  GitHubRepositoryImpl(
                    SettingsLocalDataSource(),
                    GitHubApiDataSource(),
                  ),
                ),
                getUserInfoUseCase: GetGitHubUserInfoUseCase(
                  GitHubRepositoryImpl(
                    SettingsLocalDataSource(),
                    GitHubApiDataSource(),
                  ),
                ),
              ),
        ),
      ],
      child: const MyAppContent(),
    );
  }
}

class MyAppContent extends StatefulWidget {
  const MyAppContent({super.key});

  @override
  State<MyAppContent> createState() => _MyAppContentState();
}

class _MyAppContentState extends State<MyAppContent> {
  @override
  void initState() {
    super.initState();
    // アプリ起動時にダークモード設定を読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadDarkMode();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: 'Daily Record',
          theme:
              settingsProvider.isDarkMode
                  ? ThemeData.dark()
                  : ThemeData.light(),
          home: const BlankPage(),
        );
      },
    );
  }
}

class BlankPage extends StatefulWidget {
  const BlankPage({super.key});

  @override
  State<BlankPage> createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    // 詳細ページに遷移
    Navigator.push(
      context,
      MaterialPageRoute<DayDetailPage>(
        builder: (context) => DayDetailPage(selectedDate: selectedDay),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Record'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<SettingsPage>(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 月切り替えボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month - 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_focusedDay.year}年${_focusedDay.month}月',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _focusedDay = DateTime(
                        _focusedDay.year,
                        _focusedDay.month + 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // カレンダー
            Expanded(
              child: TableCalendar<void>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.month,
                headerVisible: false,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: _onDaySelected,
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
