import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String prefConfigJsonPath = 'config_json_path';
const String prefSapshcutExePath = 'sapshcut_exe_path';

/// Default when [prefSapshcutExePath] is not set in preferences.
const String defaultSapshcutExePath =
    r'C:\Program Files (x86)\SAP\FrontEnd\SAPgui\sapshcut.exe';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _pathController = TextEditingController();
  final TextEditingController _sapshcutController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _pathController.text = prefs.getString(prefConfigJsonPath) ?? '';
    _sapshcutController.text =
        prefs.getString(prefSapshcutExePath) ?? defaultSapshcutExePath;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final path = _pathController.text.trim();
    if (path.isEmpty) {
      await prefs.remove(prefConfigJsonPath);
    } else {
      await prefs.setString(prefConfigJsonPath, path);
    }
    var sap = _sapshcutController.text.trim();
    if (sap.isEmpty) {
      await prefs.remove(prefSapshcutExePath);
      _sapshcutController.text = defaultSapshcutExePath;
    } else if (sap == defaultSapshcutExePath) {
      await prefs.remove(prefSapshcutExePath);
    } else {
      await prefs.setString(prefSapshcutExePath, sap);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved.')),
      );
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _pickJsonFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['json'],
        dialogTitle: 'Choose configuration JSON file',
        withData: false,
        lockParentWindow: true,
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path != null && path.isNotEmpty) {
        setState(() => _pathController.text = path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Could not get a file path on this platform.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File picker: $e')),
        );
      }
    }
  }

  Future<void> _pickSapshcutExe() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['exe'],
        dialogTitle: 'Choose sapshcut.exe',
        withData: false,
        lockParentWindow: true,
      );
      if (!mounted) return;
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path != null && path.isNotEmpty) {
        setState(() => _sapshcutController.text = path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get a file path on this platform.'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File picker: $e')),
        );
      }
    }
  }

  Future<void> _clearPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefConfigJsonPath);
    _pathController.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Path cleared: using the built-in configuration file.')),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    _sapshcutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'sapshcut.exe',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _sapshcutController,
                          decoration: const InputDecoration(
                            hintText: 'Full path to sapshcut.exe',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Browse…',
                        child: IconButton(
                          icon: const Icon(Icons.insert_drive_file_outlined),
                          onPressed: _pickSapshcutExe,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                      children: [
                        TextSpan(text: 'Default: '),
                        TextSpan(text: defaultSapshcutExePath),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Configuration file (JSON)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pathController,
                          decoration: const InputDecoration(
                            hintText:
                                'Absolute path to your .json (empty = built-in file)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: 'Browse…',
                        child: IconButton(
                          icon: const Icon(Icons.folder_open_outlined),
                          onPressed: _pickJsonFile,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sample: see assets/environments_example.json in the project.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _clearPath,
                    child: const Text('Reset (built-in file)'),
                  ),
                ],
              ),
            ),
    );
  }
}
