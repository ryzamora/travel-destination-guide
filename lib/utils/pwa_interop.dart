// Browser APIs needed by the Settings screen (install prompt, offline state,
// service worker controls).
//
// The web implementation calls the helpers declared in `web/pwa.js`. Every
// other platform gets a harmless stub, so the Android build keeps working.
export 'pwa_interop_stub.dart'
    if (dart.library.js_interop) 'pwa_interop_web.dart';
