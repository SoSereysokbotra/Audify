'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "1e239e934ed6be25ef387aaafb6a80cd",
"assets/AssetManifest.bin.json": "389bb7c639396d9138e97417ba8132fe",
"assets/assets/app_icon.png": "7186d7230e5b2c3b06c4ffdeef696e16",
"assets/assets/app_icon_launcher.png": "ee9430d4778e2086882c9eb14a46b194",
"assets/assets/audio/README.md": "6fad18445be8ced8bd8f5445f75e4b59",
"assets/assets/audio/song-01_back_to_friends.mp3": "95c1dc45976f4390044b6c24b2c36191",
"assets/assets/audio/song-02_the_one_that_got_away.mp3": "fb59a48f433717978abe5098d5e642d3",
"assets/assets/audio/song-03_love_me_not.mp3": "406c64eabb84771aaeaef534a3313800",
"assets/assets/audio/song-04_multo.mp3": "29d44b325fabbf9c7b08e64adb643e80",
"assets/assets/audio/song-05_joon_oun_tov_rok_ke.mp3": "29c90294947a9fa44811b76bdf46e340",
"assets/assets/audio/song-06_maong_72.mp3": "eab7af9479327059fedea6c6dc296ca0",
"assets/assets/audio/song-07_let_her_go.mp3": "e604b240ae9d2d78457619b5fbcbf4c5",
"assets/assets/audio/song-08_heres_your_perfect.mp3": "7e1f144a05da6132198ae7346a448581",
"assets/assets/audio/song-09_we_dont_talk_anymore.mp3": "73cb1f94bd1a3eeea7cea16eb6f02246",
"assets/assets/audio/song-10_7_years.mp3": "d97ea9ca42f9c0bbbd4256f1f0038ce3",
"assets/assets/audio/song-11_impossible.mp3": "f5dfef935aef5e1298c4ebe413899949",
"assets/assets/audio/song-12_should_be_me.mp3": "ef8d8e8140f2a84102680877685b8a3c",
"assets/assets/audio/song-13_it_will_rain.mp3": "d1b66f46b8117485581997c8da3921f2",
"assets/assets/audio/song-14_when_i_was_your_man.mp3": "3e747116e93e011e0c467e9764b372b6",
"assets/assets/audio/song-15_outside_slowed_reverb.mp3": "37ed576077ba8f171d4dcaec24db6281",
"assets/assets/audio/song-16_cinnamon_girl.mp3": "a283a565ebfd7c3179f53ce57635eebd",
"assets/assets/audio/song-17_ill_do_it_slowed_reverb.mp3": "00b8d430e385c6e1751d18ca4064384c",
"assets/assets/audio/song-18_margaret.mp3": "0a2c48402c2ca3a8ab0305941054f0a2",
"assets/assets/audio/song-19_no_1_party_anthem.mp3": "0ab35ed7d257575e4594de045624cb31",
"assets/assets/audio/song-20_men_arom.mp3": "bc77c8460ea198ed32a8b3371e92c78b",
"assets/assets/audio/song-21_arom_pel_khouch_jit.mp3": "4f1dbb850d567af68f8f468d1e01800e",
"assets/assets/covers/cover-1_backtofriends.jpg": "cb8799bb9bf19eda394534cd0f7281cf",
"assets/assets/covers/README.md": "ccea6eb7554b8e9ff59ef0cd5409fba5",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "540f8e26aab7c335fccab3c822ad65f9",
"assets/NOTICES": "74990d5904dbc9d3fa5214fc6b9a26f7",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "26c872dbe177d8d27646e6d5b5aa5347",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "f668e00d8e63cb23006e87fdbe1b299b",
"/": "f668e00d8e63cb23006e87fdbe1b299b",
"main.dart.js": "cee870b66426bf7a1014f7a6eedae5f3",
"manifest.json": "dfd4934753a3a03a408caa48f23e9dea",
"version.json": "f06744fae09becc51136d51802a47d53"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
