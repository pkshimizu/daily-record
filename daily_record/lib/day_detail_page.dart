import 'package:flutter/material.dart';

/// 日付詳細ページ
class DayDetailPage extends StatefulWidget {
  /// コンストラクタ
  const DayDetailPage({required this.selectedDate, super.key});

  /// 選択された日付
  final DateTime selectedDate;

  @override
  State<DayDetailPage> createState() => _DayDetailPageState();
}

/// 日付詳細ページの状態
class _DayDetailPageState extends State<DayDetailPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 内容を読み込み
  Future<void> _loadContent() async {
    // ここでファイルから内容を読み込むロジックを実装
    _textController.text = '${widget.selectedDate}の記録';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        '${widget.selectedDate.year}年'
        '${widget.selectedDate.month}月'
        '${widget.selectedDate.day}日',
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText: '今日の記録を書いてください...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const ElevatedButton(onPressed: null, child: Text('保存')),
        ],
      ),
    ),
  );
}
