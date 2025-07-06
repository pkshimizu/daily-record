import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

/// GitHub APIとの通信を担当するデータソース
class GitHubApiDataSource {
  static const String _baseUrl = 'https://api.github.com';

  /// トークンの形式が有効かどうかをチェック
  bool _isValidTokenFormat(String token) {
    // GitHub Personal Access Tokenの形式をチェック
    // ghp_ で始まるトークン（長さは可変）
    final tokenPattern = RegExp(r'^ghp_[a-zA-Z0-9]+$');
    final isValid = tokenPattern.hasMatch(token.trim());
    developer.log(
      'Token format check: $isValid for token: ${token.substring(0, 10)}...',
      name: 'GitHubApiDataSource',
    );
    return isValid;
  }

  /// GitHubトークンの有効性を検証
  Future<bool> validateToken(String token) async {
    try {
      developer.log(
        'Starting GitHub token validation...',
        name: 'GitHubApiDataSource',
      );

      // トークンの形式をチェック
      if (!_isValidTokenFormat(token)) {
        developer.log(
          'Token format validation failed',
          name: 'GitHubApiDataSource',
        );
        return false;
      }

      final trimmedToken = token.trim();
      developer.log(
        'Making API request to $_baseUrl/user',
        name: 'GitHubApiDataSource',
      );

      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Authorization': 'token $trimmedToken',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'DailyRecord/1.0',
        },
      );

      developer.log(
        'API Response Status: ${response.statusCode}',
        name: 'GitHubApiDataSource',
      );
      developer.log(
        'API Response Headers: ${response.headers}',
        name: 'GitHubApiDataSource',
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body) as Map<String, dynamic>;
        developer.log(
          'User data received: ${userData['login']}',
          name: 'GitHubApiDataSource',
        );
        return true;
      } else {
        developer.log(
          'API Error Response: ${response.body}',
          name: 'GitHubApiDataSource',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        'Token validation exception: $e',
        name: 'GitHubApiDataSource',
      );
      return false;
    }
  }

  /// GitHubユーザー情報を取得
  Future<Map<String, dynamic>?> getUserInfo(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'DailyRecord/1.0',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// リポジトリの存在を確認
  Future<bool> validateRepository(
    String token,
    String username,
    String repository,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$username/$repository'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// ファイルを作成
  Future<bool> createFile(
    String token,
    String username,
    String repository,
    String path,
    String content,
    String message,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/repos/$username/$repository/contents/$path'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': message,
          'content': base64Encode(utf8.encode(content)),
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// ファイルの内容を取得
  Future<String?> getFileContent(
    String token,
    String username,
    String repository,
    String path,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/repos/$username/$repository/contents/$path'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['content'] != null) {
          return utf8.decode(base64Decode(data['content'] as String));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// ユーザーアクティビティを取得
  Future<List<Map<String, dynamic>>> getUserActivity(
    String token,
    DateTime date,
  ) async {
    try {
      developer.log(
        'Fetching user activity for date: ${date.toIso8601String()}',
        name: 'GitHubApiDataSource',
      );

      // 指定された日付の範囲でイベントを取得
      final startDate = DateTime(date.year, date.month, date.day);
      final endDate = startDate.add(const Duration(days: 1));

      final response = await http.get(
        Uri.parse('$_baseUrl/users/${await _getUsername(token)}/events'),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'DailyRecord/1.0',
        },
      );

      if (response.statusCode == 200) {
        final events = json.decode(response.body) as List<dynamic>;
        final filteredEvents = <Map<String, dynamic>>[];

        for (final event in events) {
          final eventData = event as Map<String, dynamic>;
          final createdAt = DateTime.parse(eventData['created_at'] as String);

          if (createdAt.isAfter(startDate) && createdAt.isBefore(endDate)) {
            filteredEvents.add(eventData);
          }
        }

        developer.log(
          'Found ${filteredEvents.length} events for the specified date',
          name: 'GitHubApiDataSource',
        );

        return filteredEvents;
      } else {
        developer.log(
          'Failed to fetch events: ${response.statusCode}',
          name: 'GitHubApiDataSource',
        );
        return [];
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error fetching user activity: $e',
        name: 'GitHubApiDataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// ユーザー名を取得
  Future<String> _getUsername(String token) async {
    final userInfo = await getUserInfo(token);
    return userInfo?['login'] as String? ?? '';
  }
}
