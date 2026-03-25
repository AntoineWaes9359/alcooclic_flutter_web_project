import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SapClientSlot {
  SapClientSlot({
    required this.label,
    required this.system,
    required this.client,
  });

  final String label;
  /// SAP system / SID passed to `-system=`.
  final String system;
  /// SAP client number passed to `-client=`.
  final String client;
}

class SapEnvironment {
  SapEnvironment({
    required this.id,
    required this.title,
    required this.host,
    required this.iconName,
    required this.colorHex,
    required this.clients,
  });

  final String id;
  final String title;
  final String host;
  final String iconName;
  final String colorHex;
  final List<SapClientSlot> clients;
}

class LoadedEnvironmentConfig {
  LoadedEnvironmentConfig({
    required this.environments,
    this.language = 'EN',
  });

  final List<SapEnvironment> environments;
  final String language;
}

class EnvironmentConfigException implements Exception {
  EnvironmentConfigException(this.message);
  final String message;

  @override
  String toString() => message;
}

LoadedEnvironmentConfig parseEnvironmentsJson(String raw) {
  final dynamic decoded = jsonDecode(raw);
  if (decoded is! Map<String, dynamic>) {
    throw EnvironmentConfigException('Invalid JSON root (object expected).');
  }
  final langRaw = decoded['language'];
  final language = (langRaw is String && langRaw.trim().isNotEmpty)
      ? langRaw.trim()
      : 'EN';

  final envs = decoded['environments'];
  if (envs is! List) {
    throw EnvironmentConfigException(
        'Missing or invalid "environments" key.');
  }
  final out = <SapEnvironment>[];
  for (var i = 0; i < envs.length; i++) {
    final item = envs[i];
    if (item is! Map<String, dynamic>) {
      throw EnvironmentConfigException('Environment #$i: object expected.');
    }
    final id = item['id'] as String?;
    final title = item['title'] as String?;
    final host = item['host'] as String?;
    final iconName = item['icon'] as String? ?? 'settings';
    final colorHex = item['color'] as String? ?? '#757575';
    if (id == null || id.isEmpty) {
      throw EnvironmentConfigException('Environment #$i: "id" is required.');
    }
    if (title == null || title.isEmpty) {
      throw EnvironmentConfigException(
          'Environment #$i: "title" is required.');
    }
    if (host == null || host.isEmpty) {
      throw EnvironmentConfigException('Environment #$i: "host" is required.');
    }
    final clients = <SapClientSlot>[];
    for (final key in ['client1', 'client2', 'client3']) {
      final slot = item[key];
      if (slot == null) continue;
      if (slot is! Map<String, dynamic>) {
        throw EnvironmentConfigException(
            'Environment "$id": "$key" must be an object or null.');
      }
      final label = slot['label'] as String?;
      final system = slot['system'] as String?;
      final client = slot['client'] as String?;
      if (label == null ||
          label.isEmpty ||
          system == null ||
          system.isEmpty ||
          client == null ||
          client.isEmpty) {
        throw EnvironmentConfigException(
            'Environment "$id": "$key" requires "label", "system", and "client".');
      }
      clients.add(SapClientSlot(label: label, system: system, client: client));
    }
    if (clients.isEmpty) {
      throw EnvironmentConfigException(
          'Environment "$id": at least one of client1, client2, client3 is required.');
    }
    out.add(SapEnvironment(
      id: id,
      title: title,
      host: host,
      iconName: iconName,
      colorHex: colorHex,
      clients: clients,
    ));
  }
  return LoadedEnvironmentConfig(environments: out, language: language);
}

Future<String> loadEnvironmentsRaw(String? customPath) async {
  final trimmed = customPath?.trim();
  if (trimmed != null && trimmed.isNotEmpty) {
    final file = File(trimmed);
    if (!await file.exists()) {
      throw EnvironmentConfigException('File not found: $trimmed');
    }
    return file.readAsString();
  }
  return rootBundle.loadString('assets/environments.json');
}

Future<LoadedEnvironmentConfig> loadEnvironments(String? customPath) async {
  final raw = await loadEnvironmentsRaw(customPath);
  return parseEnvironmentsJson(raw);
}

IconData iconFromName(String name) {
  const map = <String, IconData>{
    'ac_unit_sharp': Icons.ac_unit_sharp,
    'inbox_rounded': Icons.inbox_rounded,
    'hail_outlined': Icons.hail_outlined,
    'accessible': Icons.accessible,
    'wrap_text': Icons.wrap_text,
    'code': Icons.code,
    'settings': Icons.settings,
    'cloud': Icons.cloud,
    'dns': Icons.dns,
    'storage': Icons.storage,
  };
  return map[name] ?? Icons.dns;
}

Color colorFromHex(String hex) {
  var s = hex.replaceAll('#', '');
  if (s.length == 6) {
    s = 'FF$s';
  }
  if (s.length != 8) {
    return Colors.blueGrey;
  }
  return Color(int.parse('0x$s'));
}
