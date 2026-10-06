/*
 * Travel Destination Guide - Progressive Web App helpers.
 *
 * Small bridge between the Flutter (Dart) code and the browser APIs that are
 * only available in JavaScript: the install prompt, online/offline events and
 * the service worker controls used by the Settings screen.
 */
window.tdgPwa = (function () {
  let deferredPrompt = null;
  const installListeners = [];
  const networkListeners = [];

  function notifyInstall() {
    installListeners.forEach((callback) => callback(!!deferredPrompt));
  }

  function notifyNetwork() {
    const online = navigator.onLine !== false;
    networkListeners.forEach((callback) => callback(online));
  }

  return {
    init: function () {
      window.addEventListener('beforeinstallprompt', (event) => {
        // Keep the prompt so the Settings screen can trigger it later.
        event.preventDefault();
        deferredPrompt = event;
        notifyInstall();
      });

      window.addEventListener('appinstalled', () => {
        deferredPrompt = null;
        notifyInstall();
      });

      window.addEventListener('online', notifyNetwork);
      window.addEventListener('offline', notifyNetwork);
    },

    isInstallAvailable: function () {
      return !!deferredPrompt;
    },

    isStandalone: function () {
      try {
        if (window.matchMedia && window.matchMedia('(display-mode: standalone)').matches) {
          return true;
        }
      } catch (error) {
        // Ignore browsers without matchMedia.
      }
      return navigator.standalone === true;
    },

    isOnline: function () {
      return navigator.onLine !== false;
    },

    onInstallChanged: function (callback) {
      installListeners.push(callback);
    },

    onNetworkChanged: function (callback) {
      networkListeners.push(callback);
    },

    promptInstall: async function () {
      if (!deferredPrompt) return false;
      try {
        await deferredPrompt.prompt();
        const choice = await deferredPrompt.userChoice;
        deferredPrompt = null;
        notifyInstall();
        return !!choice && choice.outcome === 'accepted';
      } catch (error) {
        return false;
      }
    },

    serviceWorkerReady: async function () {
      if (!('serviceWorker' in navigator)) return false;
      try {
        await navigator.serviceWorker.ready;
        return !!navigator.serviceWorker.controller;
      } catch (error) {
        return false;
      }
    },

    registerServiceWorker: async function (url) {
      if (!('serviceWorker' in navigator)) return false;
      try {
        await navigator.serviceWorker.register(url);
        return true;
      } catch (error) {
        return false;
      }
    },

    clearOfflineData: async function () {
      let removed = false;
      if ('serviceWorker' in navigator) {
        try {
          const registrations = await navigator.serviceWorker.getRegistrations();
          for (const registration of registrations) {
            const done = await registration.unregister();
            removed = removed || !!done;
          }
        } catch (error) {
          // Ignore browsers that block unregistering.
        }
      }
      if (window.caches) {
        try {
          const keys = await caches.keys();
          for (const key of keys) {
            await caches.delete(key);
            removed = true;
          }
        } catch (error) {
          // Ignore browsers without cache access.
        }
      }
      return removed;
    },
  };
})();
