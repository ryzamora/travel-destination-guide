/// Non-web implementation of the PWA helpers.
///
/// Progressive web app features only exist in the browser, so every call is a
/// no-op and every capability reports "not supported".
void pwaInit({
  required void Function(bool available) onInstallChanged,
  required void Function(bool online) onNetworkChanged,
}) {}

bool pwaIsInstallAvailable() => false;

bool pwaIsStandalone() => false;

bool pwaIsOnline() => true;

Future<bool> pwaPromptInstall() async => false;

Future<bool> pwaServiceWorkerReady() async => false;

Future<bool> pwaRegisterServiceWorker(String url) async => false;

Future<bool> pwaClearOfflineData() async => false;
