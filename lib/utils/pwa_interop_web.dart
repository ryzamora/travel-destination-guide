import 'dart:js_interop';

/// Web implementation of the PWA helpers.
///
/// All browser access happens in `web/pwa.js`; this file only exposes the
/// functions and callbacks to the Flutter code.
@JS('window.tdgPwa.init')
external void _init();

@JS('window.tdgPwa.isInstallAvailable')
external bool _isInstallAvailable();

@JS('window.tdgPwa.isStandalone')
external bool _isStandalone();

@JS('window.tdgPwa.isOnline')
external bool _isOnline();

@JS('window.tdgPwa.onInstallChanged')
external void _onInstallChanged(JSFunction callback);

@JS('window.tdgPwa.onNetworkChanged')
external void _onNetworkChanged(JSFunction callback);

@JS('window.tdgPwa.promptInstall')
external JSPromise<JSBoolean> _promptInstall();

@JS('window.tdgPwa.serviceWorkerReady')
external JSPromise<JSBoolean> _serviceWorkerReady();

@JS('window.tdgPwa.registerServiceWorker')
external JSPromise<JSBoolean> _registerServiceWorker(String url);

@JS('window.tdgPwa.clearOfflineData')
external JSPromise<JSBoolean> _clearOfflineData();

bool _initialized = false;
void Function(bool available)? _installCallback;
void Function(bool online)? _networkCallback;

/// Subscribes to the browser install and connectivity events.
void pwaInit({
  required void Function(bool available) onInstallChanged,
  required void Function(bool online) onNetworkChanged,
}) {
  _installCallback = onInstallChanged;
  _networkCallback = onNetworkChanged;

  if (_initialized) return;
  _initialized = true;

  _init();
  _onInstallChanged(
    ((bool available) => _installCallback?.call(available)).toJS,
  );
  _onNetworkChanged(((bool online) => _networkCallback?.call(online)).toJS);
}

/// True while the browser still offers the install prompt.
bool pwaIsInstallAvailable() => _isInstallAvailable();

/// True when the app is running as an installed application.
bool pwaIsStandalone() => _isStandalone();

/// True when the device reports an internet connection.
bool pwaIsOnline() => _isOnline();

/// Shows the browser install prompt. Returns true when the user accepted.
Future<bool> pwaPromptInstall() async =>
    (await _promptInstall().toDart).toDart;

/// True when the offline service worker controls this page.
Future<bool> pwaServiceWorkerReady() async =>
    (await _serviceWorkerReady().toDart).toDart;

/// Registers the offline service worker again.
Future<bool> pwaRegisterServiceWorker(String url) async =>
    (await _registerServiceWorker(url).toDart).toDart;

/// Unregisters the service worker and deletes every offline cache.
Future<bool> pwaClearOfflineData() async =>
    (await _clearOfflineData().toDart).toDart;
