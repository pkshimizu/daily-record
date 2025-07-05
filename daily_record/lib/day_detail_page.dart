import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DayDetailPage extends StatelessWidget {
  final DateTime selectedDate;

  const DayDetailPage({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年M月d日 (E)', 'ja_JP');
    final formattedDate = dateFormat.format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(formattedDate),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '日付: $formattedDate',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('この日の記録をここに表示します。', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '記録エリア\n\nここにその日の詳細な記録を入力できます。',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
