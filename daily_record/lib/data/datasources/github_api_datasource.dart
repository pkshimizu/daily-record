import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

class GitHubApiDataSource {
  static const String _baseUrl = 'https://api.github.com';

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
        final userData = json.decode(response.body);
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
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

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
        final data = json.decode(response.body);
        if (data['content'] != null) {
          return utf8.decode(base64Decode(data['content']));
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
