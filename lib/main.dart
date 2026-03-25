// ignore_for_file: unnecessary_string_escapes

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import 'environment_config.dart';
import 'settings_page.dart';

String _prefSameCredsAll(String envId) => 'same_creds_all_$envId';

String _userShared(String envId) => 'user$envId';

String _passwordShared(String envId) => 'password$envId';

String _userPerClient(String envId, String system, String client) =>
    'uc_${envId}_${system}_$client';

String _passwordPerClient(String envId, String system, String client) =>
    'pc_${envId}_${system}_$client';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  runApp(const MyApp());

  if (Platform.isWindows || Platform.isMacOS) {
    doWhenWindowReady(() {
      appWindow
        ..title = 'FastSAP'
        ..minSize = const Size(440, 0)
        ..size = const Size(440, 700)
        ..alignment = Alignment.center
        ..show();
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  static ThemeData _theme() {
    const neutral = Color(0xFF64748B);
    final scheme = ColorScheme.fromSeed(
      seedColor: neutral,
      brightness: Brightness.light,
      surface: const Color(0xFFF1F3F5),
      surfaceContainerLow: Colors.white,
      surfaceContainerHigh: const Color(0xFFE8EAED),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: Color(0xFF1E293B),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: scheme.surfaceContainerLow,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastSAP',
      theme: _theme(),
      home: const MyHomePage(title: 'SAP Launcher'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<SapEnvironment> _environments = [];
  String _language = 'EN';
  String? _loadError;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reloadConfig();
  }

  Future<void> _reloadConfig() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(prefConfigJsonPath);
    try {
      final cfg = await loadEnvironments(path);
      final prefLang = prefs.getString(prefSapConnectionLanguage)?.trim();
      final resolvedLang = (prefLang != null && prefLang.isNotEmpty)
          ? prefLang
          : cfg.language;
      setState(() {
        _environments = cfg.environments;
        _language =
            resolvedLang.isNotEmpty ? resolvedLang : 'EN';
        _loading = false;
      });
    } on EnvironmentConfigException catch (e) {
      setState(() {
        _environments = [];
        _loadError = e.message;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _environments = [];
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openSettings() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
    if (changed == true && mounted) {
      await _reloadConfig();
    }
  }

  Future<void> ouvrirSAP(
    String envId,
    String system,
    String client,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final prefLang = prefs.getString(prefSapConnectionLanguage)?.trim();
    final language = (prefLang != null && prefLang.isNotEmpty)
        ? prefLang
        : _language;

    SapEnvironment? envMatch;
    for (final e in _environments) {
      if (e.id == envId) {
        envMatch = e;
        break;
      }
    }
    final singleClient = envMatch != null && envMatch.clients.length == 1;
    final sameForAll =
        singleClient || (prefs.getBool(_prefSameCredsAll(envId)) ?? true);

    final String? user;
    final String? password;
    if (sameForAll) {
      user = prefs.getString(_userShared(envId));
      password = prefs.getString(_passwordShared(envId));
    } else {
      user = prefs.getString(_userPerClient(envId, system, client));
      password = prefs.getString(_passwordPerClient(envId, system, client));
    }

    if (password == null ||
        password.isEmpty ||
        user == null ||
        user.isEmpty) {
      final hint = sameForAll
          ? envId
          : '$envId / $system / $client';
      throw 'Credentials not configured for $hint';
    }

    if (Platform.isWindows) {
      final custom = prefs.getString(prefSapshcutExePath)?.trim();
      final exePath = (custom == null || custom.isEmpty)
          ? defaultSapshcutExePath
          : custom;
      final exe = File(exePath);
      if (!await exe.exists()) {
        throw 'sapshcut.exe not found: $exePath';
      }
      await Process.run(exePath, [
        '-system=$system',
        '-client=$client',
        '-user=$user',
        '-pw=$password',
        '-language=$language',
      ]);
    } else {
      throw 'This feature is only available on Windows';
    }
  }

  Future<void> _showCredentialsDialog(SapEnvironment env) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _EnvCredentialsDialog(env: env),
    );
  }

  void setWindowEffect(WindowEffect? value) {
    Window.setEffect(
      effect: value!,
    );
  }

  Widget _environmentCard(SapEnvironment env) {
    final theme = Theme.of(context);
    final accent = colorFromHex(env.colorHex);
    final icon = iconFromName(env.iconName);

    return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: theme.colorScheme.surfaceContainerLow,
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 3,
                      color: accent.withValues(alpha: 0.85),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    icon,
                                    size: 18,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    env.title,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: -0.2,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                for (final c in env.clients)
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 6),
                                      child: FilledButton.tonal(
                                        style: FilledButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(34),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                          foregroundColor: const Color(
                                              0xFF334155),
                                          backgroundColor: theme.colorScheme
                                              .surfaceContainerHigh,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () async {
                                          try {
                                            await ouvrirSAP(
                                              env.id,
                                              c.system,
                                              c.client,
                                            );
                                          } catch (e) {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text(e.toString())),
                                              );
                                            }
                                          }
                                        },
                                        child: Text(
                                          c.label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ),
                                IconButton.outlined(
                                  tooltip: 'Credentials',
                                  onPressed: () =>
                                      _showCredentialsDialog(env),
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size(34, 34),
                                    fixedSize: const Size(34, 34),
                                    foregroundColor:
                                        theme.colorScheme.onSurfaceVariant,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(Icons.password, size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _loading
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                : _loadError != null
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 40,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _loadError!,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.tonal(
                              onPressed: _openSettings,
                              child: const Text('Open settings'),
                            ),
                          ],
                        ),
                      )
                    : _environments.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'No environments in the configuration.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(
                                  'Choose a system and client to launch SAP GUI.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                for (final env in _environments) ...[
                                  _environmentCard(env),
                                  const SizedBox(height: 8),
                                ],
                              ],
                            ),
                          ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Text(
              'v2026.03.25 - Antoine WAES',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.75),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> customAnimation() async {
    for (var i = 0; i < 99; i++) {
      WindowsTaskbar.setProgress(i, 120);
      await Future.delayed(const Duration(milliseconds: 10), () {});
    }
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
  }
}

