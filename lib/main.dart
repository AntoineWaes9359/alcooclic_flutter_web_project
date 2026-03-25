// ignore_for_file: unnecessary_string_escapes

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import 'environment_config.dart';
import 'settings_page.dart';

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
      setState(() {
        _environments = cfg.environments;
        _language = cfg.language;
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
    String credentialId,
    String system,
    String client,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final password = prefs.getString('password$credentialId');
    final user = prefs.getString('user$credentialId');

    if (password == null || user == null) {
      throw 'Credentials not configured for $credentialId';
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
        '-language=$_language',
      ]);
    } else {
      throw 'This feature is only available on Windows';
    }
  }

  Future<void> sauvegarderPassword(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _showCredentialsDialog(String credentialId) async {
    late String passwordEntered;
    late String userEntered;
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final t = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Credentials ($credentialId)',
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onChanged: (value) => userEntered = value,
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
                    onChanged: (value) => passwordEntered = value,
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
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  await sauvegarderPassword('user$credentialId', userEntered);
                  await sauvegarderPassword(
                      'password$credentialId', passwordEntered);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
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
                                      _showCredentialsDialog(env.id),
                                  style: IconButton.styleFrom(
                                    minimumSize: const Size(34, 34),
                                    fixedSize: const Size(34, 34),
                                    foregroundColor:
                                        theme.colorScheme.onSurfaceVariant,
                                    padding: EdgeInsets.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(Icons.tune_rounded, size: 18),
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
      body: _loading
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
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
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
