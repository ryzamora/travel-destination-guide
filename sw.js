/*
 * Travel Destination Guide - service worker.
 *
 * Caches the app shell (index.html, main.dart.js, bootstrap) and every bundled
 * asset so the app still opens and shows all destinations when the device is
 * offline. Caching strategy:
 *   - navigations        -> network first, cached copy when offline
 *   - bundled assets     -> cache first (they do not change while the app runs)
 *   - scripts and the rest -> stale while revalidate (offline copy + update)
 */

const CACHE_VERSION = 'v1';
const APP_CACHE = 'travel-guide-app-' + CACHE_VERSION;
const CACHE_PREFIX = 'travel-guide-app-';

const PRECACHE = [
  './',
  'index.html',
  'manifest.json',
  'flutter_bootstrap.js',
  'main.dart.js',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'icons/Icon-maskable-192.png',
  'icons/Icon-maskable-512.png',
];

/** Files Flutter needs before the first frame (may not exist on every build). */
const RUNTIME_PRECACHE = [
  'assets/AssetManifest.bin.json',
  'assets/FontManifest.json',
  'assets/fonts/MaterialIcons-Regular.otf',
];

/** Image files the app always needs offline, used when the manifest is absent. */
const FALLBACK_ASSETS = [
  'assets/assets/images/avatar.png',
  'assets/assets/images/banaue.jpg',
  'assets/assets/images/boracay.jpg',
  'assets/assets/images/chocolate_hills.jpg',
  'assets/assets/images/el_nido.jpg',
  'assets/assets/images/hundred_islands.jpg',
  'assets/assets/images/intramuros.jpg',
  'assets/assets/images/logo.png',
  'assets/assets/images/mayon.jpg',
];

async function putIfOk(cache, request, response) {
  if (response && response.ok) {
    await cache.put(request, response.clone());
  }
  return response;
}

/** Adds URLs to the cache, never failing the whole install on one file. */
async function precache(cache, urls) {
  await Promise.allSettled(
    urls.map(async (url) => {
      const response = await fetch(url, { cache: 'reload' });
      if (response && response.ok) {
        await cache.put(url, response);
      }
    }),
  );
}

/** Every image/font declared in the Flutter asset manifests. */
async function collectBundledAssets() {
  try {
    const response = await fetch('assets/AssetManifest.bin.json');
    if (!response.ok) return FALLBACK_ASSETS;
    const base64 = await response.json();
    const binary = typeof base64 === 'string' ? atob(base64) : '';
    // Flutter serves every asset under the "assets/" directory, so the
    // declared keys ("assets/...", "packages/...") need that prefix.
    const keys = binary.match(/(assets|packages)\/[A-Za-z0-9_\-./]+/g) || [];
    const urls = Array.from(new Set(keys)).map((key) => 'assets/' + key);
    return urls.length > 0 ? urls : FALLBACK_ASSETS;
  } catch (error) {
    console.warn('Could not read the asset manifest:', error);
    return FALLBACK_ASSETS;
  }
}

/** Font files declared in FontManifest.json, served under "assets/". */
async function collectFonts() {
  try {
    const response = await fetch('assets/FontManifest.json');
    if (!response.ok) return [];
    const families = await response.json();
    const urls = [];
    for (const family of families) {
      for (const font of family.fonts || []) {
        if (typeof font.asset === 'string') urls.push('assets/' + font.asset);
      }
    }
    return urls;
  } catch (error) {
    return [];
  }
}

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(APP_CACHE);
      await precache(cache, PRECACHE);
      await precache(cache, RUNTIME_PRECACHE);
      await precache(cache, await collectBundledAssets());
      await precache(cache, await collectFonts());
      await self.skipWaiting();
    })(),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(
        keys
          .filter((key) => key.startsWith(CACHE_PREFIX) && key !== APP_CACHE)
          .map((key) => caches.delete(key)),
      );
      await self.clients.claim();
    })(),
  );
});

async function networkFirst(request) {
  try {
    const response = await fetch(request);
    const cache = await caches.open(APP_CACHE);
    await putIfOk(cache, request, response);
    return response;
  } catch (error) {
    const cached = await caches.match(request, { ignoreSearch: true });
    if (cached) return cached;
    const shell = await caches.match('index.html', { ignoreSearch: true });
    if (shell) return shell;
    return new Response('You are offline.', {
      status: 503,
      headers: { 'Content-Type': 'text/plain' },
    });
  }
}

async function cacheFirst(request) {
  const cached = await caches.match(request, { ignoreSearch: true });
  if (cached) return cached;
  try {
    const response = await fetch(request);
    const cache = await caches.open(APP_CACHE);
    await putIfOk(cache, request, response);
    return response;
  } catch (error) {
    return new Response('Resource unavailable offline.', {
      status: 503,
      headers: { 'Content-Type': 'text/plain' },
    });
  }
}

async function staleWhileRevalidate(request) {
  const cache = await caches.open(APP_CACHE);
  const cached = await caches.match(request, { ignoreSearch: true });
  const network = fetch(request)
    .then((response) => putIfOk(cache, request, response))
    .catch(() => null);
  if (cached) {
    return cached;
  }
  const response = await network;
  if (response) return response;
  return new Response('You are offline.', {
    status: 503,
    headers: { 'Content-Type': 'text/plain' },
  });
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  if (request.mode === 'navigate') {
    event.respondWith(networkFirst(request));
    return;
  }

  const isImmutableAsset =
    url.pathname.includes('/assets/') ||
    url.pathname.includes('/icons/') ||
    /\.(png|jpg|jpeg|gif|webp|svg|ico|woff2?|ttf|otf)$/.test(url.pathname);

  event.respondWith(
    isImmutableAsset ? cacheFirst(request) : staleWhileRevalidate(request),
  );
});