class _EnvCredentialsDialog extends StatefulWidget {
  const _EnvCredentialsDialog({required this.env});

  final SapEnvironment env;

  @override
  State<_EnvCredentialsDialog> createState() => _EnvCredentialsDialogState();
}

class _EnvCredentialsDialogState extends State<_EnvCredentialsDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late bool _sameForAll;
  late int _selectedIndex;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _userController = TextEditingController();
    _passwordController = TextEditingController();
    _selectedIndex = 0;
    _sameForAll = true;
    final multi = widget.env.clients.length > 1;
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() {
        _sameForAll =
            !multi || (prefs.getBool(_prefSameCredsAll(widget.env.id)) ?? true);
        _applyPrefsToControllers(prefs);
        _ready = true;
      });
    });
  }

  void _applyPrefsToControllers(SharedPreferences prefs) {
    final env = widget.env;
    if (_sameForAll || env.clients.length == 1) {
      _userController.text = prefs.getString(_userShared(env.id)) ?? '';
      _passwordController.text = prefs.getString(_passwordShared(env.id)) ?? '';
    } else {
      final c = env.clients[_selectedIndex];
      _userController.text =
          prefs.getString(_userPerClient(env.id, c.system, c.client)) ?? '';
      _passwordController.text = prefs.getString(
            _passwordPerClient(env.id, c.system, c.client),
          ) ??
          '';
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSameForAllChanged(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _sameForAll = value;
      _applyPrefsToControllers(prefs);
    });
  }

  Future<void> _onClientChanged(int? idx) async {
    if (idx == null) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedIndex = idx;
      _applyPrefsToControllers(prefs);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final env = widget.env;
    final user = _userController.text.trim();
    final password = _passwordController.text;

    if (env.clients.length == 1) {
      await prefs.setBool(_prefSameCredsAll(env.id), true);
      await prefs.setString(_userShared(env.id), user);
      await prefs.setString(_passwordShared(env.id), password);
    } else {
      await prefs.setBool(_prefSameCredsAll(env.id), _sameForAll);
      if (_sameForAll) {
        await prefs.setString(_userShared(env.id), user);
        await prefs.setString(_passwordShared(env.id), password);
      } else {
        final c = env.clients[_selectedIndex];
        await prefs.setString(
          _userPerClient(env.id, c.system, c.client),
          user,
        );
        await prefs.setString(
          _passwordPerClient(env.id, c.system, c.client),
          password,
        );
      }
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final env = widget.env;
    final clients = env.clients;
    final multi = clients.length > 1;

    return AlertDialog(
      title: Text(
        'Credentials (${env.id})',
        style: t.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
      content: !_ready
          ? const SizedBox(
              width: 320,
              height: 120,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : Form(
              key: _formKey,
              child: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (multi) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              title: const Text(
                                'Password is the same for all clients',
                                style: TextStyle(fontSize: 13),
                              ),
                              value: _sameForAll,
                              onChanged: (v) {
                                if (v != null) _onSameForAllChanged(v);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: Opacity(
                              opacity: _sameForAll ? 0.45 : 1,
                              child: IgnorePointer(
                                ignoring: _sameForAll,
                                child: DropdownButtonFormField<int>(
                                  isExpanded: true,
                                  // Controlled selection; `value` still required here.
                                  // ignore: deprecated_member_use
                                  value: _selectedIndex,
                                  decoration: const InputDecoration(
                                    labelText: 'Client',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    for (var i = 0; i < clients.length; i++)
                                      DropdownMenuItem(
                                        value: i,
                                        child: Text(
                                          '${clients[i].label} · ${clients[i].system}/${clients[i].client}',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                  onChanged: _sameForAll
                                      ? null
                                      : (idx) => _onClientChanged(idx),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    TextFormField(
                      controller: _userController,
                      decoration: const InputDecoration(
                        labelText: 'User',
                        hintText: 'SAP user',
                      ),
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'User is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                      ),
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _ready ? () => _save() : null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
