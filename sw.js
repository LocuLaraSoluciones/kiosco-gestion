var CACHE_NAME = 'loculara-v1';
var ASSETS = [
  '/',
  '/index.html'
];

// Instalar: cachear el shell de la app
self.addEventListener('install', function(e) {
  e.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(ASSETS);
    })
  );
  self.skipWaiting();
});

// Activar: limpiar caches viejos
self.addEventListener('activate', function(e) {
  e.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(
        keys.filter(function(k) { return k !== CACHE_NAME; })
            .map(function(k) { return caches.delete(k); })
      );
    })
  );
  self.clients.claim();
});

// Fetch: red primero, cache como fallback
self.addEventListener('fetch', function(e) {
  // Supabase siempre va a la red (datos en tiempo real)
  if(e.request.url.indexOf('supabase.co') > -1 ||
     e.request.url.indexOf('cdn.jsdelivr') > -1) {
    return; // dejar pasar sin interceptar
  }

  e.respondWith(
    fetch(e.request)
      .then(function(response) {
        // Actualizar cache con la respuesta fresca
        var copy = response.clone();
        caches.open(CACHE_NAME).then(function(cache) {
          cache.put(e.request, copy);
        });
        return response;
      })
      .catch(function() {
        // Sin internet: servir desde cache
        return caches.match(e.request).then(function(cached) {
          return cached || caches.match('/index.html');
        });
      })
  );
});
