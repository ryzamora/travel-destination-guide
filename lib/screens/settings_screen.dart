import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/app_theme.dart';
import '../utils/pwa_interop.dart';
import '../widgets/section_header.dart';

/// Settings page of the Travel Destination Guide.
///
/// Shows the Live Website link, the offline availability of the app and the
/// install / uninstall actions of the Progressive Web App version.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// The deployed website (GitHub Pages) opened by the Live Website option.
  static const String liveWebsiteUrl =
      'https://ryzamora.github.io/travel-destination-guide/';

  bool _online = true;
  bool _installAvailable = false;
  bool _standalone = false;
  bool _offlineReady = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _online = pwaIsOnline();
    _installAvailable = pwaIsInstallAvailable();
    _standalone = pwaIsStandalone();

    pwaInit(
      onInstallChanged: (bool available) {
        if (!mounted) return;
        setState(() => _installAvailable = available);
      },
      onNetworkChanged: (bool online) {
        if (!mounted) return;
        setState(() => _online = online);
      },
    );

    _refreshStatus();
  }

  Future<void> _refreshStatus() async {
    final bool ready = await pwaServiceWorkerReady();
    if (!mounted) return;
    setState(() {
      _offlineReady = ready;
      _standalone = pwaIsStandalone();
      _installAvailable = pwaIsInstallAvailable();
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openLiveWebsite() async {
    final Uri uri = Uri.parse(liveWebsiteUrl);
    bool opened = false;

    try {
      opened = await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (_) {
      opened = false;
    }

    if (!opened) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }

    if (!opened) _snack('Could not open the Live Website.');
  }

  Future<void> _installApp() async {
    if (_busy) return;
    setState(() => _busy = true);

    final bool accepted = await pwaPromptInstall();
    if (!mounted) return;

    setState(() => _busy = false);
    if (accepted) {
      _snack('Installing Travel Destination Guide...');
    } else {
      _snack(
        'Install prompt is not available right now. '
        'Use your browser menu: Install app.',
      );
    }
    await _refreshStatus();
  }

  Future<void> _setOfflineAvailability(bool enabled) async {
    if (_busy) return;
    setState(() => _busy = true);

    if (enabled) {
      await pwaRegisterServiceWorker('sw.js');
    } else {
      await pwaClearOfflineData();
    }

    if (!mounted) return;
    setState(() => _busy = false);
    await _refreshStatus();
    _snack(
      enabled
          ? 'Destinations are now saved for offline use.'
          : 'Offline copy removed from this device.',
    );
  }

  Future<void> _showUninstallHelp() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Uninstall app'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Remove the app from your device:'),
                const SizedBox(height: 10),
                _bullet(
                  'Windows / Mac: right-click the app in the Start menu or '
                  'Dock and choose Remove or Uninstall.',
                ),
                _bullet(
                  'Android: Chrome menu > Installed apps > Travel Destination '
                  'Guide > Remove.',
                ),
                _bullet(
                  'iPhone / iPad: touch and hold the app icon, then tap '
                  'Remove App.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'You can also delete the offline data the app saved on '
                  'this device:',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                final bool removed = await pwaClearOfflineData();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                await _refreshStatus();
                _snack(
                  removed
                      ? 'Offline data removed from this device.'
                      : 'No offline data was found.',
                );
              },
              child: const Text('Remove offline data'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.fiber_manual_record, size: 6),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _section(String title, String caption, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: SectionHeader(icon: icon, title: title, caption: caption),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: <Widget>[
                _section(
                  'Live Website',
                  'Open the deployed web version',
                  Icons.language,
                ),
                Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.public,
                        color: AppTheme.primary,
                      ),
                    ),
                    title: const Text('Live Website'),
                    subtitle: Text(
                      liveWebsiteUrl,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.open_in_new, size: 20),
                    onTap: _openLiveWebsite,
                  ),
                ),
                if (kIsWeb) ...<Widget>[
                  _section(
                    'Offline availability',
                    'Use the app without internet',
                    Icons.cloud_outlined,
                  ),
                  Card(
                    child: Column(
                      children: <Widget>[
                        SwitchListTile(
                          value: _offlineReady,
                          onChanged: _busy ? null : _setOfflineAvailability,
                          secondary: Icon(
                            _offlineReady
                                ? Icons.cloud_done_outlined
                                : Icons.cloud_off_outlined,
                            color: _offlineReady
                                ? AppTheme.primary
                                : Colors.grey.shade600,
                          ),
                          title: const Text('Save app for offline use'),
                          subtitle: Text(
                            _offlineReady
                                ? 'All destinations, images and travel tips '
                                    'are stored on this device.'
                                : 'Turn on to cache every destination so the '
                                    'app opens without internet.',
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                          child: Row(
                            children: <Widget>[
                              _statusChip(
                                label: _online ? 'Online' : 'Offline',
                                icon: _online
                                    ? Icons.wifi
                                    : Icons.wifi_off,
                                color: _online
                                    ? AppTheme.primary
                                    : const Color(0xFFC0392B),
                              ),
                              const SizedBox(width: 8),
                              _statusChip(
                                label: _offlineReady
                                    ? 'Offline copy ready'
                                    : 'Offline copy not saved',
                                icon: _offlineReady
                                    ? Icons.check_circle_outline
                                    : Icons.history_toggle_off,
                                color: _offlineReady
                                    ? AppTheme.primary
                                    : Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (kIsWeb && !_standalone) ...<Widget>[
                  _section(
                    'App installation',
                    'Install the guide on this device',
                    Icons.phone_iphone,
                  ),
                  Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.download_outlined,
                          color: Color(0xFFB0701C),
                        ),
                      ),
                      title: const Text('Install App'),
                      subtitle: Text(
                        _installAvailable
                            ? 'Add the Travel Destination Guide to your '
                                'home screen or taskbar.'
                            : 'Open your browser menu and choose '
                                '"Install app" to add it to this device.',
                      ),
                      trailing: ElevatedButton(
                        onPressed:
                            (_installAvailable && !_busy) ? _installApp : null,
                        child: const Text('Install'),
                      ),
                    ),
                  ),
                ],
                if (kIsWeb && _standalone) ...<Widget>[
                  _section(
                    'App installation',
                    'Remove the installed app',
                    Icons.phone_iphone,
                  ),
                  Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0392B).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.remove_circle_outline,
                          color: Color(0xFFC0392B),
                        ),
                      ),
                      title: const Text('Uninstall App'),
                      subtitle: const Text(
                        'Remove the app and its saved offline data from '
                        'this device.',
                      ),
                      trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: _showUninstallHelp,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
